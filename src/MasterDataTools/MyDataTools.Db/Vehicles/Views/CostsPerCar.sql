
CREATE VIEW [Vehicles].[CostsPerCar]
AS --
	SELECT 
		[CarID]
		,CAST(ISNULL([FillUps],0) AS DECIMAL(12, 2)) AS [FillUps]
		,CAST(ISNULL([InsurancePayments],0) AS DECIMAL(12, 2)) AS [InsurancePayments]
		,CAST(ISNULL([Payments],0) AS DECIMAL(12, 2)) AS [Payments]
		,CAST(ISNULL([OilChanges],0) AS DECIMAL(12, 2)) AS [OilChanges]
		,CAST(ISNULL([OtherServices],0) AS DECIMAL(12, 2)) AS [OtherServices]
		,CAST(ISNULL([Tires],0) AS DECIMAL(12, 2)) AS [Tires]

		,CAST(ISNULL([FillUps], 0)
			+ ISNULL([InsurancePayments], 0)
			+ ISNULL([Payments], 0)
			+ ISNULL([OilChanges], 0)
			+ ISNULL([OtherServices], 0)
			+ ISNULL([Tires], 0)
			AS DECIMAL(12,2)) AS [TotalCost]
	FROM (
		SELECT
			[CarID]
			,[Amount]
			,[RowSource]
		FROM [Vehicles].[CombinedCosts]
	) [Data] PIVOT (
		SUM([Amount])
		FOR [RowSource] IN (
			[FillUps]
			,[InsurancePayments]
			,[Payments]
			,[OilChanges]
			,[OtherServices]
			,[Tires]
		)
	) [pivoted]