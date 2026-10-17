<%@ Page Title="Manage Users" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="ManageUsers.aspx.cs" Inherits="FoundrLink.Admin.ManageUsers" %>

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
            <h2 class="fw-bold fs-3 text-dark mb-1">User Management</h2>
            <p class="text-muted mb-0">Search, filter, update credentials, and manage verification status of platform members.</p>
        </div>
        <button type="button" class="btn btn-fl-teal" data-bs-toggle="modal" data-bs-target="#addUserModal">
            <i class="bi bi-person-plus-fill me-1"></i> Add New User
        </button>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show" role="alert">
        <asp:Literal ID="litAlertMsg" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- Filters Bar -->
    <div class="card border-0 shadow-sm rounded-4 p-3 mb-4">
        <div class="row g-2 align-items-center">
            <div class="col-md-5">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="Search by name, email, or company..." />
                </div>
            </div>
            <div class="col-md-3">
                <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="form-select">
                    <asp:ListItem Text="All Roles" Value="" />
                    <asp:ListItem Text="Founder" Value="Founder" />
                    <asp:ListItem Text="Co-Founder" Value="Co-Founder" />
                    <asp:ListItem Text="Investor" Value="Investor" />
                    <asp:ListItem Text="Advisor" Value="Advisor" />
                    <asp:ListItem Text="Admin" Value="Admin" />
                </asp:DropDownList>
            </div>
            <div class="col-md-2">
                <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select">
                    <asp:ListItem Text="All Status" Value="" />
                    <asp:ListItem Text="Active" Value="Active" />
                    <asp:ListItem Text="Inactive" Value="Inactive" />
                </asp:DropDownList>
            </div>
            <div class="col-md-2 d-flex gap-2">
                <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="btn btn-dark w-100" OnClick="btnFilter_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-outline-secondary" OnClick="btnReset_Click" />
            </div>
        </div>
    </div>

    <!-- Users Table Card -->
    <div class="card border-0 shadow-sm rounded-4 p-0 overflow-hidden">
        <div class="table-responsive">
            <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                <HeaderTemplate>
                    <table class="table align-middle table-hover mb-0 fl-admin-table">
                        <thead>
                            <tr>
                                <th class="ps-4">User</th>
                                <th>Role</th>
                                <th>Company / Title</th>
                                <th>Verification</th>
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
                                <img src='<%# Eval("AvatarUrl") %>' class="rounded-circle border" width="38" height="38" style="object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                                <div>
                                    <div class="fw-bold text-dark"><%# Eval("FullName") %></div>
                                    <div class="text-muted small"><%# Eval("Email") %></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="badge bg-light text-dark border px-2 py-1"><%# Eval("Role") %></span>
                        </td>
                        <td class="small text-secondary">
                            <div><%# Eval("Title") %></div>
                            <div class="text-muted"><%# Eval("Company") %></div>
                        </td>
                        <td>
                            <%# Convert.ToBoolean(Eval("IsVerified")) 
                                ? "<span class='badge bg-teal-subtle text-teal' style='background:#E6FAF5; color:#10B981;'><i class='bi bi-patch-check-fill me-1'></i>Verified</span>" 
                                : "<span class='badge bg-light text-muted border'>Unverified</span>" %>
                        </td>
                        <td>
                            <span class='<%# Eval("Status").ToString() == "Active" ? "badge bg-success-subtle text-success" : "badge bg-danger-subtle text-danger" %>'>
                                <%# Eval("Status") %>
                            </span>
                        </td>
                        <td class="text-end pe-4">
                            <asp:LinkButton ID="btnToggleVerify" runat="server" CommandName="ToggleVerify" CommandArgument='<%# Eval("UserId") %>' CssClass="btn btn-sm btn-outline-secondary me-1" title="Toggle Verification">
                                <i class="bi bi-shield-check"></i>
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnToggleStatus" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("UserId") %>' CssClass='<%# Eval("Status").ToString() == "Active" ? "btn btn-sm btn-outline-warning me-1" : "btn btn-sm btn-outline-success me-1" %>' title="Toggle Status">
                                <i class='<%# Eval("Status").ToString() == "Active" ? "bi bi-pause-fill" : "bi bi-play-fill" %>'></i>
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
                        <asp:TextBox ID="txtNewFullName" runat="server" CssClass="form-control" placeholder="Jane Doe" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Email Address <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtNewEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="jane@foundrlink.com" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Temporary Password <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" Text="Password123" />
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label small fw-semibold">Role</label>
                            <asp:DropDownList ID="ddlNewRole" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Founder" Value="Founder" />
                                <asp:ListItem Text="Co-Founder" Value="Co-Founder" />
                                <asp:ListItem Text="Investor" Value="Investor" />
                                <asp:ListItem Text="Advisor" Value="Advisor" />
                                <asp:ListItem Text="Admin" Value="Admin" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-6">
                            <label class="form-label small fw-semibold">Verified</label>
                            <asp:DropDownList ID="ddlNewVerified" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Yes (Verified)" Value="1" />
                                <asp:ListItem Text="No" Value="0" />
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnCreateUser" runat="server" Text="Create User" CssClass="btn btn-fl-teal" OnClick="btnCreateUser_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
