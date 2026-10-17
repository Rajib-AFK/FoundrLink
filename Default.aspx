<%@ Page Title="Connect with Founders & Investors" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="FoundrLink.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-raising-card {
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            overflow: hidden;
            background: #FFFFFF;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .fl-raising-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.08);
        }
        .fl-raising-img {
            height: 180px;
            object-fit: cover;
            width: 100%;
        }
        .fl-hero-arrow {
            color: #64748B;
            font-size: 1.5rem;
            animation: bounce 2s infinite;
        }
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-8px); }
            60% { transform: translateY(-4px); }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hero Section -->
    <section class="fl-landing-hero">
        <div class="container">
            <div class="fl-landing-badge">
                <i class="bi bi-circle-fill text-teal" style="font-size: 0.5rem;"></i>
                NOW ACCEPTING Q3 COHORT APPLICATIONS
            </div>

            <h1 class="fl-landing-title">
                Connect with the top 1% of <span class="fl-landing-highlight">founders &amp; investors.</span>
            </h1>

            <p class="fl-landing-subtitle">
                An exclusive, vetted network engineered for high-stakes professional matchmaking. We align ambitious technical talent with visionary capital.
            </p>

            <div class="d-flex flex-wrap justify-content-center gap-3 mb-5">
                <a href="Register.aspx" class="btn btn-fl-teal px-4 py-2 fs-6">
                    <span>Apply as Founder</span>
                    <i class="bi bi-arrow-right"></i>
                </a>
                <a href="Login.aspx" class="btn btn-dark border border-secondary border-opacity-50 px-4 py-2 fs-6">
                    Investor Portal
                </a>
            </div>

            <div class="pt-4">
                <i class="bi bi-chevron-down fl-hero-arrow"></i>
            </div>
        </div>
    </section>

    <!-- Section 1: Precision Engineering -->
    <section class="py-5 bg-white border-bottom border-slate-200">
        <div class="container py-4">
            <div class="text-center max-w-700 mx-auto mb-5">
                <h2 class="fw-bold mb-3 fs-2">Precision Engineering for Partnerships</h2>
                <p class="text-muted">
                    Our proprietary algorithm analyzes over 50 data points to ensure compatibility across technical stack, business model, and operational ethos.
                </p>
            </div>

            <div class="row g-4">
                <div class="col-md-4">
                    <div class="p-4 rounded-3 h-100 border border-slate-100 shadow-sm bg-white position-relative">
                        <div class="fl-stat-icon-wrapper bg-teal-subtle text-teal mb-3">
                            <i class="bi bi-shield-check"></i>
                        </div>
                        <h5 class="fw-bold mb-2">1. Rigorous Vetting</h5>
                        <p class="text-muted small mb-0 lh-base">
                            Every profile undergoes a manual review process by our committee to ensure baseline traction, technical proficiency, and verified capital.
                        </p>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="p-4 rounded-3 h-100 border border-slate-100 shadow-sm bg-white position-relative">
                        <div class="fl-stat-icon-wrapper bg-teal-subtle text-teal mb-3">
                            <i class="bi bi-sliders"></i>
                        </div>
                        <h5 class="fw-bold mb-2">2. Skill Matrix Alignment</h5>
                        <p class="text-muted small mb-0 lh-base">
                            We map complimentary skill sets—pairing visionary GTM specialists with robust systems architects to build balanced founding teams.
                        </p>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="p-4 rounded-3 h-100 border border-slate-100 shadow-sm bg-white position-relative">
                        <div class="fl-stat-icon-wrapper bg-teal-subtle text-teal mb-3">
                            <i class="bi bi-send-check"></i>
                        </div>
                        <h5 class="fw-bold mb-2">3. Secure Introductions</h5>
                        <p class="text-muted small mb-0 lh-base">
                            Once mutual interest is established, warm introductions are facilitated through our encrypted platform, prioritizing privacy and intent.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Section 2: The Intelligence Behind the Match -->
    <section class="py-5 bg-light border-bottom border-slate-200">
        <div class="container py-4">
            <div class="row align-items-center g-5">
                <div class="col-lg-6">
                    <h2 class="fw-bold fs-2 mb-3">The Intelligence Behind the Match</h2>
                    <p class="text-muted mb-4 lh-base">
                        Stop wasting time on misaligned networking events. Our matching engine visualizes your operational blind spots and sources the exact talent or capital required to accelerate your roadmap.
                    </p>

                    <div class="d-flex flex-column gap-3 mb-4">
                        <div class="d-flex align-items-start gap-3">
                            <div class="text-teal fs-5 mt-1"><i class="bi bi-check2-circle"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1">Technical Stack Compatibility</h6>
                                <p class="text-muted small mb-0">Cross-reference frontend, backend, and infrastructure proficiencies.</p>
                            </div>
                        </div>

                        <div class="d-flex align-items-start gap-3">
                            <div class="text-teal fs-5 mt-1"><i class="bi bi-check2-circle"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1">Investment Thesis Alignment</h6>
                                <p class="text-muted small mb-0">Match stage, sector, and check size parameters instantly.</p>
                            </div>
                        </div>
                    </div>

                    <a href="FindCoFounders.aspx" class="btn btn-fl-primary px-4">
                        Discover Matches
                    </a>
                </div>

                <div class="col-lg-6">
                    <div class="p-4 bg-white rounded-4 border border-slate-200 shadow-sm d-flex flex-column gap-3">
                        <!-- Match Card 1 -->
                        <div class="p-3 rounded-3 border border-slate-100 bg-white">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                                <div class="d-flex align-items-center gap-2">
                                    <img src="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100" class="rounded-circle" width="38" height="38" />
                                    <div>
                                        <div class="fw-bold small">Shreya J</div>
                                        <div class="text-muted" style="font-size: 0.75rem;">Full Stack &amp; AI Architect</div>
                                    </div>
                                </div>
                                <span class="badge bg-teal-subtle text-teal fw-bold">98% Match</span>
                            </div>
                            <div class="progress mb-2" style="height: 6px;">
                                <div class="progress-bar bg-success" style="width: 98%;"></div>
                            </div>
                            <div class="d-flex gap-2">
                                <span class="badge bg-light text-dark border">React</span>
                                <span class="badge bg-light text-dark border">Node.js</span>
                                <span class="badge bg-light text-dark border">Series A</span>
                            </div>
                        </div>

                        <!-- Match Card 2 -->
                        <div class="p-3 rounded-3 border border-slate-100 bg-white">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                                <div class="d-flex align-items-center gap-2">
                                    <img src="https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100" class="rounded-circle" width="38" height="38" />
                                    <div>
                                        <div class="fw-bold small">Manoj T.</div>
                                        <div class="text-muted" style="font-size: 0.75rem;">Partner @ Apex Ventures</div>
                                    </div>
                                </div>
                                <span class="badge bg-light text-muted border fw-bold">74% Match</span>
                            </div>
                            <div class="progress mb-2" style="height: 6px;">
                                <div class="progress-bar bg-teal" style="width: 74%;"></div>
                            </div>
                            <div class="d-flex gap-2">
                                <span class="badge bg-light text-dark border">Fintech</span>
                                <span class="badge bg-light text-dark border">Seed</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Section 3: Actively Raising -->
    <section class="py-5 bg-white">
        <div class="container py-4">
            <div class="d-flex flex-wrap justify-content-between align-items-end mb-4">
                <div>
                    <h2 class="fw-bold fs-2 mb-1">Actively Raising</h2>
                    <p class="text-muted mb-0">Curated opportunities from the network.</p>
                </div>
                <a href="ExploreStartups.aspx" class="text-teal fw-bold text-decoration-none">
                    View all deal flow <i class="bi bi-arrow-right"></i>
                </a>
            </div>

            <!-- Startups Grid bound to SQL Database -->
            <div class="row g-4">
                <asp:Repeater ID="rptRaisingStartups" runat="server">
                    <ItemTemplate>
                        <div class="col-md-4">
                            <div class="fl-raising-card h-100 d-flex flex-column">
                                <div class="position-relative">
                                    <img src='<%# Eval("LogoUrl") %>' alt='<%# Eval("Name") %>' class="fl-raising-img" />
                                    <span class="position-absolute top-0 end-0 m-3 badge bg-white text-dark shadow-sm fw-bold">
                                        <%# Eval("Stage") %>
                                    </span>
                                </div>
                                <div class="p-4 d-flex flex-column flex-grow-1">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <h5 class="fw-bold mb-0"><%# Eval("Name") %></h5>
                                        <span class="text-muted"><i class="bi bi-bookmark"></i></span>
                                    </div>
                                    <p class="text-muted small flex-grow-1 mb-4 lh-base">
                                        <%# Eval("ShortDescription") %>
                                    </p>
                                    
                                    <div class="pt-3 border-top border-slate-100 mb-3">
                                        <div class="d-flex justify-content-between small text-muted mb-1">
                                            <span>Raising:</span>
                                            <span class="fw-bold text-dark"><%# FormatCurrency(Eval("FundingGoal")) %></span>
                                        </div>
                                        <div class="d-flex justify-content-between small text-muted mb-2">
                                            <span>Committed:</span>
                                            <span class="fw-bold text-teal"><%# FormatCurrency(Eval("FundingRaised")) %></span>
                                        </div>
                                        <div class="progress" style="height: 6px;">
                                            <div class="progress-bar bg-teal" style='<%# "width:" + CalculateProgress(Eval("FundingRaised"), Eval("FundingGoal")) + "%;" %>'></div>
                                        </div>
                                    </div>

                                    <a href='<%# "StartupDetails.aspx?id=" + Eval("StartupId") %>' class="btn btn-outline-dark w-100 btn-sm fw-semibold">
                                        Request Deck
                                    </a>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <!-- Platform Stats Banner -->
    <section class="bg-black text-white py-5 border-top border-dark">
        <div class="container py-4">
            <div class="row g-4 text-center">
                <div class="col-md-4 border-end border-dark">
                    <h2 class="display-5 fw-extrabold text-teal mb-1">12000+</h2>
                    <p class="text-uppercase tracking-wider small text-secondary fw-semibold mb-0">Vetted Founders</p>
                </div>
                <div class="col-md-4 border-end border-dark">
                    <h2 class="display-5 fw-extrabold text-teal mb-1">&#8377;4.2Cr</h2>
                    <p class="text-uppercase tracking-wider small text-secondary fw-semibold mb-0">Capital Deployed</p>
                </div>
                <div class="col-md-4">
                    <h2 class="display-5 fw-extrabold text-teal mb-1">850+</h2>
                    <p class="text-uppercase tracking-wider small text-secondary fw-semibold mb-0">Active Funds &amp; Angels</p>
                </div>
            </div>
        </div>
    </section>
</asp:Content>
