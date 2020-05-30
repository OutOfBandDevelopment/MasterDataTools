CREATE TABLE [Vehicles].[Stations] (
    [StationID] INT            IDENTITY (1, 1) NOT NULL,
    [Name]      NVARCHAR (256) NOT NULL,
    [Address1]  NVARCHAR (256) NULL,
    [Address2]  NVARCHAR (256) NULL,
    [City]      NVARCHAR (256) NULL,
    [State]     NVARCHAR (256) NULL,
    [ZipCode]   NVARCHAR (256) NULL,
    CONSTRAINT [PK_Stations] PRIMARY KEY CLUSTERED ([StationID] ASC)
);

