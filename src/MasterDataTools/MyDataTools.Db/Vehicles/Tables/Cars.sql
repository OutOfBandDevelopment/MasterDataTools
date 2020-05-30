CREATE TABLE [Vehicles].[Cars] (
    [CarID]         INT             IDENTITY (1, 1) NOT NULL,
    [DriverID]      INT             NOT NULL,
    [Make]          NVARCHAR (100)  NOT NULL,
    [Model]         NVARCHAR (100)  NOT NULL,
    [Year]          INT             NOT NULL,
    [SubModel]      NVARCHAR (100)  NULL,
    [StartingMiles] DECIMAL (12, 2) NOT NULL,
    [Notes]         NVARCHAR (MAX)  NULL,
    [PurchasedDate] DATETIME        NULL,
    [SoldDate]      DATETIME        NULL,
    CONSTRAINT [PK_Vehicles_Cars] PRIMARY KEY CLUSTERED ([CarID] ASC),
    CONSTRAINT [FK_Vehicles_Cars_to_Drivers] FOREIGN KEY ([DriverID]) REFERENCES [Vehicles].[Drivers] ([DriverID])
);

