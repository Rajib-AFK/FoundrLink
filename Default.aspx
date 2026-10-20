<%@ Page Title="Connect with Founders & Investors" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="FoundrLink.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-corner-card {
            background: #FFFFFF;
            border: 1px solid #E5E7EB;
            border-radius: 12px;
            padding: 32px 28px;
            position: relative;
            overflow: hidden;
            height: 100%;
        }
        .fl-corner-accent {
            position: absolute;
            top: 0;
            right: 0;
            width: 0;
            height: 0;
            border-style: solid;
            border-width: 0 44px 44px 0;
            border-color: transparent #F1F5F9 transparent transparent;
        }
        .fl-icon-mint-box {
            width: 44px;
            height: 44px;
            border-radius: 8px;
            background-color: #ECFDF5;
            color: #10B981;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            margin-bottom: 24px;
        }
        .fl-match-card-wrapper {
            position: relative;
        }
        .fl-match-card-wrapper::before {
            content: '';
            position: absolute;
            inset: -12px;
            background: radial-gradient(circle at 60% 50%, rgba(16, 185, 129, 0.12), transparent 70%);
            z-index: 0;
            border-radius: 24px;
        }
        .fl-match-card {
            position: relative;
            z-index: 1;
            background: #FFFFFF;
            border: 1px solid #E5E7EB;
            border-radius: 16px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05);
            padding: 24px;
        }
        .fl-match-candidate {
            border: 1px solid #F1F5F9;
            border-radius: 12px;
            padding: 18px;
            background: #FFFFFF;
        }
        .fl-raising-card {
            border: 1px solid #E5E7EB;
            border-radius: 12px;
            overflow: hidden;
            background: #FFFFFF;
            transition: transform 0.2s, box-shadow 0.2s;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .fl-raising-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px -5px rgba(0, 0, 0, 0.06);
        }
        .fl-raising-img {
            height: 170px;
            object-fit: cover;
            width: 100%;
        }
        .fl-stage-badge {
            position: absolute;
            top: 14px;
            right: 14px;
            background: #FFFFFF;
            color: #0F172A;
            border-radius: 6px;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 4px 10px;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
        }
        .btn-deck {
            background-color: #FFFFFF;
            color: #0F172A;
            border: 1px solid #E5E7EB;
            border-radius: 8px;
            padding: 9px;
            font-size: 0.85rem;
            font-weight: 600;
            width: 100%;
            text-align: center;
            text-decoration: none;
            display: block;
            transition: all 0.15s ease;
        }
        .btn-deck:hover {
            background-color: #F8FAFC;
            border-color: #CBD5E1;
            color: #0F172A;
        }
        .fl-hero-chevron {
            color: #64748B;
            font-size: 1.5rem;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hero Section -->
    <section class="fl-landing-hero">
        <div class="container" style="max-width: 1000px;">
            <div class="fl-landing-badge">
                <i class="bi bi-circle-fill" style="font-size: 0.5rem; color: #4EE8C4;"></i>
                NOW ACCEPTING Q3 COHORT APPLICATIONS
            </div>

            <h1 class="fl-landing-highlight">
                Connect with the top 1% of <span class="fl-landing-highlight">founders &amp;<br />investors.</span>
            </h1>

            <p class="fl-landing-subtitle">
                An exclusive, vetted network engineered for high-stakes professional matchmaking. We align ambitious technical talent with visionary capital.
            </p>

            <div class="d-flex flex-wrap justify-content-center gap-3 mb-5">
                <a href="Register.aspx" class="btn-landing-founder">
                    <span>Apply as Founder</span>
                    <i class="bi bi-arrow-right"></i>
                </a>
                <a href="Login.aspx" class="btn-landing-portal">
                    Investor Portal
                </a>
            </div>

            <div class="pt-5">
                <i class="bi bi-chevron-down fl-hero-chevron"></i>
            </div>
        </div>
    </section>

    <!-- Section 1: Precision Engineering for Partnerships -->
    <section class="py-5 bg-white">
        <div class="container py-5" style="max-width: 1200px;">
            <div class="text-center mx-auto mb-5" style="max-width: 720px;">
                <h2 class="fw-bold mb-3" style="font-size: 2.2rem; letter-spacing: -0.02em;">Precision Engineering for Partnerships</h2>
                <p class="text-muted" style="font-size: 0.95rem; line-height: 1.6;">
                    Our proprietary algorithm analyzes over 50 data points to ensure compatibility across technical stack, business model, and operational ethos.
                </p>
            </div>

            <div class="row g-4">
                <div class="col-md-4">
                    <div class="fl-corner-card">
                        <div class="fl-corner-accent"></div>
                        <div class="fl-icon-mint-box">
                            <i class="bi bi-person-check"></i>
                        </div>
                        <h4 class="fw-bold mb-2 text-dark" style="font-size: 1.15rem;">1. Rigorous Vetting</h4>
                        <p class="text-muted small mb-0" style="line-height: 1.6;">
                            Every profile undergoes a manual review process by our committee to ensure baseline traction, technical proficiency, and verified capital.
                        </p>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="fl-corner-card">
                        <div class="fl-corner-accent"></div>
                        <div class="fl-icon-mint-box">
                            <i class="bi bi-sliders"></i>
                        </div>
                        <h4 class="fw-bold mb-2 text-dark" style="font-size: 1.15rem;">2. Skill Matrix Alignment</h4>
                        <p class="text-muted small mb-0" style="line-height: 1.6;">
                            We map complimentary skill sets—pairing visionary GTM specialists with robust systems architects to build balanced founding teams.
                        </p>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="fl-corner-card">
                        <div class="fl-corner-accent"></div>
                        <div class="fl-icon-mint-box">
                            <i class="bi bi-shield-lock"></i>
                        </div>
                        <h4 class="fw-bold mb-2 text-dark" style="font-size: 1.15rem;">3. Secure Introductions</h4>
                        <p class="text-muted small mb-0" style="line-height: 1.6;">
                            Once mutual interest is established, warm introductions are facilitated through our encrypted platform, prioritizing privacy and intent.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Section 2: The Intelligence Behind the Match -->
    <section class="py-5" style="background-color: #FAFCFE; border-top: 1px solid #F1F5F9; border-bottom: 1px solid #F1F5F9;">
        <div class="container py-5" style="max-width: 1200px;">
            <div class="row align-items-center g-5">
                <div class="col-lg-6">
                    <h2 class="fw-bold mb-3" style="font-size: 2.2rem; letter-spacing: -0.02em;">The Intelligence Behind the Match</h2>
                    <p class="text-muted mb-4" style="line-height: 1.6; font-size: 0.95rem;">
                        Stop wasting time on misaligned networking events. Our matching engine visualizes your operational blind spots and sources the exact talent or capital required to accelerate your roadmap.
                    </p>

                    <div class="d-flex flex-column gap-3">
                        <div class="d-flex align-items-start gap-3">
                            <div class="rounded-circle d-flex align-items-center justify-content-center" style="width: 22px; height: 22px; background: #E6FAF4; color: #10B981; font-size: 0.8rem; margin-top: 2px;">
                                <i class="bi bi-check-lg"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark" style="font-size: 0.92rem;">Technical Stack Compatibility</h6>
                                <p class="text-muted small mb-0">Cross-reference frontend, backend, and infrastructure proficiencies.</p>
                            </div>
                        </div>

                        <div class="d-flex align-items-start gap-3">
                            <div class="rounded-circle d-flex align-items-center justify-content-center" style="width: 22px; height: 22px; background: #E6FAF4; color: #10B981; font-size: 0.8rem; margin-top: 2px;">
                                <i class="bi bi-check-lg"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark" style="font-size: 0.92rem;">Investment Thesis Alignment</h6>
                                <p class="text-muted small mb-0">Match stage, sector, and check size parameters instantly.</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="fl-match-card-wrapper">
                        <div class="fl-match-card d-flex flex-column gap-3">
                            <!-- Match Candidate 1 -->
                            <div class="fl-match-candidate">
                                <div class="d-flex align-items-center justify-content-between mb-2">
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100" class="rounded-circle" width="40" height="40" style="object-fit:cover;" alt="Shreya J" />
                                        <div class="fw-bold text-dark small">Shreya J</div>
                                    </div>
                                    <span class="small fw-bold" style="color: #059669; font-size: 0.78rem;">98% Match</span>
                                </div>
                                <div class="progress mb-3" style="height: 5px; background-color: #E2E8F0; border-radius: 4px;">
                                    <div class="progress-bar" style="width: 98%; background-color: #059669; border-radius: 4px;"></div>
                                </div>
                                <div class="d-flex gap-2">
                                    <span class="badge bg-white text-secondary border px-2 py-1" style="font-weight: 500; font-size: 0.72rem;">React</span>
                                    <span class="badge bg-white text-secondary border px-2 py-1" style="font-weight: 500; font-size: 0.72rem;">Node.js</span>
                                    <span class="badge bg-white text-secondary border px-2 py-1" style="font-weight: 500; font-size: 0.72rem;">Series A</span>
                                </div>
                            </div>

                            <!-- Match Candidate 2 -->
                            <div class="fl-match-candidate">
                                <div class="d-flex align-items-center justify-content-between mb-2">
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100" class="rounded-circle" width="40" height="40" style="object-fit:cover;" alt="Manoj T" />
                                        <div class="fw-bold text-dark small">Manoj T.</div>
                                    </div>
                                    <span class="small fw-semibold text-muted" style="font-size: 0.78rem;">74% Match</span>
                                </div>
                                <div class="progress mb-3" style="height: 5px; background-color: #E2E8F0; border-radius: 4px;">
                                    <div class="progress-bar" style="width: 74%; background-color: #CBD5E1; border-radius: 4px;"></div>
                                </div>
                                <div class="d-flex gap-2">
                                    <span class="badge bg-white text-secondary border px-2 py-1" style="font-weight: 500; font-size: 0.72rem;">Fintech</span>
                                    <span class="badge bg-white text-secondary border px-2 py-1" style="font-weight: 500; font-size: 0.72rem;">Seed</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Section 3: Actively Raising -->
    <section class="py-5" style="background-color: #F8FAFC;">
        <div class="container py-5" style="max-width: 1200px;">
            <div class="d-flex flex-wrap justify-content-between align-items-end mb-4">
                <div>
                    <h2 class="fw-bold mb-1" style="font-size: 2.2rem; letter-spacing: -0.02em;">Actively Raising</h2>
                    <p class="text-muted mb-0 small">Curated opportunities from the network.</p>
                </div>
                <a href="ExploreStartups.aspx" class="fw-semibold text-decoration-none small d-flex align-items-center gap-1" style="color: #006591;">
                    <span>View all deal flow</span>
                    <i class="bi bi-arrow-right"></i>
                </a>
            </div>

            <!-- Startups Grid bound to SQL Database -->
            <div class="row g-4">
                <asp:Repeater ID="rptRaisingStartups" runat="server">
                    <ItemTemplate>
                        <div class="col-md-4">
                            <div class="fl-raising-card">
                                <div class="position-relative">
                                    <img src='<%# Eval("LogoUrl") %>' alt='<%# Eval("Name") %>' class="fl-raising-img" onerror="this.src='https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500';" />
                                    <span class="fl-stage-badge">
                                        <%# Eval("Stage") %>
                                    </span>
                                </div>
                                <div class="p-4 d-flex flex-column flex-grow-1">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <h5 class="fw-bold mb-0 text-dark"><%# Eval("Name") %></h5>
                                        <span class="text-muted" style="cursor: pointer;"><i class="bi bi-bookmark"></i></span>
                                    </div>
                                    <p class="text-muted small flex-grow-1 mb-4 lh-base" style="min-height: 44px;">
                                        <%# Eval("ShortDescription") %>
                                    </p>
                                    
                                    <div class="pt-3 border-top mb-3" style="border-color: #F1F5F9 !important;">
                                        <div class="d-flex justify-content-between small text-muted mb-1" style="font-size: 0.8rem;">
                                            <span>Raising:</span>
                                            <span class="fw-bold text-dark"><%# FormatCurrency(Eval("FundingGoal")) %></span>
                                        </div>
                                        <div class="d-flex justify-content-between small text-muted mb-2" style="font-size: 0.8rem;">
                                            <span>Committed:</span>
                                            <span class="fw-bold" style="color: #006591;"><%# FormatCurrency(Eval("FundingRaised")) %></span>
                                        </div>
                                        <div class="progress" style="height: 4px; background-color: #E2E8F0; border-radius: 4px;">
                                            <div class="progress-bar" style='<%# "width:" + CalculateProgress(Eval("FundingRaised"), Eval("FundingGoal")) + "%; background-color: #059669; border-radius: 4px;" %>'></div>
                                        </div>
                                    </div>

                                    <a href='<%# "StartupDetails.aspx?id=" + Eval("StartupId") %>' class="btn-deck">
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
    <section class="bg-black text-white py-5">
        <div class="container py-4" style="max-width: 1200px;">
            <div class="row g-4 text-center align-items-center">
                <div class="col-md-4 border-end" style="border-color: #1F2937 !important;">
                    <h2 class="display-5 fw-extrabold mb-1" style="color: #4EE8C4; letter-spacing: -0.02em;">12000+</h2>
                    <p class="text-uppercase small fw-semibold mb-0" style="color: #64748B; letter-spacing: 0.08em; font-size: 0.75rem;">Vetted Founders</p>
                </div>
                <div class="col-md-4 border-end" style="border-color: #1F2937 !important;">
                    <h2 class="display-5 fw-extrabold mb-1" style="color: #4EE8C4; letter-spacing: -0.02em;">&#8377;4.2Cr</h2>
                    <p class="text-uppercase small fw-semibold mb-0" style="color: #64748B; letter-spacing: 0.08em; font-size: 0.75rem;">Capital Deployed</p>
                </div>
                <div class="col-md-4">
                    <h2 class="display-5 fw-extrabold mb-1" style="color: #4EE8C4; letter-spacing: -0.02em;">850+</h2>
                    <p class="text-uppercase small fw-semibold mb-0" style="color: #64748B; letter-spacing: 0.08em; font-size: 0.75rem;">Active Funds &amp; Angels</p>
                </div>
            </div>
        </div>
    </section>
</asp:Content>
