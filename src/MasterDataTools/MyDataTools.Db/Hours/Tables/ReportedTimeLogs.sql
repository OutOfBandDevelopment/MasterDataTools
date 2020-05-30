CREATE TABLE [Hours].[ReportedTimeLogs] (
    [ReportedTimeLogID] INT             IDENTITY (1, 1) NOT NULL,
    [ProjectID]         INT             NOT NULL,
    [Year]              INT             NOT NULL,
    [Month]             INT             NOT NULL,
    [Week]              INT             NOT NULL,
    [FirstOfWeek]       DATE            NOT NULL,
    [Rendering]         VARBINARY (MAX) NULL,
    [HasRendering]      AS              (case when [Rendering] IS NULL then (0) else (1) end) PERSISTED NOT NULL,
    CONSTRAINT [PK_ReportedTimeLogs] PRIMARY KEY CLUSTERED ([ReportedTimeLogID] ASC),
    CONSTRAINT [FK_ReportedTimeLogs_Projects] FOREIGN KEY ([ProjectID]) REFERENCES [Accounting].[Projects] ([ProjectID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ReportedTimeLogs]
    ON [Hours].[ReportedTimeLogs]([ProjectID] ASC, [Year] ASC, [Month] ASC, [Week] ASC);

