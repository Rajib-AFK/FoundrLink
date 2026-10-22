<%@ Page Title="Moderation & Reports" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="FoundrLink.Admin.Reports" %>

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
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header Row -->
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <h1 class="fw-bold fs-2 text-dark mb-0" style="letter-spacing: -0.02em;">Reports & Categories</h1>
        <div class="d-flex align-items-center gap-2">
            <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&auto=format&fit=crop&q=80" class="rounded-circle border" width="38" height="38" style="object-fit:cover;" />
        </div>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show rounded-3 shadow-sm border-0" role="alert">
        <div class="d-flex align-items-center gap-2">
            <i class="bi bi-check-circle-fill fs-5 text-success"></i>
            <div><asp:Literal ID="litAlertMsg" runat="server" /></div>
        </div>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- Navigation / Tab Bar Card -->
    <div class="card border-0 shadow-sm rounded-4 mb-4 px-4 bg-white" style="border: 1px solid #E2E8F0 !important;">
        <div class="d-flex align-items-center gap-2 py-3 border-bottom border-3 text-teal fw-bold small" style="border-color: #008C75 !important; color: #008C75; width: fit-content; margin-bottom: -1px;">
            <i class="bi bi-flag"></i> Moderation Queue
        </div>
    </div>

    <!-- Pending Reports Card -->
    <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4" style="border: 1px solid #E2E8F0 !important;">
        <div class="d-flex justify-content-between align-items-center p-4 border-bottom flex-wrap gap-3">
            <div>
                <h5 class="fw-bold text-dark mb-1 fs-5">Moderation &amp; Reports</h5>
                <p class="text-muted mb-0 small" style="font-size: 0.8rem;">Review, investigate, and resolve user-submitted moderation tickets.</p>
            </div>
            <div class="d-flex align-items-center flex-wrap gap-2">
                <div class="input-group input-group-sm" style="max-width: 240px;">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control rounded-start-3 shadow-none" placeholder="Search reports..." />
                    <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="btn btn-dark btn-sm rounded-end-3" OnClick="btnFilter_Click" />
                </div>
                <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select form-select-sm rounded-3 shadow-none text-muted" AutoPostBack="true" OnSelectedIndexChanged="btnFilter_Click" style="width: auto; min-width: 130px; font-size: 0.82rem;">
                    <asp:ListItem Text="All Statuses" Value="" />
                    <asp:ListItem Text="Pending" Value="Pending" />
                    <asp:ListItem Text="Resolved" Value="Resolved" />
                    <asp:ListItem Text="Dismissed" Value="Dismissed" />
                </asp:DropDownList>
                <asp:DropDownList ID="ddlPriorityFilter" runat="server" CssClass="form-select form-select-sm rounded-3 shadow-none text-muted" AutoPostBack="true" OnSelectedIndexChanged="btnFilter_Click" style="width: auto; min-width: 120px; font-size: 0.82rem;">
                    <asp:ListItem Text="All Priorities" Value="" />
                    <asp:ListItem Text="Urgent" Value="Urgent" />
                    <asp:ListItem Text="High" Value="High" />
                    <asp:ListItem Text="Normal" Value="Normal" />
                </asp:DropDownList>
                <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-sm btn-outline-secondary rounded-3" OnClick="btnReset_Click" />
            </div>
        </div>

        <div class="table-responsive">
            <asp:Repeater ID="rptReports" runat="server" OnItemCommand="rptReports_ItemCommand">
                <HeaderTemplate>
                    <table class="table align-middle mb-0">
                        <thead>
                            <tr>
                                <th class="fl-admin-th ps-4">Code</th>
                                <th class="fl-admin-th">Reporter</th>
                                <th class="fl-admin-th">Reported Item</th>
                                <th class="fl-admin-th">Type</th>
                                <th class="fl-admin-th">Date</th>
                                <th class="fl-admin-th">Status</th>
                                <th class="fl-admin-th text-end pe-4">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr class="hover-bg-light">
                        <td class="fl-admin-td ps-4 fw-bold text-dark small" style="font-size:0.8rem;">
                            <%# Eval("ReportCode") %>
                        </td>
                        <td class="fl-admin-td text-dark small" style="font-size:0.82rem;">
                            <%# Eval("ReporterEmail") %>
                        </td>
                        <td class="fl-admin-td">
                            <span class="text-teal fw-semibold small d-block" style="color: #008C75;">
                                <%# Eval("ReportedItem") %>
                            </span>
                            <span class="text-muted small" style="font-size:0.75rem;" title='<%# Eval("Details") %>'>
                                <%# Eval("Details") != null && Eval("Details").ToString().Length > 60 ? Eval("Details").ToString().Substring(0, 60) + "..." : Eval("Details") %>
                            </span>
                        </td>
                        <td class="fl-admin-td">
                            <span class="badge rounded-2 px-2 py-1 small fw-semibold" style="background:#FEE2E2; color:#DC2626; font-size: 0.72rem;">
                                <%# Eval("ReportType") != null && !string.IsNullOrEmpty(Eval("ReportType").ToString()) ? Eval("ReportType") : "Spam" %>
                            </span>
                        </td>
                        <td class="fl-admin-td text-muted small" style="font-size: 0.8rem;">
                            <%# Eval("CreatedAt", "{0:MMM dd, yyyy}") %>
                        </td>
                        <td class="fl-admin-td">
                            <span class='<%# GetStatusBadgeClass(Eval("Status")) %>'>
                                <%# Eval("Status") %>
                            </span>
                        </td>
                        <td class="fl-admin-td text-end pe-4">
                            <div class="d-flex align-items-center justify-content-end gap-1">
                                <asp:LinkButton ID="btnResolve" runat="server" CommandName="Resolve" CommandArgument='<%# Eval("ReportId") %>' CssClass="btn btn-sm bg-white rounded-3 px-2 py-1 fw-semibold small shadow-none" style="border: 1px solid #00A884; color: #00A884; font-size: 0.78rem;" title="Mark as Resolved" Visible='<%# Eval("Status") != null && Eval("Status").ToString() == "Pending" %>'>
                                    <i class="bi bi-check-lg"></i> Resolve
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnDismiss" runat="server" CommandName="Dismiss" CommandArgument='<%# Eval("ReportId") %>' CssClass="btn btn-sm bg-white rounded-3 px-2 py-1 fw-semibold small shadow-none" style="border: 1px solid #94A3B8; color: #64748B; font-size: 0.78rem;" title="Dismiss Report" Visible='<%# Eval("Status") != null && Eval("Status").ToString() == "Pending" %>'>
                                    <i class="bi bi-x-lg"></i> Dismiss
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnReopen" runat="server" CommandName="Reopen" CommandArgument='<%# Eval("ReportId") %>' CssClass="btn btn-sm btn-outline-warning rounded-3 px-2 py-1 fw-semibold small shadow-none" style="font-size: 0.78rem;" title="Reopen Report" Visible='<%# Eval("Status") != null && Eval("Status").ToString() != "Pending" %>'>
                                    <i class="bi bi-arrow-counterclockwise"></i> Reopen
                                </asp:LinkButton>
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>

        <asp:Panel ID="pnlNoReports" runat="server" Visible="false" CssClass="text-center py-5 text-muted small">
            <i class="bi bi-inbox fs-2 d-block mb-2 text-secondary"></i>
            No moderation reports found for the selected criteria.
        </asp:Panel>

        <!-- Table Footer / Pagination -->
        <div class="d-flex justify-content-between align-items-center p-3 px-4 bg-white border-top flex-wrap gap-2">
            <asp:Literal ID="litPaginationInfo" runat="server" Text="Showing 0 entries" />
            <div class="d-flex align-items-center gap-1">
                <asp:LinkButton ID="btnPrevPage" runat="server" CssClass="fl-page-btn" OnClick="btnPrevPage_Click" ToolTip="Previous Page">
                    <i class="bi bi-chevron-left"></i>
                </asp:LinkButton>
                <asp:LinkButton ID="btnNextPage" runat="server" CssClass="fl-page-btn" OnClick="btnNextPage_Click" ToolTip="Next Page">
                    <i class="bi bi-chevron-right"></i>
                </asp:LinkButton>
            </div>
        </div>
    </div>
</asp:Content>
