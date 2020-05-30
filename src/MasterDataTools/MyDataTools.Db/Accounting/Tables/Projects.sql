CREATE TABLE [Accounting].[Projects] (
    [ProjectID]     INT           IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (50) NOT NULL,
    [CustomerID]    INT           NOT NULL,
    [HourlyRate]    FLOAT (53)    NULL,
    [DefaultMiles]  FLOAT (53)    NULL,
    [DefaultTermID] INT           NULL,
    CONSTRAINT [PK_Projects] PRIMARY KEY CLUSTERED ([ProjectID] ASC),
    CONSTRAINT [FK_Projects_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Common].[Customers] ([CustomerID]),
    CONSTRAINT [FK_Projects_Terms] FOREIGN KEY ([DefaultTermID]) REFERENCES [Accounting].[Terms] ([TermID])
);

