# Getting Started & Local Setup

This guide walks you through setting up the complete **FoundrLink** development environment from scratch on a Windows workstation.

---

## 1. System Requirements & Prerequisites

Ensure your system meets the following specifications before beginning:

| Component | Minimum Requirement | Recommended |
|---|---|---|
| **Operating System** | Windows 10 (64-bit) | Windows 11 Pro / Enterprise |
| **IDE** | Visual Studio 2022 Community | Visual Studio 2022 / 2026 (any edition) |
| **Workloads** | ASP.NET and web development | ASP.NET and web development + .NET desktop |
| **Target Framework** | .NET Framework 4.7.2 Developer Pack | .NET Framework 4.8 Developer Pack |
| **Database** | SQL Server 2016 Express / LocalDB | SQL Server LocalDB `(localdb)\MSSQLLocalDB` |
| **Web Server** | IIS Express 10.0 (bundled with Visual Studio) | IIS Express 10.0 |
| **Git Client** | Git for Windows 2.30+ | Git for Windows + GitHub CLI (`gh`) |

---

## 2. Step-by-Step Installation & Setup

### Step 1: Clone the Repository
Open PowerShell or your preferred terminal and clone the repository:

```powershell
git clone https://github.com/Rajib-AFK/FoundrLink.git
cd FoundrLink
```

---

### Step 2: Initialize SQL Server LocalDB & Execute Seed Script

FoundrLink requires a running SQL Server database named `FoundrLinkDB`.

1. **Verify LocalDB is running:**
   ```powershell
   sqllocaldb info MSSQLLocalDB
   ```
   If it is stopped, start the instance:
   ```powershell
   sqllocaldb start MSSQLLocalDB
   ```

2. **Execute the Database Creation & Seed Script:**
   You can run the script using `sqlcmd` from your terminal or via SQL Server Management Studio (SSMS):

   *Using `sqlcmd`:*
   ```powershell
   sqlcmd -S "(localdb)\MSSQLLocalDB" -i "Database\FoundrLink_Schema_And_Seed.sql"
   ```

   *Using Visual Studio:*
   - Open Visual Studio.
   - Go to **View** -> **SQL Server Object Explorer**.
   - Expand `(localdb)\MSSQLLocalDB`.
   - Right-click and choose **New Query**.
   - Open `Database/FoundrLink_Schema_And_Seed.sql`, paste its contents, and click **Execute (Ctrl+Shift+E)**.

---

### Step 3: Verify or Update `Web.config` Connection String

Open `Web.config` in the root folder. Verify that the connection string points to your local database:

```xml
<connectionStrings>
  <add name="FoundrLinkDb" 
       connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=FoundrLinkDb;Integrated Security=True;MultipleActiveResultSets=True;" 
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

> [!NOTE]
> If using SQL Server Express instead of LocalDB, change `Data Source=(localdb)\MSSQLLocalDB` to `Data Source=.\SQLEXPRESS;Integrated Security=True;Initial Catalog=FoundrLinkDb;`.

---

### Step 4: Open and Build the Solution in Visual Studio

1. Double-click `FoundrLink.sln` to open the project in Visual Studio.
2. Ensure the build configuration is set to **Debug** and **Any CPU**.
3. Restore NuGet packages (if prompted) via **Tools** -> **NuGet Package Manager** -> **Restore NuGet Packages**.
4. Build the solution via **Build** -> **Rebuild Solution** (or press `Ctrl+Shift+B`).
5. Confirm that the build finishes with **0 Errors**.

---

### Step 5: Run the Application via IIS Express

1. Set `FoundrLink` as the **Startup Project** (right-click the project in Solution Explorer -> *Set as Startup Project*).
2. Right-click `Default.aspx` and select **Set As Start Page**.
3. Press **F5** (or click the green **IIS Express (Google Chrome / Edge)** button).
4. Visual Studio will spin up IIS Express and open your default browser at a URL like:
   ```
   http://localhost:50321/Default.aspx
   ```

---

## 3. Pre-Configured Test Accounts

Use any of the following accounts to test role-specific experiences:

| Role | Email | Password | Access Target |
|---|---|---|---|
| **Administrator** | `admin@ripaldesign.studio` | `Password123` | Redirects to `/Admin/Dashboard.aspx` |
| **Startup Founder** | `founder@ripaldesign.studio` | `Password123` | Redirects to `/Dashboard.aspx` |
| **Technical Co-Founder** | `cofounder@ripaldesign.studio` | `Password123` | Profile showcases skills and compatibility |
| **Angel Investor** | `investor@ripaldesign.studio` | `Password123` | Access to deal flow and request pitch deck |

---

## 4. Verification & Smoke Test Checklist

- [ ] **Home Page Loads:** `http://localhost:50321/Default.aspx` displays hero banner, statistics (12,000+ Founders, ₹4.2Cr Deployed), and deal showcase cards.
- [ ] **Registration Works:** Visit `/Register.aspx`, create a test account, and confirm record is inserted into `dbo.Users`.
- [ ] **Admin Login Works:** Sign in with `admin@ripaldesign.studio` / `Password123` and verify `/Admin/Dashboard.aspx` renders KPI cards.
- [ ] **Startup Discovery:** Visit `/ExploreStartups.aspx`, apply an industry filter (e.g. `FinTech`), and ensure filtered cards render.
- [ ] **Co-Founder Search:** Visit `/FindCoFounders.aspx` and test searching by role or tech stack.
- [ ] **Direct Messaging:** Open `/Messages.aspx` and verify conversation threads load.

---

> [!TIP]
> Facing issues connecting to the database or running IIS Express? Refer to the **[Troubleshooting & FAQ](Troubleshooting-and-FAQ)** guide.
