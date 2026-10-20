# Configuration & Connection Strings

This page provides an architectural breakdown of the configuration settings in FoundrLink, including `Web.config`, database connection strings, session timeouts, and best practices for secret management.

---

## 1. Structure of `Web.config`

The `Web.config` file in the root directory manages ASP.NET runtime options, security policies, handler mappings, and database connectivity.

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <connectionStrings>
    <add name="FoundrLinkDb" 
         connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=FoundrLinkDb;Integrated Security=True;MultipleActiveResultSets=True;" 
         providerName="System.Data.SqlClient" />
  </connectionStrings>
  
  <system.web>
    <compilation debug="true" targetFramework="4.7.2" />
    <httpRuntime targetFramework="4.7.2" maxRequestLength="10240" />
    
    <sessionState mode="InProc" 
                  cookieless="false" 
                  timeout="60" />
                  
    <customErrors mode="RemoteOnly" defaultRedirect="~/Default.aspx" />
  </system.web>
  
  <system.webServer>
    <defaultDocument>
      <files>
        <clear />
        <add value="Default.aspx" />
      </files>
    </defaultDocument>
    <security>
      <requestFiltering>
        <!-- 10 MB maximum upload size for avatars and pitch assets -->
        <requestLimits maxAllowedContentLength="10485760" />
      </requestFiltering>
    </security>
  </system.webServer>
</configuration>
```

---

## 2. How `DbHelper.cs` Resolves Connection Strings

Rather than scattering raw ADO.NET connection strings throughout Web Forms code-behind files, FoundrLink centralizes connection string retrieval in [`Helpers/DbHelper.cs`](file:///D:/dotnet/Foundrlink_new/FoundrLink/Helpers/DbHelper.cs):

```csharp
public static string ConnectionString
{
    get
    {
        var connSetting = ConfigurationManager.ConnectionStrings["FoundrLinkDb"];
        if (connSetting == null || string.IsNullOrWhiteSpace(connSetting.ConnectionString))
        {
            // Defensive programmatic fallback to local developer database
            return @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=FoundrLinkDb;Integrated Security=True;MultipleActiveResultSets=True;";
        }
        return connSetting.ConnectionString;
    }
}
```

### Benefits of this Design:
1. **Defensive Fallback:** If `Web.config` is missing the `FoundrLinkDb` key during initial setup or testing, the system automatically falls back to the standard SQL Server LocalDB instance without crashing.
2. **Centralized Modification:** Changing the database provider or connection properties in `Web.config` instantly propagates to all 18+ Web Forms pages without recompilation.
3. **Connection Pooling Enabled:** By leveraging standard ADO.NET connection strings, ASP.NET and SQL Server automatically manage a pool of reusable connections, eliminating TCP socket exhaustion under high concurrent load.

---

## 3. Comparison of Common Connection Strings

Depending on where you are running FoundrLink, configure `FoundrLinkDb` as follows:

### 1. SQL Server LocalDB (Default Visual Studio Dev Machine)
```xml
<connectionStrings>
  <add name="FoundrLinkDb" 
       connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=FoundrLinkDb;Integrated Security=True;MultipleActiveResultSets=True;" 
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

### 2. Dedicated SQL Server Express / Developer Edition
```xml
<connectionStrings>
  <add name="FoundrLinkDb" 
       connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=FoundrLinkDb;Integrated Security=True;MultipleActiveResultSets=True;" 
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

### 3. Remote Azure SQL Database (Shared Multi-Developer & Production VM)
```xml
<connectionStrings>
  <add name="FoundrLinkDb" 
       connectionString="Server=tcp:foundrlink-sqlserver.database.windows.net,1433;Initial Catalog=FoundrLinkDb;Persist Security Info=False;User ID=foundr_admin;Password=YourStrongPasswordHere!123;MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" 
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

---

## 4. Session State & File Upload Configuration

### In-Proc Session Configuration
```xml
<sessionState mode="InProc" cookieless="false" timeout="60" />
```
- **`mode="InProc"`:** High performance in-memory session storage. Ideal for single-server setups and local development.
- **`timeout="60"`:** Sessions remain active for 60 minutes of inactivity before requiring re-authentication.

### File Upload Limits (`maxAllowedContentLength`)
FoundrLink allows founders to upload startup logos and pitch assets:
- **`maxRequestLength="10240"`:** Set in `<httpRuntime>` (measured in Kilobytes = 10 MB).
- **`maxAllowedContentLength="10485760"`:** Set in `<requestFiltering>` (measured in Bytes = 10 MB). Both limits must align to avoid HTTP 404.13 or 400 bad request errors during large file uploads.

---

## 5. Security & Git Hygiene (Preventing Password Leaks)

> [!CAUTION]
> **Never commit production passwords or sensitive connection strings into public Git repositories!**

To maintain clean Git hygiene while sharing a live database among team members:
1. Keep the local development string pointing to `(localdb)\MSSQLLocalDB` in the version-controlled `Web.config`.
2. For production deployment on Azure, use **Web.Release.config** transformation or set the connection string directly in the IIS Application Pool or Azure Portal environment settings.
3. If using an external configuration file:
   ```xml
   <connectionStrings configSource="connectionStrings.user.config" />
   ```
   Add `connectionStrings.user.config` to `.gitignore`.

---

> [!TIP]
> Ready to explore how users authenticate and navigate roles? Continue to **[Authentication & Role Workflows](Authentication-and-Role-Workflows)**.
