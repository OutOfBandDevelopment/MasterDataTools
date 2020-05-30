CREATE TABLE [Accounting].[LineItems] (
    [LineItemID]     INT            IDENTITY (1, 1) NOT NULL,
    [Description]    NVARCHAR (256) NOT NULL,
    [Quantity]       FLOAT (53)     NOT NULL,
    [UnitPrice]      FLOAT (53)     NOT NULL,
    [TaxRate]        FLOAT (53)     NULL,
    [ExtendedAmount] AS             ([Quantity]*[UnitPrice]) PERSISTED NOT NULL,
    [TaxAmount]      AS             (([Quantity]*[UnitPrice])*[TaxRate]) PERSISTED,
    [TotalAmount]    AS             (([Quantity]*[UnitPrice])*((1)+isnull([TaxRate],(0)))) PERSISTED NOT NULL,
    [ProjectID]      INT            NULL,
    [InvoiceID]      INT            NULL,
    CONSTRAINT [PK_LineItems] PRIMARY KEY CLUSTERED ([LineItemID] ASC),
    CONSTRAINT [FK_LineItems_Invoices] FOREIGN KEY ([InvoiceID]) REFERENCES [Accounting].[Invoices] ([InvoiceID])
);

