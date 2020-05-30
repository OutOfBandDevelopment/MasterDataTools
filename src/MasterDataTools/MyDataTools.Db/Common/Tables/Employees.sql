CREATE TABLE [Common].[Employees] (
    [EmployeeID]   INT              IDENTITY (1, 1) NOT NULL,
    [UserID]       UNIQUEIDENTIFIER NULL,
    [Name]         NVARCHAR (256)   NOT NULL,
    [Email]        NVARCHAR (256)   NOT NULL,
    [DefaultCarID] INT              NULL,
    CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED ([EmployeeID] ASC),
    CONSTRAINT [FK_Employees_Cars] FOREIGN KEY ([DefaultCarID]) REFERENCES [Vehicles].[Cars] ([CarID])
);

