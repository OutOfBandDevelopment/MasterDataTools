CREATE TABLE [Hours].[TimeLogs] (
    [TimeLogID]         INT            IDENTITY (1, 1) NOT NULL,
    [Date]              DATE           NOT NULL,
    [StartTime]         TIME (7)       NOT NULL,
    [StartBreak]        TIME (7)       NULL,
    [EndBreak]          TIME (7)       NULL,
    [EndTIme]           TIME (7)       NULL,
    [Note]              NVARCHAR (265) NULL,
    [InvoiceID]         INT            NULL,
    [ProjectID]         INT            NOT NULL,
    [Miles]             FLOAT (53)     NULL,
    [Hours]             AS             (CONVERT([float],datediff(minute,[StartTime],isnull([EndTIme],'0:00'))-CONVERT([float],datediff(minute,isnull([StartBreak],'0:00'),isnull([EndBreak],'0:00'))))/(60.0)),
    [CarID]             INT            NULL,
    [ReportedTimeLogID] INT            NULL,
    CONSTRAINT [PK_TimeLogs] PRIMARY KEY CLUSTERED ([TimeLogID] ASC),
    CONSTRAINT [FK_TimeLogs_Cars] FOREIGN KEY ([CarID]) REFERENCES [Vehicles].[Cars] ([CarID]),
    CONSTRAINT [FK_TimeLogs_Projects] FOREIGN KEY ([ProjectID]) REFERENCES [Accounting].[Projects] ([ProjectID]),
    CONSTRAINT [FK_TimeLogs_ReportedTimeLogs] FOREIGN KEY ([ReportedTimeLogID]) REFERENCES [Hours].[ReportedTimeLogs] ([ReportedTimeLogID])
);

