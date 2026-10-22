<%@ Page Title="Founder Profile" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="FoundrLink.Profile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-profile-header-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: var(--fl-radius-card);
            padding: 32px;
            margin-bottom: 24px;
        }
        .fl-profile-avatar-xl {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            background: #CBD5E1;
            border: 4px solid #FFFFFF;
            box-shadow: 0 4px 12px rgba(0,0,0,0.06);
            flex-shrink: 0;
        }
        .fl-impact-card {
            background-color: #0F172A;
            color: #FFFFFF;
            border-radius: var(--fl-radius-card);
            padding: 28px 24px;
            margin-bottom: 24px;
        }
        .fl-impact-value {
            font-size: 2.3rem;
            font-weight: 800;
            line-height: 1;
            letter-spacing: -0.02em;
        }
        .fl-tag-chip {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 6px;
            background: #F1F5F9;
            color: #334155;
            font-size: 0.8rem;
            font-weight: 500;
            margin-right: 6px;
            margin-bottom: 8px;
        }
        .fl-startup-preview-banner {
            height: 80px;
            background: linear-gradient(90deg, #0F172A 0%, #2DD4BF 100%);
            border-top-left-radius: var(--fl-radius-card);
            border-top-right-radius: var(--fl-radius-card);
            position: relative;
        }
        .fl-startup-logo-overlap {
            position: absolute;
            left: 24px;
            bottom: -28px;
            width: 64px;
            height: 64px;
            border-radius: 12px;
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.06);
            overflow: hidden;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Top Header Banner Card -->
    <div class="fl-profile-header-card d-flex flex-wrap align-items-center justify-content-between gap-4">
        <div class="d-flex flex-wrap align-items-center gap-4">
            <asp:Image ID="imgAvatar" runat="server" CssClass="fl-profile-avatar-xl" ImageUrl="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200" />
            <div>
                <h2 class="fw-bold mb-1 text-dark" style="font-size: 2.2rem; letter-spacing: -0.02em;">
                    <asp:Literal ID="litFullName" runat="server" Text="Yash Vinchhi" />
                </h2>
                <h5 class="text-secondary fw-medium mb-3" style="font-size: 1.1rem; color: #475569 !important;">
                    <asp:Literal ID="litHeadline" runat="server" Text="Founder &amp; CEO @ NexusTech" />
                </h5>
                <div class="d-flex flex-wrap align-items-center gap-3 text-muted small">
                    <span><i class="bi bi-geo-alt me-1"></i><asp:Literal ID="litLocation" runat="server" Text="Mumbai, India" /></span>
                    <span><i class="bi bi-briefcase me-1"></i><asp:Literal ID="litIndustry" runat="server" Text="SaaS, FinTech" /></span>
                    <asp:Panel ID="pnlVerified" runat="server" CssClass="fl-badge fl-badge-active">
                        <i class="bi bi-patch-check-fill me-1"></i> Verified Founder
                    </asp:Panel>
                </div>
            </div>
        </div>

        <div class="d-flex align-items-center gap-2">
            <button type="button" class="btn-fl-outline" onclick="navigator.clipboard.writeText(window.location.href); alert('Profile link copied to clipboard!');">
                <i class="bi bi-share"></i> Share
            </button>
            <a id="lnkEditProfile" runat="server" href="Settings.aspx" class="btn-fl-dark">
                <i class="bi bi-pencil"></i> Edit Profile
            </a>
            <asp:Panel ID="pnlVisitorActions" runat="server" Visible="false" CssClass="d-inline-flex align-items-center gap-2">
                <asp:LinkButton ID="btnConnect" runat="server" CssClass="btn-fl-primary px-3 py-2 text-decoration-none" OnClick="btnConnect_Click">
                    <i class="bi bi-person-plus-fill me-1"></i> Connect
                </asp:LinkButton>
                <asp:LinkButton ID="btnMessage" runat="server" CssClass="btn-fl-outline px-3 py-2 text-decoration-none" OnClick="btnMessage_Click">
                    <i class="bi bi-chat-dots-fill me-1"></i> Message
                </asp:LinkButton>
                <asp:LinkButton ID="btnOpenReportProfile" runat="server" CssClass="btn btn-sm btn-outline-secondary px-2 py-2" OnClick="btnOpenReportProfile_Click" ToolTip="Report this founder profile">
                    <i class="bi bi-flag"></i>
                </asp:LinkButton>
            </asp:Panel>
        </div>
    </div>

    <!-- Profile Action Alerts -->
    <asp:Panel ID="pnlProfileAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show rounded-3 shadow-sm mb-4">
        <asp:Literal ID="litProfileAlertMessage" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- Report User Form Panel -->
    <asp:Panel ID="pnlReportUser" runat="server" Visible="false" CssClass="card border-warning-subtle bg-light p-4 mb-4 rounded-3 shadow-sm">
        <h6 class="fw-bold text-dark mb-1"><i class="bi bi-flag-fill text-danger me-1"></i> Report this Founder Profile</h6>
        <p class="text-muted small mb-3">Help maintain platform integrity. Reports are strictly confidential and investigated by FoundrLink compliance officers.</p>
        <div class="row g-3 mb-3">
            <div class="col-md-5">
                <label class="form-label small fw-semibold text-dark mb-1">Reason for Report <span class="text-danger">*</span></label>
                <asp:DropDownList ID="ddlReportUserCategory" runat="server" CssClass="form-select form-select-sm">
                    <asp:ListItem Text="Impersonation or Fake Profile" Value="Impersonation" />
                    <asp:ListItem Text="Spam or Unsolicited Marketing" Value="Spam" />
                    <asp:ListItem Text="Suspicious or Fraudulent Activity" Value="Suspicious Activity" />
                    <asp:ListItem Text="Harassment or Inappropriate Behavior" Value="Inappropriate Content" />
                    <asp:ListItem Text="Other Violation" Value="Other" />
                </asp:DropDownList>
            </div>
            <div class="col-12">
                <label class="form-label small fw-semibold text-dark mb-1">Details &amp; Explanation <span class="text-danger">*</span></label>
                <asp:TextBox ID="txtReportUserDetails" runat="server" TextMode="MultiLine" Rows="3" MaxLength="500" CssClass="form-control form-control-sm" placeholder="Please provide specific information describing why this account should be reviewed (max 500 characters)..." />
            </div>
        </div>
        <div class="d-flex gap-2">
            <asp:Button ID="btnSubmitReportUser" runat="server" Text="Submit Report" CssClass="btn btn-sm btn-danger px-3" OnClick="btnSubmitReportUser_Click" />
            <asp:Button ID="btnCancelReportUser" runat="server" Text="Cancel" CssClass="btn btn-sm btn-outline-secondary px-3" OnClick="btnCancelReportUser_Click" />
        </div>
    </asp:Panel>

    <!-- Main Content Grid -->
    <div class="row g-4">
        <!-- Left 8 Columns -->
        <div class="col-lg-8">
            <!-- About Me Card -->
            <div class="fl-card mb-4">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <i class="bi bi-person text-dark fs-5"></i>
                    <h5 class="fw-bold mb-0 text-dark">About Me</h5>
                </div>
                <div class="text-secondary lh-base" style="font-size: 0.92rem; color: #475569 !important;">
                    <asp:Literal ID="litBio" runat="server" />
                </div>
            </div>

            <!-- Current Startup Summary Card -->
            <div class="fl-card p-0 overflow-hidden mb-4">
                <div class="fl-startup-preview-banner">
                    <div class="fl-startup-logo-overlap">
                        <img src="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100" width="56" height="56" style="object-fit:cover; border-radius:8px;" alt="Logo" />
                    </div>
                </div>
                <div class="p-4" style="padding-top: 40px !important;">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <a id="lnkStartupWebsite" runat="server" href="#" target="_blank" class="fw-bold text-dark text-decoration-none fs-5 d-flex align-items-center gap-2">
                            <asp:Literal ID="litStartupWebsite" runat="server" Text="nexustech.io" />
                            <i class="bi bi-box-arrow-up-right fs-6 text-muted"></i>
                        </a>
                        <span class="badge bg-light text-muted border px-3 py-1 fw-bold text-uppercase" style="font-size: 0.72rem; letter-spacing: 0.05em;">
                            <asp:Literal ID="litStartupStage" runat="server" Text="SEED STAGE" />
                        </span>
                    </div>

                    <div class="row text-center py-3 my-2 border-top border-bottom border-slate-100 g-3" style="border-color: #F1F5F9 !important;">
                        <div class="col-3 border-end" style="border-color: #F1F5F9 !important;">
                            <div class="text-muted text-uppercase" style="font-size: 0.68rem; font-weight: 700; letter-spacing: 0.05em;">FOUNDED</div>
                            <div class="fw-bold fs-5 text-dark mt-1"><asp:Literal ID="litFoundedYear" runat="server" Text="2022" /></div>
                        </div>
                        <div class="col-3 border-end" style="border-color: #F1F5F9 !important;">
                            <div class="text-muted text-uppercase" style="font-size: 0.68rem; font-weight: 700; letter-spacing: 0.05em;">TEAM SIZE</div>
                            <div class="fw-bold fs-5 text-dark mt-1"><asp:Literal ID="litTeamSize" runat="server" Text="12" /></div>
                        </div>
                        <div class="col-3 border-end" style="border-color: #F1F5F9 !important;">
                            <div class="text-muted text-uppercase" style="font-size: 0.68rem; font-weight: 700; letter-spacing: 0.05em;">FUNDING</div>
                            <div class="fw-bold fs-5 text-dark mt-1"><asp:Literal ID="litFunding" runat="server" Text="₹1.5M" /></div>
                        </div>
                        <div class="col-3">
                            <div class="text-muted text-uppercase" style="font-size: 0.68rem; font-weight: 700; letter-spacing: 0.05em;">MRR</div>
                            <div class="fw-bold fs-5 text-dark mt-1"><asp:Literal ID="litMRR" runat="server" Text="₹45k" /></div>
                        </div>
                    </div>

                    <p class="text-muted small mb-0 mt-3 lh-base" style="font-size: 0.85rem;">
                        <asp:Literal ID="litStartupDescription" runat="server" Text="Automating backend compliance and payment routing for marketplace platforms. We reduce integration time by 60% and ensure global cross-border regulatory compliance." />
                    </p>
                </div>
            </div>

            <!-- I Can Offer & Looking For Row -->
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="fl-card h-100">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <i class="bi bi-gift text-dark fs-5"></i>
                            <h5 class="fw-bold mb-0 text-dark">I Can Offer</h5>
                        </div>
                        <ul class="list-unstyled d-flex flex-column gap-3 mb-0">
                            <asp:Repeater ID="rptCanOffer" runat="server">
                                <ItemTemplate>
                                    <li class="d-flex align-items-start gap-2 small text-dark" style="font-size: 0.85rem;">
                                        <div class="rounded-circle d-flex align-items-center justify-content-center" style="width: 18px; height: 18px; background: #E6FAF4; color: #10B981; font-size: 0.72rem; flex-shrink: 0; margin-top: 2px;">
                                            <i class="bi bi-check-lg"></i>
                                        </div>
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
                            <i class="bi bi-search text-dark fs-5"></i>
                            <h5 class="fw-bold mb-0 text-dark">Looking For</h5>
                        </div>
                        <ul class="list-unstyled d-flex flex-column gap-3 mb-0">
                            <asp:Repeater ID="rptLookingFor" runat="server">
                                <ItemTemplate>
                                    <li class="d-flex align-items-start gap-2 small text-dark" style="font-size: 0.85rem;">
                                        <i class="bi bi-arrow-right text-muted fs-6 mt-0" style="color: #94A3B8 !important;"></i>
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
                <div class="text-uppercase tracking-wider fw-bold text-secondary mb-4" style="font-size: 0.75rem; letter-spacing: 0.08em; color: #94A3B8 !important;">PLATFORM IMPACT</div>
                <div class="row g-4">
                    <div class="col-6">
                        <div class="fl-impact-value text-white">
                            <asp:Literal ID="litImpactConnections" runat="server" Text="342" />
                        </div>
                        <div class="text-secondary small mt-1" style="color: #94A3B8 !important; font-size: 0.75rem;">Connections</div>
                    </div>
                    <div class="col-6">
                        <div class="fl-impact-value" style="color: #4EE8C4;">
                            <asp:Literal ID="litImpactIntros" runat="server" Text="14" />
                        </div>
                        <div class="text-secondary small mt-1" style="color: #94A3B8 !important; font-size: 0.75rem;">Intros Made</div>
                    </div>
                    <div class="col-6">
                        <div class="fl-impact-value text-white">
                            <asp:Literal ID="litImpactTeams" runat="server" Text="3" />
                        </div>
                        <div class="text-secondary small mt-1" style="color: #94A3B8 !important; font-size: 0.75rem;">Active Teams</div>
                    </div>
                    <div class="col-6">
                        <div class="fl-impact-value text-white">
                            <asp:Literal ID="litImpactSaved" runat="server" Text="8" />
                        </div>
                        <div class="text-secondary small mt-1" style="color: #94A3B8 !important; font-size: 0.75rem;">Projects Saved</div>
                    </div>
                </div>
            </div>

            <!-- Interests & Expertise Card -->
            <div class="fl-card mb-4">
                <div class="fl-card-header mb-3">
                    <h5 class="fw-bold mb-0 text-dark" style="font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em;">INTERESTS &amp; EXPERTISE</h5>
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
                <div class="p-3 d-flex justify-content-between align-items-center border-bottom" style="border-color: #F1F5F9 !important;">
                    <span class="fw-bold small text-dark">Base of Operations</span>
                    <i class="bi bi-map text-muted"></i>
                </div>
                <div style="height: 180px; background: url('https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&auto=format&fit=crop&q=80') center center / cover no-repeat; position: relative;">
                    <div class="position-absolute bottom-0 start-0 m-3 px-3 py-1 bg-white rounded shadow-sm fw-bold small">
                        <asp:Literal ID="litBaseLocation" runat="server" Text="San Francisco" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
