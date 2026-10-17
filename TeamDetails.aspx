<%@ Page Title="Team Details" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="TeamDetails.aspx.cs" Inherits="FoundrLink.TeamDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-team-member-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: 12px;
            padding: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            text-decoration: none;
            color: inherit;
            transition: all 0.2s;
        }
        .fl-team-member-card:hover {
            border-color: #94A3B8;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            color: inherit;
        }
        .fl-role-card {
            border: 1px solid var(--fl-border-color);
            border-radius: 10px;
            padding: 16px;
            background: #FFFFFF;
        }
        .fl-timeline-item {
            position: relative;
            padding-left: 28px;
            margin-bottom: 20px;
        }
        .fl-timeline-dot {
            position: absolute;
            left: 0;
            top: 4px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background-color: var(--fl-accent-teal-dark);
        }
        .fl-timeline-dot-muted {
            background-color: #94A3B8;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Top Startup Header Card -->
    <div class="fl-card mb-4">
        <div class="d-flex flex-wrap align-items-center justify-content-between gap-4">
            <div class="d-flex align-items-center gap-4">
                <div class="fl-startup-logo-box" style="width: 80px; height: 80px;">
                    <asp:Image ID="imgLogo" runat="server" CssClass="rounded-2" Width="72" Height="72" style="object-fit:cover;" ImageUrl="https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=150" />
                </div>
                <div>
                    <h2 class="fw-bold mb-1 fs-3 text-dark">
                        <asp:Literal ID="litStartupName" runat="server" Text="NeuroSync" />
                    </h2>
                    <p class="text-muted mb-3 fs-6">
                        <asp:Literal ID="litTagline" runat="server" Text="Seamless Neural Interfaces for Remote Work" />
                    </p>
                    <div class="d-flex flex-wrap gap-2">
                        <span class="badge bg-teal-subtle text-teal rounded-pill px-3 py-1 fw-bold">
                            <i class="bi bi-circle-fill me-1" style="font-size: 0.5rem;"></i> Active
                        </span>
                        <span class="badge bg-light text-muted border rounded-pill px-3 py-1">
                            <i class="bi bi-currency-dollar me-1"></i> <asp:Literal ID="litStage" runat="server" Text="Seed Stage" />
                        </span>
                        <span class="badge bg-light text-muted border rounded-pill px-3 py-1">
                            <i class="bi bi-geo-alt me-1"></i> <asp:Literal ID="litLocation" runat="server" Text="Bangalore, Karnataka" />
                        </span>
                        <span class="badge bg-light text-muted border rounded-pill px-3 py-1">
                            <i class="bi bi-people me-1"></i> <asp:Literal ID="litTeamSize" runat="server" Text="12 Members" />
                        </span>
                    </div>
                </div>
            </div>

            <div class="d-flex align-items-center gap-2">
                <asp:Button ID="btnMessageTeam" runat="server" Text="Message Team" CssClass="btn btn-fl-outline" OnClick="btnMessageTeam_Click" />
                <a id="lnkManageTeam" runat="server" href="#" class="btn btn-fl-primary">
                    <i class="bi bi-gear me-1"></i> Manage Team
                </a>
            </div>
        </div>
    </div>

    <!-- Main Grid -->
    <div class="row g-4">
        <!-- Left Column -->
        <div class="col-lg-8">
            <!-- About the Company -->
            <div class="fl-card mb-4">
                <h5 class="fw-bold mb-3 text-dark">About the Company</h5>
                <p class="text-muted lh-base mb-0" style="font-size: 0.95rem;">
                    <asp:Literal ID="litAbout" runat="server" Text="NeuroSync is building the next generation of non-invasive neural interfaces designed specifically for knowledge workers. Our proprietary headset and software suite allows professionals to interact with complex digital environments using thought-intent, drastically reducing physical fatigue and increasing productivity in remote work settings. Founded by researchers from MIT and Stanford, we are currently in closed beta with select enterprise partners." />
                </p>
            </div>

            <!-- Team Members -->
            <div class="fl-card">
                <div class="fl-card-header mb-3">
                    <h5 class="fw-bold mb-0 text-dark">Team Members</h5>
                    <a href="#" class="small text-teal fw-bold text-decoration-none">View All</a>
                </div>

                <div class="row g-3">
                    <asp:Repeater ID="rptMembers" runat="server">
                        <ItemTemplate>
                            <div class="col-md-6">
                                <a href='<%# Eval("UserId") != DBNull.Value ? "Profile.aspx?id=" + Eval("UserId") : "#" %>' class="fl-team-member-card">
                                    <div class="d-flex align-items-center gap-3">
                                        <img src='<%# Eval("AvatarUrl") %>' class="rounded-circle" width="46" height="46" style="object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                                        <div>
                                            <div class="fw-bold text-dark small"><%# Eval("Name") %></div>
                                            <div class="text-muted" style="font-size: 0.75rem;"><%# Eval("Role") %></div>
                                        </div>
                                    </div>
                                    <i class="bi bi-arrow-right text-muted"></i>
                                </a>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>

        <!-- Right Column -->
        <div class="col-lg-4">
            <!-- Open Roles -->
            <div class="fl-card mb-4">
                <div class="fl-card-header mb-3">
                    <h5 class="fw-bold mb-0 text-dark">Open Roles</h5>
                    <span class="badge bg-light text-muted border rounded-circle" style="width: 24px; height: 24px; display:inline-flex; align-items:center; justify-content:center;">
                        <asp:Literal ID="litRoleCount" runat="server" Text="3" />
                    </span>
                </div>

                <div class="d-flex flex-column gap-3 mb-4">
                    <asp:Repeater ID="rptRoles" runat="server">
                        <ItemTemplate>
                            <div class="fl-role-card">
                                <div class="fw-bold small text-dark mb-1"><%# Eval("Title") %></div>
                                <div class="text-muted small" style="font-size: 0.75rem;">
                                    <i class="bi bi-geo-alt me-1"></i><%# Eval("Location") %> &bull; <i class="bi bi-clock me-1"></i><%# Eval("PositionType") %>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <a href="#" class="btn btn-outline-secondary w-100 btn-sm fw-semibold">
                    View Careers Page
                </a>
            </div>

            <!-- Activity Stream -->
            <div class="fl-card">
                <div class="fl-card-header mb-4">
                    <h5 class="fw-bold mb-0 text-dark">Activity</h5>
                </div>

                <div>
                    <asp:Repeater ID="rptUpdates" runat="server">
                        <ItemTemplate>
                            <div class="fl-timeline-item">
                                <div class='<%# "fl-timeline-dot " + (Container.ItemIndex > 0 ? "fl-timeline-dot-muted" : "") %>'></div>
                                <div class="small fw-semibold text-dark"><%# Eval("AuthorName") %></div>
                                <div class="text-muted small" style="font-size: 0.8rem;"><%# Eval("Content") %></div>
                                <div class="text-secondary" style="font-size: 0.7rem; margin-top: 2px;"><%# Eval("TimeAgo") %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
