<%@ Page Title="Founder Profile" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="FoundrLink.Profile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-profile-header-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: 16px;
            padding: 32px;
            margin-bottom: 24px;
        }
        .fl-profile-avatar-xl {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            background: #E2E8F0;
            border: 4px solid #FFFFFF;
            box-shadow: 0 4px 12px rgba(0,0,0,0.06);
        }
        .fl-impact-card {
            background-color: #0F172A;
            color: #FFFFFF;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
        }
        .fl-impact-value {
            font-size: 2.5rem;
            font-weight: 800;
            line-height: 1;
        }
        .fl-tag-chip {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 8px;
            background: #F1F5F9;
            color: #334155;
            font-size: 0.82rem;
            font-weight: 500;
            margin-right: 6px;
            margin-bottom: 8px;
        }
        .fl-startup-preview-banner {
            height: 70px;
            background: linear-gradient(90deg, #0F172A 0%, #0D9488 100%);
            border-top-left-radius: 14px;
            border-top-right-radius: 14px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Top Header Banner Card -->
    <div class="fl-profile-header-card d-flex flex-wrap align-items-center justify-content-between gap-4">
        <div class="d-flex flex-wrap align-items-center gap-4">
            <asp:Image ID="imgAvatar" runat="server" CssClass="fl-profile-avatar-xl" ImageUrl="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200" />
            <div>
                <h2 class="display-6 fw-bold mb-1">
                    <asp:Literal ID="litFullName" runat="server" Text="Yash Vinchhi" />
                </h2>
                <h5 class="text-secondary fw-medium mb-3">
                    <asp:Literal ID="litHeadline" runat="server" Text="Founder &amp; CEO @ NexusTech" />
                </h5>
                <div class="d-flex flex-wrap align-items-center gap-3 text-muted small">
                    <span><i class="bi bi-geo-alt me-1"></i><asp:Literal ID="litLocation" runat="server" Text="Mumbai, India" /></span>
                    <span><i class="bi bi-briefcase me-1"></i><asp:Literal ID="litIndustry" runat="server" Text="SaaS, FinTech" /></span>
                    <asp:Panel ID="pnlVerified" runat="server" CssClass="badge bg-teal-subtle text-teal fw-semibold rounded-pill px-3 py-1">
                        <i class="bi bi-patch-check-fill me-1"></i> Verified Founder
                    </asp:Panel>
                </div>
            </div>
        </div>

        <div class="d-flex align-items-center gap-2">
            <button type="button" class="btn btn-fl-outline" onclick="navigator.clipboard.writeText(window.location.href); alert('Profile link copied to clipboard!');">
                <i class="bi bi-share"></i> Share
            </button>
            <a href="Settings.aspx" class="btn btn-fl-primary">
                <i class="bi bi-pencil"></i> Edit Profile
            </a>
        </div>
    </div>

    <!-- Main Content Grid -->
    <div class="row g-4">
        <!-- Left 8 Columns -->
        <div class="col-lg-8">
            <!-- About Me Card -->
            <div class="fl-card mb-4">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <div class="fl-stat-icon-wrapper bg-teal-subtle text-teal" style="width: 32px; height: 32px; font-size: 1rem;">
                        <i class="bi bi-person"></i>
                    </div>
                    <h5 class="fw-bold mb-0">About Me</h5>
                </div>
                <div class="text-muted lh-base" style="font-size: 0.95rem;">
                    <asp:Literal ID="litBio" runat="server" />
                </div>
            </div>

            <!-- Current Startup Summary Card -->
            <div class="fl-card p-0 overflow-hidden mb-4">
                <div class="fl-startup-preview-banner"></div>
                <div class="p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <a id="lnkStartupWebsite" runat="server" href="#" target="_blank" class="fw-bold text-dark text-decoration-none fs-5 d-flex align-items-center gap-2">
                            <asp:Literal ID="litStartupWebsite" runat="server" Text="nexustech.io" />
                            <i class="bi bi-box-arrow-up-right fs-6 text-muted"></i>
                        </a>
                        <span class="badge bg-light text-muted border px-3 py-1 fw-bold text-uppercase">
                            <asp:Literal ID="litStartupStage" runat="server" Text="SEED STAGE" />
                        </span>
                    </div>

                    <div class="row text-center py-3 my-2 border-top border-bottom border-slate-100 g-3">
                        <div class="col-3 border-end">
                            <div class="text-muted text-uppercase" style="font-size: 0.7rem; font-weight: 700;">FOUNDED</div>
                            <div class="fw-bold fs-5 text-dark"><asp:Literal ID="litFoundedYear" runat="server" Text="2022" /></div>
                        </div>
                        <div class="col-3 border-end">
                            <div class="text-muted text-uppercase" style="font-size: 0.7rem; font-weight: 700;">TEAM SIZE</div>
                            <div class="fw-bold fs-5 text-dark"><asp:Literal ID="litTeamSize" runat="server" Text="12" /></div>
                        </div>
                        <div class="col-3 border-end">
                            <div class="text-muted text-uppercase" style="font-size: 0.7rem; font-weight: 700;">FUNDING</div>
                            <div class="fw-bold fs-5 text-dark"><asp:Literal ID="litFunding" runat="server" Text="₹1.5M" /></div>
                        </div>
                        <div class="col-3">
                            <div class="text-muted text-uppercase" style="font-size: 0.7rem; font-weight: 700;">MRR</div>
                            <div class="fw-bold fs-5 text-dark"><asp:Literal ID="litMRR" runat="server" Text="₹45k" /></div>
                        </div>
                    </div>

                    <p class="text-muted small mb-0 mt-3 lh-base">
                        <asp:Literal ID="litStartupDescription" runat="server" Text="Automating backend compliance and payment routing for marketplace platforms. We reduce integration time by 60% and ensure global cross-border regulatory compliance." />
                    </p>
                </div>
            </div>

            <!-- I Can Offer & Looking For Row -->
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="fl-card h-100">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <div class="fl-stat-icon-wrapper bg-teal-subtle text-teal" style="width: 32px; height: 32px; font-size: 1rem;">
                                <i class="bi bi-gift"></i>
                            </div>
                            <h5 class="fw-bold mb-0">I Can Offer</h5>
                        </div>
                        <ul class="list-unstyled d-flex flex-column gap-3 mb-0">
                            <asp:Repeater ID="rptCanOffer" runat="server">
                                <ItemTemplate>
                                    <li class="d-flex align-items-start gap-2 small text-dark">
                                        <i class="bi bi-check2-circle text-teal fs-6 mt-0"></i>
                                        <span><%# Container.DataItem %></span>
                                    </li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ul>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="fl-card h-100">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <div class="fl-stat-icon-wrapper bg-light text-muted border" style="width: 32px; height: 32px; font-size: 1rem;">
                                <i class="bi bi-search"></i>
                            </div>
                            <h5 class="fw-bold mb-0">Looking For</h5>
                        </div>
                        <ul class="list-unstyled d-flex flex-column gap-3 mb-0">
                            <asp:Repeater ID="rptLookingFor" runat="server">
                                <ItemTemplate>
                                    <li class="d-flex align-items-start gap-2 small text-dark">
                                        <i class="bi bi-arrow-right text-muted fs-6 mt-0"></i>
                                        <span><%# Container.DataItem %></span>
                                    </li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right 4 Columns -->
        <div class="col-lg-4">
            <!-- Platform Impact Dark Card -->
            <div class="fl-impact-card">
                <div class="text-uppercase tracking-wider fw-bold small text-secondary mb-4">PLATFORM IMPACT</div>
                <div class="row g-4">
                    <div class="col-6">
                        <div class="fl-impact-value text-white">
                            <asp:Literal ID="litImpactConnections" runat="server" Text="342" />
                        </div>
                        <div class="text-secondary small mt-1">Connections</div>
                    </div>
                    <div class="col-6">
                        <div class="fl-impact-value text-teal">
                            <asp:Literal ID="litImpactIntros" runat="server" Text="14" />
                        </div>
                        <div class="text-secondary small mt-1">Intros Made</div>
                    </div>
                    <div class="col-6">
                        <div class="fl-impact-value text-white">
                            <asp:Literal ID="litImpactTeams" runat="server" Text="3" />
                        </div>
                        <div class="text-secondary small mt-1">Active Teams</div>
                    </div>
                    <div class="col-6">
                        <div class="fl-impact-value text-white">
                            <asp:Literal ID="litImpactSaved" runat="server" Text="8" />
                        </div>
                        <div class="text-secondary small mt-1">Projects Saved</div>
                    </div>
                </div>
            </div>

            <!-- Interests & Expertise Card -->
            <div class="fl-card mb-4">
                <div class="fl-card-header mb-3">
                    <h5 class="fw-bold mb-0">INTERESTS &amp; EXPERTISE</h5>
                </div>
                <div class="d-flex flex-wrap">
                    <asp:Repeater ID="rptInterests" runat="server">
                        <ItemTemplate>
                            <span class="fl-tag-chip"><%# Container.DataItem %></span>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Base of Operations Map Card -->
            <div class="fl-card p-0 overflow-hidden">
                <div class="p-3 d-flex justify-content-between align-items-center border-bottom border-slate-100">
                    <span class="fw-bold small text-dark">Base of Operations</span>
                    <i class="bi bi-map text-muted"></i>
                </div>
                <div style="height: 180px; background: url('https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&auto=format&fit=crop&q=80') center center / cover no-repeat; position: relative;">
                    <div class="position-absolute bottom-0 start-0 m-3 px-3 py-1 bg-white rounded shadow-sm fw-bold small">
                        <asp:Literal ID="litBaseLocation" runat="server" Text="San Francisco &amp; Mumbai" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
