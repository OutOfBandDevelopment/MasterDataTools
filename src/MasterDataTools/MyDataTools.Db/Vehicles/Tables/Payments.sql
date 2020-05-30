CREATE TABLE [Vehicles].[Payments] (
    [PaymentID] INT             IDENTITY (1, 1) NOT NULL,
    [CarID]     INT             NOT NULL,
    [Date]      DATETIME        NOT NULL,
    [Amount]    DECIMAL (14, 4) NOT NULL,
    [PaidTo]    NVARCHAR (100)  NOT NULL,
    [Notes]     NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_Vehicles_Payments] PRIMARY KEY CLUSTERED ([PaymentID] ASC),
    CONSTRAINT [FK_Vehicles_Payments_to_Cars] FOREIGN KEY ([CarID]) REFERENCES [Vehicles].[Cars] ([CarID])
);

