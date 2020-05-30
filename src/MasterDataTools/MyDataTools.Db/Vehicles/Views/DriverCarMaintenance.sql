
CREATE VIEW [Vehicles].[DriverCarMaintenance]
AS -- 
	SELECT 
		[Drivers].[DriverID]
		,[Cars].[CarID]
		,[MaintenanceSchedules].[MaintenanceScheduleID]

		,[Drivers].[Name] AS [Driver]

		,[Cars].[Make]
		,[Cars].[Model]
		,[Cars].[SubModel]

		,ISNULL([TotalMiles].[TotalMiles], [Cars].[StartingMiles]) AS [TotalMiles]

		,[MaintenanceSchedules].[Miles] AS [ScheduledMiles]
		,CASE [MaintenanceSchedules].[IsComplete]
			WHEN 0 THEN [MaintenanceSchedules].[Miles] - ISNULL([TotalMiles].[TotalMiles], [Cars].[StartingMiles]) 
			END AS [DueIn]
	
		,[MaintenanceSchedules].[WorkItems]
		,[MaintenanceSchedules].[CompletedOn]
		,[MaintenanceSchedules].[IsComplete]

	FROM [Vehicles].[Cars]
	INNER JOIN [Vehicles].[Drivers]
		ON [Drivers].[DriverID] = [Cars].[DriverID]
	LEFT OUTER JOIN [Vehicles].[TotalMiles]
		ON [TotalMiles].[CarID] = [Cars].[CarID]
	INNER JOIN [Vehicles].[MaintenanceSchedules]
		ON [MaintenanceSchedules].[CarID] = [Cars].[CarID]
	--WHERE
	--	[MaintenanceSchedules].[IsComplete] = 0