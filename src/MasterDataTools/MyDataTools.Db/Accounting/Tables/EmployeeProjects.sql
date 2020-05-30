CREATE TABLE [Accounting].[EmployeeProjects] (
    [EmployeProjectID] INT IDENTITY (1, 1) NOT NULL,
    [EmployeeID]       INT NOT NULL,
    [ProjectID]        INT NOT NULL,
    CONSTRAINT [PK_EmployeeProjects] PRIMARY KEY CLUSTERED ([EmployeProjectID] ASC),
    CONSTRAINT [FK_EmployeeProjects_Employees] FOREIGN KEY ([EmployeeID]) REFERENCES [Common].[Employees] ([EmployeeID]),
    CONSTRAINT [FK_EmployeeProjects_Projects] FOREIGN KEY ([ProjectID]) REFERENCES [Accounting].[Projects] ([ProjectID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeeProjects]
    ON [Accounting].[EmployeeProjects]([EmployeeID] ASC, [ProjectID] ASC);

