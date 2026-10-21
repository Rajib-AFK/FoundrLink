-- ====================================================================
-- FoundrLink Database Schema & Comprehensive Seed Data Script
-- Microsoft SQL Server 2016+ / LocalDB
-- All sample emails strictly conform to @ripaldesign.studio convention
-- Populates all 20 tables with rich, production-like data for real graphs
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
        Role NVARCHAR(100) NOT NULL DEFAULT 'Founder', -- Founder, Investor, Co-Founder, Admin
        Title NVARCHAR(200) NULL,
        Location NVARCHAR(200) NULL,
        Bio NVARCHAR(MAX) NULL,
        AvatarUrl NVARCHAR(510) NULL,
        Company NVARCHAR(200) NULL,
        IsVerified BIT NOT NULL DEFAULT 0,
        Status NVARCHAR(100) NOT NULL DEFAULT 'Active', -- Active, Pending, Inactive, Suspended
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

-- 3. UserProfiles Table
IF OBJECT_ID('dbo.UserProfiles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserProfiles (
        ProfileId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL UNIQUE FOREIGN KEY REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
        Headline NVARCHAR(200) NULL,
        Bio NVARCHAR(MAX) NULL,
        Location NVARCHAR(100) NULL,
        Industry NVARCHAR(100) NULL,
        IsVerified BIT NOT NULL DEFAULT 0,
        ProfileCompletion INT NOT NULL DEFAULT 85,
        StartupWebsite NVARCHAR(200) NULL,
        FoundedYear INT NULL DEFAULT 2024,
        TeamSize INT NULL DEFAULT 3,
        FundingAmount NVARCHAR(50) NULL,
        MRR NVARCHAR(50) NULL,
        CanOffer NVARCHAR(MAX) NULL,
        LookingFor NVARCHAR(MAX) NULL,
        Interests NVARCHAR(MAX) NULL,
        BaseLocation NVARCHAR(100) NULL,
        Availability NVARCHAR(50) NOT NULL DEFAULT 'Full-time',
        TopSkills NVARCHAR(300) NULL
    );
END
GO

-- 4. Startups Table
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
        Status NVARCHAR(100) NOT NULL DEFAULT 'Active', -- Active, Approved, Published, Under Review, Draft, Rejected
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 5. OpenPositions Table
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

-- 6. StartupOpenRoles Table
IF OBJECT_ID('dbo.StartupOpenRoles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.StartupOpenRoles (
        RoleId INT IDENTITY(1,1) PRIMARY KEY,
        StartupId INT NOT NULL FOREIGN KEY REFERENCES dbo.Startups(StartupId) ON DELETE CASCADE,
        RoleTitle NVARCHAR(200) NOT NULL,
        Location NVARCHAR(200) NOT NULL DEFAULT 'Remote',
        EmploymentType NVARCHAR(100) NOT NULL DEFAULT 'Full-time',
        Description NVARCHAR(MAX) NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- 7. TeamMembers Table
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

-- 8. StartupMembers Table
IF OBJECT_ID('dbo.StartupMembers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.StartupMembers (
        MemberId INT IDENTITY(1,1) PRIMARY KEY,
        StartupId INT NOT NULL FOREIGN KEY REFERENCES dbo.Startups(StartupId) ON DELETE CASCADE,
        UserId INT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        MemberName NVARCHAR(200) NOT NULL,
        RoleTitle NVARCHAR(200) NOT NULL,
        AvatarUrl NVARCHAR(510) NULL,
        JoinedDate DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- 9. StartupUpdates Table
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

-- 10. Conversations Table
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

-- 11. Messages Table
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

-- 12. Notifications Table
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

-- 13. ModerationReports Table
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

-- 14. Reports Table
IF OBJECT_ID('dbo.Reports', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Reports (
        ReportId INT IDENTITY(1,1) PRIMARY KEY,
        ReporterUserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        ReporterEmail NVARCHAR(300) NOT NULL,
        ReportedItemType NVARCHAR(100) NOT NULL,
        ReportedItemId INT NOT NULL,
        ReportedItemTitle NVARCHAR(200) NOT NULL,
        ReportType NVARCHAR(100) NOT NULL,
        Details NVARCHAR(MAX) NULL,
        Status NVARCHAR(100) NOT NULL DEFAULT 'Pending',
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- 15. ConnectionRequests Table
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

-- 16. CollaborationRequests Table
IF OBJECT_ID('dbo.CollaborationRequests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CollaborationRequests (
        RequestId INT IDENTITY(1,1) PRIMARY KEY,
        SenderUserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        ReceiverUserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        StartupId INT NOT NULL FOREIGN KEY REFERENCES dbo.Startups(StartupId),
        Message NVARCHAR(MAX) NULL,
        Status NVARCHAR(100) NOT NULL DEFAULT 'Pending',
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- 17. Connections Table
IF OBJECT_ID('dbo.Connections', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Connections (
        ConnectionId INT IDENTITY(1,1) PRIMARY KEY,
        RequesterUserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        ReceiverUserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        Status NVARCHAR(100) NOT NULL DEFAULT 'Accepted',
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- 18. Deadlines Table
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

-- 19. ActivityLogs Table
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

-- 20. ConnectionGrowth Table
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

-- Adjust Constraints for Compatibility
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Startups_Status')
BEGIN
    ALTER TABLE dbo.Startups DROP CONSTRAINT CK_Startups_Status;
END
ALTER TABLE dbo.Startups ADD CONSTRAINT CK_Startups_Status CHECK ([Status]='Rejected' OR [Status]='Approved' OR [Status]='Under Review' OR [Status]='Draft' OR [Status]='Active' OR [Status]='Published');

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Notifications_Type')
BEGIN
    ALTER TABLE dbo.Notifications DROP CONSTRAINT CK_Notifications_Type;
END
ALTER TABLE dbo.Notifications ADD CONSTRAINT CK_Notifications_Type CHECK ([NotificationType]='Activity' OR [NotificationType]='Matches' OR [NotificationType]='Requests' OR [NotificationType]='System');
GO

-- ====================================================================
-- SEED DATA SECTION
-- ====================================================================

DECLARE @DefaultPwd NVARCHAR(512) = '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601'; -- SHA256('Password123')

-- 1. Default Accounts
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'admin@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Platform Admin', 'admin@ripaldesign.studio', @DefaultPwd, 'Admin', 'Platform Administrator', 'Mumbai, India', 'FoundrLink Head System Administrator & Moderation Lead.', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150', 'FoundrLink HQ', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Demo Founder', 'founder@ripaldesign.studio', @DefaultPwd, 'Founder', 'Startup Founder & CEO', 'Bengaluru, India', 'Serial entrepreneur building next-generation autonomous AI developer agents.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', 'TechNovate Labs', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Demo Co-Founder', 'cofounder@ripaldesign.studio', @DefaultPwd, 'Co-Founder', 'Lead Systems & Full-Stack Architect', 'Hyderabad, India', 'Systems architect specialized in distributed cloud systems, real-time telemetry, and LLM orchestration.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', 'TechNovate Labs', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'investor@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Demo Investor', 'investor@ripaldesign.studio', @DefaultPwd, 'Investor', 'Managing Partner & Angel Backer', 'Mumbai, India', 'Early-stage angel backer focused on B2B SaaS, developer tooling, and applied machine learning.', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'Apex Capital', 1, 'Active');
END

-- Ensure all accounts use @ripaldesign.studio and @DefaultPwd
UPDATE dbo.Users SET Email = 'admin.platform@ripaldesign.studio' WHERE Email = 'admin@foundrlink.com';
UPDATE dbo.Users 
SET Email = REPLACE(Email, SUBSTRING(Email, CHARINDEX('@', Email), LEN(Email)), '@ripaldesign.studio'),
    PasswordHash = @DefaultPwd,
    Status = 'Active',
    IsVerified = 1
WHERE Email NOT LIKE '%@ripaldesign.studio';
GO

-- 2. FounderProfiles & 3. UserProfiles for all users
DECLARE @uId INT;
DECLARE user_cursor CURSOR FOR SELECT UserId FROM dbo.Users;
OPEN user_cursor;
FETCH NEXT FROM user_cursor INTO @uId;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.FounderProfiles WHERE UserId = @uId)
    BEGIN
        INSERT INTO dbo.FounderProfiles 
        (UserId, PlatformImpactConnections, PlatformImpactIntros, PlatformImpactTeams, PlatformImpactSaved, Interests, Skills, ICanOffer, LookingFor, Availability, BaseLocation, ProfileCompletionPercentage)
        VALUES 
        (@uId, 85 + (@uId * 7 % 150), 12 + (@uId * 3 % 25), 2 + (@uId % 4), 18 + (@uId * 5 % 40), 
         'AI/ML, Enterprise SaaS, Developer Tools, FinTech', 
         'System Architecture, Product Strategy, Cloud Infrastructure, Go-To-Market', 
         'Technical leadership, MVP rapid prototyping, seed-stage fundraising guidance', 
         'Seed Stage Investors, Senior Full-Stack Engineers, Co-Founders with GTM expertise', 
         'Full-time', 'Bengaluru, India', 85 + (@uId % 15));
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.UserProfiles WHERE UserId = @uId)
    BEGIN
        INSERT INTO dbo.UserProfiles 
        (UserId, Headline, Bio, Location, Industry, IsVerified, ProfileCompletion, StartupWebsite, FoundedYear, TeamSize, FundingAmount, MRR, CanOffer, LookingFor, Interests, BaseLocation, Availability, TopSkills)
        VALUES 
        (@uId, 
         'High-growth tech builder & co-founder scaling software platforms.', 
         'Passionate about software architecture, scaling resilient cloud services, and empowering early-stage startups.',
         'Bengaluru, India', 'Software / AI', 1, 90, 'https://technovate.ripaldesign.studio', 2024, 4, '$500,000', '$22,000',
         'Full-stack development, cloud architecture, system design',
         'Strategic angel investors, product designers, technical peers',
         'Artificial Intelligence, Cloud Computing, Distributed Systems',
         'Bengaluru, India', 'Full-time', 'C#, .NET, React, SQL, Azure, Python');
    END

    FETCH NEXT FROM user_cursor INTO @uId;
END
CLOSE user_cursor;
DEALLOCATE user_cursor;
GO

-- 4. Startups Flagship
DECLARE @FounderUserId INT;
SELECT TOP 1 @FounderUserId = UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio';
IF @FounderUserId IS NULL SELECT TOP 1 @FounderUserId = UserId FROM dbo.Users WHERE Role = 'Founder';

IF NOT EXISTS (SELECT 1 FROM dbo.Startups WHERE Name = 'TechNovate AI')
BEGIN
    INSERT INTO dbo.Startups 
    (FounderId, Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, FullDescription, Problem, Solution, TeamSize, RequiredSkills, Location, WebsiteUrl, Commitment, FoundedYear, FundingRaised, FundingGoal, MRR, Status, CreatedAt, UpdatedAt)
    VALUES
    (@FounderUserId, 
     'TechNovate AI', 
     'Autonomous engineering and code workflow intelligence for high-velocity teams.',
     'AI/ML', 
     'Seed Stage', 
     'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150',
     'TechNovate builds intelligent developer assistants that orchestrate system verification, CI/CD triage, and architecture reviews.',
     'TechNovate AI represents the next leap in developer tooling. By synthesizing AST analysis and deep contextual understanding of enterprise repos, TechNovate slashes review cycles and empowers small teams to execute at hyper-scale.',
     'Modern engineering teams spend over 35% of their working hours debugging regressions, reviewing boilerplate PRs, and untangling deployment bottlenecks.',
     'An end-to-end autonomous assistant natively plugged into code review and testing pipelines that detects edge cases before production.',
     4, 
     'C#, .NET Core, React, TypeScript, Python, Azure ML', 
     'Bengaluru, India', 
     'https://technovate.ripaldesign.studio', 
     'Full-time', 
     2024, 
     250000.00, 
     1000000.00, 
     18500.00, 
     'Published', 
     SYSUTCDATETIME(), 
     SYSUTCDATETIME());
END
GO

-- 5. OpenPositions & 6. StartupOpenRoles
DECLARE @MainStartupId INT;
SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups WHERE Name = 'TechNovate AI';
IF @MainStartupId IS NULL SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups;

IF NOT EXISTS (SELECT 1 FROM dbo.OpenPositions WHERE StartupId = @MainStartupId AND Title = 'Senior Full-Stack Architect')
BEGIN
    INSERT INTO dbo.OpenPositions (StartupId, Title, Location, PositionType, CreatedAt)
    VALUES 
    (@MainStartupId, 'Senior Full-Stack Architect', 'Remote (India)', 'Full-time', SYSUTCDATETIME()),
    (@MainStartupId, 'Lead Machine Learning Engineer', 'Bengaluru, India', 'Full-time', SYSUTCDATETIME()),
    (@MainStartupId, 'Product Designer (UI/UX)', 'Remote', 'Part-time / Equity', SYSUTCDATETIME());
END

IF NOT EXISTS (SELECT 1 FROM dbo.StartupOpenRoles WHERE StartupId = @MainStartupId)
BEGIN
    INSERT INTO dbo.StartupOpenRoles (StartupId, RoleTitle, Location, EmploymentType, Description, CreatedAt)
    VALUES 
    (@MainStartupId, 'Principal Infrastructure Engineer', 'Bengaluru, India', 'Full-time', 'Scale Kubernetes clusters and distributed streaming pipelines.', GETDATE()),
    (@MainStartupId, 'Developer Advocate & Growth Lead', 'Remote', 'Full-time', 'Lead developer community engagement and technical documentation.', GETDATE()),
    (@MainStartupId, 'Frontend Engineer (React)', 'Remote', 'Part-time', 'Build snappy, intuitive developer interfaces and telemetry dashboards.', GETDATE());
END
GO

-- 7. TeamMembers & 8. StartupMembers
DECLARE @MainStartupId INT;
DECLARE @FounderId INT, @CoFounderId INT;
SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups WHERE Name = 'TechNovate AI';
IF @MainStartupId IS NULL SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups;
SELECT TOP 1 @FounderId = UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio';
SELECT TOP 1 @CoFounderId = UserId FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio';

IF @FounderId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TeamMembers WHERE StartupId = @MainStartupId AND UserId = @FounderId)
BEGIN
    INSERT INTO dbo.TeamMembers (StartupId, UserId, Name, Role, AvatarUrl, JoinedDate)
    VALUES (@MainStartupId, @FounderId, 'Demo Founder', 'Founder & CEO', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', SYSUTCDATETIME());
END

IF @CoFounderId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TeamMembers WHERE StartupId = @MainStartupId AND UserId = @CoFounderId)
BEGIN
    INSERT INTO dbo.TeamMembers (StartupId, UserId, Name, Role, AvatarUrl, JoinedDate)
    VALUES (@MainStartupId, @CoFounderId, 'Demo Co-Founder', 'Co-Founder & CTO', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', SYSUTCDATETIME());
END
GO

-- 9. StartupUpdates
DECLARE @MainStartupId INT;
SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups WHERE Name = 'TechNovate AI';
IF @MainStartupId IS NULL SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups;

IF NOT EXISTS (SELECT 1 FROM dbo.StartupUpdates WHERE StartupId = @MainStartupId)
BEGIN
    INSERT INTO dbo.StartupUpdates (StartupId, AuthorName, Content, CreatedAt)
    VALUES 
    (@MainStartupId, 'Demo Founder', 'Closed seed funding milestone with lead participation from Apex Capital!', DATEADD(DAY, -14, SYSUTCDATETIME())),
    (@MainStartupId, 'Demo Co-Founder', 'Beta v1.2 launched with real-time distributed telemetry and AST code parser integration.', DATEADD(DAY, -5, SYSUTCDATETIME())),
    (@MainStartupId, 'Demo Founder', 'Welcomed 25 new enterprise pilot partners across India and Singapore.', DATEADD(DAY, -1, SYSUTCDATETIME()));
END
GO

-- 10. Conversations & 11. Messages
DECLARE @FId INT, @CId INT, @IId INT;
SELECT TOP 1 @FId = UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio';
SELECT TOP 1 @CId = UserId FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio';
SELECT TOP 1 @IId = UserId FROM dbo.Users WHERE Email = 'investor@ripaldesign.studio';

IF @FId IS NOT NULL AND @CId IS NOT NULL
BEGIN
    DECLARE @ConvId1 INT;
    SELECT @ConvId1 = ConversationId FROM dbo.Conversations WHERE (User1Id = @FId AND User2Id = @CId) OR (User1Id = @CId AND User2Id = @FId);
    IF @ConvId1 IS NULL
    BEGIN
        INSERT INTO dbo.Conversations (User1Id, User2Id, LastMessageAt) VALUES (@FId, @CId, SYSUTCDATETIME());
        SET @ConvId1 = SCOPE_IDENTITY();
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE ConversationId = @ConvId1)
    BEGIN
        INSERT INTO dbo.Messages (ConversationId, SenderId, ReceiverId, Content, IsRead, SentAt)
        VALUES 
        (@ConvId1, @CId, @FId, 'Hey! I reviewed the architecture for our AI pipeline, the latency numbers look incredible.', 0, DATEADD(MINUTE, -40, SYSUTCDATETIME())),
        (@ConvId1, @FId, @CId, 'Awesome! Let us prepare the demo for our investor check-in on Thursday.', 1, DATEADD(MINUTE, -20, SYSUTCDATETIME()));
    END
END
GO

-- 18. Deadlines Table
DELETE FROM dbo.Deadlines;
DECLARE @uId INT;
DECLARE dl_cursor CURSOR FOR SELECT UserId FROM dbo.Users;
OPEN dl_cursor;
FETCH NEXT FROM dl_cursor INTO @uId;
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO dbo.Deadlines (UserId, Title, Description, DeadlineDate, MonthText, DayText)
    VALUES 
    (@uId, 'Seed Pitch Deck Submission', 'Finalize slide deck and 3-year financial model for syndicate review.', DATEADD(DAY, 4, GETDATE()), 'OCT', '25'),
    (@uId, 'FoundrLink Winter Demo Day', 'Present 5-minute live product walkthrough to 120+ active seed funds.', DATEADD(DAY, 18, GETDATE()), 'NOV', '08'),
    (@uId, 'Co-Founder FAST Agreement Execution', 'Review equity vesting cliffs and intellectual property assignments.', DATEADD(DAY, 35, GETDATE()), 'NOV', '25');

    FETCH NEXT FROM dl_cursor INTO @uId;
END
CLOSE dl_cursor;
DEALLOCATE dl_cursor;
GO

-- 19. ActivityLogs Table
DELETE FROM dbo.ActivityLogs;
DECLARE @uId INT;
DECLARE act_cursor CURSOR FOR SELECT UserId FROM dbo.Users;
OPEN act_cursor;
FETCH NEXT FROM act_cursor INTO @uId;
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO dbo.ActivityLogs (UserId, ActivityText, ActivityType, TimeAgo, CreatedAt)
    VALUES 
    (@uId, 'Apex Capital viewed your startup pitch deck', 'Like', '15m ago', DATEADD(MINUTE, -15, GETDATE())),
    (@uId, 'Demo Co-Founder accepted your collaboration invite', 'Join', '2h ago', DATEADD(HOUR, -2, GETDATE())),
    (@uId, 'You received an intro request from TechNovate Labs', 'Message', '5h ago', DATEADD(HOUR, -5, GETDATE())),
    (@uId, 'Your profile was featured in Top 5% Builders this week', 'Bell', '1d ago', DATEADD(DAY, -1, GETDATE()));

    FETCH NEXT FROM act_cursor INTO @uId;
END
CLOSE act_cursor;
DEALLOCATE act_cursor;
GO

-- 20. ConnectionGrowth Table (Powers real chart in Dashboard.aspx)
DELETE FROM dbo.ConnectionGrowth;
DECLARE @uId INT, @role NVARCHAR(100);
DECLARE cg_cursor CURSOR FOR SELECT UserId, Role FROM dbo.Users;
OPEN cg_cursor;
FETCH NEXT FROM cg_cursor INTO @uId, @role;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @b1 INT = 12 + (@uId * 3 % 8);
    DECLARE @b2 INT = @b1 + 14 + (@uId * 5 % 10);
    DECLARE @b3 INT = @b2 + 18 + (@uId * 4 % 12);
    DECLARE @b4 INT = @b3 + 22 + (@uId * 7 % 14);
    DECLARE @b5 INT = @b4 + 28 + (@uId * 6 % 16);
    DECLARE @b6 INT = @b5 + 34 + (@uId * 8 % 20);

    IF @role = 'Investor'
    BEGIN
        SET @b1 = @b1 + 15;
        SET @b2 = @b2 + 25;
        SET @b3 = @b3 + 40;
        SET @b4 = @b4 + 55;
        SET @b5 = @b5 + 75;
        SET @b6 = @b6 + 100;
    END

    INSERT INTO dbo.ConnectionGrowth (UserId, MonthLabel, MonthOrder, CountValue)
    VALUES 
    (@uId, 'May', 1, @b1),
    (@uId, 'Jun', 2, @b2),
    (@uId, 'Jul', 3, @b3),
    (@uId, 'Aug', 4, @b4),
    (@uId, 'Sep', 5, @b5),
    (@uId, 'Oct', 6, @b6);

    FETCH NEXT FROM cg_cursor INTO @uId, @role;
END
CLOSE cg_cursor;
DEALLOCATE cg_cursor;
GO

PRINT 'FoundrLink database schema & sample data initialized successfully!';
GO
