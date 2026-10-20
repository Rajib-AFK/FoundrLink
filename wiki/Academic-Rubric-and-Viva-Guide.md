# Academic Rubric & Viva Guide

This document maps the **FoundrLink** architecture and implementation directly to the academic rubric for **CE545: Enterprise Computing Through .NET Frameworks**, providing comprehensive technical justifications and model viva responses.

---

## 1. Academic Rubric Alignment Matrix

| Evaluation Stage | Marks | Requirements Prescribed | FoundrLink Implementation & Artifact Evidence |
|---|:---:|---|---|
| **TCIE-I: Exploration & UI** | 20 | Problem exploration, user personas, market citations, SRS specifications, Figma wireframes. | • 18 UI screens matching Figma specifications.<br/>• Comprehensive problem analysis citing Harvard research.<br/>• Detailed SRS in `docs/03-requirements.md`. |
| **TCIE-II: Layouts & Database** | 20 | Multi-tier architecture, normalized ERD (3NF), database schema, master pages layout hierarchy. | • 3 Master Pages (`Site.Master`, `User.Master`, `Admin.Master`).<br/>• 14 normalized SQL tables with referential integrity.<br/>• Multi-tier architecture blueprint in `docs/05-system-architecture.md`. |
| **TSEE: Implementation** | 50 | Full functional Web Forms implementation, ADO.NET data access, OOP principles, collections, state management, Git audit. | • 18+ Web Forms (`.aspx` + `.cs`).<br/>• Zero-ORM high-performance ADO.NET with `DbHelper.cs`.<br/>• PBKDF2 cryptography with `RNGCryptoServiceProvider`.<br/>• ViewState, In-Proc Session, and Application state layers. |

---

## 2. Demonstration of Object-Oriented Programming (OOP) Principles

FoundrLink's C# codebase rigorously exercises the four pillars of Object-Oriented Programming:

### 1. Encapsulation
- **Implementation:** Data properties and implementation logic are bundled together, shielding internal state from arbitrary external mutation.
- **Evidence:** 
  - [`Helpers/DbHelper.cs`](file:///D:/dotnet/Foundrlink_new/FoundrLink/Helpers/DbHelper.cs) encapsulates connection string resolution, connection lifetime management (`using (var conn = ...)`), and SQL parameter binding. Code-behind pages never interact with low-level ADO.NET plumbing directly.
  - Form validation rules and credential hashing in [`Helpers/SecurityHelper.cs`](file:///D:/dotnet/Foundrlink_new/FoundrLink/Helpers/SecurityHelper.cs) hide iteration count, salt generation, and bitwise comparison behind clean public interfaces (`HashPassword`, `VerifyPassword`).

### 2. Inheritance
- **Implementation:** Derived classes inherit properties and behaviors from base framework classes, establishing clear specialized hierarchies.
- **Evidence:**
  - All Web Forms pages (`Dashboard.aspx.cs`, `ManageStartup.aspx.cs`, etc.) inherit from `System.Web.UI.Page`.
  - Master pages (`Site.Master.cs`, `User.Master.cs`, `Admin.Master.cs`) inherit from `System.Web.UI.MasterPage`.

### 3. Polymorphism
- **Implementation:** Methods execute different behaviors based on invocation parameters (overloading) or overridden base behaviors (overriding).
- **Evidence:**
  - **Method Overloading:** `DbHelper` provides overloaded methods:
    - `ExecuteNonQuery(string query)` vs. `ExecuteNonQuery(string query, params SqlParameter[] parameters)`.
    - `ExecuteScalar(string query)` vs. `ExecuteScalar(string query, params SqlParameter[] parameters)`.
  - **Lifecycle Overriding:** Overriding virtual lifecycle methods like `Page_Load(object sender, EventArgs e)`, `OnInit()`, and custom event dispatchers.

### 4. Abstraction
- **Implementation:** Complex underlying mechanics (database connection pooling, cryptographic salt derivation, ADO.NET transactions) are hidden behind clear, declarative function signatures.
- **Evidence:** The presentation layer calls `DbHelper.ExecuteDataTable(query, params)` without needing to know whether the target database is SQL Server LocalDB or Azure SQL PaaS.

---

## 3. Collections Framework & Data Structures

FoundrLink leverages strong typing and efficient data structures throughout its data pipeline:

| Collection / Structure | Usage in FoundrLink | Performance Characteristics |
|---|---|---|
| `List<SqlParameter>` | Building dynamic query parameters in search/filter routines (`ExploreStartups.aspx.cs`). | Dynamic resizing $O(1)$ amortized; contiguous memory layout. |
| `DataTable` / `DataRow` | Transferring tabular database records between ADO.NET and Web Forms Repeater / GridView controls. | In-memory disconnected tabular cache with schema metadata. |
| `Dictionary<string, object>` | Key-value parameter mappings and session state storage. | $O(1)$ constant-time lookup based on hash codes. |
| `HashSet<int>` | Deduplicating conversation participant IDs and connection requests. | $O(1)$ membership testing to eliminate redundant processing. |

---

## 4. Key Viva Questions & Model Answers

### Q1: Why did you choose native ADO.NET instead of Entity Framework (EF)?
> **Model Answer:**  
> "We chose native ADO.NET with parameterized queries and a centralized helper abstraction (`DbHelper.cs`) for three primary reasons:  
> 1. **Performance & Control:** ADO.NET offers zero-overhead execution and precise control over the generated SQL queries, preventing common ORM pitfalls like the $N+1$ query problem.  
> 2. **Security:** Every query uses strongly typed `SqlParameter` objects, providing complete immunity against SQL injection vulnerabilities.  
> 3. **Architectural Mastery:** It directly satisfies the CE545 enterprise computing rubric by demonstrating deep understanding of connection lifetimes, data adapters, connection pooling, and disconnected `DataTable` architectures."

---

### Q2: How does FoundrLink protect user passwords against credential theft?
> **Model Answer:**  
> "FoundrLink never stores passwords in plaintext. We implement salted PBKDF2 (`Rfc2898DeriveBytes`) using 10,000 iterations and a 16-byte cryptographically secure random salt generated by `RNGCryptoServiceProvider`.  
> The salt and iteration count are serialized with the digest as `{iterations}.{base64Salt}.{base64Hash}`. When verifying passwords during sign-in, we use constant-time bitwise comparison (`SlowEquals`) to eliminate timing side-channel attacks. We also maintain backward compatibility for legacy SHA-256 hashes."

---

### Q3: Explain how Web Forms manages state between HTTP requests.
> **Model Answer:**  
> "HTTP is inherently stateless. FoundrLink maintains continuity using a multi-tiered state strategy:  
> 1. **ViewState (`__VIEWSTATE`):** Encodes control state, active tab selections, and repeater indices on the client side, allowing controls to retain values across postbacks without hitting the database.  
> 2. **Session State (`Session[...]`):** Maintains server-side in-memory user identity (`UserId`, `FullName`, `UserRole`) with a 60-minute sliding window.  
> 3. **Application State (`Application[...]`):** Stores global system telemetry (total active sessions, system uptime).  
> 4. **SQL Server Database:** Provides durable, permanent persistence that survives application recycles and server reboots."

---

### Q4: How is Role-Based Access Control (RBAC) enforced?
> **Model Answer:**  
> "Authorization is enforced at both the Master Page and individual page lifecycle levels. In `Admin.Master.cs`, `Page_Init` validates that `SecurityHelper.IsUserLoggedIn()` is true and that `Session["UserRole"] == "Admin"`. If an unauthenticated user or a non-admin role attempts to access `/Admin/*`, they are immediately redirected. Similarly, member workspace pages redirect unauthenticated requests to `/Login.aspx` with a `returnUrl` parameter."

---

### Q5: How do you handle database transactions to maintain ACID compliance?
> **Model Answer:**  
> "For multi-step write operations — such as deleting a startup and cascading related team members, or accepting a connection request and simultaneously creating a private conversation thread — we utilize `SqlTransaction`. This guarantees atomicity: if any step fails, the entire transaction rolls back (`Rollback()`), leaving the database in a consistent state."

---

> [!TIP]
> See **[Team Work Distribution](Team-Work-Distribution)** for the team roster and individual task ownership records.
