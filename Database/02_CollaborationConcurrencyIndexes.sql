-- Migration 02: Unique Filtered Indexes to Prevent Race-Condition Duplicates
-- FoundrLink - Phase 3 Collaboration Workflows
USE [FoundrLinkDB];
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_CollaborationRequests_Pending' AND object_id = OBJECT_ID('dbo.CollaborationRequests'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UQ_CollaborationRequests_Pending
    ON dbo.CollaborationRequests (SenderUserId, StartupId)
    WHERE Status = 'Pending';
    PRINT 'UQ_CollaborationRequests_Pending index created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_ConnectionRequests_Pending' AND object_id = OBJECT_ID('dbo.ConnectionRequests'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UQ_ConnectionRequests_Pending
    ON dbo.ConnectionRequests (SenderId, ReceiverId)
    WHERE Status = 'Pending';
    PRINT 'UQ_ConnectionRequests_Pending index created.';
END
GO
