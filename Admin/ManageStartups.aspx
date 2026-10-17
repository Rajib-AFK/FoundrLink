<%@ Page Title="Manage Startups" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="ManageStartups.aspx.cs" Inherits="FoundrLink.Admin.ManageStartups" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-admin-table th {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #64748B;
            background: #F8FAFC;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <div>
            <h2 class="fw-bold fs-3 text-dark mb-1">Manage Startups</h2>
            <p class="text-muted mb-0">Review, approve, curate, and moderate startup profiles across all stages.</p>
        </div>
        <a href="../ManageStartup.aspx" class="btn btn-fl-teal">
            <i class="bi bi-plus-lg me-1"></i> Register New Startup
        </a>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show" role="alert">
        <asp:Literal ID="litAlertMsg" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- Filter Bar -->
    <div class="card border-0 shadow-sm rounded-4 p-3 mb-4">
        <div class="row g-2 align-items-center">
            <div class="col-md-4">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="Search startup name, problem, or city..." />
                </div>
            </div>
            <div class="col-md-3">
                <asp:DropDownList ID="ddlIndustry" runat="server" CssClass="form-select">
                    <asp:ListItem Text="All Industries" Value="" />
                    <asp:ListItem Text="Artificial Intelligence" Value="Artificial Intelligence" />
                    <asp:ListItem Text="Digital Health" Value="Digital Health" />
                    <asp:ListItem Text="Fintech" Value="Fintech" />
                    <asp:ListItem Text="Climate Tech" Value="Climate Tech" />
                    <asp:ListItem Text="EdTech" Value="EdTech" />
                    <asp:ListItem Text="SaaS" Value="SaaS" />
                </asp:DropDownList>
            </div>
            <div class="col-md-3">
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                    <asp:ListItem Text="All Statuses" Value="" />
                    <asp:ListItem Text="Published" Value="Published" />
                    <asp:ListItem Text="Draft" Value="Draft" />
                </asp:DropDownList>
            </div>
            <div class="col-md-2 d-flex gap-2">
                <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="btn btn-dark w-100" OnClick="btnFilter_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-outline-secondary" OnClick="btnReset_Click" />
            </div>
        </div>
    </div>

    <!-- Startups Table Card -->
    <div class="card border-0 shadow-sm rounded-4 p-0 overflow-hidden">
        <div class="table-responsive">
            <asp:Repeater ID="rptStartups" runat="server" OnItemCommand="rptStartups_ItemCommand">
                <HeaderTemplate>
                    <table class="table align-middle table-hover mb-0 fl-admin-table">
                        <thead>
                            <tr>
                                <th class="ps-4">Startup</th>
                                <th>Founder</th>
                                <th>Industry & Stage</th>
                                <th>Funding Goal</th>
                                <th>Status</th>
                                <th class="text-end pe-4">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="ps-4">
                            <div class="d-flex align-items-center gap-3">
                                <img src='<%# Eval("LogoUrl") %>' class="rounded-3 border" width="40" height="40" style="object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100';" />
                                <div>
                                    <div class="fw-bold text-dark"><%# Eval("Name") %></div>
                                    <div class="text-muted small text-truncate" style="max-width:240px;"><%# Eval("Tagline") %></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div class="fw-semibold text-dark small"><%# Eval("FounderName") %></div>
                            <div class="text-muted" style="font-size:0.7rem;"><%# Eval("FounderEmail") %></div>
                        </td>
                        <td class="small">
                            <span class="badge bg-light text-dark border me-1"><%# Eval("Industry") %></span>
                            <span class="text-muted"><%# Eval("Stage") %></span>
                        </td>
                        <td class="small fw-semibold text-dark">
                            $<%# Convert.ToDecimal(Eval("FundingGoal")).ToString("N0") %>
                        </td>
                        <td>
                            <span class='<%# Eval("Status").ToString() == "Published" ? "badge bg-success-subtle text-success" : "badge bg-warning-subtle text-warning" %>'>
                                <%# Eval("Status") %>
                            </span>
                        </td>
                        <td class="text-end pe-4">
                            <a href='<%# "../StartupDetails.aspx?id=" + Eval("StartupId") %>' target="_blank" class="btn btn-sm btn-outline-secondary me-1" title="View Public Page">
                                <i class="bi bi-eye"></i>
                            </a>
                            <asp:LinkButton ID="btnTogglePublish" runat="server" CommandName="TogglePublish" CommandArgument='<%# Eval("StartupId") %>' CssClass='<%# Eval("Status").ToString() == "Published" ? "btn btn-sm btn-outline-warning me-1" : "btn btn-sm btn-outline-success me-1" %>' title="Toggle Published State">
                                <i class='<%# Eval("Status").ToString() == "Published" ? "bi bi-file-earmark-lock" : "bi bi-check2-circle" %>'></i>
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteStartup" CommandArgument='<%# Eval("StartupId") %>' CssClass="btn btn-sm btn-outline-danger" title="Delete Startup" OnClientClick="return confirm('Are you sure you want to permanently delete this startup?');">
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
    </div>
</asp:Content>
