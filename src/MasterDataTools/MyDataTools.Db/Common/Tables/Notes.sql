CREATE TABLE [Common].[Notes] (
    [NoteID]   INT            IDENTITY (1, 1) NOT NULL,
    [Date]     DATETIME       CONSTRAINT [DF_Notes_Date] DEFAULT (getdate()) NOT NULL,
    [Note]     NVARCHAR (MAX) NOT NULL,
    [Complete] BIT            NULL,
    CONSTRAINT [PK_Notes] PRIMARY KEY CLUSTERED ([NoteID] ASC)
);

