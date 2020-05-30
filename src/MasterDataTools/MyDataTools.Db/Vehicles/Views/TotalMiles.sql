
CREATE VIEW [Vehicles].[TotalMiles]
AS --
	SELECT 
		[CarID]
		,MAX([TotalMiles]) AS [TotalMiles]
	FROM [Vehicles].[CombinedCosts]
	GROUP BY
		[CarID]