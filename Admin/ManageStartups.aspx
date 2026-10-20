<%@ Page Title="Manage Startups" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="ManageStartups.aspx.cs" Inherits="FoundrLink.Admin.ManageStartups" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-admin-th {
            font-size: 0.8rem;
            font-weight: 700;
            color: #1E293B;
            background: #F8FAFC !important;
            border-bottom: 1px solid #E2E8F0;
            padding: 14px 16px;
        }
        .fl-admin-td {
            padding: 16px;
            vertical-align: middle;
            border-bottom: 1px solid #F1F5F9;
        }
        .fl-page-btn {
            width: 32px;
            height: 32px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 6px;
            border: 1px solid #E2E8F0;
            background: #FFFFFF;
            color: #475569;
            font-size: 0.82rem;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .fl-page-btn:hover {
            background: #F8FAFC;
            color: #0F172A;
        }
        .fl-page-btn.active {
            background: #00A884;
            color: #FFFFFF;
            border-color: #00A884;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header Row -->
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <div>
            <h1 class="fw-bold fs-2 text-dark mb-1" style="letter-spacing: -0.02em;">Manage Startups</h1>
            <p class="text-muted mb-0 small">Review, filter, and manage startup profiles in the network.</p>
        </div>
        <a href="../ManageStartup.aspx" class="btn text-white fw-semibold px-3 py-2 rounded-3 shadow-none border-0 d-inline-flex align-items-center gap-2" style="background:#00A884; font-size: 0.88rem;">
            <i class="bi bi-plus-lg"></i> New Startup
        </a>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show rounded-3 shadow-sm border-0" role="alert">
        <div class="d-flex align-items-center gap-2">
            <i class="bi bi-check-circle-fill fs-5 text-success"></i>
            <div><asp:Literal ID="litAlertMsg" runat="server" /></div>
        </div>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- Filters Card -->
    <div class="card border-0 shadow-sm rounded-4 p-4 mb-4" style="border: 1px solid #E2E8F0 !important;">
        <div class="row g-3 mb-3">
            <div class="col-md-3">
                <label class="form-label text-dark fw-bold small mb-1" style="font-size:0.8rem;">Search</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="Search startups..." />
                </div>
            </div>
            <div class="col-md-3">
                <label class="form-label text-dark fw-bold small mb-1" style="font-size:0.8rem;">Industry</label>
                <asp:DropDownList ID="ddlIndustry" runat="server" CssClass="form-select rounded-3">
                    <asp:ListItem Text="All Industries" Value="" />
                    <asp:ListItem Text="Artificial Intelligence" Value="Artificial Intelligence" />
                    <asp:ListItem Text="AI/ML" Value="AI/ML" />
                    <asp:ListItem Text="Digital Health" Value="Digital Health" />
                    <asp:ListItem Text="Healthtech" Value="Healthtech" />
                    <asp:ListItem Text="Fintech" Value="Fintech" />
                    <asp:ListItem Text="Climate Tech" Value="Climate Tech" />
                    <asp:ListItem Text="EdTech" Value="EdTech" />
                    <asp:ListItem Text="SaaS" Value="SaaS" />
                </asp:DropDownList>
            </div>
            <div class="col-md-3">
                <label class="form-label text-dark fw-bold small mb-1" style="font-size:0.8rem;">Stage</label>
                <select class="form-select rounded-3">
                    <option value="">All Stages</option>
                    <option value="Idea">Idea</option>
                    <option value="MVP">MVP</option>
                    <option value="Seed">Seed</option>
                    <option value="Series A">Series A</option>
                    <option value="Growth">Growth</option>
                </select>
            </div>
            <div class="col-md-3">
                <label class="form-label text-dark fw-bold small mb-1" style="font-size:0.8rem;">Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select rounded-3">
                    <asp:ListItem Text="All Statuses" Value="" />
                    <asp:ListItem Text="Published" Value="Published" />
                    <asp:ListItem Text="Draft" Value="Draft" />
                </asp:DropDownList>
            </div>
        </div>

        <div>
            <asp:Button ID="btnReset" runat="server" Text="Clear Filters" CssClass="btn btn-light text-dark fw-semibold border rounded-3 px-3 py-2 small shadow-none" OnClick="btnReset_Click" />
            <asp:Button ID="btnFilter" runat="server" Text="Apply Filter" CssClass="btn text-white fw-semibold rounded-3 px-3 py-2 small shadow-none ms-2" style="background:#0F172A;" OnClick="btnFilter_Click" />
        </div>
    </div>

    <!-- Startups Table Card -->
    <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4" style="border: 1px solid #E2E8F0 !important;">
        <div class="table-responsive">
            <asp:Repeater ID="rptStartups" runat="server" OnItemCommand="rptStartups_ItemCommand">
                <HeaderTemplate>
                    <table class="table align-middle mb-0">
                        <thead>
                            <tr>
                                <th class="fl-admin-th ps-4">Startup</th>
                                <th class="fl-admin-th">Founder</th>
                                <th class="fl-admin-th">Industry & Stage</th>
                                <th class="fl-admin-th">Team</th>
                                <th class="fl-admin-th">Status</th>
                                <th class="fl-admin-th">Created</th>
                                <th class="fl-admin-th text-end pe-4">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr class="hover-bg-light">
                        <td class="fl-admin-td ps-4">
                            <div class="d-flex align-items-center gap-3">
                                <img src='<%# Eval("LogoUrl") %>' class="rounded-3 border flex-shrink-0" width="38" height="38" style="object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100';" />
                                <div>
                                    <div class="fw-bold text-dark small"><%# Eval("Name") %></div>
                                    <div class="text-muted small" style="font-size:0.72rem;"><%# Eval("Tagline") %></div>
                                </div>
                            </div>
                        </td>
                        <td class="fl-admin-td">
                            <div class="d-flex align-items-center gap-2">
                                <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100" class="rounded-circle border flex-shrink-0" width="28" height="28" style="object-fit:cover;" />
                                <div>
                                    <div class="fw-bold text-dark small"><%# Eval("FounderName") %></div>
                                    <div class="text-muted small" style="font-size:0.7rem;"><%# Eval("FounderEmail") %></div>
                                </div>
                            </div>
                        </td>
                        <td class="fl-admin-td">
                            <div class="fw-bold text-dark small"><%# Eval("Industry") %></div>
                            <div class="text-muted small" style="font-size:0.72rem;"><%# Eval("Stage") %></div>
                        </td>
                        <td class="fl-admin-td">
                            <span class="fw-semibold text-dark small">12</span>
                        </td>
                        <td class="fl-admin-td">
                            <span class='<%# Eval("Status").ToString() == "Published" ? "badge rounded-pill px-3 py-1 fw-semibold small" : "badge rounded-pill px-3 py-1 fw-semibold small" %>' style='<%# Eval("Status").ToString() == "Published" ? "background:#4EE8C4; color:#0F172A;" : "background:#E2E8F0; color:#475569;" %>'>
                                <%# Eval("Status").ToString() == "Published" ? "Active" : "Draft" %>
                            </span>
                        </td>
                        <td class="fl-admin-td text-muted small" style="font-size:0.8rem;">
                            Oct 12, 2023
                        </td>
                        <td class="fl-admin-td text-end pe-4">
                            <a href='<%# "../StartupDetails.aspx?id=" + Eval("StartupId") %>' target="_blank" class="btn btn-sm btn-link text-muted p-1" title="View Public Page">
                                <i class="bi bi-eye"></i>
                            </a>
                            <asp:LinkButton ID="btnTogglePublish" runat="server" CommandName="TogglePublish" CommandArgument='<%# Eval("StartupId") %>' CssClass="btn btn-sm btn-link text-muted p-1" title="Toggle Published State">
                                <i class="bi bi-arrow-repeat"></i>
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteStartup" CommandArgument='<%# Eval("StartupId") %>' CssClass="btn btn-sm btn-link text-danger p-1" title="Delete Startup" OnClientClick="return confirm('Are you sure you want to permanently delete this startup?');">
                                <i class="bi bi-trash"></i>
                            </asp:LinkButton>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>

        <!-- Table Footer / Pagination -->
        <div class="d-flex justify-content-between align-items-center p-3 px-4 bg-white border-top flex-wrap gap-2">
            <span class="text-muted small" style="font-size: 0.8rem;">Showing 1 to 2 of 10 entries</span>
            <div class="d-flex align-items-center gap-1">
                <a href="javascript:void(0)" class="fl-page-btn"><i class="bi bi-chevron-left"></i></a>
                <a href="javascript:void(0)" class="fl-page-btn active">1</a>
                <a href="javascript:void(0)" class="fl-page-btn">2</a>
                <a href="javascript:void(0)" class="fl-page-btn">3</a>
                <a href="javascript:void(0)" class="fl-page-btn"><i class="bi bi-chevron-right"></i></a>
            </div>
        </div>
    </div>
</asp:Content>
