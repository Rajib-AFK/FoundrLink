-- ====================================================================
-- FoundrLink Database Schema & Seed Data Script
-- Microsoft SQL Server 2016+ / LocalDB
-- ====================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'FoundrLinkDB')
BEGIN
    CREATE DATABASE [FoundrLinkDB];
END
GO

USE [FoundrLinkDB];
GO

-- 1. Users Table
IF OBJECT_ID('dbo.Users', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users (
        UserId INT IDENTITY(1,1) PRIMARY KEY,
        FullName NVARCHAR(200) NOT NULL,
        Email NVARCHAR(300) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(512) NOT NULL,
        Role NVARCHAR(100) NOT NULL DEFAULT 'Founder', -- Founder, Investor, Co-Founder, Technical, Admin
        Title NVARCHAR(200) NULL,
        Location NVARCHAR(200) NULL,
        Bio NVARCHAR(MAX) NULL,
        AvatarUrl NVARCHAR(510) NULL,
        Company NVARCHAR(200) NULL,
        IsVerified BIT NOT NULL DEFAULT 0,
        Status NVARCHAR(100) NOT NULL DEFAULT 'Active', -- Active, Pending, Inactive
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 2. FounderProfiles Table
IF OBJECT_ID('dbo.FounderProfiles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FounderProfiles (
        ProfileId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL UNIQUE FOREIGN KEY REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
        PlatformImpactConnections INT NOT NULL DEFAULT 0,
        PlatformImpactIntros INT NOT NULL DEFAULT 0,
        PlatformImpactTeams INT NOT NULL DEFAULT 0,
        PlatformImpactSaved INT NOT NULL DEFAULT 0,
        Interests NVARCHAR(MAX) NULL,
        Skills NVARCHAR(MAX) NULL,
        ICanOffer NVARCHAR(MAX) NULL,
        LookingFor NVARCHAR(MAX) NULL,
        Availability NVARCHAR(100) NOT NULL DEFAULT 'Full-time',
        BaseLocation NVARCHAR(200) NULL,
        ProfileCompletionPercentage INT NOT NULL DEFAULT 85
    );
END
GO

-- 3. Startups Table
IF OBJECT_ID('dbo.Startups', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Startups (
        StartupId INT IDENTITY(1,1) PRIMARY KEY,
        FounderId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        Name NVARCHAR(200) NOT NULL,
        Tagline NVARCHAR(400) NULL,
        Industry NVARCHAR(100) NULL,
        Stage NVARCHAR(100) NOT NULL DEFAULT 'Seed Stage', -- Pre-Seed, Seed Stage, Series A, MVP, Draft
        LogoUrl NVARCHAR(510) NULL,
        ShortDescription NVARCHAR(500) NULL,
        FullDescription NVARCHAR(MAX) NULL,
        Problem NVARCHAR(MAX) NULL,
        Solution NVARCHAR(MAX) NULL,
        TeamSize INT NOT NULL DEFAULT 1,
        RequiredSkills NVARCHAR(400) NULL,
        Location NVARCHAR(200) NULL,
        WebsiteUrl NVARCHAR(300) NULL,
        Commitment NVARCHAR(100) NULL DEFAULT 'Part-time / Equity',
        FoundedYear INT NULL DEFAULT 2023,
        FundingRaised DECIMAL(18,2) NOT NULL DEFAULT 0,
        FundingGoal DECIMAL(18,2) NOT NULL DEFAULT 0,
        MRR DECIMAL(18,2) NOT NULL DEFAULT 0,
        Status NVARCHAR(100) NOT NULL DEFAULT 'Active', -- Active, Approved, Under Review, Draft, Rejected
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 4. OpenPositions Table
IF OBJECT_ID('dbo.OpenPositions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OpenPositions (
        PositionId INT IDENTITY(1,1) PRIMARY KEY,
        StartupId INT NOT NULL FOREIGN KEY REFERENCES dbo.Startups(StartupId) ON DELETE CASCADE,
        Title NVARCHAR(200) NOT NULL,
        Location NVARCHAR(200) NOT NULL DEFAULT 'Remote',
        PositionType NVARCHAR(100) NOT NULL DEFAULT 'Full-time',
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 5. TeamMembers Table
IF OBJECT_ID('dbo.TeamMembers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TeamMembers (
        TeamMemberId INT IDENTITY(1,1) PRIMARY KEY,
        StartupId INT NOT NULL FOREIGN KEY REFERENCES dbo.Startups(StartupId) ON DELETE CASCADE,
        UserId INT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        Name NVARCHAR(200) NOT NULL,
        Role NVARCHAR(200) NOT NULL,
        AvatarUrl NVARCHAR(510) NULL,
        JoinedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 6. StartupUpdates Table
IF OBJECT_ID('dbo.StartupUpdates', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.StartupUpdates (
        UpdateId INT IDENTITY(1,1) PRIMARY KEY,
        StartupId INT NOT NULL FOREIGN KEY REFERENCES dbo.Startups(StartupId) ON DELETE CASCADE,
        AuthorName NVARCHAR(200) NOT NULL,
        Content NVARCHAR(MAX) NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 7. Conversations Table
IF OBJECT_ID('dbo.Conversations', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Conversations (
        ConversationId INT IDENTITY(1,1) PRIMARY KEY,
        User1Id INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        User2Id INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        LastMessageAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 8. Messages Table
IF OBJECT_ID('dbo.Messages', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Messages (
        MessageId INT IDENTITY(1,1) PRIMARY KEY,
        ConversationId INT NOT NULL FOREIGN KEY REFERENCES dbo.Conversations(ConversationId) ON DELETE CASCADE,
        SenderId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        ReceiverId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        Content NVARCHAR(MAX) NOT NULL,
        IsRead BIT NOT NULL DEFAULT 0,
        SentAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 9. Notifications Table
IF OBJECT_ID('dbo.Notifications', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Notifications (
        NotificationId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
        Title NVARCHAR(250) NOT NULL,
        Message NVARCHAR(MAX) NULL,
        NotificationType NVARCHAR(100) NOT NULL DEFAULT 'Activity', -- Requests, Matches, Activity, System
        ActionRequired BIT NOT NULL DEFAULT 0,
        IsRead BIT NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 10. ModerationReports Table
IF OBJECT_ID('dbo.ModerationReports', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ModerationReports (
        ReportId INT IDENTITY(1,1) PRIMARY KEY,
        ReportCode NVARCHAR(50) NOT NULL,
        ReporterEmail NVARCHAR(300) NOT NULL,
        ReportedItem NVARCHAR(400) NOT NULL,
        ReportType NVARCHAR(100) NOT NULL DEFAULT 'Spam', -- Spam, Content Violation, Suspicious Activity
        Priority NVARCHAR(50) NOT NULL DEFAULT 'Medium', -- High, Medium, Low
        Details NVARCHAR(MAX) NULL,
        Status NVARCHAR(100) NOT NULL DEFAULT 'Pending', -- Pending, Resolved, Dismissed
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        ResolvedAt DATETIME2 NULL
    );
END
GO

-- 11. ConnectionRequests Table
IF OBJECT_ID('dbo.ConnectionRequests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ConnectionRequests (
        RequestId INT IDENTITY(1,1) PRIMARY KEY,
        SenderId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        ReceiverId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        StartupId INT NULL FOREIGN KEY REFERENCES dbo.Startups(StartupId),
        Note NVARCHAR(MAX) NULL,
        Status NVARCHAR(100) NOT NULL DEFAULT 'Pending', -- Pending, Accepted, Declined
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 12. Deadlines Table
IF OBJECT_ID('dbo.Deadlines', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Deadlines (
        DeadlineId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        Title NVARCHAR(200) NOT NULL,
        Description NVARCHAR(300) NULL,
        DeadlineDate DATETIME NOT NULL,
        MonthText NVARCHAR(10) NULL,
        DayText NVARCHAR(10) NULL
    );
END
GO

-- 13. ActivityLogs Table
IF OBJECT_ID('dbo.ActivityLogs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ActivityLogs (
        ActivityId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        ActivityText NVARCHAR(400) NOT NULL,
        ActivityType NVARCHAR(50) NOT NULL DEFAULT 'Like',
        TimeAgo NVARCHAR(50) NOT NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- 14. ConnectionGrowth Table
IF OBJECT_ID('dbo.ConnectionGrowth', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ConnectionGrowth (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        MonthLabel NVARCHAR(20) NOT NULL,
        MonthOrder INT NOT NULL,
        CountValue INT NOT NULL
    );
END
GO

-- Password hash: PBKDF2 of 'Password123'
DECLARE @DefaultPwd NVARCHAR(512) = '10000.HbBo9Q4mDoQ19K4EfuEczw==.agGzYGJcPYaHJ7fjRBNzviLbh9pnUi+U4+OdzYQonrg=';

-- Verify default users exist
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'admin@foundrlink.com')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Admin User', 'admin@foundrlink.com', @DefaultPwd, 'Admin', 'Platform Administrator', 'Mumbai, India', 'FoundrLink System Administrator', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&auto=format&fit=crop&q=80', 'FoundrLink', 1, 'Active');
END
GO
