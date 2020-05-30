CREATE TABLE [Vehicles].[OilChanges] (
    [OilChangeID]  INT             IDENTITY (1, 1) NOT NULL,
    [CarID]        INT             NOT NULL,
    [Date]         DATETIME        NOT NULL,
    [ChangeMiles]  DECIMAL (10, 2) NOT NULL,
    [OilBrand]     NVARCHAR (100)  NULL,
    [FilterBrand]  NVARCHAR (100)  NULL,
    [Quarts]       DECIMAL (7, 4)  NULL,
    [OilCost]      DECIMAL (14, 4) NULL,
    [FilterCost]   DECIMAL (14, 4) NULL,
    [LaborCost]    DECIMAL (14, 4) NULL,
    [TaxRate]      DECIMAL (4, 4)  NULL,
    [OtherCost]    DECIMAL (14, 4) NULL,
    [Location]     NVARCHAR (100)  NOT NULL,
    [Notes]        NVARCHAR (MAX)  NULL,
    [ExtendedCost] AS              (CONVERT([decimal](14,4),(((isnull([OilCost],(0))+isnull([FilterCost],(0)))+isnull([LaborCost],(0)))+isnull([OtherCost],(0)))+isnull([TaxRate],(0))*(((isnull([OilCost],(0))+isnull([FilterCost],(0)))+isnull([LaborCost],(0)))+isnull([OtherCost],(0))))) PERSISTED,
    CONSTRAINT [PK_Vehicles_OilChanges] PRIMARY KEY CLUSTERED ([OilChangeID] ASC),
    CONSTRAINT [FK_Vehicles_OilChanges_to_Cars] FOREIGN KEY ([CarID]) REFERENCES [Vehicles].[Cars] ([CarID])
);

