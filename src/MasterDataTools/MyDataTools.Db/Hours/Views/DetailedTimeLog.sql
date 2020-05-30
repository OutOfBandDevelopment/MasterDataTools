


CREATE VIEW [Hours].[DetailedTimeLog]
AS  --
	SELECT 
		[TimeLogs].[TimeLogID]
		,[TimeLogs].[InvoiceID]
		,[TimeLogs].[ProjectID]
		,[TimeLogs].[CarID]
		
		,DATEPART(YEAR, [TimeLogs].[Date]) [Year]
		,DATEPART(MONTH, [TimeLogs].[Date]) [Month]
		,DATEPART(WEEK, [TimeLogs].[Date]) [Week]
		,DATEPART(DW, [TimeLogs].[Date]) [DoW]
		,CASE DATEPART(dw, [TimeLogs].[Date]) 
			WHEN 1 THEN 'Sunday'
			WHEN 2 THEN 'Monday'
			WHEN 3 THEN 'Tuesday'
			WHEN 4 THEN 'Wednesday'
			WHEN 5 THEN 'Thursday'
			WHEN 6 THEN 'Friday'
			WHEN 7 THEN 'Saturday'
			END AS [DayOfWeek]
		,[TimeLogs].[Date]
		,[TimeLogs].[StartTime]
		,[TimeLogs].[StartBreak]
		,[TimeLogs].[EndBreak]
		,[TimeLogs].[EndTIme]
		,[TimeLogs].[Note]
		,[TimeLogs].[Miles]
		,[TimeLogs].[Hours]
	FROM [Hours].[TimeLogs]