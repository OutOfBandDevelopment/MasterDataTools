
CREATE VIEW [Vehicles].[CarCosts_RolledUp]
AS --
	SELECT 
		[CarID]
		,DATEPART(YEAR, [Date]) AS [Year]
		,DATEPART(MONTH, [Date]) AS [Month]
		--,DATEPART(DAY, [Date]) AS [Day]
		,SUM([Amount]) AS [Amount]
	FROM [Vehicles].[CombinedCosts]
	GROUP BY
		[CarID]
		,ROLLUP (
			DATEPART(YEAR, [Date])
			,DATEPART(MONTH, [Date])
			--,DATEPART(DAY, [Date])
		)