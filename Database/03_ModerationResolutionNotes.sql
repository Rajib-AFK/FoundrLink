-- Migration 03: Add ResolutionNotes column to dbo.ModerationReports for audit & moderation history
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ModerationReports' AND COLUMN_NAME = 'ResolutionNotes'
)
BEGIN
    ALTER TABLE dbo.ModerationReports ADD ResolutionNotes NVARCHAR(1000) NULL;
END
GO
