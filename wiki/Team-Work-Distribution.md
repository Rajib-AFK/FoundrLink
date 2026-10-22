# Team Work Distribution

**Course:** CE545 — Enterprise Computing Through .NET Frameworks  
**Academic Year:** 2026–27  
**Team Size:** Exactly 3 Students  
**Repository:** [Rajib-AFK/FoundrLink](https://github.com/Rajib-AFK/FoundrLink)

---

## 1. Team Roster & Module Responsibilities

| Member | Student ID | Primary Technical Specialization | Secondary Responsibilities |
|---|---|---|---|
| **Yash Vinchhi** | `24CE0501` | **Lead Software Architect & Backend/Database Specialist**<br/>Database schema design (3NF), ADO.NET repositories, connection pooling, transaction integrity, cloud deployment architecture. | System architecture documentation, performance optimization, Azure VM setup. |
| **Rajibul Sheikh** | `24CE0502` | **Frontend Lead / ASP.NET Web Forms Designer**<br/>Master pages (`Site.Master`, `User.Master`, `Admin.Master`), CSS design system matching Figma, server controls, Web Forms ViewState, client/server validation. | UI/wireframe documentation, responsive asset curation, public discovery pages. |
| **Chirag Fofandi** | `24CE0503` | **QA & Security Lead / Admin & Moderation Specialist**<br/>Admin portal (`Admin/Dashboard.aspx`, `Reports.aspx`), PBKDF2/SHA-256 security architecture, session state manager, automated test suites, compliance matrix. | Viva preparation, git version control audit, user moderation queues. |

---

## 2. Deliverable Ownership by Rubric Phase

### Phase 1: TCIE-I — Exploration & UI Wireframes (20 Marks)
| Deliverable / Task | Owner | Reviewer | Source Evidence Path | Status |
|---|---|---|---|:---:|
| Problem exploration & research citations | Yash Vinchhi | Chirag Fofandi | `docs/01-project-definition.md` | ✅ VERIFIED |
| Software Requirements Specification (SRS) | Rajibul Sheikh | Yash Vinchhi | `docs/03-requirements.md` | ✅ VERIFIED |
| Screen inventory & wireframe mapping | Rajibul Sheikh | Chirag Fofandi | `docs/04-wireframes-and-ui.md` | ✅ VERIFIED |
| TCIE-I Voice-Viva preparation notes | Chirag Fofandi | Team | `docs/10-viva-preparation.md` | ✅ VERIFIED |

---

### Phase 2: TCIE-II — Layouts & Database Design (20 Marks)
| Deliverable / Task | Owner | Reviewer | Source Evidence Path | Status |
|---|---|---|---|:---:|
| System architecture & multi-tier diagram | Yash Vinchhi | Rajibul Sheikh | `docs/05-system-architecture.md` | ✅ VERIFIED |
| Normalized ER Diagram & 3NF review | Yash Vinchhi | Chirag Fofandi | `docs/06-database-design.md` | ✅ VERIFIED |
| SQL schema & seed data creation | Yash Vinchhi | Rajibul Sheikh | `Database/FoundrLink_Schema_And_Seed.sql` | ✅ VERIFIED |
| Master page layout architecture | Rajibul Sheikh | Yash Vinchhi | `Site.Master`, `User.Master`, `Admin.Master` | ✅ VERIFIED |
| TCIE-II Voice-Viva preparation notes | Chirag Fofandi | Team | `docs/10-viva-preparation.md` | ✅ VERIFIED |

---

### Phase 3: TSEE — Full Implementation (50 Marks)
| Deliverable / Task | Owner | Reviewer | Source Evidence Path | Status |
|---|---|---|---|:---:|
| Web Forms UI implementation (18 screens) | Rajibul Sheikh | Yash Vinchhi | Root `.aspx` files | ✅ IMPLEMENTED |
| ADO.NET Data Access Layer & `DbHelper` | Yash Vinchhi | Chirag Fofandi | `Helpers/DbHelper.cs` | ✅ IMPLEMENTED |
| PBKDF2 Cryptographic Security & Session State | Chirag Fofandi | Yash Vinchhi | `Helpers/SecurityHelper.cs` | ✅ IMPLEMENTED |
| Co-Founder Matchmaking & Startup Directory | Yash Vinchhi | Rajibul Sheikh | `FindCoFounders.aspx`, `ExploreStartups.aspx` | ✅ IMPLEMENTED |
| Admin Console & Moderation Ticketing | Chirag Fofandi | Rajibul Sheikh | `Admin/` directory | ✅ IMPLEMENTED |
| Multi-Tier Service Architecture & Decoupled BLL | Chirag Fofandi | Yash Vinchhi | `Services/`, `Models/` | ✅ IMPLEMENTED |
| Automated Regression Test Suite (15 Test Cases) | Chirag Fofandi | Yash Vinchhi | `Tests/TestRunner.cs`, `run-tests.ps1` | ✅ VERIFIED |
| Cloud Deployment Guide & Azure Setup | Yash Vinchhi | Chirag Fofandi | `server.md` & Azure VM | ✅ VERIFIED |
| GitHub Wiki Documentation & Version Control | Team | Team | GitHub Wiki & `wiki/` | ✅ PUBLISHED |

---

## 3. Mentor Progress Review Log

- **Initial Review (October 2026):** Database schema validated on LocalDB; ADO.NET data access abstractions verified; comprehensive SRS, architectural diagrams, and ERD documentation signed off.
- **Mid-Term Review (October 2026):** All 18 functional screens built and integrated with database layer; PBKDF2 cryptography and role-based access gating demonstrated.
- **Final Pre-Viva Review (October 2026):** End-to-end integration verified; Azure Windows Server VM deployment guide and GitHub Wiki complete.
