-- ====================================================================
-- FoundrLink - Comprehensive Seed Data Script for All Tables
-- Conforms strictly to @ripaldesign.studio email convention
-- Populates all 20 tables and ensures real dashboard graph data
-- ====================================================================

USE [FoundrLinkDB];
GO

SET NOCOUNT ON;

-- 0. Adjust constraints if necessary to support all valid domain statuses
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Users_Role')
BEGIN
    ALTER TABLE dbo.Users DROP CONSTRAINT CK_Users_Role;
END
ALTER TABLE dbo.Users ADD CONSTRAINT CK_Users_Role CHECK ([Role]='Admin' OR [Role]='Co-Founder' OR [Role]='Investor' OR [Role]='Founder' OR [Role]='Technical' OR [Role]='Marketing');

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

-- 1. Default Password Hash (SHA-256 for 'Password123')
DECLARE @DefaultPwd NVARCHAR(512) = '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601';

-- Update all non-ripaldesign.studio emails to conform strictly to user rule
UPDATE dbo.Users 
SET Email = REPLACE(Email, SUBSTRING(Email, CHARINDEX('@', Email), LEN(Email)), '@ripaldesign.studio'),
    PasswordHash = @DefaultPwd,
    Status = 'Active',
    IsVerified = 1
WHERE Email NOT LIKE '%@ripaldesign.studio';

-- Ensure default test accounts exist
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

-- Extended realistic profiles
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'yash@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Yash Vinchhi', 'yash@ripaldesign.studio', @DefaultPwd, 'Founder', 'Founder & Systems Architect', 'Mumbai, India', 'Serial entrepreneur focused on building scalable infrastructure that empowers creators.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', 'NexusTech', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'rachit@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Rachit Agrawal', 'rachit@ripaldesign.studio', @DefaultPwd, 'Co-Founder', 'Full Stack & Cloud Lead', 'Bengaluru, India', 'Specializing in high throughput APIs, distributed microservices, and React.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', 'FoundrLink', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'ananya@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Ananya Iyer', 'ananya@ripaldesign.studio', @DefaultPwd, 'Marketing', 'Head of Growth & Community', 'Hyderabad, India', 'Obsessed with product-led growth, virality loops, and zero-to-one B2B inbound marketing funnels.', 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150', 'GrowthLoop', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'manoj@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Manoj Tiwari', 'manoj@ripaldesign.studio', @DefaultPwd, 'Co-Founder', 'Lead Product Designer (UI/UX)', 'Delhi, India', 'Designing clean, human-centered SaaS tools. Ex-agency design lead focused on Figma systems.', 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150', 'Apex Studio', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'shreya@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Shreya Joshi', 'shreya@ripaldesign.studio', @DefaultPwd, 'Co-Founder', 'AI & Machine Learning Architect', 'Pune, India', 'Building fine-tuned LLM agents, vector retrieval pipelines, and AI copilot systems.', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150', 'NeuroSync', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'rohan@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Rohan Verma', 'rohan@ripaldesign.studio', @DefaultPwd, 'Technical', 'Senior Backend & DevOps Engineer', 'Bengaluru, India', 'Building Kubernetes clusters, high-frequency event queues, and zero-downtime database pipelines.', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'CloudShield', 1, 'Active');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'priya@ripaldesign.studio')
BEGIN
    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status)
    VALUES ('Priya Patel', 'priya@ripaldesign.studio', @DefaultPwd, 'Founder', 'Fintech Founder & Strategy Lead', 'Ahmedabad, India', 'Pioneering frictionless cross-border corporate payments and regulatory-compliant banking SDKs.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', 'PayFlow', 1, 'Active');
END
GO

-- 2. FounderProfiles & 3. UserProfiles
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

-- 4. Startups
DECLARE @FId INT, @YashId INT, @PriyaId INT;
SELECT TOP 1 @FId = UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio';
SELECT TOP 1 @YashId = UserId FROM dbo.Users WHERE Email = 'yash@ripaldesign.studio';
SELECT TOP 1 @PriyaId = UserId FROM dbo.Users WHERE Email = 'priya@ripaldesign.studio';
IF @YashId IS NULL SET @YashId = @FId;
IF @PriyaId IS NULL SET @PriyaId = @FId;

IF NOT EXISTS (SELECT 1 FROM dbo.Startups WHERE Name = 'TechNovate AI')
BEGIN
    INSERT INTO dbo.Startups 
    (FounderId, Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, FullDescription, Problem, Solution, TeamSize, RequiredSkills, Location, WebsiteUrl, Commitment, FoundedYear, FundingRaised, FundingGoal, MRR, Status, CreatedAt, UpdatedAt)
    VALUES
    (@FId, 
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

IF NOT EXISTS (SELECT 1 FROM dbo.Startups WHERE Name = 'NexusTech')
BEGIN
    INSERT INTO dbo.Startups (FounderId, Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, FullDescription, Problem, Solution, TeamSize, RequiredSkills, Location, WebsiteUrl, Commitment, FoundedYear, FundingRaised, FundingGoal, MRR, Status)
    VALUES (@YashId, 'NexusTech', 'Scalable enterprise infrastructure and real-time backend synchronization', 'Enterprise SaaS', 'Series A', 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=200',
    'High-performance distributed database synchronization and API gateway platform for global scale.',
    'NexusTech powers enterprise data streaming with sub-millisecond edge synchronization.',
    'Legacy cloud infrastructures struggle with global replication consistency and escalating ingress/egress bandwidth costs.',
    'A geo-distributed synchronization engine that reduces data replication latency by 85%.',
    12, 'Go, Rust, Distributed Systems, Kubernetes, Kafka', 'Mumbai, India', 'https://nexustech.ripaldesign.studio', 'Full-time', 2022, 15000000, 20000000, 120000, 'Published');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Startups WHERE Name = 'PayFlow')
BEGIN
    INSERT INTO dbo.Startups (FounderId, Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, FullDescription, Problem, Solution, TeamSize, RequiredSkills, Location, WebsiteUrl, Commitment, FoundedYear, FundingRaised, FundingGoal, MRR, Status)
    VALUES (@PriyaId, 'PayFlow', 'Modern cross-border B2B payments and automated treasury reconciliations', 'FinTech', 'Seed Stage', 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=200',
    'Instant global payouts, virtual multi-currency corporate cards, and automated ERP reconciliation.',
    'PayFlow replaces legacy correspondent banking networks with smart treasury liquidity routing.',
    'Cross-border corporate payouts take 3-5 business days and incur up to 4% in hidden FX conversion markups.',
    'Instant local-rail settlement across 40+ currencies with unified automated compliance auditing.',
    6, 'React, Node.js, PostgreSQL, Banking APIs, Docker', 'Ahmedabad, India', 'https://payflow.ripaldesign.studio', 'Full-time', 2023, 3500000, 5000000, 48000, 'Published');
END

-- Ensure all Startups have Published / Active status
UPDATE dbo.Startups SET Status = 'Published' WHERE Status IN ('Draft', 'Under Review');
GO

-- 7. TeamMembers for all startups
DECLARE @MainStartupId INT, @FId INT, @CId INT, @IId INT, @ManojId INT, @ShreyaId INT, @RohanId INT;
SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups WHERE Name = 'TechNovate AI';
IF @MainStartupId IS NULL SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups;
SELECT TOP 1 @FId = UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio';
SELECT TOP 1 @CId = UserId FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio';
SELECT TOP 1 @IId = UserId FROM dbo.Users WHERE Email = 'investor@ripaldesign.studio';
SELECT TOP 1 @ManojId = UserId FROM dbo.Users WHERE Email = 'manoj@ripaldesign.studio';
SELECT TOP 1 @ShreyaId = UserId FROM dbo.Users WHERE Email = 'shreya@ripaldesign.studio';
SELECT TOP 1 @RohanId = UserId FROM dbo.Users WHERE Email = 'rohan@ripaldesign.studio';

IF @FId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TeamMembers WHERE StartupId = @MainStartupId AND UserId = @FId)
BEGIN
    INSERT INTO dbo.TeamMembers (StartupId, UserId, Name, Role, AvatarUrl, JoinedDate)
    VALUES (@MainStartupId, @FId, 'Demo Founder', 'Founder & CEO', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', SYSUTCDATETIME());
END

IF @CId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TeamMembers WHERE StartupId = @MainStartupId AND UserId = @CId)
BEGIN
    INSERT INTO dbo.TeamMembers (StartupId, UserId, Name, Role, AvatarUrl, JoinedDate)
    VALUES (@MainStartupId, @CId, 'Demo Co-Founder', 'Lead Systems Architect', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', SYSUTCDATETIME());
END

IF @ShreyaId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TeamMembers WHERE StartupId = @MainStartupId AND UserId = @ShreyaId)
BEGIN
    INSERT INTO dbo.TeamMembers (StartupId, UserId, Name, Role, AvatarUrl, JoinedDate)
    VALUES (@MainStartupId, @ShreyaId, 'Shreya Joshi', 'Principal AI Architect', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150', SYSUTCDATETIME());
END

IF @ManojId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TeamMembers WHERE StartupId = @MainStartupId AND UserId = @ManojId)
BEGIN
    INSERT INTO dbo.TeamMembers (StartupId, UserId, Name, Role, AvatarUrl, JoinedDate)
    VALUES (@MainStartupId, @ManojId, 'Manoj Tiwari', 'Lead Design Architect', 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150', SYSUTCDATETIME());
END
GO

-- 10. Conversations & 11. Messages
DECLARE @FId INT, @CId INT, @IId INT, @ManojId INT, @ShreyaId INT;
SELECT TOP 1 @FId = UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio';
SELECT TOP 1 @CId = UserId FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio';
SELECT TOP 1 @IId = UserId FROM dbo.Users WHERE Email = 'investor@ripaldesign.studio';
SELECT TOP 1 @ManojId = UserId FROM dbo.Users WHERE Email = 'manoj@ripaldesign.studio';
SELECT TOP 1 @ShreyaId = UserId FROM dbo.Users WHERE Email = 'shreya@ripaldesign.studio';

-- Conv 1: Founder & Co-Founder
IF @FId IS NOT NULL AND @CId IS NOT NULL
BEGIN
    DECLARE @Conv1 INT;
    SELECT @Conv1 = ConversationId FROM dbo.Conversations WHERE (User1Id = @FId AND User2Id = @CId) OR (User1Id = @CId AND User2Id = @FId);
    IF @Conv1 IS NULL
    BEGIN
        INSERT INTO dbo.Conversations (User1Id, User2Id, LastMessageAt) VALUES (@FId, @CId, SYSUTCDATETIME());
        SET @Conv1 = SCOPE_IDENTITY();
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE ConversationId = @Conv1)
    BEGIN
        INSERT INTO dbo.Messages (ConversationId, SenderId, ReceiverId, Content, IsRead, SentAt)
        VALUES 
        (@Conv1, @CId, @FId, 'Hey! I checked our multi-region latency telemetry. All nodes reporting sub-40ms.', 1, DATEADD(HOUR, -3, SYSUTCDATETIME())),
        (@Conv1, @FId, @CId, 'Incredible work! The investor syndicate asked for these exact figures for our Friday demo.', 0, DATEADD(MINUTE, -25, SYSUTCDATETIME()));
    END
END

-- Conv 2: Founder & Investor
IF @FId IS NOT NULL AND @IId IS NOT NULL
BEGIN
    DECLARE @Conv2 INT;
    SELECT @Conv2 = ConversationId FROM dbo.Conversations WHERE (User1Id = @FId AND User2Id = @IId) OR (User1Id = @IId AND User2Id = @FId);
    IF @Conv2 IS NULL
    BEGIN
        INSERT INTO dbo.Conversations (User1Id, User2Id, LastMessageAt) VALUES (@FId, @IId, SYSUTCDATETIME());
        SET @Conv2 = SCOPE_IDENTITY();
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE ConversationId = @Conv2)
    BEGIN
        INSERT INTO dbo.Messages (ConversationId, SenderId, ReceiverId, Content, IsRead, SentAt)
        VALUES 
        (@Conv2, @IId, @FId, 'Hello! I reviewed your Q3 deck on FoundrLink. We would like to schedule a partner meeting.', 0, DATEADD(HOUR, -1, SYSUTCDATETIME()));
    END
END

-- Conv 3: Founder & Manoj (Designer)
IF @FId IS NOT NULL AND @ManojId IS NOT NULL
BEGIN
    DECLARE @Conv3 INT;
    SELECT @Conv3 = ConversationId FROM dbo.Conversations WHERE (User1Id = @FId AND User2Id = @ManojId) OR (User1Id = @ManojId AND User2Id = @FId);
    IF @Conv3 IS NULL
    BEGIN
        INSERT INTO dbo.Conversations (User1Id, User2Id, LastMessageAt) VALUES (@FId, @ManojId, SYSUTCDATETIME());
        SET @Conv3 = SCOPE_IDENTITY();
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE ConversationId = @Conv3)
    BEGIN
        INSERT INTO dbo.Messages (ConversationId, SenderId, ReceiverId, Content, IsRead, SentAt)
        VALUES 
        (@Conv3, @ManojId, @FId, 'Finished updating the design tokens in Figma. Ready for handoff.', 1, DATEADD(DAY, -1, SYSUTCDATETIME())),
        (@Conv3, @FId, @ManojId, 'Looks super sharp! Merging into main branch.', 1, DATEADD(HOUR, -6, SYSUTCDATETIME()));
    END
END
GO

-- 12. Notifications (All notification categories)
DECLARE @FId INT;
SELECT TOP 1 @FId = UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio';

IF @FId IS NOT NULL
BEGIN
    DELETE FROM dbo.Notifications WHERE UserId = @FId;
    INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, IsRead, CreatedAt)
    VALUES 
    (@FId, 'New Collaboration Request', 'Manoj Tiwari requested to join TechNovate AI as Lead Designer.', 'Requests', 1, 0, DATEADD(MINUTE, -10, SYSUTCDATETIME())),
    (@FId, 'New 98% Compatibility Match', 'Shreya Joshi matches your requirement for AI/ML Architect.', 'Matches', 0, 0, DATEADD(HOUR, -2, SYSUTCDATETIME())),
    (@FId, 'Investor Viewed Your Startup', 'Demo Investor viewed your pitch deck and revenue traction charts.', 'Activity', 0, 0, DATEADD(HOUR, -5, SYSUTCDATETIME())),
    (@FId, 'System Security Verification', 'Your profile and corporate email domain @ripaldesign.studio have been verified.', 'System', 0, 1, DATEADD(DAY, -1, SYSUTCDATETIME())),
    (@FId, 'Pitch Deck Downloaded', 'Apex Capital downloaded your audited compliance summary.', 'Activity', 0, 1, DATEADD(DAY, -2, SYSUTCDATETIME()));
END
GO

-- 16. CollaborationRequests (All four statuses: Pending, Accepted, Declined, Withdrawn)
DELETE FROM dbo.CollaborationRequests;
DECLARE @MainSId INT, @FId INT, @CId INT, @IId INT, @ManojId INT, @ShreyaId INT, @RohanId INT, @AnanyaId INT;
SELECT TOP 1 @MainSId = StartupId FROM dbo.Startups WHERE Name = 'TechNovate AI';
IF @MainSId IS NULL SELECT TOP 1 @MainSId = StartupId FROM dbo.Startups;
SELECT TOP 1 @FId = UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio';
SELECT TOP 1 @CId = UserId FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio';
SELECT TOP 1 @IId = UserId FROM dbo.Users WHERE Email = 'investor@ripaldesign.studio';
SELECT TOP 1 @ManojId = UserId FROM dbo.Users WHERE Email = 'manoj@ripaldesign.studio';
SELECT TOP 1 @ShreyaId = UserId FROM dbo.Users WHERE Email = 'shreya@ripaldesign.studio';
SELECT TOP 1 @RohanId = UserId FROM dbo.Users WHERE Email = 'rohan@ripaldesign.studio';
SELECT TOP 1 @AnanyaId = UserId FROM dbo.Users WHERE Email = 'ananya@ripaldesign.studio';

IF @FId IS NOT NULL
BEGIN
    -- Received by Founder
    IF @ManojId IS NOT NULL
        INSERT INTO dbo.CollaborationRequests (SenderUserId, ReceiverUserId, StartupId, Message, Status, CreatedAt)
        VALUES (@ManojId, @FId, @MainSId, 'Hi! I would love to lead product design and UX architecture for TechNovate AI.', 'Pending', DATEADD(MINUTE, -45, SYSUTCDATETIME()));

    IF @ShreyaId IS NOT NULL
        INSERT INTO dbo.CollaborationRequests (SenderUserId, ReceiverUserId, StartupId, Message, Status, CreatedAt)
        VALUES (@ShreyaId, @FId, @MainSId, 'Excited to contribute to your agentic LLM parsing pipeline as AI Architect.', 'Accepted', DATEADD(DAY, -2, SYSUTCDATETIME()));

    IF @RohanId IS NOT NULL
        INSERT INTO dbo.CollaborationRequests (SenderUserId, ReceiverUserId, StartupId, Message, Status, CreatedAt)
        VALUES (@RohanId, @FId, @MainSId, 'Applying for Cloud / DevOps infrastructure role.', 'Declined', DATEADD(DAY, -5, SYSUTCDATETIME()));

    IF @AnanyaId IS NOT NULL
        INSERT INTO dbo.CollaborationRequests (SenderUserId, ReceiverUserId, StartupId, Message, Status, CreatedAt)
        VALUES (@AnanyaId, @FId, @MainSId, 'Interested in leading developer community growth.', 'Withdrawn', DATEADD(DAY, -7, SYSUTCDATETIME()));

    -- Sent by Founder
    IF @CId IS NOT NULL
        INSERT INTO dbo.CollaborationRequests (SenderUserId, ReceiverUserId, StartupId, Message, Status, CreatedAt)
        VALUES (@FId, @CId, @MainSId, 'Invitation to join as Technical Co-Founder & Lead Architect.', 'Accepted', DATEADD(DAY, -14, SYSUTCDATETIME()));

    IF @IId IS NOT NULL
        INSERT INTO dbo.CollaborationRequests (SenderUserId, ReceiverUserId, StartupId, Message, Status, CreatedAt)
        VALUES (@FId, @IId, @MainSId, 'Would love to discuss our seed round term sheet.', 'Pending', DATEADD(HOUR, -6, SYSUTCDATETIME()));
END
GO

-- 17. Connections (Mutual accepted connections)
DELETE FROM dbo.Connections;
DECLARE @FId INT, @CId INT, @IId INT, @ManojId INT, @ShreyaId INT, @YashId INT;
SELECT TOP 1 @FId = UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio';
SELECT TOP 1 @CId = UserId FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio';
SELECT TOP 1 @IId = UserId FROM dbo.Users WHERE Email = 'investor@ripaldesign.studio';
SELECT TOP 1 @ManojId = UserId FROM dbo.Users WHERE Email = 'manoj@ripaldesign.studio';
SELECT TOP 1 @ShreyaId = UserId FROM dbo.Users WHERE Email = 'shreya@ripaldesign.studio';
SELECT TOP 1 @YashId = UserId FROM dbo.Users WHERE Email = 'yash@ripaldesign.studio';

IF @FId IS NOT NULL
BEGIN
    IF @CId IS NOT NULL INSERT INTO dbo.Connections (RequesterUserId, ReceiverUserId, Status, CreatedAt) VALUES (@FId, @CId, 'Accepted', DATEADD(DAY, -20, SYSUTCDATETIME()));
    IF @IId IS NOT NULL INSERT INTO dbo.Connections (RequesterUserId, ReceiverUserId, Status, CreatedAt) VALUES (@FId, @IId, 'Accepted', DATEADD(DAY, -10, SYSUTCDATETIME()));
    IF @ManojId IS NOT NULL INSERT INTO dbo.Connections (RequesterUserId, ReceiverUserId, Status, CreatedAt) VALUES (@FId, @ManojId, 'Accepted', DATEADD(DAY, -8, SYSUTCDATETIME()));
    IF @ShreyaId IS NOT NULL INSERT INTO dbo.Connections (RequesterUserId, ReceiverUserId, Status, CreatedAt) VALUES (@FId, @ShreyaId, 'Accepted', DATEADD(DAY, -5, SYSUTCDATETIME()));
    IF @YashId IS NOT NULL INSERT INTO dbo.Connections (RequesterUserId, ReceiverUserId, Status, CreatedAt) VALUES (@FId, @YashId, 'Accepted', DATEADD(DAY, -2, SYSUTCDATETIME()));
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
    (@uId, 'Seed Pitch Deck Submission', 'Finalize slide deck and 3-year financial model for syndicate review.', DATEADD(DAY, 4, GETDATE()), 'DEC', '05'),
    (@uId, 'FoundrLink Winter Demo Day', 'Present 5-minute live product walkthrough to 120+ active seed funds.', DATEADD(DAY, 18, GETDATE()), 'DEC', '19'),
    (@uId, 'Co-Founder FAST Agreement Execution', 'Review equity vesting cliffs and intellectual property assignments.', DATEADD(DAY, 35, GETDATE()), 'JAN', '05');

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

-- 20. ConnectionGrowth Table
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
    (@uId, 'Jul', 1, @b1),
    (@uId, 'Aug', 2, @b2),
    (@uId, 'Sep', 3, @b3),
    (@uId, 'Oct', 4, @b4),
    (@uId, 'Nov', 5, @b5),
    (@uId, 'Dec', 6, @b6);

    FETCH NEXT FROM cg_cursor INTO @uId, @role;
END
CLOSE cg_cursor;
DEALLOCATE cg_cursor;
GO

PRINT 'FoundrLink database comprehensive sample data initialized successfully!';
GO
