CREATE TABLE [Vehicles].[Tires] (
    [TireID]         INT             IDENTITY (1, 1) NOT NULL,
    [CarID]          INT             NOT NULL,
    [Date]           DATETIME        NOT NULL,
    [Miles]          DECIMAL (14, 4) NOT NULL,
    [Make]           NVARCHAR (256)  NOT NULL,
    [Model]          NVARCHAR (256)  NOT NULL,
    [Cost]           DECIMAL (14, 4) NOT NULL,
    [Quantity]       INT             NOT NULL,
    [TaxRate]        DECIMAL (4, 4)  NOT NULL,
    [WarrantyMonths] INT             NOT NULL,
    [WarrantyMiles]  DECIMAL (14, 4) NOT NULL,
    [Note]           NVARCHAR (MAX)  NULL,
    [ExpireDate]     AS              (dateadd(month,[WarrantyMonths],[Date])) PERSISTED,
    [ExpireMiles]    AS              ([Miles]+[WarrantyMiles]) PERSISTED,
    [ExtendedCost]   AS              (CONVERT([decimal](14,4),([Cost]*[Quantity])*((1)+[TaxRate]))) PERSISTED,
    CONSTRAINT [PK_Vehicles_Tires] PRIMARY KEY CLUSTERED ([TireID] ASC),
    CONSTRAINT [FK_Vehicles_Tires_to_Cars] FOREIGN KEY ([CarID]) REFERENCES [Vehicles].[Cars] ([CarID])
);

