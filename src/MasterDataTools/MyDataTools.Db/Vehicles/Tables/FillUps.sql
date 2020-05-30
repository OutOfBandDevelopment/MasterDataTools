CREATE TABLE [Vehicles].[FillUps] (
    [FillUpID]       INT             IDENTITY (1, 1) NOT NULL,
    [CarID]          INT             NOT NULL,
    [Date]           DATETIME        NOT NULL,
    [CostPerGallon]  DECIMAL (14, 4) NOT NULL,
    [Gallons]        DECIMAL (14, 4) NOT NULL,
    [Octane]         INT             NOT NULL,
    [TankMiles]      DECIMAL (14, 4) NOT NULL,
    [TotalMiles]     DECIMAL (14, 4) NOT NULL,
    [Station]        NVARCHAR (256)  NOT NULL,
    [Notes]          NVARCHAR (MAX)  NULL,
    [ExtendedCost]   AS              (CONVERT([decimal](14,4),[CostPerGallon]*[Gallons])) PERSISTED,
    [MilesPerGallon] AS              (case [Gallons] when (0) then (0) else CONVERT([decimal](14,4),[TankMiles]/[Gallons]) end) PERSISTED,
    CONSTRAINT [PK_Vehicles_FillUps] PRIMARY KEY CLUSTERED ([FillUpID] ASC),
    CONSTRAINT [FK_Vehicles_FillUps_to_Cars] FOREIGN KEY ([CarID]) REFERENCES [Vehicles].[Cars] ([CarID])
);

