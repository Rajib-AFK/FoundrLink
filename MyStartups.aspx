<%@ Page Title="My Startups" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="MyStartups.aspx.cs" Inherits="FoundrLink.MyStartups" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-startup-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: var(--fl-radius-card);
            padding: 24px;
            margin-bottom: 20px;
            transition: all 0.2s ease;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
        }
        .fl-startup-card:hover {
            box-shadow: 0 6px 18px rgba(0,0,0,0.05);
            border-color: #CBD5E1;
        }
        .fl-startup-logo {
            width: 56px;
            height: 56px;
            border-radius: 10px;
            object-fit: cover;
            border: 1px solid #E2E8F0;
        }
        .fl-badge-status {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 20px;
        }
        .fl-stat-pill {
            background-color: #F8FAFC;
            border: 1px solid #E2E8F0;
            border-radius: 8px;
            padding: 8px 14px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
        <div>
            <h2 class="fw-bold text-dark mb-1" style="font-size: 1.85rem; letter-spacing: -0.02em;">My Startups</h2>
            <p class="text-muted small mb-0">Manage your active ventures, open positions, team rosters, and investor pitch details.</p>
        </div>
        <div>
            <a href="ManageStartup.aspx" class="btn-fl-primary d-inline-flex align-items-center gap-2 px-3 py-2 fw-semibold" style="font-size: 0.88rem;">
                <i class="bi bi-plus-lg"></i> Create New Startup
            </a>
        </div>
    </div>

    <!-- Alert Panel -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show mb-4" role="alert">
        <asp:Literal ID="litAlertMessage" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- KPI Summary Row -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="fl-card p-3 d-flex align-items-center gap-3">
                <div class="fl-stat-icon-wrapper bg-dark text-white rounded-3 p-3">
                    <i class="bi bi-briefcase-fill fs-4"></i>
                </div>
                <div>
                    <div class="text-muted small fw-medium">Ventures Founded</div>
                    <div class="fs-4 fw-bold text-dark"><asp:Literal ID="litTotalVentures" runat="server" Text="0" /></div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="fl-card p-3 d-flex align-items-center gap-3">
                <div class="fl-stat-icon-wrapper bg-teal-subtle text-teal rounded-3 p-3">
                    <i class="bi bi-people-fill fs-4"></i>
                </div>
                <div>
                    <div class="text-muted small fw-medium">Active Team Members</div>
                    <div class="fs-4 fw-bold text-dark"><asp:Literal ID="litTotalTeamMembers" runat="server" Text="0" /></div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="fl-card p-3 d-flex align-items-center gap-3">
                <div class="fl-stat-icon-wrapper bg-warning-subtle text-warning rounded-3 p-3">
                    <i class="bi bi-envelope-paper-fill fs-4"></i>
                </div>
                <div>
                    <div class="text-muted small fw-medium">Pending Join Requests</div>
                    <div class="fs-4 fw-bold text-dark"><asp:Literal ID="litPendingRequests" runat="server" Text="0" /></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Empty State -->
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="fl-card text-center py-5">
        <div style="font-size: 3rem; color: #94A3B8;"><i class="bi bi-rocket-takeoff"></i></div>
        <h4 class="fw-bold text-dark mt-3 mb-1">No ventures published yet</h4>
        <p class="text-muted small mb-4" style="max-width: 480px; margin: 0 auto;">
            You haven't listed any startups on FoundrLink yet. Create your startup pitch to begin recruiting co-founders, hiring early talent, and meeting investors.
        </p>
        <a href="ManageStartup.aspx" class="btn-fl-primary px-4 py-2">
            <i class="bi bi-plus-lg me-1"></i> Create Your First Startup
        </a>
    </asp:Panel>

    <!-- Startups List -->
    <asp:Repeater ID="rptStartups" runat="server" OnItemCommand="rptStartups_ItemCommand">
        <ItemTemplate>
            <div class="fl-startup-card">
                <div class="d-flex flex-wrap justify-content-between align-items-start gap-3 mb-3">
                    <div class="d-flex align-items-start gap-3">
                        <img src='<%# !string.IsNullOrEmpty(Eval("LogoUrl")?.ToString()) ? Eval("LogoUrl") : "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100" %>' 
                             class="fl-startup-logo" 
                             onerror="this.src='https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100';" />
                        <div>
                            <div class="d-flex align-items-center gap-2 mb-1">
                                <h5 class="fw-bold text-dark mb-0"><%#: Eval("Name") %></h5>
                                <span class='<%# "fl-badge-status " + (Eval("Status")?.ToString() == "Active" || Eval("Status")?.ToString() == "Published" ? "bg-success-subtle text-success" : "bg-secondary-subtle text-secondary") %>'>
                                    <%#: Eval("Status") %>
                                </span>
                                <span class="badge bg-light text-muted border"><%#: Eval("Stage") %></span>
                            </div>
                            <div class="text-muted small mb-2"><%#: Eval("Tagline") %></div>
                            <div class="small text-muted">
                                <i class="bi bi-geo-alt me-1"></i><%#: Eval("Location") %> &bull; 
                                <i class="bi bi-tag me-1"></i><%#: Eval("Industry") %> &bull; 
                                Founded <%#: Eval("FoundedYear") %>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex gap-2">
                        <a href='<%# "StartupDetails.aspx?id=" + Eval("StartupId") %>' class="btn btn-sm btn-outline-secondary px-3 py-1 fw-medium" title="Public Listing">
                            <i class="bi bi-eye me-1"></i> View
                        </a>
                        <a href='<%# "ManageStartup.aspx?id=" + Eval("StartupId") %>' class="btn btn-sm btn-dark px-3 py-1 fw-medium" title="Edit Startup">
                            <i class="bi bi-pencil-square me-1"></i> Edit
                        </a>
                    </div>
                </div>

                <!-- Traction Pills -->
                <div class="row g-2 mb-3">
                    <div class="col-sm-3 col-6">
                        <div class="fl-stat-pill text-center">
                            <div class="text-muted small" style="font-size: 0.72rem;">Team Size</div>
                            <div class="fw-bold text-dark"><%#: Eval("TeamCount") %> Members</div>
                        </div>
                    </div>
                    <div class="col-sm-3 col-6">
                        <div class="fl-stat-pill text-center">
                            <div class="text-muted small" style="font-size: 0.72rem;">Open Positions</div>
                            <div class="fw-bold text-dark"><%#: Eval("OpenPositionsCount") %> Roles</div>
                        </div>
                    </div>
                    <div class="col-sm-3 col-6">
                        <div class="fl-stat-pill text-center">
                            <div class="text-muted small" style="font-size: 0.72rem;">Funding Goal</div>
                            <div class="fw-bold text-dark"><%# FormatCurrency(Eval("FundingGoal")) %></div>
                        </div>
                    </div>
                    <div class="col-sm-3 col-6">
                        <div class="fl-stat-pill text-center">
                            <div class="text-muted small" style="font-size: 0.72rem;">Capital Raised</div>
                            <div class="fw-bold text-dark"><%# FormatCurrency(Eval("FundingRaised")) %></div>
                        </div>
                    </div>
                </div>

                <!-- Footer Quick Links -->
                <div class="pt-3 border-top d-flex justify-content-between align-items-center flex-wrap gap-2" style="border-color: #F1F5F9 !important;">
                    <div class="d-flex gap-3 small">
                        <a href='<%# "TeamDetails.aspx?id=" + Eval("StartupId") %>' class="text-decoration-none text-muted fw-semibold">
                            <i class="bi bi-people me-1"></i> Team &amp; Careers (<%#: Eval("OpenPositionsCount") %>)
                        </a>
                        <a href='<%# "CollaborationRequests.aspx?tab=Received" %>' class="text-decoration-none text-muted fw-semibold">
                            <i class="bi bi-inbox me-1"></i> Review Requests (<%#: Eval("PendingRequestCount") %>)
                        </a>
                    </div>

                    <div>
                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteStartup" CommandArgument='<%# Eval("StartupId") %>' CssClass="text-danger small text-decoration-none" OnClientClick="return confirm('Are you sure you want to delete this startup? All associated team and position records will be permanently removed.');">
                            <i class="bi bi-trash3 me-1"></i> Delete
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Content>
