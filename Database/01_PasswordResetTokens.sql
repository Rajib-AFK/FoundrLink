-- Migration: Add PasswordResetTokens Table
-- FoundrLink - Phase 2 Account Recovery
USE [FoundrLinkDB];
GO

IF OBJECT_ID('dbo.PasswordResetTokens', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PasswordResetTokens (
        TokenId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
        TokenHash NVARCHAR(128) NOT NULL,
        ExpiresAt DATETIME2 NOT NULL,
        IsUsed BIT NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );

    CREATE INDEX IX_PasswordResetTokens_TokenHash ON dbo.PasswordResetTokens(TokenHash);
    PRINT 'PasswordResetTokens table created successfully.';
END
GO
