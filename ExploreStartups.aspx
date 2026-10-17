<%@ Page Title="Explore Startups" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="ExploreStartups.aspx.cs" Inherits="FoundrLink.ExploreStartups" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-startup-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: 14px;
            padding: 24px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: all 0.2s ease;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            height: 100%;
        }
        .fl-startup-card:hover {
            box-shadow: 0 8px 20px rgba(0,0,0,0.06);
            transform: translateY(-2px);
        }
        .fl-startup-logo-box {
            width: 52px;
            height: 52px;
            border-radius: 10px;
            border: 1px solid #E2E8F0;
            background: #F8FAFC;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }
        .fl-skill-chip {
            background-color: #EEF2FF;
            color: #4F46E5;
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 6px;
            display: inline-block;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mb-4">
        <h2 class="fw-bold mb-1 fs-3">Explore Startups</h2>
        <p class="text-muted small">Discover ideas, projects and teams looking for people like you.</p>
    </div>

    <!-- Filter Card -->
    <div class="fl-card mb-4">
        <div class="mb-3">
            <div class="input-group">
                <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="Search startups, industries or skills..." />
            </div>
        </div>

        <div class="row g-3 mb-3">
            <div class="col-md-3">
                <asp:DropDownList ID="ddlIndustry" runat="server" CssClass="form-select">
                    <asp:ListItem Value="" Text="All Industries" />
                    <asp:ListItem Value="AI/ML" Text="AI/ML" />
                    <asp:ListItem Value="FinTech" Text="FinTech" />
                    <asp:ListItem Value="PropTech" Text="PropTech" />
                    <asp:ListItem Value="HealthTech" Text="HealthTech" />
                    <asp:ListItem Value="Climate Tech" Text="Climate Tech" />
                    <asp:ListItem Value="Sustainability" Text="Sustainability" />
                </asp:DropDownList>
            </div>

            <div class="col-md-3">
                <asp:DropDownList ID="ddlSkill" runat="server" CssClass="form-select">
                    <asp:ListItem Value="" Text="Required Skill" />
                    <asp:ListItem Value="Full Stack" Text="Full Stack Dev" />
                    <asp:ListItem Value="Product Manager" Text="Product Manager" />
                    <asp:ListItem Value="Smart Contract" Text="Smart Contract Dev" />
                    <asp:ListItem Value="UI/UX" Text="UI/UX Designer" />
                    <asp:ListItem Value="Data Scientist" Text="Data Scientist" />
                    <asp:ListItem Value="Python" Text="Python" />
                    <asp:ListItem Value="React" Text="React" />
                </asp:DropDownList>
            </div>

            <div class="col-md-3">
                <asp:DropDownList ID="ddlStage" runat="server" CssClass="form-select">
                    <asp:ListItem Value="" Text="Startup Stage" />
                    <asp:ListItem Value="Pre-Seed" Text="Pre-Seed" />
                    <asp:ListItem Value="Seed Stage" Text="Seed Stage" />
                    <asp:ListItem Value="Series A" Text="Series A" />
                    <asp:ListItem Value="MVP" Text="MVP" />
                </asp:DropDownList>
            </div>

            <div class="col-md-3">
                <asp:DropDownList ID="ddlTeamSize" runat="server" CssClass="form-select">
                    <asp:ListItem Value="" Text="Team Size" />
                    <asp:ListItem Value="1-5" Text="1-5" />
                    <asp:ListItem Value="6-15" Text="6-15" />
                    <asp:ListItem Value="16-50" Text="16-50" />
                </asp:DropDownList>
            </div>
        </div>

        <div class="d-flex justify-content-end gap-2">
            <asp:Button ID="btnClear" runat="server" Text="Clear Filters" CssClass="btn btn-fl-outline" OnClick="btnClear_Click" />
            <asp:Button ID="btnApply" runat="server" Text="Apply Filters" CssClass="btn btn-fl-primary" OnClick="btnApply_Click" />
        </div>
    </div>

    <!-- Results Subheader -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-3">
        <div class="small text-muted">
            Showing <strong class="text-dark"><asp:Literal ID="litMatchCount" runat="server" Text="12" /></strong> startups matching your profile
        </div>
        <div class="d-flex align-items-center gap-2">
            <span class="small text-muted">SORT BY</span>
            <asp:DropDownList ID="ddlSort" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                <asp:ListItem Value="match" Text="Best Match" />
                <asp:ListItem Value="newest" Text="Newest First" />
                <asp:ListItem Value="size" Text="Team Size" />
            </asp:DropDownList>
        </div>
    </div>

    <!-- Startups Grid -->
    <div class="row g-4 mb-4">
        <asp:Repeater ID="rptStartups" runat="server">
            <ItemTemplate>
                <div class="col-md-6">
                    <div class="fl-startup-card">
                        <div>
                            <div class="d-flex align-items-start gap-3 mb-3">
                                <div class="fl-startup-logo-box">
                                    <img src='<%# Eval("LogoUrl") %>' alt='<%# Eval("Name") %>' width="44" height="44" style="object-fit:cover; border-radius:6px;" onerror="this.src='https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100';" />
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="fw-bold mb-0 text-dark"><%# Eval("Name") %></h5>
                                    <div class="text-muted small">
                                        <i class="bi bi-geo-alt"></i> <%# Eval("Location") %>
                                    </div>
                                </div>
                            </div>

                            <p class="text-muted small mb-3 lh-base">
                                <%# Eval("ShortDescription") %>
                            </p>

                            <div class="d-flex flex-wrap gap-2 mb-3">
                                <span class="badge bg-light text-dark border"><%# Eval("Industry") %></span>
                                <span class="badge bg-light text-dark border"><%# Eval("Stage") %></span>
                                <span class="badge bg-light text-dark border"><i class="bi bi-people me-1"></i><%# Eval("TeamSize") %> members</span>
                            </div>

                            <div class="mb-3">
                                <div class="text-uppercase text-muted" style="font-size: 0.68rem; font-weight: 700; margin-bottom: 4px;">REQUIRED SKILLS</div>
                                <div class="d-flex flex-wrap gap-2">
                                    <%# FormatSkills(Eval("RequiredSkills")) %>
                                </div>
                            </div>
                        </div>

                        <div class="pt-3 border-top border-slate-100 d-flex justify-content-between align-items-center mt-3">
                            <div class="d-flex align-items-center gap-2">
                                <img src='<%# Eval("FounderAvatar") %>' class="rounded-circle" width="32" height="32" style="object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                                <div>
                                    <div class="fw-bold text-dark" style="font-size: 0.8rem;"><%# Eval("FounderName") %></div>
                                    <div class="text-muted" style="font-size: 0.7rem;"><%# Eval("FounderTitle") %></div>
                                </div>
                            </div>

                            <a href='<%# "StartupDetails.aspx?id=" + Eval("StartupId") %>' class="btn btn-fl-outline btn-sm">
                                View Details
                            </a>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Content>
