<%@ Page Title="Settings" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="FoundrLink.Settings" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-settings-tab-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 16px;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 500;
            color: #475569;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .fl-settings-tab-btn:hover {
            background-color: #F1F5F9;
            color: #0F172A;
        }
        .fl-settings-tab-btn.active {
            background-color: #E2E8F0;
            color: #0F172A;
            font-weight: 600;
        }
        .fl-settings-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: var(--fl-radius-card);
            padding: 32px;
            margin-bottom: 24px;
        }
        .fl-danger-card {
            background: #FFFFFF;
            border: 1px solid #FECACA;
            border-radius: var(--fl-radius-card);
            padding: 32px;
        }
        .fl-deactivate-inner-box {
            background-color: #FEF2F2;
            border: 1px solid #FEE2E2;
            border-radius: 8px;
            padding: 18px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .btn-fl-danger {
            background-color: #B91C1C;
            color: #FFFFFF;
            border: none;
            border-radius: 6px;
            padding: 8px 18px;
            font-size: 0.88rem;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.15s ease;
        }
        .btn-fl-danger:hover {
            background-color: #991B1B;
            color: #FFFFFF;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mb-4">
        <h2 class="fw-bold fs-3 text-dark mb-1" style="font-size: 2rem; letter-spacing: -0.02em;">Settings</h2>
        <p class="text-muted small mb-0">Manage your account preferences and security settings.</p>
    </div>

    <!-- Feedback Messages -->
    <asp:Panel ID="pnlAlertSuccess" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>
        <asp:Literal ID="litAlertSuccess" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <asp:Panel ID="pnlAlertError" runat="server" Visible="false" CssClass="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        <asp:Literal ID="litAlertError" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <div class="row g-4">
        <!-- Left Tab Navigation -->
        <div class="col-lg-3">
            <div class="d-flex flex-column gap-1">
                <a href="#account" class="fl-settings-tab-btn active">
                    <i class="bi bi-person fs-5"></i>
                    <span>Account</span>
                </a>
                <a href="Notifications.aspx" class="fl-settings-tab-btn">
                    <i class="bi bi-bell fs-5"></i>
                    <span>Notifications</span>
                </a>
            </div>
        </div>

        <!-- Right Content Area -->
        <div class="col-lg-9">
            <!-- 1. Profile Information Card -->
            <div class="fl-settings-card">
                <h4 class="fw-bold text-dark mb-4" style="font-size: 1.25rem;">Profile Information</h4>

                <!-- Profile Photo Upload Section -->
                <div class="d-flex flex-wrap align-items-center gap-4 mb-4 p-3 bg-light rounded-3 border">
                    <asp:Image ID="imgAvatarPreview" runat="server" CssClass="rounded-circle border shadow-sm" Width="80" Height="80" style="object-fit: cover; flex-shrink: 0;" ImageUrl="~/Images/default-avatar.png" />
                    <div class="flex-grow-1" style="min-width: 240px;">
                        <label class="form-label small fw-semibold text-dark mb-1">Profile Photo</label>
                        <asp:FileUpload ID="fuAvatar" runat="server" CssClass="form-control form-control-sm mb-1" accept=".jpg,.jpeg,.png,.webp,.gif" />
                        <div class="text-muted small" style="font-size: 0.75rem;">
                            Upload a JPG, PNG, or WebP image (max 5 MB).
                        </div>
                    </div>
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-6">
                        <label class="form-label small fw-semibold text-dark mb-1">First Name</label>
                        <input type="text" id="txtFirstName" class="form-control" style="height: 44px;" oninput="syncFullName()" />
                    </div>
                    <div class="col-6">
                        <label class="form-label small fw-semibold text-dark mb-1">Last Name</label>
                        <input type="text" id="txtLastName" class="form-control" style="height: 44px;" oninput="syncFullName()" />
                    </div>
                </div>

                <!-- Hidden / Synced server controls -->
                <asp:TextBox ID="txtFullName" runat="server" style="display:none;" />
                <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Full Name is required." ValidationGroup="ProfileGroup" />

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-dark mb-1">Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" style="height: 44px;" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Email is required." ValidationGroup="ProfileGroup" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Invalid email address format." ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ValidationGroup="ProfileGroup" />
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-semibold text-dark mb-1">Company / Startup Name</label>
                    <asp:TextBox ID="txtCompany" runat="server" CssClass="form-control" placeholder="Acme Corp" style="height: 44px;" />
                </div>

                <!-- Optional metadata controls hidden to preserve code-behind -->
                <div style="display:none;">
                    <asp:TextBox ID="txtAvatarUrl" runat="server" />
                    <asp:TextBox ID="txtTitle" runat="server" />
                    <asp:TextBox ID="txtLocation" runat="server" />
                    <asp:DropDownList ID="ddlRole" runat="server">
                        <asp:ListItem Text="Founder" Value="Founder" />
                        <asp:ListItem Text="Co-Founder" Value="Co-Founder" />
                        <asp:ListItem Text="Investor" Value="Investor" />
                        <asp:ListItem Text="Advisor" Value="Advisor" />
                    </asp:DropDownList>
                    <asp:TextBox ID="txtBio" runat="server" />
                </div>

                <div class="d-flex justify-content-end">
                    <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes" CssClass="btn-fl-dark px-4" ValidationGroup="ProfileGroup" OnClick="btnSaveProfile_Click" />
                </div>
            </div>

            <!-- 2. Change Password Card -->
            <div class="fl-settings-card">
                <h4 class="fw-bold text-dark mb-4" style="font-size: 1.25rem;">Change Password</h4>

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-dark mb-1">Current Password</label>
                    <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-control" TextMode="Password" style="height: 44px;" />
                    <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server" ControlToValidate="txtCurrentPassword" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Current password is required." ValidationGroup="PasswordGroup" />
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-6">
                        <label class="form-label small fw-semibold text-dark mb-1">New Password</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" style="height: 44px;" />
                        <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" ControlToValidate="txtNewPassword" Display="Dynamic" CssClass="text-danger small" ErrorMessage="New password is required." ValidationGroup="PasswordGroup" />
                        <asp:RegularExpressionValidator ID="revNewPassword" runat="server" ControlToValidate="txtNewPassword" ValidationExpression=".{8,}" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Must be at least 8 characters." ValidationGroup="PasswordGroup" />
                    </div>

                    <div class="col-6">
                        <label class="form-label small fw-semibold text-dark mb-1">Confirm New Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" style="height: 44px;" />
                        <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Please confirm new password." ValidationGroup="PasswordGroup" />
                        <asp:CompareValidator ID="cvPasswords" runat="server" ControlToCompare="txtNewPassword" ControlToValidate="txtConfirmPassword" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Passwords do not match." ValidationGroup="PasswordGroup" />
                    </div>
                </div>

                <div class="d-flex justify-content-end">
                    <asp:Button ID="btnUpdatePassword" runat="server" Text="Update Password" CssClass="btn-fl-outline px-4" ValidationGroup="PasswordGroup" OnClick="btnUpdatePassword_Click" />
                </div>
            </div>

            <!-- 3. Deactivate Account Card -->
            <div class="fl-danger-card">
                <h4 class="fw-bold text-danger mb-1" style="font-size: 1.25rem;">Deactivate Account</h4>
                <p class="text-muted small mb-4">Temporarily disable your profile, hidden from discovery until reactivated.</p>

                <div class="fl-deactivate-inner-box">
                    <div>
                        <div class="fw-bold text-dark small" style="font-size: 0.9rem;">Deactivate Account</div>
                        <div class="text-muted small" style="font-size: 0.8rem;">Temporarily remove your data from FoundrLink discovery.</div>
                    </div>
                    <asp:Button ID="btnDeactivate" runat="server" Text="Deactivate Account" CssClass="btn-fl-danger" OnClientClick="return confirm('Are you sure you want to deactivate your account?');" OnClick="btnDeactivate_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script>
        function initNames() {
            var full = document.getElementById('<%= txtFullName.ClientID %>').value || '';
            var parts = full.trim().split(/\s+/);
            if (parts.length > 0 && parts[0]) {
                document.getElementById('txtFirstName').value = parts[0];
                document.getElementById('txtLastName').value = parts.slice(1).join(' ');
            }
        }
        function syncFullName() {
            var fn = document.getElementById('txtFirstName').value.trim();
            var ln = document.getElementById('txtLastName').value.trim();
            document.getElementById('<%= txtFullName.ClientID %>').value = (fn + ' ' + ln).trim();
        }
        document.addEventListener('DOMContentLoaded', initNames);
    </script>
</asp:Content>
