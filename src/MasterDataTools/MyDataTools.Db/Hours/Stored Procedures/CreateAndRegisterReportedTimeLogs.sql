CREATE PROCEDURE [Hours].[CreateAndRegisterReportedTimeLogs]
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION 

			-- Create [ReportedTimeLogs] for weeks that are not posted
			INSERT INTO [Hours].[ReportedTimeLogs] (
				[ProjectID]
				,[Year]
				,[Month]
				,[Week]
				,[FirstOfWeek]
			)
			SELECT DISTINCT
				[TimeSheets].[ProjectID]
				,[TimeSheets].[Year]
				,[TimeSheets].[Month]
				,[TimeSheets].[Week]
				,[TimeSheets].[FirstOfWeek]
			FROM [Hours].[TimeLogs]
			INNER JOIN  [Hours].[DetailedTimeLog]
				ON [TimeLogs].[TimeLogID] = [DetailedTimeLog].[TimeLogID]
			INNER JOIN [Hours].[TimeSheets]
				ON [TimeSheets].[ProjectID] = [DetailedTimeLog].[ProjectID]
					 AND [TimeSheets].[Year] = [DetailedTimeLog].[Year]
					 AND [TimeSheets].[Month] = [DetailedTimeLog].[Month]
					 AND [TimeSheets].[Week] = [DetailedTimeLog].[Week]
			WHERE 
				[TimeLogs].[ReportedTimeLogID] IS NULL
				AND NOT EXISTS (
					SELECT *
					FROM [Hours].[ReportedTimeLogs]
					WHERE
						[ReportedTimeLogs].[ProjectID] = [DetailedTimeLog].[ProjectID]
						AND [ReportedTimeLogs].[Year] = [DetailedTimeLog].[Year]
						AND [ReportedTimeLogs].[Month] = [DetailedTimeLog].[Month]
						AND [ReportedTimeLogs].[Week] = [DetailedTimeLog].[Week]
				);

			-- Update Time Logs to matched reported time

			UPDATE [Hours].[TimeLogs]
			SET [ReportedTimeLogID] = [ReportedTimeLogs].[ReportedTimeLogID]
			FROM [Hours].[TimeLogs]
			INNER JOIN  [Hours].[DetailedTimeLog]
				ON [TimeLogs].[TimeLogID] = [DetailedTimeLog].[TimeLogID]
			INNER JOIN [Hours].[ReportedTimeLogs]
				ON [ReportedTimeLogs].[ProjectID] = [DetailedTimeLog].[ProjectID]
					 AND [ReportedTimeLogs].[Year] = [DetailedTimeLog].[Year]
					 AND [ReportedTimeLogs].[Month] = [DetailedTimeLog].[Month]
					 AND [ReportedTimeLogs].[Week] = [DetailedTimeLog].[Week]
			WHERE 
				[TimeLogs].[ReportedTimeLogID] IS NULL

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH    
		-- https://technet.microsoft.com/en-us/library/ms179296(v=sql.105).aspx
		SELECT
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage;

		-- Test XACT_STATE for 1 or -1.
		-- XACT_STATE = 0 means there is no transaction and
		-- a commit or rollback operation would generate an error.

		-- Test whether the transaction is uncommittable.
		IF (XACT_STATE()) = -1
		BEGIN
			PRINT
				N'The transaction is in an uncommittable state. ' +
				'Rolling back transaction.'
			ROLLBACK TRANSACTION;
		END;

		-- Test whether the transaction is active and valid.
		IF (XACT_STATE()) = 1
		BEGIN
			PRINT
				N'The transaction is committable. ' +
				'Committing transaction.'
			COMMIT TRANSACTION;   
		END;
	END CATCH

END