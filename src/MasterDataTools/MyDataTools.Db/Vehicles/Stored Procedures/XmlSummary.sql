
CREATE PROCEDURE [Vehicles].[XmlSummary] 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		[Drivers].[DriverID] AS [@id]
		,[Drivers].[Name] AS [@name]
		,CAST((SELECT 
			[Cars].[CarID] AS [@id]
			,[Cars].[Make] AS [@make]
			,[Cars].[Model] AS [@model]
			,[Cars].[SubModel] AS [@sub-model]
			,[Cars].[StartingMiles] AS [@starting-miles]
			,[Cars].[Notes] AS [@notes]
			,[Cars].[PurchasedDate] AS [@purchase-date]
			,CAST((SELECT 
				[FillUps].[FillUpID] AS [@id]
				,[FillUps].[Date] AS [@date]
				--,[FillUps].[CostPerGallon] AS [@cost-per-gallon]
				,[FillUps].[Gallons] AS [@gallons]
				,[FillUps].[Octane] AS [@octane]
				,[FillUps].[TankMiles] AS [@tank-miles]
				,[FillUps].[TotalMiles] AS [@total-miles]
				,[FillUps].[Station] AS [@station]
				,[FillUps].[Notes] AS [@notes]
				--,[FillUps].[ExtendedCost] AS [@extended-cost]
				,[FillUps].[MilesPerGallon] AS [@miles-per-gallon]
			FROM [Vehicles].[FillUps]
			WHERE
				[FillUps].[CarID] = [Cars].[CarID]
			FOR XML PATH('fill-up')) AS XML)
			,CAST((SELECT 
				[OilChanges].[OilChangeID] AS [@id]
				,[OilChanges].[Date] AS [@date]
				,[OilChanges].[ChangeMiles] AS [@change-miles]
				,[OilChanges].[OilBrand] AS [@oil-brand]
				,[OilChanges].[FilterBrand] AS [@filter-brand]
				--,[OilChanges].[Quarts] AS [@quarts]
				--,[OilChanges].[OilCost] AS [@oil-cost]
				--,[OilChanges].[FilterCost] AS [@filter-cost] 
				--,[OilChanges].[LaborCost] AS [@labor-cost]
				--,[OilChanges].[TaxRate] AS [@tax-rate]
				--,[OilChanges].[OtherCost] AS [@other-cost]
				,[OilChanges].[Location] AS [@location]
				,[OilChanges].[Notes] As [@notes]
				--,[OilChanges].[ExtendedCost] AS [@extended-cost]
			FROM [Vehicles].[OilChanges]
			WHERE
				[OilChanges].[CarID] = [Cars].[CarID]
			FOR XML PATH('oil-changes')) AS XML)
			,CAST((SELECT 
				[OtherServices].[OtherServiceID] AS [@id]
				,[OtherServices].[Date] AS [@date]
				,[OtherServices].[Miles] As [@miles]
				,[OtherServices].[Item] AS [@item]
				--,[OtherServices].[Cost] AS [@cost]
				--,[OtherServices].[Rate] AS [@rate]
				,[OtherServices].[Location] AS [@location]
				,[OtherServices].[Notes] AS [@note]
				--,[OtherServices].[ExtendedCost] AS [@extended-cost]
			FROM [Vehicles].[OtherServices]
			WHERE
				[OtherServices].[CarID] = [Cars].[CarID]
			FOR XML PATH('other-services')) AS XML)
			,CAST((SELECT 
				[Tires].[TireID] AS [@id]
				,[Tires].[Date] AS [@date]
				,[Tires].[Miles] AS [@miles]
				,[Tires].[Make] AS [@make]
				,[Tires].[Model] AS [@model]
				--,[Tires].[Cost] AS [@cost]
				,[Tires].[Quantity] AS [@quantity]
				--,[Tires].[TaxRate] AS [@tax-rate]
				,[Tires].[WarrantyMonths] AS [@warranty-months]
				,[Tires].[WarrantyMiles] AS [@warranty-miles]
				,[Tires].[Note] AS [@note]
				,[Tires].[ExpireDate] AS [@expire-date]
				,[Tires].[ExpireMiles] AS [@expire-miles]
				--,[Tires].[ExtendedCost] AS [@extended-cost]
			FROM [Vehicles].[Tires]
			WHERE
				[Tires].[CarID] = [Cars].[CarID]
			FOR XML PATH('tires')) AS XML)
		FROM [Vehicles].[Cars]
		WHERE
			[Cars].[DriverID] = [Drivers].[DriverID]
		FOR XML PATH('car')) AS XML)
	FROM [Vehicles].[Drivers]
	FOR XML PATH('driver'), ROOT('drivers')
END