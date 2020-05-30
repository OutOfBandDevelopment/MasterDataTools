


CREATE VIEW [Accounting].[Vehicles]
AS --
	WITH [LoggedMiles] AS (
		SELECT 
			[TimeLogs].[CarID],
			YEAR([TimeLogs].[Date]) AS [Year],
			SUM([TimeLogs].[miles]) AS [LoggedMiles]
		FROM [Hours].[TimeLogs]
		WHERE
			[TimeLogs].[miles] IS NOT NULL
		GROUP BY 
			[TimeLogs].[CarID], 
			YEAR([TimeLogs].[Date]) 
	), [AllMiles] AS (
		SELECT 
			[CarID]
			,YEAR([Date]) As [Year]
			,SUM([Amount]) [Cost]
			,MAX([TotalMiles]) - MIN([TotalMiles]) AS [TotalMiles]
		FROM [Vehicles].[CombinedCosts]
		WHERE
			[CombinedCosts].[Date] > '3/16/2015'
		GROUP BY
			[CarID]
			,YEAR([Date])
	)
		SELECT 
			[AllMiles].[CarID]
			,[AllMiles].[Year]
			,[AllMiles].[Cost]
			,[LoggedMiles].[LoggedMiles]
			,[AllMiles].[TotalMiles]
			,CAST(ROUND([LoggedMiles].[LoggedMiles] / [AllMiles].[TotalMiles] * 100,2) AS NVARCHAR(10)) + '%' AS [PercentBusiness]
			,[AllMiles].[Cost] * [LoggedMiles].[LoggedMiles] / [AllMiles].[TotalMiles] AS [Expense]
		FROM [LoggedMiles]
		INNER JOIN [AllMiles]
			ON [LoggedMiles].[CarID] = [AllMiles].[CarID]
				AND [LoggedMiles].[Year] = [AllMiles].[Year]