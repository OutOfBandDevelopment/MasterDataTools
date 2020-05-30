CREATE TABLE [Vehicles].[OtherServices] (
    [OtherServiceID] INT             IDENTITY (1, 1) NOT NULL,
    [CarID]          INT             NOT NULL,
    [Date]           DATETIME        NOT NULL,
    [Miles]          DECIMAL (14, 4) NOT NULL,
    [Item]           NVARCHAR (200)  NOT NULL,
    [Cost]           DECIMAL (14, 4) NOT NULL,
    [Rate]           DECIMAL (4, 4)  NOT NULL,
    [Location]       NVARCHAR (100)  NOT NULL,
    [Notes]          NVARCHAR (MAX)  NULL,
    [ExtendedCost]   AS              (CONVERT([decimal](14,4),[Cost]+[Cost]*[Rate])) PERSISTED,
    CONSTRAINT [PK_Vehicles_OtherServices] PRIMARY KEY CLUSTERED ([OtherServiceID] ASC),
    CONSTRAINT [FK_Vehicles_OtherServices_to_Cars] FOREIGN KEY ([CarID]) REFERENCES [Vehicles].[Cars] ([CarID])
);

