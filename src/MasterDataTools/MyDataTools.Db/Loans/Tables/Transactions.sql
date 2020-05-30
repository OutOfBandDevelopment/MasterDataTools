CREATE TABLE [Loans].[Transactions] (
    [TransactionID] INT             IDENTITY (1, 1) NOT NULL,
    [CustomerID]    INT             NOT NULL,
    [Credit]        DECIMAL (18, 8) NULL,
    [Debit]         DECIMAL (18, 8) NULL,
    [Note]          NVARCHAR (MAX)  NULL,
    [DateTime]      DATETIME        CONSTRAINT [DF_Transactions_DateTime] DEFAULT (getdate()) NOT NULL,
    [Currency]      NVARCHAR (5)    CONSTRAINT [DF_Transactions_Currency] DEFAULT ('USD') NOT NULL,
    [Related]       INT             NULL,
    CONSTRAINT [PK_Transactions] PRIMARY KEY CLUSTERED ([TransactionID] ASC),
    CONSTRAINT [FK_Transactions_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Common].[Customers] ([CustomerID])
);

