CREATE TABLE [Accounting].[Vendors] (
    [VendorID] INT            IDENTITY (1, 1) NOT NULL,
    [Name]     NVARCHAR (128) NOT NULL,
    [WebSite]  NVARCHAR (256) NULL,
    [Username] NVARCHAR (128) NULL,
    [Password] NVARCHAR (128) NULL,
    [Note]     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Vendors] PRIMARY KEY CLUSTERED ([VendorID] ASC)
);

