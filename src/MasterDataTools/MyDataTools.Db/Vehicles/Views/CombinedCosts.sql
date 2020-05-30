


CREATE VIEW [Vehicles].[CombinedCosts]
AS --
WITH [Costs] AS (
	SELECT 
		[InsurancePaymentID] AS [RowID]
		,'InsurancePayments' AS [RowSource]
		,[CarID]
		,[Date]
		,[Amount]
		,CAST(NULL AS DECIMAL(14,4)) AS [TotalMiles]
	FROM [Vehicles].[InsurancePayments]
	UNION ALL 
	SELECT 
		[PaymentID] AS [RowID]
		,'Payments' AS [RowSource]
		,[CarID]
		,[Date]
		,[Amount]
		,CAST(NULL AS DECIMAL(14,4)) AS [TotalMiles]
	FROM [Vehicles].[Payments]
	UNION ALL 
	SELECT 
		[OilChangeID] AS [RowID]
		,'OilChanges' AS [RowSource]
		,[CarID]
		,[Date]
		,[ExtendedCost]
		,[ChangeMiles] AS [TotalMiles]
	FROM [Vehicles].[OilChanges]
	UNION ALL 
	SELECT 
		[FillUpID] AS [RowID]
		,'FillUps' AS [RowSource]
		,[CarID]
		,[Date]
		,[ExtendedCost]
		,[TotalMiles]
	FROM [Vehicles].[FillUps]
	UNION ALL 
	SELECT 
		[OtherServiceID] AS [RowID]
		,'OtherServices' AS [RowSource]
		,[CarID]
		,[Date]
		,[ExtendedCost]
		,[Miles] AS [TotalMiles]
	FROM [Vehicles].[OtherServices]
	UNION ALL 
	SELECT 
		[TireID] AS [RowID]
		,'Tires' AS [RowSource]
		,[CarID]
		,[Date]
		,[ExtendedCost]
		,[Miles] AS [TotalMiles]
	FROM [Vehicles].[Tires]
)
	SELECT *
	FROM [Costs]