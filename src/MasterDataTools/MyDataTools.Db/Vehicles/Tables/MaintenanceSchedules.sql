CREATE TABLE [Vehicles].[MaintenanceSchedules] (
    [MaintenanceScheduleID] INT             IDENTITY (1, 1) NOT NULL,
    [CarID]                 INT             NOT NULL,
    [Miles]                 DECIMAL (14, 4) NOT NULL,
    [WorkItems]             NVARCHAR (MAX)  NOT NULL,
    [CompletedOn]           DATETIME        NULL,
    [IsComplete]            AS              (CONVERT([bit],case when [CompletedOn] IS NOT NULL then (1) else (0) end)) PERSISTED,
    CONSTRAINT [PK_MaintenanceSchedules] PRIMARY KEY CLUSTERED ([MaintenanceScheduleID] ASC),
    CONSTRAINT [FK_Vehicles_MaintenanceSchedules_to_Cars] FOREIGN KEY ([CarID]) REFERENCES [Vehicles].[Cars] ([CarID])
);

