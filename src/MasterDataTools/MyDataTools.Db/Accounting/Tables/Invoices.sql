CREATE TABLE [Accounting].[Invoices] (
    [InvoiceID]           INT             IDENTITY (1, 1) NOT NULL,
    [CustomerID]          INT             NOT NULL,
    [Notes]               NVARCHAR (MAX)  NULL,
    [InvoiceDate]         DATE            NULL,
    [DueDate]             DATE            NULL,
    [TermsID]             INT             NOT NULL,
    [TermsAndConditions]  NVARCHAR (MAX)  NULL,
    [InvoiceStatusCode]   NVARCHAR (50)   NOT NULL,
    [RenderedInvoiceMime] NVARCHAR (256)  NULL,
    [RenderedInvoice]     VARBINARY (MAX) NULL,
    [InvoiceNumber]       INT             NULL,
    [PaidDate]            DATETIME        NULL,
    [Comment]             NVARCHAR (MAX)  NULL,
    [HasRenderedInvoice]  AS              (case when [RenderedInvoice] IS NULL then (0) else (1) end) PERSISTED NOT NULL,
    CONSTRAINT [PK_Invoices] PRIMARY KEY CLUSTERED ([InvoiceID] ASC),
    CONSTRAINT [FK_Invoices_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Common].[Customers] ([CustomerID]),
    CONSTRAINT [FK_Invoices_Terms] FOREIGN KEY ([TermsID]) REFERENCES [Accounting].[Terms] ([TermID])
);

