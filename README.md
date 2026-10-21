# FoundrLink 🚀

[![Platform](https://img.shields.io/badge/Platform-.NET%20Framework%204.8-512BD4?logo=dotnet)](https://github.com/Rajib-AFK/FoundrLink/wiki/System-Architecture-and-Tech-Stack)
[![Application Type](https://img.shields.io/badge/Architecture-ASP.NET%20Web%20Forms%20%2B%20Services-blue)](https://github.com/Rajib-AFK/FoundrLink/wiki/System-Architecture-and-Tech-Stack)
[![Database](https://img.shields.io/badge/Database-SQL%20Server%20LocalDB-CC292B?logo=microsoftsqlserver)](https://github.com/Rajib-AFK/FoundrLink/wiki/Database-Design-and-Data-Dictionary)
[![Test Suite](https://img.shields.io/badge/Tests-15%20Passed%20%7C%20100%25-brightgreen)](https://github.com/Rajib-AFK/FoundrLink)
[![Academic Course](https://img.shields.io/badge/Course-CE545%20Enterprise%20Computing-green)](https://github.com/Rajib-AFK/FoundrLink/wiki/Academic-Rubric-and-Viva-Guide)
[![Wiki](https://img.shields.io/badge/Documentation-GitHub%20Wiki-brightgreen?logo=gitbook)](https://github.com/Rajib-AFK/FoundrLink/wiki)

> **Professional Matchmaking & Discovery Platform for High-Growth Founders, Technical Builders, and Visionary Capital**

---

## 🏛️ Enterprise Multi-Tier Architecture

FoundrLink follows a decoupled, layered enterprise architecture complying with the **CE545: Enterprise Computing Through .NET Frameworks** curriculum:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   1. Presentation Tier (ASP.NET Web Forms)             │
│  Site.Master │ User.Master │ Admin.Master                              │
│  14 Web Forms: Default.aspx, Login.aspx, Register.aspx, Dashboard.aspx │
│  Admin Console: /Admin/Dashboard.aspx, ManageUsers.aspx, Reports.aspx  │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
┌────────────────────────────────────▼───────────────────────────────────┐
│              2. Business Logic Tier (Service Abstractions)             │
│  • IUserService / UserService (Auth, role management, verification)   │
│  • IModerationService / ModerationService (Tickets, resolve, dismiss) │
│  • IStartupService / StartupService (Directory query, status updates)  │
│  • IValidationService / ValidationService (Email, password, XSS sanit) │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
┌────────────────────────────────────▼───────────────────────────────────┐
│                 3. Domain Entities & DTO Layer (Models)                │
│  • User.cs (Identity & roles)     • Startup.cs (Pitch & traction)     │
│  • ModerationReport.cs (Tickets)  • ServiceResult.cs (Result envelope)│
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
┌────────────────────────────────────▼───────────────────────────────────┐
│              4. Data Access Layer & Resilience Tier (DAL)               │
│  • DbHelper.cs: Parameterized ADO.NET, connection pooling, transactions│
│  • LocalFallbackStore.cs: In-memory circuit-breaker JSON data store    │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
┌────────────────────────────────────▼───────────────────────────────────┐
│                   5. Relational Persistence Tier                       │
│  Microsoft SQL Server (LocalDB / Azure SQL) - 14 Normalized 3NF Tables  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🧪 Automated Testing & Regression Harness

FoundrLink includes an automated unit and regression test harness ([`run-tests.ps1`](file:///d:/FoundrLink/run-tests.ps1) and [`Tests/TestRunner.cs`](file:///d:/FoundrLink/Tests/TestRunner.cs)) verifying all mission-critical security, validation, cryptography, and fallback behaviors.

### Running the Test Suite:
```powershell
.\run-tests.ps1
```

### Verified Test Cases (15/15 Passing):
1. **PBKDF2 Cryptography:** Validates that password hashes follow the `{iterations}.{base64Salt}.{base64Hash}` format using 60,000 rounds.
2. **PBKDF2 Password Match:** Verifies that genuine passwords pass authentication.
3. **PBKDF2 Password Rejection:** Verifies that invalid credentials are mathematically rejected.
4. **Legacy SHA-256 Backward Compatibility:** Validates that legacy seed hashes verify seamlessly.
5. **Open Redirection Defense (Positive):** Confirms safe local URLs (`/Dashboard.aspx`, `~/Profile.aspx`) are allowed.
6. **Open Redirection Defense (Negative):** Rejects phishing and protocol-relative attempts (`//evil.com`, `/\evil.com`, `javascript:`).
7. **Input Validation (Registration):** Confirms valid credentials pass validation.
8. **Password Complexity (< 8 chars):** Rejects short passwords with descriptive feedback.
9. **Password Complexity (Symbols/Digits):** Rejects passwords lacking numbers or symbols.
10. **Password Confirmation:** Rejects mismatched confirm-password entries.
11. **Email Format Validation:** Rejects malformed email structures.
12. **XSS Sanitization:** Strips executable `<script>` tags from user-submitted text.
13. **Moderation Ticketing:** Verifies formatted `TKT-XXXX` ticket codes are generated upon submission.
14. **Offline Fallback Store (Accounts):** Confirms seed demo accounts are accessible offline.
15. **Offline Fallback Store (Scalar):** Confirms scalar count queries operate without SQL Server.

---

## ⚡ Quick Start (Local Development)

### 1. Prerequisites
- **Visual Studio 2022 / 2026** with the *ASP.NET and web development* workload.
- **.NET Framework 4.8 / 4.7.2** Developer Pack.
- **SQL Server LocalDB** `(localdb)\MSSQLLocalDB` (bundled with Visual Studio).

### 2. Setup Database
Open PowerShell in the project directory and run the initialization script:
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -i "Database\FoundrLink_Schema_And_Seed.sql"
```

### 3. Open and Run in Visual Studio
1. Open `FoundrLink.sln`.
2. Ensure `FoundrLink` is set as the Startup Project.
3. Press **F5** to run with IIS Express. The application will launch at `http://localhost:50321/Default.aspx`.

### 4. Test Accounts
| Role | Email | Password | Target Portal |
|---|---|---|---|
| **Platform Administrator** | `admin@ripaldesign.studio` | `Password123` | `/Admin/Dashboard.aspx` |
| **Startup Founder** | `founder@ripaldesign.studio` | `Password123` | `/Dashboard.aspx` |
| **Technical Co-Founder** | `cofounder@ripaldesign.studio` | `Password123` | `/Profile.aspx` |
| **Angel Investor** | `investor@ripaldesign.studio` | `Password123` | `/ExploreStartups.aspx` |

---

## 📖 Complete Project Documentation & Wiki

The exhaustive architectural documentation, database design, security specifications, deployment manuals, and viva defense guides are hosted in the **[FoundrLink GitHub Wiki](https://github.com/Rajib-AFK/FoundrLink/wiki)**:

| Wiki Topic | Description | Link |
|---|---|:---:|
| 🏠 **Wiki Home** | Central landing page, badges, and quick links | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Home) |
| 📌 **Project Overview & Vision** | Problem statement, personas, and market analysis | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Project-Overview-and-Vision) |
| 🏛️ **System Architecture & Tech Stack** | Multi-tier architecture, Web Forms lifecycle, and ADRs | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/System-Architecture-and-Tech-Stack) |
| 🗄️ **Database Design & Data Dictionary** | 14 normalized tables (3NF), Mermaid ERD, and schema details | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Database-Design-and-Data-Dictionary) |
| 🚀 **Getting Started & Local Setup** | Step-by-step Visual Studio, LocalDB, and IIS Express onboarding | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Getting-Started-and-Local-Setup) |
| ⚙️ **Configuration & Connection Strings** | `Web.config` breakdown, connection strings, and security | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Configuration-and-Connection-Strings) |
| 🔐 **Authentication & Role Workflows** | RBAC, registration, salted PBKDF2 cryptography, and sessions | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Authentication-and-Role-Workflows) |
| 💼 **Startup Management & Discovery** | Pitch listings, open positions, milestone updates, and filters | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Startup-Management-and-Discovery) |
| 🤝 **Co-Founder Matchmaking & Profiles** | Skill alignment ("I Can Offer" / "Looking For") and portfolios | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Co-Founder-Matchmaking-and-Profiles) |
| 💬 **Messaging & Notifications** | Threaded direct messaging and actionable alerts (Accept/Decline) | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Messaging-and-Notifications) |
| 🛡️ **Admin Console & Moderation** | KPI metrics dashboard, user management, and violation reports | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Admin-Console-and-Moderation) |
| 🔒 **Security & State Management** | PBKDF2/SHA-256, SQL parameterization, ViewState vs. Session | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Security-and-State-Management) |
| ☁️ **Deployment to Azure Windows Server** | Windows Server 2022 VM, IIS 10.0, Azure SQL, and Let's Encrypt | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Deployment-to-Azure-Windows-Server) |
| 🎓 **Academic Rubric & Viva Guide** | CE545 rubric alignment, OOP principles demonstration, viva Q&A | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Academic-Rubric-and-Viva-Guide) |
| 📋 **Team Work Distribution** | Roster, task ownership matrix, and mentor review logs | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Team-Work-Distribution) |
| ❓ **Troubleshooting & FAQ** | Common LocalDB errors, IIS port conflicts, and resolution steps | [Read Page](https://github.com/Rajib-AFK/FoundrLink/wiki/Troubleshooting-and-FAQ) |

---

## 👥 Engineering Team & Credits

Developed for **CE545: Enterprise Computing Through .NET Frameworks (AY 2026–27)**:
- **Yash Vinchhi** (`24CE0501`) — Lead Software Architect & Backend/Database Specialist
- **Rajibul Sheikh** (`24CE0502`) — Frontend Lead / ASP.NET Web Forms Designer
- **Chirag Fofandi** (`24CE0503`) — QA & Security Lead / Admin & Moderation Specialist
