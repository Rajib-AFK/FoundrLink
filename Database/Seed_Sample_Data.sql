-- ====================================================================
-- FoundrLink - Comprehensive Seed Data Script for All Tables
-- Conforms strictly to @ripaldesign.studio email convention
-- Populates all 20 tables and ensures real dashboard graph data
-- ====================================================================

USE [FoundrLinkDB];
GO

SET NOCOUNT ON;

-- 0. Adjust constraints if necessary to support all valid domain statuses
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

-- Update individual emails to prevent unique key conflicts
UPDATE dbo.Users SET Email = 'admin.platform@ripaldesign.studio' WHERE Email = 'admin@foundrlink.com';

-- Update all remaining external emails to @ripaldesign.studio
UPDATE dbo.Users 
SET Email = REPLACE(Email, SUBSTRING(Email, CHARINDEX('@', Email), LEN(Email)), '@ripaldesign.studio'),
    PasswordHash = @DefaultPwd,
    Status = 'Active',
    IsVerified = 1
WHERE Email NOT LIKE '%@ripaldesign.studio';

-- Ensure default system accounts exist
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
GO

-- 2. FounderProfiles
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
    FETCH NEXT FROM user_cursor INTO @uId;
END
CLOSE user_cursor;
DEALLOCATE user_cursor;
GO

-- 3. UserProfiles
DECLARE @uId INT;
DECLARE up_cursor CURSOR FOR SELECT UserId FROM dbo.Users;
OPEN up_cursor;
FETCH NEXT FROM up_cursor INTO @uId;

WHILE @@FETCH_STATUS = 0
BEGIN
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
    FETCH NEXT FROM up_cursor INTO @uId;
END
CLOSE up_cursor;
DEALLOCATE up_cursor;
GO

-- 4. Startups Table
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

-- Ensure diverse statuses for Admin Dashboard KPI and ExploreStartups
UPDATE dbo.Startups SET Status = 'Published' WHERE StartupId IN (SELECT TOP 4 StartupId FROM dbo.Startups);
UPDATE dbo.Startups SET Status = 'Active' WHERE StartupId IN (SELECT TOP 3 StartupId FROM dbo.Startups WHERE Status != 'Published');
GO

-- 5. OpenPositions
DECLARE @MainStartupId INT;
SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups WHERE Name = 'TechNovate AI';
IF @MainStartupId IS NULL SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups ORDER BY StartupId ASC;

IF NOT EXISTS (SELECT 1 FROM dbo.OpenPositions WHERE StartupId = @MainStartupId AND Title = 'Senior Full-Stack Architect')
BEGIN
    INSERT INTO dbo.OpenPositions (StartupId, Title, Location, PositionType, CreatedAt)
    VALUES 
    (@MainStartupId, 'Senior Full-Stack Architect', 'Remote (India)', 'Full-time', SYSUTCDATETIME()),
    (@MainStartupId, 'Lead Machine Learning Engineer', 'Bengaluru, India', 'Full-time', SYSUTCDATETIME()),
    (@MainStartupId, 'Product Designer (UI/UX)', 'Remote', 'Part-time / Equity', SYSUTCDATETIME());
END
GO

-- 6. StartupOpenRoles
DECLARE @MainStartupId INT;
SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups WHERE Name = 'TechNovate AI';
IF @MainStartupId IS NULL SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups ORDER BY StartupId ASC;

IF NOT EXISTS (SELECT 1 FROM dbo.StartupOpenRoles WHERE StartupId = @MainStartupId)
BEGIN
    INSERT INTO dbo.StartupOpenRoles (StartupId, RoleTitle, Location, EmploymentType, Description, CreatedAt)
    VALUES 
    (@MainStartupId, 'Principal Infrastructure Engineer', 'Bengaluru, India', 'Full-time', 'Scale Kubernetes clusters and distributed streaming pipelines.', GETDATE()),
    (@MainStartupId, 'Developer Advocate & Growth Lead', 'Remote', 'Full-time', 'Lead developer community engagement and technical documentation.', GETDATE()),
    (@MainStartupId, 'Frontend Engineer (React)', 'Remote', 'Part-time', 'Build snappy, intuitive developer interfaces and telemetry dashboards.', GETDATE());
END
GO

-- 7. TeamMembers
DECLARE @MainStartupId INT;
DECLARE @FounderId INT;
DECLARE @CoFounderId INT;

SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups WHERE Name = 'TechNovate AI';
IF @MainStartupId IS NULL SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups ORDER BY StartupId ASC;

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

-- Ensure active users belong to at least 1-2 teams so Dashboard 'Teams Joined' counter > 0
DECLARE @uId INT;
DECLARE team_cursor CURSOR FOR SELECT UserId FROM dbo.Users WHERE Role != 'Admin';
OPEN team_cursor;
FETCH NEXT FROM team_cursor INTO @uId;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.TeamMembers WHERE UserId = @uId)
    BEGIN
        DECLARE @sId INT;
        SELECT TOP 1 @sId = StartupId FROM dbo.Startups ORDER BY NEWID();
        INSERT INTO dbo.TeamMembers (StartupId, UserId, Name, Role, AvatarUrl, JoinedDate)
        SELECT @sId, @uId, FullName, 'Core Technical Advisor', AvatarUrl, SYSUTCDATETIME()
        FROM dbo.Users WHERE UserId = @uId;
    END
    FETCH NEXT FROM team_cursor INTO @uId;
END
CLOSE team_cursor;
DEALLOCATE team_cursor;
GO

-- 8. StartupMembers
DECLARE @MainStartupId INT;
SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups WHERE Name = 'TechNovate AI';
IF @MainStartupId IS NULL SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups ORDER BY StartupId ASC;

IF NOT EXISTS (SELECT 1 FROM dbo.StartupMembers WHERE StartupId = @MainStartupId)
BEGIN
    INSERT INTO dbo.StartupMembers (StartupId, UserId, MemberName, RoleTitle, AvatarUrl, JoinedDate)
    SELECT TOP 3 @MainStartupId, UserId, FullName, 'Founding Engineer', AvatarUrl, GETDATE()
    FROM dbo.Users WHERE Role != 'Admin';
END
GO

-- 9. StartupUpdates
DECLARE @MainStartupId INT;
SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups WHERE Name = 'TechNovate AI';
IF @MainStartupId IS NULL SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups ORDER BY StartupId ASC;

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

IF @FId IS NOT NULL AND @IId IS NOT NULL
BEGIN
    DECLARE @ConvId2 INT;
    SELECT @ConvId2 = ConversationId FROM dbo.Conversations WHERE (User1Id = @FId AND User2Id = @IId) OR (User1Id = @IId AND User2Id = @FId);
    IF @ConvId2 IS NULL
    BEGIN
        INSERT INTO dbo.Conversations (User1Id, User2Id, LastMessageAt) VALUES (@IId, @FId, SYSUTCDATETIME());
        SET @ConvId2 = SCOPE_IDENTITY();
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE ConversationId = @ConvId2)
    BEGIN
        INSERT INTO dbo.Messages (ConversationId, SenderId, ReceiverId, Content, IsRead, SentAt)
        VALUES 
        (@ConvId2, @IId, @FId, 'Hi Demo Founder, we are very excited about your progress with TechNovate. When can we review the cap table?', 0, DATEADD(HOUR, -3, SYSUTCDATETIME()));
    END
END

-- Ensure every user has at least 2 received messages so 'Active Messages' counter > 0
DECLARE @uId INT;
DECLARE msg_cursor CURSOR FOR SELECT UserId FROM dbo.Users WHERE Role != 'Admin';
OPEN msg_cursor;
FETCH NEXT FROM msg_cursor INTO @uId;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE ReceiverId = @uId)
    BEGIN
        DECLARE @PartnerId INT;
        SELECT TOP 1 @PartnerId = UserId FROM dbo.Users WHERE UserId != @uId;
        IF @PartnerId IS NOT NULL
        BEGIN
            DECLARE @conv INT;
            SELECT @conv = ConversationId FROM dbo.Conversations WHERE (User1Id = @uId AND User2Id = @PartnerId) OR (User1Id = @PartnerId AND User2Id = @uId);
            IF @conv IS NULL
            BEGIN
                INSERT INTO dbo.Conversations (User1Id, User2Id, LastMessageAt) VALUES (@PartnerId, @uId, SYSUTCDATETIME());
                SET @conv = SCOPE_IDENTITY();
            END
            INSERT INTO dbo.Messages (ConversationId, SenderId, ReceiverId, Content, IsRead, SentAt)
            VALUES (@conv, @PartnerId, @uId, 'Hello! I checked out your profile on FoundrLink and would love to connect.', 0, DATEADD(HOUR, -2, SYSUTCDATETIME()));
        END
    END
    FETCH NEXT FROM msg_cursor INTO @uId;
END
CLOSE msg_cursor;
DEALLOCATE msg_cursor;
GO

-- 12. Notifications
DECLARE @uId INT;
DECLARE notif_cursor CURSOR FOR SELECT UserId FROM dbo.Users WHERE Role != 'Admin';
OPEN notif_cursor;
FETCH NEXT FROM notif_cursor INTO @uId;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Notifications WHERE UserId = @uId)
    BEGIN
        INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, IsRead, CreatedAt)
        VALUES 
        (@uId, 'New connection request received', 'Demo Investor wants to connect with you regarding early-stage backing.', 'Requests', 1, 0, DATEADD(HOUR, -1, SYSUTCDATETIME())),
        (@uId, 'Your startup was verified', 'TechNovate AI has been approved and awarded the Verified Builder badge.', 'System', 0, 1, DATEADD(DAY, -2, SYSUTCDATETIME())),
        (@uId, 'Upcoming Demo Day deadline', 'Reminder: Submit your pitch presentation for the FoundrLink Winter Demo Day.', 'Activity', 0, 0, DATEADD(HOUR, -5, SYSUTCDATETIME()));
    END
    FETCH NEXT FROM notif_cursor INTO @uId;
END
CLOSE notif_cursor;
DEALLOCATE notif_cursor;
GO

-- 13. ModerationReports & 14. Reports
UPDATE dbo.ModerationReports 
SET ReporterEmail = REPLACE(ReporterEmail, SUBSTRING(ReporterEmail, CHARINDEX('@', ReporterEmail), LEN(ReporterEmail)), '@ripaldesign.studio');

IF NOT EXISTS (SELECT 1 FROM dbo.ModerationReports WHERE ReportCode = '#RPT-101')
BEGIN
    INSERT INTO dbo.ModerationReports (ReportCode, ReporterEmail, ReportedItem, ReportType, Priority, Details, Status, CreatedAt, ResolvedAt)
    VALUES 
    ('#RPT-101', 'audit@ripaldesign.studio', 'Startup: "CryptoYield Flow"', 'Content Violation', 'High', 'Unregistered token distribution link posted in public pitch deck.', 'Pending', DATEADD(HOUR, -4, SYSUTCDATETIME()), NULL),
    ('#RPT-102', 'compliance@ripaldesign.studio', 'User: "SpamBot Automations"', 'Spam', 'Medium', 'Automated unsolicited promotional direct messaging to 15 founders.', 'Pending', DATEADD(HOUR, -12, SYSUTCDATETIME()), NULL),
    ('#RPT-103', 'trust@ripaldesign.studio', 'Suspicious Activity: Fast Account Creation', 'Suspicious Activity', 'Low', 'Multiple sign-in attempts from single proxy node.', 'Resolved', DATEADD(DAY, -2, SYSUTCDATETIME()), SYSUTCDATETIME());
END

IF NOT EXISTS (SELECT 1 FROM dbo.Reports WHERE ReporterEmail = 'audit@ripaldesign.studio')
BEGIN
    DECLARE @FirstUserId INT;
    SELECT TOP 1 @FirstUserId = UserId FROM dbo.Users;
    INSERT INTO dbo.Reports (ReporterUserId, ReporterEmail, ReportedItemType, ReportedItemId, ReportedItemTitle, ReportType, Details, Status, CreatedAt)
    VALUES 
    (@FirstUserId, 'audit@ripaldesign.studio', 'Startup', 1, 'CryptoYield Flow', 'Content Violation', 'Review pitch content for policy adherence.', 'Pending', GETDATE()),
    (@FirstUserId, 'compliance@ripaldesign.studio', 'User', 2, 'SpamBot Automations', 'Spam', 'Bulk messaging detection flagged by system rate limiter.', 'Pending', GETDATE());
END
GO

-- 15. ConnectionRequests & 16. CollaborationRequests & 17. Connections
DECLARE @FId INT, @CId INT, @IId INT;
SELECT TOP 1 @FId = UserId FROM dbo.Users WHERE Email = 'founder@ripaldesign.studio';
SELECT TOP 1 @CId = UserId FROM dbo.Users WHERE Email = 'cofounder@ripaldesign.studio';
SELECT TOP 1 @IId = UserId FROM dbo.Users WHERE Email = 'investor@ripaldesign.studio';

IF @FId IS NOT NULL AND @CId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ConnectionRequests WHERE SenderId = @CId AND ReceiverId = @FId)
BEGIN
    INSERT INTO dbo.ConnectionRequests (SenderId, ReceiverId, StartupId, Note, Status, CreatedAt)
    VALUES (@CId, @FId, NULL, 'Hi, excited to team up as Co-Founder & CTO on TechNovate AI!', 'Accepted', SYSUTCDATETIME());
END

IF @FId IS NOT NULL AND @IId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ConnectionRequests WHERE SenderId = @IId AND ReceiverId = @FId)
BEGIN
    INSERT INTO dbo.ConnectionRequests (SenderId, ReceiverId, StartupId, Note, Status, CreatedAt)
    VALUES (@IId, @FId, NULL, 'We would like to discuss leading your seed round allocation.', 'Pending', SYSUTCDATETIME());
END

DECLARE @MainStartupId INT;
SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups WHERE Name = 'TechNovate AI';
IF @MainStartupId IS NULL SELECT TOP 1 @MainStartupId = StartupId FROM dbo.Startups;

IF @CId IS NOT NULL AND @FId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.CollaborationRequests WHERE SenderUserId = @CId AND StartupId = @MainStartupId)
BEGIN
    INSERT INTO dbo.CollaborationRequests (SenderUserId, ReceiverUserId, StartupId, Message, Status, CreatedAt)
    VALUES (@CId, @FId, @MainStartupId, 'Excited to collaborate on the high-throughput architecture and streaming core.', 'Pending', GETDATE());
END

IF @FId IS NOT NULL AND @CId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Connections WHERE (RequesterUserId = @FId AND ReceiverUserId = @CId) OR (RequesterUserId = @CId AND ReceiverUserId = @FId))
BEGIN
    INSERT INTO dbo.Connections (RequesterUserId, ReceiverUserId, Status, CreatedAt)
    VALUES (@FId, @CId, 'Accepted', GETDATE());
END
GO

-- 18. Deadlines Table (For User Dashboard upcoming deadlines card)
DELETE FROM dbo.Deadlines; -- Refresh with accurate upcoming dates

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

-- 19. ActivityLogs Table (For User Dashboard recent activity feed)
DELETE FROM dbo.ActivityLogs; -- Refresh with realistic activity items

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

-- 20. ConnectionGrowth Table (CRITICAL: Powers real graph in Dashboard.aspx)
DELETE FROM dbo.ConnectionGrowth; -- Ensure clean, reliable dynamic monthly points for each user

DECLARE @uId INT;
DECLARE @role NVARCHAR(100);
DECLARE cg_cursor CURSOR FOR SELECT UserId, Role FROM dbo.Users;
OPEN cg_cursor;
FETCH NEXT FROM cg_cursor INTO @uId, @role;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Varied, realistic upward monthly trajectory tailored to user role and id
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

PRINT 'FoundrLink database sample data seeded successfully for all tables!';
GO
