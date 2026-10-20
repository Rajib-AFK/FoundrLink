# Co-Founder Matchmaking & Profiles

FoundrLink's matchmaking engine addresses the primary cause of startup failure — team misalignment — by structuring co-founder exploration around explicit skill taxonomy, complementary capabilities, and verified availability.

---

## 1. Co-Founder Discovery Directory (`FindCoFounders.aspx`)

The `FindCoFounders.aspx` portal allows founders to discover compatible technical and business talent across multiple dimensions:

```mermaid
flowchart TD
    Catalog["FindCoFounders.aspx Directory"] --> RoleFilter["Role Filter:<br/>• Technical Co-Founder / CTO<br/>• Business / CEO<br/>• Marketing / CMO<br/>• Product / CPO"]
    Catalog --> SkillFilter["Skill Tags Search:<br/>'C#', 'SQL', 'React', 'Cloud', 'GTM'"]
    Catalog --> AvailFilter["Commitment Level:<br/>• Full-time<br/>• Part-time<br/>• Equity / Sweat"]
    Catalog --> LocationFilter["Location / Remote Preference"]
    
    RoleFilter & SkillFilter & AvailFilter & LocationFilter --> Query["Query dbo.Users JOIN dbo.FounderProfiles"]
    Query --> Repeater["Render Co-Founder Match Cards"]
```

### Match Card Structure:
- **Header:** Full Name, Title, Verification Badge, and Avatar.
- **Location & Availability:** Geographic base and commitment badge (e.g. `Full-time`, `Part-time / Equity`).
- **Core Skill Tags:** Visual chips rendered from comma-delimited `Skills` column (e.g., `ASP.NET`, `SQL Server`, `Azure`, `System Architecture`).
- **Complementary Matrix Snippet:**
  - *I Can Offer:* Architecture design, database optimization, backend scaling.
  - *Looking For:* Commercial co-founder with SaaS sales background.
- **Action Buttons:** "View Profile" and "Connect" (triggers connection request modal).

---

## 2. Founder & Member Profile (`Profile.aspx`)

The `Profile.aspx` page serves as a verified professional portfolio tailored specifically for early-stage startup collaboration:

### Key Profile Sections:
1. **Hero Header:**
   - Avatar image, full name, professional title, and company.
   - Profile Completion Gauge (calculated metric from 0% to 100%).
   - Action buttons: "Edit Profile" (for owner) or "Send Message" / "Connect" (for visitors).
2. **Platform Impact Metrics Bar:**
   - Binds to `dbo.FounderProfiles` metrics:
     - 🤝 **Connections Made:** Total confirmed founder/co-founder matches.
     - 🚀 **Introductions Facilitated:** Investor introductions generated.
     - 👥 **Teams Formed:** Active startups co-founded through the platform.
     - ⏱️ **Hours Saved:** Efficiency metric based on automated discovery.
3. **Offerings & Needs Matrix:**
   - **"What I Can Offer":** Detailed technical or business competencies the user brings to a venture.
   - **"What I Am Looking For":** Explicit requirements for ideal co-founders or investors.
4. **Associated Startups:**
   - Queries `dbo.Startups` where `FounderId = @UserId` or `dbo.TeamMembers` where `UserId = @UserId`.

---

## 3. Connection Request Workflow

Connecting with a potential co-founder initiates a formal workflow tracked in `dbo.ConnectionRequests`:

```mermaid
sequenceDiagram
    autonumber
    actor Founder as Sender (e.g. Founder)
    participant UI as FindCoFounders.aspx / Profile.aspx
    participant DB as SQL Server (dbo.ConnectionRequests & dbo.Notifications)
    actor CoFounder as Recipient (e.g. Co-Founder)

    Founder->>UI: Click "Connect" on match card
    UI->>UI: Open Connection Request Modal
    Founder->>UI: Enter personalized pitch note & click "Send Request"
    UI->>DB: INSERT INTO dbo.ConnectionRequests (SenderId, ReceiverId, Note, Status='Pending')
    UI->>DB: INSERT INTO dbo.Notifications (UserId=ReceiverId, Title='New Connection Request', ActionRequired=1)
    DB-->>UI: Success confirmation
    UI-->>Founder: Show alert "Connection request sent!"

    Note over CoFounder,DB: Recipient receives notification in Notifications.aspx
    CoFounder->>DB: Views request & clicks "Accept"
    DB->>DB: UPDATE dbo.ConnectionRequests SET Status='Accepted' WHERE RequestId=@Id
    DB->>DB: INSERT INTO dbo.Conversations (User1Id, User2Id, LastMessageAt=NOW)
    DB->>DB: INSERT INTO dbo.Notifications (UserId=SenderId, Title='Connection Request Accepted!')
    DB-->>CoFounder: Status updated to Connected
```

### Database Persistence:
```csharp
public static bool SendConnectionRequest(int senderId, int receiverId, string note, int? startupId = null)
{
    string query = @"
        INSERT INTO dbo.ConnectionRequests (SenderId, ReceiverId, StartupId, Note, Status, CreatedAt)
        VALUES (@SenderId, @ReceiverId, @StartupId, @Note, 'Pending', SYSUTCDATETIME());

        INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, CreatedAt)
        VALUES (@ReceiverId, 'New Co-Founder Connection Request', @Note, 'Requests', 1, SYSUTCDATETIME());";

    int rows = DbHelper.ExecuteNonQuery(query,
        DbHelper.CreateParam("@SenderId", SqlDbType.Int, senderId),
        DbHelper.CreateParam("@ReceiverId", SqlDbType.Int, receiverId),
        DbHelper.CreateParam("@StartupId", SqlDbType.Int, (object)startupId ?? DBNull.Value),
        DbHelper.CreateParam("@Note", SqlDbType.NVarChar, note));

    return rows > 0;
}
```

---

> [!TIP]
> Once connected, users collaborate via private channels. See **[Messaging & Notifications](Messaging-and-Notifications)**.
