CREATE TABLE [Accounting].[BillingDocuments] (
    [BillingDocument] INT             IDENTITY (1, 1) NOT NULL,
    [DownloadedDate]  DATETIME        NOT NULL,
    [Data]            VARBINARY (MAX) NOT NULL,
    [Comment]         NVARCHAR (MAX)  NULL,
    [VendorID]        INT             NOT NULL,
    [Amount]          DECIMAL (18, 2) NULL,
    [PaidDate]        DATETIME        NULL,
    CONSTRAINT [PK_BillingDocuments] PRIMARY KEY CLUSTERED ([BillingDocument] ASC),
    CONSTRAINT [FK_BillingDocuments_Vendors] FOREIGN KEY ([VendorID]) REFERENCES [Accounting].[Vendors] ([VendorID])
);

