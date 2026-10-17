<%@ Page Title="Find Co-Founders" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="FindCoFounders.aspx.cs" Inherits="FoundrLink.FindCoFounders" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-founder-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: 14px;
            padding: 24px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            height: 100%;
            transition: all 0.2s ease;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
        }
        .fl-founder-card:hover {
            box-shadow: 0 8px 20px rgba(0,0,0,0.06);
            transform: translateY(-2px);
        }
        .fl-filter-panel {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: 14px;
            padding: 24px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row g-4">
        <!-- Left Filter Column -->
        <div class="col-lg-3">
            <div class="fl-filter-panel">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h6 class="fw-bold text-uppercase tracking-wider mb-0 text-dark">FILTERS</h6>
                    <asp:LinkButton ID="btnClearFilters" runat="server" CssClass="small text-muted text-decoration-none" OnClick="btnClearFilters_Click">Clear All</asp:LinkButton>
                </div>

                <!-- Role Filter -->
                <div class="mb-4">
                    <label class="fw-bold small text-dark mb-2 d-block">Role</label>
                    <div class="form-check mb-2">
                        <asp:CheckBox ID="chkRoleTech" runat="server" CssClass="form-check-input" AutoPostBack="true" OnCheckedChanged="Filter_Changed" />
                        <label class="form-check-label small" for="chkRoleTech">Technical (CTO)</label>
                    </div>
                    <div class="form-check mb-2">
                        <asp:CheckBox ID="chkRoleBiz" runat="server" CssClass="form-check-input" AutoPostBack="true" OnCheckedChanged="Filter_Changed" />
                        <label class="form-check-label small" for="chkRoleBiz">Business (CEO)</label>
                    </div>
                    <div class="form-check">
                        <asp:CheckBox ID="chkRoleMarketing" runat="server" CssClass="form-check-input" AutoPostBack="true" OnCheckedChanged="Filter_Changed" />
                        <label class="form-check-label small" for="chkRoleMarketing">Marketing (CMO)</label>
                    </div>
                </div>

                <!-- Top Skills Filter -->
                <div class="mb-4">
                    <label class="fw-bold small text-dark mb-2 d-block">Top Skills</label>
                    <div class="d-flex flex-wrap gap-2">
                        <asp:LinkButton ID="btnSkillReact" runat="server" CssClass="badge bg-dark text-white text-decoration-none py-2 px-3" OnClick="btnSkill_Click" CommandArgument="React">
                            React <i class="bi bi-x-circle ms-1"></i>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnSkillPython" runat="server" CssClass="badge bg-light text-dark border text-decoration-none py-2 px-3" OnClick="btnSkill_Click" CommandArgument="Python">Python</asp:LinkButton>
                        <asp:LinkButton ID="btnSkillAI" runat="server" CssClass="badge bg-light text-dark border text-decoration-none py-2 px-3" OnClick="btnSkill_Click" CommandArgument="AI/ML">AI/ML</asp:LinkButton>
                        <asp:LinkButton ID="btnSkillFintech" runat="server" CssClass="badge bg-light text-dark border text-decoration-none py-2 px-3" OnClick="btnSkill_Click" CommandArgument="Fintech">Fintech</asp:LinkButton>
                    </div>
                </div>

                <!-- Industry Filter -->
                <div class="mb-4">
                    <label class="fw-bold small text-dark mb-2 d-block">Industry</label>
                    <asp:DropDownList ID="ddlIndustry" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                        <asp:ListItem Value="" Text="Any Industry" />
                        <asp:ListItem Value="FinTech" Text="FinTech" />
                        <asp:ListItem Value="Healthtech" Text="Healthtech" />
                        <asp:ListItem Value="AI/ML" Text="AI/ML" />
                        <asp:ListItem Value="SaaS" Text="SaaS" />
                    </asp:DropDownList>
                </div>

                <!-- Availability Filter -->
                <div class="mb-3">
                    <label class="fw-bold small text-dark mb-2 d-block">Availability</label>
                    <div class="form-check mb-2">
                        <asp:RadioButton ID="rbAvailAll" runat="server" GroupName="avail" Checked="true" CssClass="form-check-input" AutoPostBack="true" OnCheckedChanged="Filter_Changed" />
                        <label class="form-check-label small" for="rbAvailAll">All Availabilities</label>
                    </div>
                    <div class="form-check mb-2">
                        <asp:RadioButton ID="rbAvailFull" runat="server" GroupName="avail" CssClass="form-check-input" AutoPostBack="true" OnCheckedChanged="Filter_Changed" />
                        <label class="form-check-label small" for="rbAvailFull">Full-time</label>
                    </div>
                    <div class="form-check">
                        <asp:RadioButton ID="rbAvailPart" runat="server" GroupName="avail" CssClass="form-check-input" AutoPostBack="true" OnCheckedChanged="Filter_Changed" />
                        <label class="form-check-label small" for="rbAvailPart">Part-time / Side Hustle</label>
                    </div>
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
                <div class="d-flex flex-wrap gap-2">
                    <asp:Panel ID="pnlFilterRole" runat="server" Visible="false" CssClass="badge bg-light text-dark border px-3 py-2">
                        Role: <asp:Literal ID="litFilterRoleName" runat="server" />
                    </asp:Panel>
                    <asp:Panel ID="pnlFilterSkill" runat="server" Visible="false" CssClass="badge bg-light text-dark border px-3 py-2">
                        Skill: <asp:Literal ID="litFilterSkillName" runat="server" />
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
                                    <div class="d-flex align-items-start gap-3 mb-3">
                                        <img src='<%# Eval("AvatarUrl") %>' class="rounded-circle" width="52" height="52" style="object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                                        <div>
                                            <h6 class="fw-bold mb-0 text-dark"><%# Eval("FullName") %></h6>
                                            <div class="text-uppercase tracking-wider fw-bold text-teal" style="font-size: 0.68rem; margin-top: 2px;">
                                                <%# Eval("Title") %>
                                            </div>
                                            <div class="text-muted small" style="font-size: 0.75rem;">
                                                <i class="bi bi-geo-alt"></i> <%# Eval("Location") %>
                                            </div>
                                        </div>
                                    </div>

                                    <p class="text-muted small mb-3 lh-base" style="min-height: 48px;">
                                        <%# Eval("Bio") %>
                                    </p>

                                    <div class="d-flex flex-wrap gap-1 mb-4">
                                        <%# FormatSkillPills(Eval("Skills")) %>
                                    </div>
                                </div>

                                <div class="pt-3 border-top border-slate-100 d-flex gap-2">
                                    <a href='<%# "Profile.aspx?id=" + Eval("UserId") %>' class="btn btn-fl-outline btn-sm flex-grow-1">
                                        View Profile
                                    </a>
                                    <asp:LinkButton ID="btnConnect" runat="server" CommandName="Connect" CommandArgument='<%# Eval("UserId") %>' CssClass="btn btn-fl-primary btn-sm px-3">
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
