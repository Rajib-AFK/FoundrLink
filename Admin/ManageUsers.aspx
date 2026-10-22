<%@ Page Title="Manage Users" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="ManageUsers.aspx.cs" Inherits="FoundrLink.Admin.ManageUsers" %>

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
        .fl-page-btn-dark {
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
        .fl-page-btn-dark:hover {
            background: #F8FAFC;
            color: #0F172A;
        }
        .fl-page-btn-dark.active {
            background: #0F172A;
            color: #FFFFFF;
            border-color: #0F172A;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header Row -->
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <div>
            <h1 class="fw-bold fs-2 text-dark mb-1" style="letter-spacing: -0.02em;">Manage Users</h1>
            <p class="text-muted mb-0 small">View, filter, and manage platform members.</p>
        </div>
        <button type="button" class="btn text-white fw-semibold px-3 py-2 rounded-3 shadow-none border-0 d-inline-flex align-items-center gap-2" style="background:#0F172A; font-size: 0.88rem;" data-bs-toggle="modal" data-bs-target="#addUserModal">
            <i class="bi bi-person-plus-fill"></i> Add User
        </button>
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
        <div class="row g-3 align-items-end">
            <div class="col-md-5">
                <label class="form-label text-dark fw-bold small mb-1" style="font-size:0.8rem;">Search Users</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="Search by name or email..." />
                </div>
            </div>
            <div class="col-md-3">
                <label class="form-label text-dark fw-bold small mb-1" style="font-size:0.8rem;">Role</label>
                <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="form-select rounded-3">
                    <asp:ListItem Text="All Roles" Value="" />
                    <asp:ListItem Text="Founder" Value="Founder" />
                    <asp:ListItem Text="Co-Founder" Value="Co-Founder" />
                    <asp:ListItem Text="Investor" Value="Investor" />
                    <asp:ListItem Text="Advisor" Value="Advisor" />
                    <asp:ListItem Text="Technical" Value="Technical" />
                    <asp:ListItem Text="Admin" Value="Admin" />
                </asp:DropDownList>
            </div>
            <div class="col-md-2">
                <label class="form-label text-dark fw-bold small mb-1" style="font-size:0.8rem;">Status</label>
                <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select rounded-3">
                    <asp:ListItem Text="All Statuses" Value="" />
                    <asp:ListItem Text="Active" Value="Active" />
                    <asp:ListItem Text="Inactive" Value="Inactive" />
                </asp:DropDownList>
            </div>
            <div class="col-md-2 d-flex gap-2">
                <asp:Button ID="btnReset" runat="server" Text="Clear" CssClass="btn btn-outline-secondary rounded-3 px-3 py-2 small shadow-none flex-grow-1" OnClick="btnReset_Click" />
                <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="btn text-white fw-semibold rounded-3 px-3 py-2 small shadow-none flex-grow-1" style="background:#0F172A;" OnClick="btnFilter_Click" />
            </div>
        </div>
    </div>

    <!-- Users Table Card -->
    <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4" style="border: 1px solid #E2E8F0 !important;">
        <div class="table-responsive">
            <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand" OnItemDataBound="rptUsers_ItemDataBound">
                <HeaderTemplate>
                    <table class="table align-middle mb-0">
                        <thead>
                            <tr>
                                <th class="fl-admin-th ps-4">User</th>
                                <th class="fl-admin-th">Email</th>
                                <th class="fl-admin-th">Primary Role</th>
                                <th class="fl-admin-th">Joined Date</th>
                                <th class="fl-admin-th">Status</th>
                                <th class="fl-admin-th text-end pe-4">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr class="hover-bg-light">
                        <td class="fl-admin-td ps-4">
                            <div class="d-flex align-items-center gap-3">
                                <img src='<%# Eval("AvatarUrl") %>' class="rounded-circle border flex-shrink-0" width="34" height="34" style="object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                                <div class="fw-bold text-dark small"><%# Eval("FullName") %></div>
                            </div>
                        </td>
                        <td class="fl-admin-td text-muted small" style="font-size:0.82rem;">
                            <%# Eval("Email") %>
                        </td>
                        <td class="fl-admin-td text-dark small">
                            <asp:DropDownList ID="ddlRoleChange" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlRoleChange_SelectedIndexChanged" CssClass="form-select form-select-sm py-0 px-2 d-inline-block" style="font-size: 0.8rem; height: 28px; width: auto; max-width: 125px;">
                                <asp:ListItem Text="Founder" Value="Founder" />
                                <asp:ListItem Text="Co-Founder" Value="Co-Founder" />
                                <asp:ListItem Text="Investor" Value="Investor" />
                                <asp:ListItem Text="Advisor" Value="Advisor" />
                                <asp:ListItem Text="Technical" Value="Technical" />
                                <asp:ListItem Text="Admin" Value="Admin" />
                            </asp:DropDownList>
                            <asp:HiddenField ID="hfRowUserId" runat="server" Value='<%# Eval("UserId") %>' />
                        </td>
                        <td class="fl-admin-td text-muted small" style="font-size:0.82rem;">
                            <%# Eval("CreatedAt", "{0:MMM dd, yyyy}") %>
                        </td>
                        <td class="fl-admin-td">
                            <span class='<%# Eval("Status").ToString() == "Active" ? "badge rounded-pill px-3 py-1 fw-semibold small" : "badge rounded-pill px-3 py-1 fw-semibold small" %>' style='<%# Eval("Status").ToString() == "Active" ? "background:#DCFCE7; color:#15803D;" : "background:#F1F5F9; color:#475569;" %>'>
                                <%# Eval("Status") %>
                            </span>
                        </td>
                        <td class="fl-admin-td text-end pe-4">
                            <asp:LinkButton ID="btnToggleVerify" runat="server" CommandName="ToggleVerify" CommandArgument='<%# Eval("UserId") %>' CssClass="btn btn-sm btn-link text-muted p-1" title="Toggle Verification">
                                <i class="bi bi-shield-check"></i>
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnToggleStatus" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("UserId") %>' CssClass="btn btn-sm btn-link text-muted p-1" title="Toggle Active / Inactive" OnClientClick="return confirm('Are you sure you want to change this user active status?');">
                                <i class="bi bi-arrow-repeat"></i>
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

        <asp:Panel ID="pnlNoUsers" runat="server" Visible="false" CssClass="text-center py-5 text-muted small">
            <i class="bi bi-people fs-2 d-block mb-2 text-secondary"></i>
            No platform members found matching your search criteria.
        </asp:Panel>

        <!-- Table Footer / Pagination -->
        <div class="d-flex justify-content-between align-items-center p-3 px-4 bg-white border-top flex-wrap gap-2">
            <asp:Literal ID="litPaginationInfo" runat="server" Text="Showing 0 entries" />
            <div class="d-flex align-items-center gap-1">
                <asp:LinkButton ID="btnPrevPage" runat="server" CssClass="fl-page-btn-dark" OnClick="btnPrevPage_Click" ToolTip="Previous Page">
                    <i class="bi bi-chevron-left"></i>
                </asp:LinkButton>
                <asp:LinkButton ID="btnNextPage" runat="server" CssClass="fl-page-btn-dark" OnClick="btnNextPage_Click" ToolTip="Next Page">
                    <i class="bi bi-chevron-right"></i>
                </asp:LinkButton>
            </div>
        </div>
    </div>

    <!-- Add User Modal -->
    <div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content rounded-4 border-0 shadow">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold text-dark" id="addUserModalLabel">Create Platform User</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Full Name <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtNewFullName" runat="server" CssClass="form-control rounded-3" placeholder="Jane Doe" />
                        <asp:RequiredFieldValidator ID="rfvNewFullName" runat="server" ControlToValidate="txtNewFullName" ErrorMessage="Full Name is required." Display="Dynamic" CssClass="text-danger small mt-1 d-block" ValidationGroup="CreateUserGroup" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Email Address <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtNewEmail" runat="server" CssClass="form-control rounded-3" TextMode="Email" placeholder="jane@ripaldesign.studio" />
                        <asp:RequiredFieldValidator ID="rfvNewEmail" runat="server" ControlToValidate="txtNewEmail" ErrorMessage="Email is required." Display="Dynamic" CssClass="text-danger small mt-1 d-block" ValidationGroup="CreateUserGroup" />
                        <asp:RegularExpressionValidator ID="revNewEmail" runat="server" ControlToValidate="txtNewEmail" ErrorMessage="Valid email address is required." Display="Dynamic" CssClass="text-danger small mt-1 d-block" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ValidationGroup="CreateUserGroup" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Temporary Password <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control rounded-3" Text="Password123" />
                        <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" ControlToValidate="txtNewPassword" ErrorMessage="Password is required." Display="Dynamic" CssClass="text-danger small mt-1 d-block" ValidationGroup="CreateUserGroup" />
                        <asp:RegularExpressionValidator ID="revNewPassword" runat="server" ControlToValidate="txtNewPassword" ErrorMessage="Password must be at least 8 characters." Display="Dynamic" CssClass="text-danger small mt-1 d-block" ValidationExpression="^.{8,}$" ValidationGroup="CreateUserGroup" />
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label small fw-semibold">Role</label>
                            <asp:DropDownList ID="ddlNewRole" runat="server" CssClass="form-select rounded-3">
                                <asp:ListItem Text="Founder" Value="Founder" />
                                <asp:ListItem Text="Co-Founder" Value="Co-Founder" />
                                <asp:ListItem Text="Investor" Value="Investor" />
                                <asp:ListItem Text="Advisor" Value="Advisor" />
                                <asp:ListItem Text="Admin" Value="Admin" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-6">
                            <label class="form-label small fw-semibold">Verified</label>
                            <asp:DropDownList ID="ddlNewVerified" runat="server" CssClass="form-select rounded-3">
                                <asp:ListItem Text="Yes (Verified)" Value="1" />
                                <asp:ListItem Text="No" Value="0" />
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light rounded-3 px-3" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnCreateUser" runat="server" Text="Create User" CssClass="btn text-white rounded-3 px-3 fw-semibold" style="background:#0F172A;" OnClick="btnCreateUser_Click" ValidationGroup="CreateUserGroup" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
