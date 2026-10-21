<%@ Page Title="Find Co-Founders" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="FindCoFounders.aspx.cs" Inherits="FoundrLink.FindCoFounders" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-founder-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: var(--fl-radius-card);
            padding: 24px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            height: 100%;
            transition: all 0.2s ease;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
        }
        .fl-founder-card:hover {
            box-shadow: 0 8px 20px rgba(0,0,0,0.05);
            border-color: #CBD5E1;
        }
        .fl-filter-panel {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: var(--fl-radius-card);
            padding: 24px;
        }
        .fl-skill-chip-blue {
            background-color: #E0F2FE;
            color: #0284C7;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 4px;
            display: inline-block;
            letter-spacing: 0.04em;
        }
        .fl-skill-chip-gray {
            background-color: #F1F5F9;
            color: #475569;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 4px;
            display: inline-block;
            letter-spacing: 0.04em;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row g-4">
        <!-- Left Filter Column -->
        <div class="col-lg-3">
            <div class="fl-filter-panel">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h6 class="fw-bold text-uppercase tracking-wider mb-0 text-dark" style="font-size: 0.8rem; letter-spacing: 0.08em;">FILTERS</h6>
                    <asp:LinkButton ID="btnClearFilters" runat="server" CssClass="small text-muted text-decoration-none" OnClick="btnClearFilters_Click" style="font-size: 0.75rem;">Clear All</asp:LinkButton>
                </div>

                <!-- Role Filter -->
                <div class="mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <label class="fw-bold small text-dark mb-0">Role</label>
                        <i class="bi bi-chevron-up text-muted small" style="font-size: 0.7rem;"></i>
                    </div>
                    <div class="form-check mb-2">
                        <asp:CheckBox ID="chkRoleTech" runat="server" CssClass="form-check-input" AutoPostBack="true" OnCheckedChanged="Filter_Changed" Checked="true" />
                        <label class="form-check-label small text-dark" for="chkRoleTech">Technical (CTO)</label>
                    </div>
                    <div class="form-check mb-2">
                        <asp:CheckBox ID="chkRoleBiz" runat="server" CssClass="form-check-input" AutoPostBack="true" OnCheckedChanged="Filter_Changed" />
                        <label class="form-check-label small text-dark" for="chkRoleBiz">Business (CEO)</label>
                    </div>
                    <div class="form-check">
                        <asp:CheckBox ID="chkRoleMarketing" runat="server" CssClass="form-check-input" AutoPostBack="true" OnCheckedChanged="Filter_Changed" />
                        <label class="form-check-label small text-dark" for="chkRoleMarketing">Marketing (CMO)</label>
                    </div>
                </div>

                <!-- Top Skills Filter -->
                <div class="mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <label class="fw-bold small text-dark mb-0">Top Skills</label>
                        <i class="bi bi-chevron-up text-muted small" style="font-size: 0.7rem;"></i>
                    </div>
                    <div class="d-flex flex-wrap gap-2 mb-2">
                        <asp:LinkButton ID="btnSkillReact" runat="server" CssClass="badge bg-dark text-white text-decoration-none py-2 px-3" OnClick="btnSkill_Click" CommandArgument="React" style="border-radius: 20px; font-weight: 500;">
                            React <i class="bi bi-x ms-1"></i>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnSkillPython" runat="server" CssClass="badge bg-light text-dark border text-decoration-none py-2 px-3" OnClick="btnSkill_Click" CommandArgument="Python" style="border-radius: 20px; font-weight: 500;">Python</asp:LinkButton>
                        <asp:LinkButton ID="btnSkillAI" runat="server" CssClass="badge bg-light text-dark border text-decoration-none py-2 px-3" OnClick="btnSkill_Click" CommandArgument="AI/ML" style="border-radius: 20px; font-weight: 500;">AI/ML</asp:LinkButton>
                        <asp:LinkButton ID="btnSkillFintech" runat="server" CssClass="badge bg-light text-dark border text-decoration-none py-2 px-3" OnClick="btnSkill_Click" CommandArgument="Fintech" style="border-radius: 20px; font-weight: 500;">Sales</asp:LinkButton>
                    </div>
                    <a href="#" class="small text-muted text-decoration-none" style="font-size: 0.75rem;">+ Add skill</a>
                </div>

                <!-- Industry Filter -->
                <div class="mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <label class="fw-bold small text-dark mb-0">Industry</label>
                        <i class="bi bi-chevron-up text-muted small" style="font-size: 0.7rem;"></i>
                    </div>
                    <asp:DropDownList ID="ddlIndustry" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" style="height: 38px;">
                        <asp:ListItem Value="" Text="Any Industry" />
                        <asp:ListItem Value="FinTech" Text="FinTech" />
                        <asp:ListItem Value="Healthtech" Text="Healthtech" />
                        <asp:ListItem Value="AI/ML" Text="AI/ML" />
                        <asp:ListItem Value="SaaS" Text="SaaS" />
                    </asp:DropDownList>
                </div>

                <!-- Availability Filter -->
                <div class="mb-2">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <label class="fw-bold small text-dark mb-0">Availability</label>
                        <i class="bi bi-chevron-up text-muted small" style="font-size: 0.7rem;"></i>
                    </div>
                    <div class="form-check mb-2">
                        <asp:RadioButton ID="rbAvailFull" runat="server" GroupName="avail" Checked="true" CssClass="form-check-input" AutoPostBack="true" OnCheckedChanged="Filter_Changed" />
                        <label class="form-check-label small text-dark" for="rbAvailFull">Full-time</label>
                    </div>
                    <div class="form-check">
                        <asp:RadioButton ID="rbAvailPart" runat="server" GroupName="avail" CssClass="form-check-input" AutoPostBack="true" OnCheckedChanged="Filter_Changed" />
                        <label class="form-check-label small text-dark" for="rbAvailPart">Part-time / Side Hustle</label>
                    </div>
                    <asp:RadioButton ID="rbAvailAll" runat="server" GroupName="avail" style="display:none;" />
                </div>
            </div>
        </div>

        <!-- Right Results Column -->
        <div class="col-lg-9">
            <!-- Header bar with matches count and pills -->
            <div class="d-flex flex-wrap align-items-center gap-3 mb-4">
                <span class="small fw-semibold text-muted">
                    <strong class="text-dark"><asp:Literal ID="litCount" runat="server" Text="24" /></strong> Matches found
                </span>
                <span class="text-muted">|</span>
                <div class="d-flex flex-wrap gap-2 align-items-center">
                    <asp:Panel ID="pnlFilterRole" runat="server" Visible="false" CssClass="badge bg-light text-dark border px-3 py-2" style="border-radius: 6px; font-weight: 500; font-size: 0.78rem;">
                        Role: <asp:Literal ID="litFilterRoleName" runat="server" /> <i class="bi bi-x ms-1"></i>
                    </asp:Panel>
                    <asp:Panel ID="pnlFilterSkill" runat="server" Visible="false" CssClass="badge bg-light text-dark border px-3 py-2" style="border-radius: 6px; font-weight: 500; font-size: 0.78rem;">
                        Skill: <asp:Literal ID="litFilterSkillName" runat="server" /> <i class="bi bi-x ms-1"></i>
                    </asp:Panel>
                </div>
            </div>

            <!-- Founders Grid -->
            <div class="row g-4">
                <asp:Repeater ID="rptFounders" runat="server" OnItemCommand="rptFounders_ItemCommand">
                    <ItemTemplate>
                        <div class="col-md-4">
                            <div class="fl-founder-card">
                                <div>
                                    <div class="d-flex align-items-center justify-content-between mb-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <img src='<%# Eval("AvatarUrl") %>' class="rounded-circle" width="52" height="52" style="object-fit:cover; flex-shrink: 0;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                                            <div>
                                                <h6 class="fw-bold mb-0 text-dark" style="font-size: 1.05rem;"><%# Eval("FullName") %></h6>
                                                <div class="text-uppercase tracking-wider fw-bold" style="font-size: 0.68rem; margin-top: 2px; color: #0284C7; letter-spacing: 0.05em;">
                                                    <%# Eval("Title") %>
                                                </div>
                                                <div class="text-muted small" style="font-size: 0.75rem;">
                                                    <i class="bi bi-geo-alt"></i> <%# Eval("Location") %>
                                                </div>
                                            </div>
                                        </div>
                                        <span class="badge rounded-pill px-2 py-1 align-self-start fw-bold" style="background-color: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; font-size: 0.68rem;">
                                            <i class="bi bi-stars"></i> <%# CalculateMatchScore(Eval("Skills")) %>% Match
                                        </span>
                                    </div>

                                    <p class="text-muted small mb-3 lh-base" style="min-height: 48px; font-size: 0.82rem;">
                                        <%# Eval("Bio") %>
                                    </p>

                                    <div class="d-flex flex-wrap gap-1 mb-4">
                                        <%# FormatSkillPills(Eval("Skills")) %>
                                    </div>
                                </div>

                                <div class="pt-3 border-top d-flex gap-2" style="border-color: #F1F5F9 !important;">
                                    <a href='<%# "Profile.aspx?id=" + Eval("UserId") %>' class="btn-fl-outline flex-grow-1 justify-content-center" style="padding: 7px 12px; font-size: 0.82rem;">
                                        View Profile
                                    </a>
                                    <asp:LinkButton ID="btnConnect" runat="server" CommandName="Connect" CommandArgument='<%# Eval("UserId") %>' CssClass="btn-fl-primary px-3 justify-content-center" style="padding: 7px 16px; font-size: 0.82rem;">
                                        Connect
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</asp:Content>
