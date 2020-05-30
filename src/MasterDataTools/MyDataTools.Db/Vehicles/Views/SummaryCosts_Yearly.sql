
CREATE VIEW [Vehicles].[SummaryCosts_Yearly]
AS
	WITH [Details] AS (
		SELECT 
			[CarID]
			,YEAR([Date]) AS [Year]
			,SUM([Amount]) AS [YearlyCost]
			,MAX([TotalMiles]) AS [TotalMiles]
		FROM [Vehicles].[CombinedCosts]
		GROUP BY
			[CarID]
			,YEAR([Date])
	), [YearlySummary] AS (
		SELECT 
			[Details].[CarID]
			,[Details].[Year]
			,[Details].[YearlyCost]
			,[Details].[TotalMiles]
			,ISNULL([LastYear].[YearlyCost],0) AS [YearlyCost_LastYear]
			,ISNULL([LastYear].[TotalMiles],(
				SELECT TOP 1 
					[StartingMiles]
				FROM [Vehicles].[Cars]
				WHERE
					[Cars].[CarID] = [Details].[CarID]
				)) AS [TotalMiles_LastYear]
		
			,[Details].[TotalMiles] - ISNULL([LastYear].[TotalMiles],(
				SELECT TOP 1 
					[StartingMiles]
				FROM [Vehicles].[Cars]
				WHERE
					[Cars].[CarID] = [Details].[CarID]
				)) AS [MilesThisYear]
			,[Details].[YearlyCost] - ISNULL([LastYear].[YearlyCost],0) AS [CostDifferenceYear]
		FROM [Details]
		LEFT JOIN [Details] AS [LastYear]
			ON [LastYear].[CarID] = [Details].[CarID]
				AND [LastYear].[Year] = [Details].[Year] - 1
	)
		SELECT 
			[YearlySummary].[CarID]
			,[YearlySummary].[Year]
			,[YearlySummary].[YearlyCost]
			,[YearlySummary].[TotalMiles]
			--,[YearlySummary].[TotalCost_LastYear]
			--,[YearlySummary].[TotalMiles_LastYear]
		
			,[YearlySummary].[MilesThisYear]
			,[YearlySummary].[CostDifferenceYear]

			
			,[YearlySummary].[YearlyCost] / [YearlySummary].[TotalMiles] AS [CostPerMile]
		FROM [YearlySummary]