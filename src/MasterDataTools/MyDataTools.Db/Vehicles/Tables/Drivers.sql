CREATE TABLE [Vehicles].[Drivers] (
    [DriverID] INT              IDENTITY (1, 1) NOT NULL,
    [Name]     NVARCHAR (256)   NOT NULL,
    [UserID]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Vehicles_Drivers] PRIMARY KEY CLUSTERED ([DriverID] ASC)
);

