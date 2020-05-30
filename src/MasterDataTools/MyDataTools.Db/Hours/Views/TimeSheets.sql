
CREATE VIEW [Hours].[TimeSheets]
AS --
	WITH [FixedWeeks] AS (
		SELECT 
			[TimeLogs].[InvoiceID]
			,[TimeLogs].[ProjectID]
			,[TimeLogs].[CarID]
		
			,[TimeLogs].[Year]
			,[TimeLogs].[Month]
			,CASE 
				WHEN [TimeLogs].[ProjectID] IN (1) THEN -- Saturday is the first of the week for lightwell
					CASE [TimeLogs].[DoW]
						WHEN 7 THEN [TimeLogs].[Week] - 1
						ELSE [TimeLogs].[Week]
					END
				ELSE [TimeLogs].[Week]
				END AS [Week]

			,CASE 
				WHEN [TimeLogs].[ProjectID] IN (1) THEN -- Saturday is the first of the week for lightwell
					DATEADD(DAY, -1 * ([TimeLogs].[DoW]), [TimeLogs].[Date])
				ELSE 
					DATEADD(DAY, -1 * ([TimeLogs].[DoW]) + 1, [TimeLogs].[Date])
				END AS [FirstOfWeek]

			,[TimeLogs].[DayOfWeek]
			,[TimeLogs].[Miles]
			,[TimeLogs].[Hours]
		FROM [Hours].[DetailedTimeLog] AS [TimeLogs]
	), [DetailedDays] As (
		SELECT 
			[TimeLogs].[InvoiceID]
			,[TimeLogs].[ProjectID]
			--,[TimeLogs].[CarID]
		
			,[TimeLogs].[Year]
			,[TimeLogs].[Month]

			,[TimeLogs].[Week]
			,[TimeLogs].[FirstOfWeek]

			,[TimeLogs].[DayOfWeek]
			,SUM([TimeLogs].[Miles]) OVER (
				PARTITION BY
					[Year]
					,[Month]
					,[Week]
					,[ProjectID]
				) AS [Miles]
			,SUM([TimeLogs].[Hours]) OVER (
				PARTITION BY
					[Year]
					,[Month]
					,[Week]
					,[ProjectID]
				) AS [TotalHours]
			,[TimeLogs].[Hours]
		FROM [FixedWeeks] AS [TimeLogs]
	), [Pivoted] AS (
		SELECT 
			*
		FROM [DetailedDays] AS [TimeLogs]
		PIVOT (
			SUM([Hours])
			FOR [DayOfWeek] IN (
				[Saturday]
				,[Sunday]
				,[Monday]
				,[Tuesday]
				,[Wednesday]
				,[Thursday]
				,[Friday]
			)
		) [pivoted]
	)
		SELECT 
			*
			,ROW_NUMBER() OVER (
				ORDER BY
					[Year]
					,[Month]
					,[Week]
					,[ProjectID]
			) AS [Row_Order]
		FROM [Pivoted]