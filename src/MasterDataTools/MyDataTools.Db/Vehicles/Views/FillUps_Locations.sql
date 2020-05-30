
CREATE VIEW [Vehicles].[FillUps_Locations]
AS --
SELECT 
	[Stations].[StationID]
	,[FillUps].[FillUpID]
	,[FillUps].[CarID]
	,[Cars].[DriverID]
	,ISNULL([Stations].[Name], [FillUps].[Station]) AS [Station]
	,[Stations].[Address1]
	,[Stations].[City]
	,[Stations].[State]
	,[Stations].[ZipCode]
	,[FillUps].[TankMiles]	
	,[FillUps].[Date]
	,[Cars].[Year]
	,[Cars].[Make]
	,[Cars].[Model]
	,ROW_NUMBER() OVER (
		ORDER BY
			[FillUps].[Date]
			,[FillUps].[FillUpID]
	) AS [OrderNumber]
FROM [Vehicles].[Stations]
RIGHT OUTER JOIN [Vehicles].[FillUps]
	ON [FillUps].[Station] = [Stations].[Name]
INNER JOIN [Vehicles].[Cars]
	ON [Cars].[CarID] = [FillUps].[CarID]
--ORDER BY
--	[FillUps].[Date]
--	,[FillUps].[FillUpID]