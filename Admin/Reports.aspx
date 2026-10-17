<%@ Page Title="Moderation & Reports" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="FoundrLink.Admin.Reports" %>

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
    <div class="row mb-4">
        <div class="col-12">
            <h2 class="fw-bold fs-3 text-dark mb-1">Reports & Moderation</h2>
            <p class="text-muted">Review incoming platform flags, suspicious activity, and support tickets requiring administrative intervention.</p>
        </div>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show" role="alert">
        <asp:Literal ID="litAlertMsg" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- Filter Bar -->
    <div class="card border-0 shadow-sm rounded-4 p-3 mb-4">
        <div class="row g-2 align-items-center">
            <div class="col-md-5">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="Search ticket code, reporter, or subject..." />
                </div>
            </div>
            <div class="col-md-3">
                <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select">
                    <asp:ListItem Text="All Statuses" Value="" />
                    <asp:ListItem Text="Pending Review" Value="Pending" />
                    <asp:ListItem Text="Resolved" Value="Resolved" />
                    <asp:ListItem Text="Dismissed" Value="Dismissed" />
                </asp:DropDownList>
            </div>
            <div class="col-md-2">
                <asp:DropDownList ID="ddlPriorityFilter" runat="server" CssClass="form-select">
                    <asp:ListItem Text="All Priorities" Value="" />
                    <asp:ListItem Text="Urgent" Value="Urgent" />
                    <asp:ListItem Text="High" Value="High" />
                    <asp:ListItem Text="Normal" Value="Normal" />
                </asp:DropDownList>
            </div>
            <div class="col-md-2 d-flex gap-2">
                <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="btn btn-dark w-100" OnClick="btnFilter_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-outline-secondary" OnClick="btnReset_Click" />
            </div>
        </div>
    </div>

    <!-- Reports Table Card -->
    <div class="card border-0 shadow-sm rounded-4 p-0 overflow-hidden">
        <div class="table-responsive">
            <asp:Repeater ID="rptReports" runat="server" OnItemCommand="rptReports_ItemCommand">
                <HeaderTemplate>
                    <table class="table align-middle table-hover mb-0 fl-admin-table">
                        <thead>
                            <tr>
                                <th class="ps-4">Ticket</th>
                                <th>Reporter</th>
                                <th>Category & Details</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Date</th>
                                <th class="text-end pe-4">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="ps-4 fw-bold text-dark font-monospace small">
                            <%# Eval("ReportCode") %>
                        </td>
                        <td class="small">
                            <div class="fw-semibold text-dark"><%# Eval("ReporterEmail") %></div>
                        </td>
                        <td>
                            <div class="fw-bold small text-dark"><%# Eval("ReportedItem") %></div>
                            <div class="text-muted small text-truncate" style="max-width: 280px;" title='<%# Eval("Details") %>'><%# Eval("Details") %></div>
                        </td>
                        <td>
                            <span class='<%# GetPriorityBadgeClass(Eval("Priority").ToString()) %>'>
                                <%# Eval("Priority") %>
                            </span>
                        </td>
                        <td>
                            <span class='<%# Eval("Status").ToString() == "Pending" ? "badge bg-warning-subtle text-warning" : (Eval("Status").ToString() == "Resolved" ? "badge bg-success-subtle text-success" : "badge bg-secondary-subtle text-secondary") %>'>
                                <%# Eval("Status") %>
                            </span>
                        </td>
                        <td class="small text-muted">
                            <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy") %>
                        </td>
                        <td class="text-end pe-4">
                            <%# Eval("Status").ToString() == "Pending" ? @"
                                <asp:LinkButton runat='server' CommandName='Resolve' CommandArgument='" + Eval("ReportId") + @"' CssClass='btn btn-sm btn-outline-success me-1' title='Resolve Ticket'>
                                    <i class='bi bi-check-circle'></i> Resolve
                                </asp:LinkButton>
                                <asp:LinkButton runat='server' CommandName='Dismiss' CommandArgument='" + Eval("ReportId") + @"' CssClass='btn btn-sm btn-outline-secondary' title='Dismiss Ticket'>
                                    <i class='bi bi-slash-circle'></i> Dismiss
                                </asp:LinkButton>
                            " : @"
                                <span class='text-muted small'><i class='bi bi-check2 text-success me-1'></i>Done</span>
                            " %>
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
