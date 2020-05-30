CREATE TABLE [Accounting].[Terms] (
    [TermID]  INT            IDENTITY (1, 1) NOT NULL,
    [Name]    NVARCHAR (50)  NOT NULL,
    [Details] NVARCHAR (MAX) NULL,
    [Rules]   XML            NULL,
    CONSTRAINT [PK_Terms] PRIMARY KEY CLUSTERED ([TermID] ASC)
);

