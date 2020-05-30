CREATE TABLE [Common].[Customers] (
    [CustomerID]      INT            IDENTITY (1, 1) NOT NULL,
    [CompanyName]     NVARCHAR (50)  NULL,
    [FirstName]       NVARCHAR (50)  NULL,
    [LastName]        NVARCHAR (50)  NULL,
    [Address1]        NVARCHAR (128) NULL,
    [Address2]        NVARCHAR (128) NULL,
    [City]            NVARCHAR (128) NULL,
    [State]           NVARCHAR (128) NULL,
    [PostalCode]      NVARCHAR (50)  NULL,
    [Country]         NVARCHAR (50)  NULL,
    [AccountingEmail] NVARCHAR (256) NULL,
    [ContractEmail]   NVARCHAR (256) NULL,
    [Phone]           NVARCHAR (256) NULL,
    [Notes]           NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);

