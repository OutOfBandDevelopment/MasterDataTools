CREATE TABLE [Vehicles].[InsurancePayments] (
    [InsurancePaymentID] INT             IDENTITY (1, 1) NOT NULL,
    [CarID]              INT             NOT NULL,
    [Date]               DATETIME        NOT NULL,
    [Amount]             DECIMAL (14, 4) NOT NULL,
    [PaidTo]             NVARCHAR (100)  NOT NULL,
    [Notes]              NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_Vehicles_InsurancePayments] PRIMARY KEY CLUSTERED ([InsurancePaymentID] ASC),
    CONSTRAINT [FK_Vehicles_InsurancePayments_to_Cars] FOREIGN KEY ([CarID]) REFERENCES [Vehicles].[Cars] ([CarID])
);

