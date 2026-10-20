# Troubleshooting & FAQ

This guide resolves common runtime issues, database connection errors, IIS configurations, and operational questions encountered when developing or deploying FoundrLink.

---

## 1. Database Connection & LocalDB Troubleshooting

### Issue 1: `SqlException: Cannot open database "FoundrLinkDb" requested by the login.`
- **Cause:** The database `FoundrLinkDb` has not yet been created on your local SQL Server instance.
- **Solution:** 
  1. Open PowerShell or Command Prompt.
  2. Run the initialization script:
     ```powershell
     sqlcmd -S "(localdb)\MSSQLLocalDB" -i "Database\FoundrLink_Schema_And_Seed.sql"
     ```
  3. Alternatively, open SSMS, connect to `(localdb)\MSSQLLocalDB`, open `Database/FoundrLink_Schema_And_Seed.sql`, and execute the script.

---

### Issue 2: `The server was not found or was not accessible (provider: Named Pipes Provider, error: 40 - Could not open a connection to SQL Server)`
- **Cause:** The SQL Server LocalDB instance `MSSQLLocalDB` is stopped or corrupted.
- **Solution:**
  1. Check status in PowerShell:
     ```powershell
     sqllocaldb info MSSQLLocalDB
     ```
  2. If `State: Stopped`, start it:
     ```powershell
     sqllocaldb start MSSQLLocalDB
     ```
  3. If still failing, recreate the LocalDB instance:
     ```powershell
     sqllocaldb stop MSSQLLocalDB
     sqllocaldb delete MSSQLLocalDB
     sqllocaldb create MSSQLLocalDB
     sqllocaldb start MSSQLLocalDB
     sqlcmd -S "(localdb)\MSSQLLocalDB" -i "Database\FoundrLink_Schema_And_Seed.sql"
     ```

---

## 2. Web Server & IIS Express Troubleshooting

### Issue 3: `Port conflict / Address already in use` when pressing F5 in Visual Studio
- **Cause:** Another process or orphaned IIS Express worker is occupying the configured port.
- **Solution:**
  1. Close Visual Studio.
  2. Open PowerShell and kill lingering IIS Express processes:
     ```powershell
     Get-Process iisexpress -ErrorAction SilentlyContinue | Stop-Process -Force
     ```
  3. Restart Visual Studio. If necessary, assign a new port in `FoundrLink.csproj.user` under `<DevelopmentServerPort>`.

---

### Issue 4: `HTTP 404.13 - The request filtering module is configured to deny a request that exceeds the request content length.`
- **Cause:** An uploaded startup pitch deck or high-resolution logo exceeded the default ASP.NET 4 MB upload ceiling.
- **Solution:**
  FoundrLink is configured for 10 MB uploads. Ensure both `system.web` and `system.webServer` sections in `Web.config` contain matching limits:
  ```xml
  <system.web>
    <httpRuntime maxRequestLength="10240" />
  </system.web>
  <system.webServer>
    <security>
      <requestFiltering>
        <requestLimits maxAllowedContentLength="10485760" />
      </requestFiltering>
    </security>
  </system.webServer>
  ```

---

### Issue 5: Image Upload Permissions Error on Windows Server / IIS (`Access to path ... is denied`)
- **Cause:** The IIS Application Pool identity (`IIS_IUSRS` / `IUSR`) lacks write access to the physical image upload folder.
- **Solution:**
  Run PowerShell on the server as Administrator:
  ```powershell
  icacls "C:\inetpub\foundrlink\Images" /grant "IIS_IUSRS:(OI)(CI)M" /T
  icacls "C:\inetpub\foundrlink\Images" /grant "IUSR:(OI)(CI)M" /T
  ```

---

## 3. GitHub Wiki & Repository FAQ

### Q1: Why did visiting `https://github.com/Rajib-AFK/FoundrLink/wiki` initially redirect to the repository homepage?
> **Answer:**  
> On GitHub, a repository's wiki git repository (`https://github.com/<owner>/<repo>.wiki.git`) is not created on disk until the repository owner/collaborator visits the Wiki tab in their browser and clicks **"Create the first page"** (or saves an initial page). Once that first page is saved via the web UI, GitHub provisions the `.wiki.git` repository, allowing the automated `deploy-wiki.ps1` script to push all wiki documentation directly.

---

### Q2: How can I push updates to the GitHub Wiki?
> **Answer:**  
> Once the wiki is initialized on GitHub, run the provided automation script from the project root:
> ```powershell
> .\deploy-wiki.ps1
> ```
> This script commits all markdown files in `wiki/` and pushes them straight to `https://github.com/Rajib-AFK/FoundrLink.wiki.git`.

---

### Q3: What are the default test login credentials?
> **Answer:**  
> - **Platform Admin:** `admin@foundrlink.com` | `Password123`
> - **Founder:** `founder@foundrlink.com` | `Password123`
> - **Co-Founder:** `cofounder@foundrlink.com` | `Password123`
> - **Investor:** `investor@foundrlink.com` | `Password123`

---

### Q4: Can FoundrLink run on Linux using Mono or .NET Core?
> **Answer:**  
> While modern ASP.NET Core runs cross-platform, Classic ASP.NET Web Forms (`System.Web`) is built specifically for Microsoft .NET Framework 4.8 on Windows Server / IIS. While the SQL Server database engine can run on Linux (Ubuntu), the Web Forms presentation layer requires Windows Server with IIS 10.0.

---

> [!TIP]
> Return to the **[Wiki Home](Home)** or check the **[Project Overview & Vision](Project-Overview-and-Vision)**.
