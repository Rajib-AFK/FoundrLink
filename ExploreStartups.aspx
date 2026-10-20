<%@ Page Title="Explore Startups" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="ExploreStartups.aspx.cs" Inherits="FoundrLink.ExploreStartups" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-startup-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: var(--fl-radius-card);
            padding: 24px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: all 0.2s ease;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            height: 100%;
        }
        .fl-startup-card:hover {
            box-shadow: 0 8px 20px rgba(0,0,0,0.05);
            border-color: #CBD5E1;
        }
        .fl-startup-logo-box {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            border: 1px solid #E2E8F0;
            background: #F8FAFC;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            flex-shrink: 0;
        }
        .fl-skill-pill {
            background-color: #EEF2FF;
            color: #4F46E5;
            font-size: 0.74rem;
            font-weight: 600;
            padding: 4px 12px;
            border-radius: 20px;
            display: inline-block;
        }
        .fl-meta-tag {
            background-color: #F8FAFC;
            color: #475569;
            border: 1px solid #E2E8F0;
            border-radius: 6px;
            padding: 3px 8px;
            font-size: 0.72rem;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .fl-search-input-wrapper {
            position: relative;
        }
        .fl-search-input-wrapper i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #94A3B8;
        }
        .fl-search-input-wrapper input {
            padding-left: 42px !important;
            height: 44px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mb-4">
        <h2 class="fw-bold mb-1 text-dark" style="font-size: 1.85rem; letter-spacing: -0.02em;">Explore Startups</h2>
        <p class="text-muted small mb-0">Discover ideas, projects and teams looking for people like you.</p>
    </div>

    <!-- Filter Card -->
    <div class="fl-card mb-4 p-4">
        <div class="mb-3">
            <div class="fl-search-input-wrapper">
                <i class="bi bi-search"></i>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search startups, industries or skills..." />
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <asp:DropDownList ID="ddlIndustry" runat="server" CssClass="form-select" style="height: 42px;">
                    <asp:ListItem Value="" Text="Industry" />
                    <asp:ListItem Value="AI/ML" Text="AI/ML" />
                    <asp:ListItem Value="FinTech" Text="FinTech" />
                    <asp:ListItem Value="PropTech" Text="PropTech" />
                    <asp:ListItem Value="HealthTech" Text="HealthTech" />
                    <asp:ListItem Value="Climate Tech" Text="Climate Tech" />
                    <asp:ListItem Value="Sustainability" Text="Sustainability" />
                </asp:DropDownList>
            </div>

            <div class="col-md-3">
                <asp:DropDownList ID="ddlSkill" runat="server" CssClass="form-select" style="height: 42px;">
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
                <asp:DropDownList ID="ddlStage" runat="server" CssClass="form-select" style="height: 42px;">
                    <asp:ListItem Value="" Text="Startup Stage" />
                    <asp:ListItem Value="Pre-Seed" Text="Pre-Seed" />
                    <asp:ListItem Value="Seed Stage" Text="Seed Stage" />
                    <asp:ListItem Value="Series A" Text="Series A" />
                    <asp:ListItem Value="MVP" Text="MVP" />
                </asp:DropDownList>
            </div>

            <div class="col-md-3">
                <asp:DropDownList ID="ddlTeamSize" runat="server" CssClass="form-select" style="height: 42px;">
                    <asp:ListItem Value="" Text="Team Size" />
                    <asp:ListItem Value="1-5" Text="1-5" />
                    <asp:ListItem Value="6-15" Text="6-15" />
                    <asp:ListItem Value="16-50" Text="16-50" />
                </asp:DropDownList>
            </div>
        </div>

        <div class="d-flex justify-content-end gap-2">
            <asp:Button ID="btnClear" runat="server" Text="Clear Filters" CssClass="btn-fl-outline" OnClick="btnClear_Click" />
            <asp:Button ID="btnApply" runat="server" Text="Apply Filters" CssClass="btn-fl-dark" OnClick="btnApply_Click" />
        </div>
    </div>

    <!-- Results Subheader -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-3">
        <div class="small text-muted">
            Showing <strong class="text-dark"><asp:Literal ID="litMatchCount" runat="server" Text="24" /></strong> startups matching your profile
        </div>
        <div class="d-flex align-items-center gap-2">
            <span class="small text-muted" style="font-size: 0.75rem; font-weight: 700;">SORT BY</span>
            <asp:DropDownList ID="ddlSort" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged" style="width: 140px; font-size: 0.82rem;">
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
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="fl-startup-logo-box">
                                    <img src='<%# Eval("LogoUrl") %>' alt='<%# Eval("Name") %>' width="44" height="44" style="object-fit:cover; border-radius:8px;" onerror="this.src='https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100';" />
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="fw-bold mb-0 text-dark" style="font-size: 1.15rem;"><%# Eval("Name") %></h5>
                                    <div class="text-muted small" style="font-size: 0.78rem;">
                                        <i class="bi bi-geo-alt"></i> <%# Eval("Location") %>
                                    </div>
                                </div>
                            </div>

                            <p class="text-muted small mb-3 lh-base" style="min-height: 42px;">
                                <%# Eval("ShortDescription") %>
                            </p>

                            <div class="d-flex flex-wrap gap-2 mb-3">
                                <span class="fl-meta-tag"><%# Eval("Industry") %></span>
                                <span class="fl-meta-tag"><%# Eval("Stage") %></span>
                                <span class="fl-meta-tag"><i class="bi bi-people"></i> <%# Eval("TeamSize") %></span>
                            </div>

                            <div class="mb-3">
                                <div class="text-uppercase text-muted" style="font-size: 0.68rem; font-weight: 700; letter-spacing: 0.05em; margin-bottom: 6px;">
                                    <i class="bi bi-geo-alt me-1"></i><%# Eval("Location").ToString().ToUpper() %>
                                </div>
                                <div class="d-flex flex-wrap gap-2">
                                    <%# FormatSkills(Eval("RequiredSkills")) %>
                                </div>
                            </div>
                        </div>

                        <div class="pt-3 border-top d-flex justify-content-between align-items-center mt-3" style="border-color: #F1F5F9 !important;">
                            <div class="d-flex align-items-center gap-2">
                                <img src='<%# Eval("FounderAvatar") %>' class="rounded-circle" width="34" height="34" style="object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                                <div>
                                    <div class="fw-bold text-dark small" style="font-size: 0.82rem;"><%# Eval("FounderName") %>, CEO</div>
                                </div>
                            </div>

                            <a href='<%# "StartupDetails.aspx?id=" + Eval("StartupId") %>' class="btn-fl-outline" style="padding: 6px 14px; font-size: 0.82rem;">
                                View Details
                            </a>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <!-- Pagination -->
    <div class="d-flex justify-content-center mt-4">
        <div class="fl-pagination">
            <a href="#" class="fl-page-btn"><i class="bi bi-chevron-left"></i></a>
            <a href="#" class="fl-page-btn active">1</a>
            <a href="#" class="fl-page-btn">2</a>
            <a href="#" class="fl-page-btn">3</a>
            <span class="px-2 text-muted">...</span>
            <a href="#" class="fl-page-btn">8</a>
            <a href="#" class="fl-page-btn"><i class="bi bi-chevron-right"></i></a>
        </div>
    </div>
</asp:Content>
