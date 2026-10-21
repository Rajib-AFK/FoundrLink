-- ====================================================================
-- FoundrLink Database Schema & Seed Data Script
-- Microsoft SQL Server 2016+ / LocalDB
-- Sample Domain: strictly @ripaldesign.studio
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
        Role NVARCHAR(100) NOT NULL DEFAULT 'Founder', -- Founder, Investor, Co-Founder, Technical, Admin, Marketing
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
        FoundedYear INT NULL DEFAULT 2024,
        FundingRaised DECIMAL(18,2) NOT NULL DEFAULT 0,
        FundingGoal DECIMAL(18,2) NOT NULL DEFAULT 0,
        MRR DECIMAL(18,2) NOT NULL DEFAULT 0,
        Status NVARCHAR(100) NOT NULL DEFAULT 'Active', -- Active, Approved, Published, Draft, Rejected
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

-- 15. CollaborationRequests Table
IF OBJECT_ID('dbo.CollaborationRequests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CollaborationRequests (
        RequestId INT IDENTITY(1,1) PRIMARY KEY,
        SenderUserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        ReceiverUserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        StartupId INT NOT NULL FOREIGN KEY REFERENCES dbo.Startups(StartupId),
        Message NVARCHAR(MAX) NULL,
        Status NVARCHAR(100) NOT NULL DEFAULT 'Pending', -- Pending, Accepted, Declined
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 16. Connections Table
IF OBJECT_ID('dbo.Connections', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Connections (
        ConnectionId INT IDENTITY(1,1) PRIMARY KEY,
        RequesterUserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        ReceiverUserId INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        Status NVARCHAR(100) NOT NULL DEFAULT 'Connected', -- Connected, Blocked
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 17. Reports Table
IF OBJECT_ID('dbo.Reports', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Reports (
        ReportId INT IDENTITY(1,1) PRIMARY KEY,
        ReporterUserId INT NULL FOREIGN KEY REFERENCES dbo.Users(UserId),
        ReporterEmail NVARCHAR(300) NOT NULL,
        ReportedItemType NVARCHAR(100) NOT NULL,
        ReportedItemId INT NOT NULL,
        ReportedItemTitle NVARCHAR(400) NOT NULL,
        ReportType NVARCHAR(100) NOT NULL DEFAULT 'Spam',
        Details NVARCHAR(MAX) NULL,
        Status NVARCHAR(100) NOT NULL DEFAULT 'Pending',
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- ====================================================================
-- SEED DATA SECTION
-- Default Password: Password123 (SHA-256: 008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601)
-- ====================================================================
DECLARE @DefaultPwd NVARCHAR(512) = '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601';

-- 1. Default Test Accounts
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'admin@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Platform Admin', 'admin@ripaldesign.studio', @DefaultPwd, 'Admin', 'Platform Administrator', 'Mumbai, India', 'FoundrLink System Administrator', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&auto=format&fit=crop&q=80', 'FoundrLink', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Startup Founder', 'founder@ripaldesign.studio', @DefaultPwd, 'Founder', 'Startup Founder & CEO', 'Bengaluru, India', 'Serial entrepreneur with a passion for building scalable infrastructure that empowers creators and small businesses.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80', 'NeuroSync', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Technical Co-Founder', 'cofounder@ripaldesign.studio', @DefaultPwd, 'Co-Founder', 'Technical Co-founder & Lead Backend', 'Bengaluru, India', 'Full-stack builder specializing in distributed systems, high throughput APIs, React, and Node microservices.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80', 'FoundrLink', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'investor@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Angel Investor', 'investor@ripaldesign.studio', @DefaultPwd, 'Investor', 'Managing Partner & Angel Investor', 'Mumbai, India', 'Early-stage angel and seed investor focused on B2B SaaS, AI, and developer tools.', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80', 'Apex Capital', 1, 'Active');
END

-- 2. Extended Team & Co-Founder Profiles (All @ripaldesign.studio)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'yash@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Yash Vinchhi', 'yash@ripaldesign.studio', @DefaultPwd, 'Founder', 'Founder & Systems Architect', 'Mumbai, India', 'Serial entrepreneur focused on building scalable infrastructure that empowers creators.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80', 'NeuroSync', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'rachit@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Rachit Agrawal', 'rachit@ripaldesign.studio', @DefaultPwd, 'Co-Founder', 'Full Stack & Cloud Lead', 'Bengaluru, India', 'Specializing in high throughput APIs, distributed microservices, and React.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80', 'FoundrLink', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'chirag@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Chirag K F', 'chirag@ripaldesign.studio', @DefaultPwd, 'Founder', 'Aspiring Founder & Developer', 'Bengaluru, India', 'Passionate developer building next-gen scalable products for startup ecosystems.', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80', 'FoundrLink', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'ananya@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Ananya Iyer', 'ananya@ripaldesign.studio', @DefaultPwd, 'Marketing', 'Head of Growth & Community', 'Hyderabad, India', 'Obsessed with product-led growth, virality loops, and zero-to-one B2B inbound marketing funnels.', 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&auto=format&fit=crop&q=80', 'GrowthLoop', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'manoj@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Manoj Tiwari', 'manoj@ripaldesign.studio', @DefaultPwd, 'Co-Founder', 'Lead Product Designer (UI/UX)', 'Delhi, India', 'Designing clean, human-centered SaaS tools. Ex-agency design lead focused on Figma systems.', 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&auto=format&fit=crop&q=80', 'Apex Studio', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'shreya@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Shreya Joshi', 'shreya@ripaldesign.studio', @DefaultPwd, 'Co-Founder', 'AI & Machine Learning Architect', 'Pune, India', 'Building fine-tuned LLM agents, vector retrieval pipelines, and AI copilot systems.', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80', 'NeuroSync', 1, 'Active');
END
GO

-- 3. FounderProfiles Seed
DECLARE @UFounder INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio');
DECLARE @UCofounder INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio');
DECLARE @UYash INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'yash@ripaldesign.studio');
DECLARE @UChirag INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'chirag@ripaldesign.studio');
DECLARE @UAnanya INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'ananya@ripaldesign.studio');
DECLARE @UManoj INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'manoj@ripaldesign.studio');
DECLARE @UShreya INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'shreya@ripaldesign.studio');

IF @UFounder IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.FounderProfiles WHERE UserId = @UFounder)
BEGIN
    INSERT INTO dbo.FounderProfiles (UserId, PlatformImpactConnections, PlatformImpactIntros, PlatformImpactTeams, PlatformImpactSaved, Interests, Skills, ICanOffer, LookingFor, Availability, BaseLocation, ProfileCompletionPercentage)
    VALUES (@UFounder, 342, 14, 3, 8, 'FinTech, SaaS, AI/ML', 'System Architecture, Go, Python, React, Cloud Ops', 'Technical Architecture Review;Go-to-Market Strategy for B2B;Introductions to Seed Investors', 'Technical Co-founder with ML background', 'Full-time', 'San Francisco & Mumbai', 95);
END

IF @UCofounder IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.FounderProfiles WHERE UserId = @UCofounder)
BEGIN
    INSERT INTO dbo.FounderProfiles (UserId, PlatformImpactConnections, PlatformImpactIntros, PlatformImpactTeams, PlatformImpactSaved, Interests, Skills, ICanOffer, LookingFor, Availability, BaseLocation, ProfileCompletionPercentage)
    VALUES (@UCofounder, 189, 8, 2, 5, 'Developer Tools, Web3, SaaS', 'React, Node.js, TypeScript, PostgreSQL, Docker', 'Full Stack Prototype in 48 Hours;Database Optimization', 'Visionary Product CEO with domain expertise', 'Full-time', 'Bengaluru, India', 85);
END

IF @UChirag IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.FounderProfiles WHERE UserId = @UChirag)
BEGIN
    INSERT INTO dbo.FounderProfiles (UserId, PlatformImpactConnections, PlatformImpactIntros, PlatformImpactTeams, PlatformImpactSaved, Interests, Skills, ICanOffer, LookingFor, Availability, BaseLocation, ProfileCompletionPercentage)
    VALUES (@UChirag, 75, 4, 1, 3, 'EdTech, Student Communities, AI', 'C#, ASP.NET, React, SQL Server, Python', 'Rapid MVP Development;Full Stack Engineering;Student Outreach', 'Co-Founders (Marketing / Design);Early Pilot Projects', 'Full-time', 'Bengaluru, India', 90);
END

IF @UAnanya IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.FounderProfiles WHERE UserId = @UAnanya)
BEGIN
    INSERT INTO dbo.FounderProfiles (UserId, PlatformImpactConnections, PlatformImpactIntros, PlatformImpactTeams, PlatformImpactSaved, Interests, Skills, ICanOffer, LookingFor, Availability, BaseLocation, ProfileCompletionPercentage)
    VALUES (@UAnanya, 210, 11, 2, 6, 'Consumer Tech, D2C, Marketplaces', 'Growth Marketing, SEO, Social Media Strategy, Copywriting', '0 to 10k User Acquisition Strategy;Content Marketing Playbooks', 'Early stage startup looking for growth lead', 'Part-time', 'Hyderabad, India', 88);
END

IF @UManoj IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.FounderProfiles WHERE UserId = @UManoj)
BEGIN
    INSERT INTO dbo.FounderProfiles (UserId, PlatformImpactConnections, PlatformImpactIntros, PlatformImpactTeams, PlatformImpactSaved, Interests, Skills, ICanOffer, LookingFor, Availability, BaseLocation, ProfileCompletionPercentage)
    VALUES (@UManoj, 155, 9, 3, 4, 'B2B SaaS, Design Systems, Mobile Apps', 'Figma, UI/UX Design, Design Systems, User Research', 'Complete Figma UI Kit;Design Audit & UX Teardown', 'Technical founder building impactful SaaS', 'Full-time', 'Delhi, India', 92);
END

IF @UShreya IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.FounderProfiles WHERE UserId = @UShreya)
BEGIN
    INSERT INTO dbo.FounderProfiles (UserId, PlatformImpactConnections, PlatformImpactIntros, PlatformImpactTeams, PlatformImpactSaved, Interests, Skills, ICanOffer, LookingFor, Availability, BaseLocation, ProfileCompletionPercentage)
    VALUES (@UShreya, 280, 16, 4, 12, 'Generative AI, LLMs, Computer Vision', 'Python, PyTorch, LangChain, Vector DBs, FastAPI', 'End-to-End LLM Integration;Custom Model Fine-tuning', 'Business-savvy co-founder with B2B sales experience', 'Full-time', 'Pune, India', 98);
END
GO

-- 4. Startups Seed
DECLARE @UFounder INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio');
DECLARE @UYash INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'yash@ripaldesign.studio');
DECLARE @UChirag INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'chirag@ripaldesign.studio');

IF NOT EXISTS (SELECT 1 FROM dbo.Startups WHERE Name = 'NeuroSync')
BEGIN
    INSERT INTO dbo.Startups (FounderId, Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, FullDescription, Problem, Solution, TeamSize, RequiredSkills, Location, WebsiteUrl, Commitment, FoundedYear, FundingRaised, FundingGoal, MRR, Status)
    VALUES (ISNULL(@UYash, @UFounder), 'NeuroSync', 'AI-powered workflow automation and predictive intelligence', 'Artificial Intelligence', 'Seed Stage', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200&auto=format&fit=crop&q=80',
    'Automating enterprise decision workflows with proprietary real-time LLM agents.',
    'NeuroSync is building the next-generation operating system for enterprise productivity. By orchestrating specialized AI agents, knowledge workers save over 15 hours every week on mundane data cross-referencing.',
    'Enterprises drown in siloed data across hundreds of SaaS tools without unified intelligence.',
    'A unified agentic workflow orchestrator that connects CRM, ERP, and databases seamlessly.',
    4, 'React, Python, LangChain, Vector DBs, UI/UX', 'Remote / Mumbai', 'https://neurosync.ripaldesign.studio', 'Full-time', 2024, 2500000, 5000000, 42000, 'Published');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Startups WHERE Name = 'EcoTrack')
BEGIN
    INSERT INTO dbo.Startups (FounderId, Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, FullDescription, Problem, Solution, TeamSize, RequiredSkills, Location, WebsiteUrl, Commitment, FoundedYear, FundingRaised, FundingGoal, MRR, Status)
    VALUES (@UFounder, 'EcoTrack', 'Automated API-driven carbon auditing & sustainability compliance', 'CleanTech', 'MVP', 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=200&auto=format&fit=crop&q=80',
    'Helping mid-market companies achieve ESG compliance with zero-overhead sensor integrations.',
    'EcoTrack automates the entire scope 1, 2, and 3 emissions reporting pipeline for manufacturing and logistics firms with audit-ready accuracy.',
    'ESG reporting regulations are rapidly tightening globally, forcing mid-market companies into manual spreadsheet hell.',
    'A real-time continuous auditing SaaS that produces audit-ready compliance certificates in minutes.',
    3, 'Python, Data Engineering, IoT, Angular', 'Bengaluru, India', 'https://ecotrack.ripaldesign.studio', 'Part-time / Equity', 2023, 800000, 2000000, 18000, 'Published');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Startups WHERE Name = 'FoundrLink')
BEGIN
    INSERT INTO dbo.Startups (FounderId, Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, FullDescription, Problem, Solution, TeamSize, RequiredSkills, Location, WebsiteUrl, Commitment, FoundedYear, FundingRaised, FundingGoal, MRR, Status)
    VALUES (ISNULL(@UChirag, @UFounder), 'FoundrLink', 'Smart co-founder discovery and startup team assembly platform', 'EdTech & Productivity', 'Seed Stage', 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=200&auto=format&fit=crop&q=80',
    'Connecting ambitious students and founders with the exact developer, designer, and marketer talent they need.',
    'FoundrLink eliminates the friction of finding co-founders. Instead of relying on random WhatsApp groups and cold LinkedIn DMs, builders showcase their ideas and connect with verified talent based on matching skills, availability, and vision.',
    'People have ideas and people have skills, but there is no focused platform connecting the two for startup collaboration.',
    'A dedicated matching hub where founders post project needs and skilled builders find equity projects with transparent skill compatibility.',
    3, 'C#, React, SQL, Product Design, Growth Marketing', 'Bengaluru, India', 'https://foundrlink.ripaldesign.studio', 'Full-time / Equity', 2024, 1500000, 3000000, 25000, 'Published');
END
GO

-- 5. OpenPositions Seed
DECLARE @SNeuro INT = (SELECT TOP 1 StartupId FROM dbo.Startups WHERE Name = 'NeuroSync');
DECLARE @SEco INT = (SELECT TOP 1 StartupId FROM dbo.Startups WHERE Name = 'EcoTrack');
DECLARE @SFoundr INT = (SELECT TOP 1 StartupId FROM dbo.Startups WHERE Name = 'FoundrLink');

IF @SNeuro IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.OpenPositions WHERE StartupId = @SNeuro)
BEGIN
    INSERT INTO dbo.OpenPositions (StartupId, Title, Location, PositionType)
    VALUES (@SNeuro, 'Lead AI / ML Engineer (Co-Founder)', 'Remote', 'Full-time / Equity'),
           (@SNeuro, 'Product Designer (Figma & Design Systems)', 'Remote', 'Part-time / Equity');
END

IF @SEco IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.OpenPositions WHERE StartupId = @SEco)
BEGIN
    INSERT INTO dbo.OpenPositions (StartupId, Title, Location, PositionType)
    VALUES (@SEco, 'IoT Hardware Integration Specialist', 'Bengaluru, India', 'Part-time / Equity'),
           (@SEco, 'CleanTech Growth Lead', 'Remote', 'Full-time / Equity');
END

IF @SFoundr IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.OpenPositions WHERE StartupId = @SFoundr)
BEGIN
    INSERT INTO dbo.OpenPositions (StartupId, Title, Location, PositionType)
    VALUES (@SFoundr, 'Frontend React Architect', 'Remote / Bengaluru', 'Full-time / Equity'),
           (@SFoundr, 'Growth & Campus Ambassador Lead', 'Remote / Hybrid', 'Part-time / Equity');
END
GO

-- 6. TeamMembers Seed
DECLARE @SNeuro INT = (SELECT TOP 1 StartupId FROM dbo.Startups WHERE Name = 'NeuroSync');
DECLARE @SFoundr INT = (SELECT TOP 1 StartupId FROM dbo.Startups WHERE Name = 'FoundrLink');
DECLARE @UYash INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'yash@ripaldesign.studio');
DECLARE @UShreya INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'shreya@ripaldesign.studio');
DECLARE @UChirag INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'chirag@ripaldesign.studio');

IF @SNeuro IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TeamMembers WHERE StartupId = @SNeuro)
BEGIN
    INSERT INTO dbo.TeamMembers (StartupId, UserId, Name, Role, AvatarUrl)
    VALUES (@SNeuro, @UYash, 'Yash Vinchhi', 'Founder & CEO', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80'),
           (@SNeuro, @UShreya, 'Shreya Joshi', 'Co-Founder & AI Lead', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80');
END

IF @SFoundr IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TeamMembers WHERE StartupId = @SFoundr)
BEGIN
    INSERT INTO dbo.TeamMembers (StartupId, UserId, Name, Role, AvatarUrl)
    VALUES (@SFoundr, @UChirag, 'Chirag K F', 'Founder & Lead Builder', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80');
END
GO

-- 7. StartupUpdates Seed
DECLARE @SNeuro INT = (SELECT TOP 1 StartupId FROM dbo.Startups WHERE Name = 'NeuroSync');
DECLARE @SFoundr INT = (SELECT TOP 1 StartupId FROM dbo.Startups WHERE Name = 'FoundrLink');

IF @SNeuro IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.StartupUpdates WHERE StartupId = @SNeuro)
BEGIN
    INSERT INTO dbo.StartupUpdates (StartupId, AuthorName, Content)
    VALUES (@SNeuro, 'Yash Vinchhi', 'Completed private Beta release with 5 enterprise pilot partners across logistics and SaaS.'),
           (@SNeuro, 'Shreya Joshi', 'Integrated proprietary vector embeddings pipeline reducing query latency by 45%.');
END

IF @SFoundr IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.StartupUpdates WHERE StartupId = @SFoundr)
BEGIN
    INSERT INTO dbo.StartupUpdates (StartupId, AuthorName, Content)
    VALUES (@SFoundr, 'Chirag K F', 'Surpassed 500 verified student co-founder applications across top university tech hubs!');
END
GO

-- 8. ConnectionGrowth & ActivityLogs Seed
DECLARE @UCofounder INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio');
DECLARE @UFounder INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio');

IF @UCofounder IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ConnectionGrowth WHERE UserId = @UCofounder)
BEGIN
    INSERT INTO dbo.ConnectionGrowth (UserId, MonthLabel, MonthOrder, CountValue)
    VALUES (@UCofounder, 'Jan', 1, 12),
           (@UCofounder, 'Feb', 2, 28),
           (@UCofounder, 'Mar', 3, 45),
           (@UCofounder, 'Apr', 4, 82),
           (@UCofounder, 'May', 5, 124),
           (@UCofounder, 'Jun', 6, 189);
END

IF @UFounder IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ConnectionGrowth WHERE UserId = @UFounder)
BEGIN
    INSERT INTO dbo.ConnectionGrowth (UserId, MonthLabel, MonthOrder, CountValue)
    VALUES (@UFounder, 'Jan', 1, 20),
           (@UFounder, 'Feb', 2, 48),
           (@UFounder, 'Mar', 3, 95),
           (@UFounder, 'Apr', 4, 160),
           (@UFounder, 'May', 5, 245),
           (@UFounder, 'Jun', 6, 342);
END

IF @UCofounder IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ActivityLogs WHERE UserId = @UCofounder)
BEGIN
    INSERT INTO dbo.ActivityLogs (UserId, ActivityText, ActivityType, TimeAgo)
    VALUES (@UCofounder, 'Connected with Shreya Joshi (AI Architect)', 'Connection', '10 mins ago'),
           (@UCofounder, 'Applied to join NeuroSync as Backend Lead', 'Application', '2 hours ago'),
           (@UCofounder, 'Updated skills profile with React & TypeScript', 'Profile', '1 day ago');
END
GO

-- 9. Conversations & Messages Seed
DECLARE @UFounder INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio');
DECLARE @UCofounder INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio');
DECLARE @UAnanya INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'ananya@ripaldesign.studio');

IF @UFounder IS NOT NULL AND @UCofounder IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Conversations WHERE (User1Id = @UFounder AND User2Id = @UCofounder) OR (User1Id = @UCofounder AND User2Id = @UFounder))
BEGIN
    INSERT INTO dbo.Conversations (User1Id, User2Id, LastMessageAt)
    VALUES (@UFounder, @UCofounder, SYSUTCDATETIME());

    DECLARE @ConvId INT = SCOPE_IDENTITY();

    INSERT INTO dbo.Messages (ConversationId, SenderId, ReceiverId, Content, IsRead, SentAt)
    VALUES (@ConvId, @UCofounder, @UFounder, 'Hi! I saw your listing for NeuroSync. I have deep experience in distributed systems and React.', 1, DATEADD(hour, -2, SYSUTCDATETIME())),
           (@ConvId, @UFounder, @UCofounder, 'Hey! Thanks for reaching out. We are currently scaling our agent orchestration layer. Would love to hop on a sync call.', 0, DATEADD(minute, -30, SYSUTCDATETIME()));
END
GO

-- 10. Notifications Seed
DECLARE @UFounder INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio');
DECLARE @UCofounder INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio');

IF @UFounder IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Notifications WHERE UserId = @UFounder)
BEGIN
    INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, IsRead)
    VALUES (@UFounder, 'New Connection Request', 'Ananya Iyer (Marketing Lead) sent you a connection request.', 'Requests', 1, 0),
           (@UFounder, 'High Match Candidate Found', 'Technical Co-Founder has a 94% skill match with NeuroSync open positions.', 'Matches', 0, 0),
           (@UFounder, 'Welcome to FoundrLink', 'Your startup NeuroSync has been successfully published to the discovery feed.', 'System', 0, 1);
END

IF @UCofounder IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Notifications WHERE UserId = @UCofounder)
BEGIN
    INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, IsRead)
    VALUES (@UCofounder, 'Application Viewed', 'Startup Founder viewed your profile for the Backend Lead position.', 'Activity', 0, 0),
           (@UCofounder, 'New Opportunity Match', 'FoundrLink is actively looking for React & C# builders.', 'Matches', 0, 0);
END
GO

-- 11. ModerationReports Seed (For Admin Console)
IF NOT EXISTS (SELECT 1 FROM dbo.ModerationReports WHERE ReportCode = 'TKT-1042')
BEGIN
    INSERT INTO dbo.ModerationReports (ReportCode, ReporterEmail, ReportedItem, ReportType, Priority, Details, Status, CreatedAt)
    VALUES ('TKT-1042', 'investor@ripaldesign.studio', 'Listing: CryptoAI Scam Project', 'Content Violation', 'High', 'Project claims false university affiliations and unrealistic guaranteed returns.', 'Pending', SYSUTCDATETIME()),
           ('TKT-1088', 'cofounder@ripaldesign.studio', 'User: Spammer Profile', 'Spam', 'Medium', 'Repeated unsolicited sales pitches in direct messages.', 'Pending', SYSUTCDATETIME()),
           ('TKT-0950', 'founder@ripaldesign.studio', 'Account Verification Request', 'Suspicious Activity', 'Low', 'Requested manual identity badge verification for campus demo.', 'Resolved', DATEADD(day, -2, SYSUTCDATETIME()));
END
GO
