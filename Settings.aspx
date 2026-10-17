<%@ Page Title="Settings" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="FoundrLink.Settings" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-settings-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: 14px;
            padding: 32px;
            margin-bottom: 28px;
        }
        .fl-danger-card {
            background: #FFF5F5;
            border: 1px solid #FED7D7;
            border-radius: 14px;
            padding: 32px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row mb-4">
        <div class="col-12">
            <h2 class="fw-bold fs-3 text-dark mb-1">Account Settings</h2>
            <p class="text-muted">Manage your personal credentials, profile information, and platform security.</p>
        </div>
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

    <div class="row">
        <div class="col-lg-8">
            <!-- Profile Info Section -->
            <div class="fl-settings-card">
                <h4 class="fw-bold fs-5 text-dark mb-1">Profile Information</h4>
                <p class="text-muted small mb-4">Update your basic identity and public contact details.</p>

                <div class="d-flex align-items-center gap-4 mb-4">
                    <asp:Image ID="imgAvatarPreview" runat="server" CssClass="rounded-circle border" Width="80" Height="80" style="object-fit:cover;" />
                    <div>
                        <label class="form-label fw-semibold small mb-1">Profile Picture URL</label>
                        <asp:TextBox ID="txtAvatarUrl" runat="server" CssClass="form-control form-control-sm" style="max-width: 380px;" placeholder="https://..." />
                        <div class="text-muted small mt-1" style="font-size: 0.75rem;">Enter a valid image URL for your public avatar.</div>
                    </div>
                </div>

                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">Full Name <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" />
                        <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Full Name is required." ValidationGroup="ProfileGroup" />
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">Email Address <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" />
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Email is required." ValidationGroup="ProfileGroup" />
                        <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Invalid email address format." ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ValidationGroup="ProfileGroup" />
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">Professional Title</label>
                        <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="e.g. Co-Founder & CTO" />
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">Company / Startup</label>
                        <asp:TextBox ID="txtCompany" runat="server" CssClass="form-control" placeholder="e.g. HealthPulse" />
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">Location</label>
                        <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control" placeholder="e.g. San Francisco, CA" />
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">Role</label>
                        <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Founder" Value="Founder" />
                            <asp:ListItem Text="Co-Founder" Value="Co-Founder" />
                            <asp:ListItem Text="Investor" Value="Investor" />
                            <asp:ListItem Text="Advisor" Value="Advisor" />
                        </asp:DropDownList>
                    </div>

                    <div class="col-12">
                        <label class="form-label fw-semibold small">Bio</label>
                        <asp:TextBox ID="txtBio" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Brief summary of your background, experience, and passions..." />
                    </div>
                </div>

                <div class="mt-4 pt-3 border-top d-flex justify-content-end">
                    <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes" CssClass="btn btn-fl-teal px-4" ValidationGroup="ProfileGroup" OnClick="btnSaveProfile_Click" />
                </div>
            </div>

            <!-- Password & Security Section -->
            <div class="fl-settings-card">
                <h4 class="fw-bold fs-5 text-dark mb-1">Security & Password</h4>
                <p class="text-muted small mb-4">Ensure your account is using a strong and unique password.</p>

                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label fw-semibold small">Current Password <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-control" TextMode="Password" />
                        <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server" ControlToValidate="txtCurrentPassword" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Current password is required." ValidationGroup="PasswordGroup" />
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">New Password <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" />
                        <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" ControlToValidate="txtNewPassword" Display="Dynamic" CssClass="text-danger small" ErrorMessage="New password is required." ValidationGroup="PasswordGroup" />
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">Confirm New Password <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" />
                        <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Please confirm your new password." ValidationGroup="PasswordGroup" />
                        <asp:CompareValidator ID="cvPasswords" runat="server" ControlToCompare="txtNewPassword" ControlToValidate="txtConfirmPassword" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Passwords do not match." ValidationGroup="PasswordGroup" />
                    </div>
                </div>

                <div class="mt-4 pt-3 border-top d-flex justify-content-end">
                    <asp:Button ID="btnUpdatePassword" runat="server" Text="Update Password" CssClass="btn btn-dark px-4" ValidationGroup="PasswordGroup" OnClick="btnUpdatePassword_Click" />
                </div>
            </div>

            <!-- Danger Zone -->
            <div class="fl-danger-card">
                <h4 class="fw-bold fs-5 text-danger mb-1">Danger Zone</h4>
                <p class="text-muted small mb-3">Once you deactivate your account, your profile and active startups will no longer be visible to others.</p>
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <div class="fw-bold text-dark small">Deactivate Account</div>
                        <div class="text-muted small">Disable all connection invites and hide from startup discovery.</div>
                    </div>
                    <asp:Button ID="btnDeactivate" runat="server" Text="Deactivate Account" CssClass="btn btn-outline-danger btn-sm" OnClientClick="return confirm('Are you sure you want to deactivate your account?');" OnClick="btnDeactivate_Click" />
                </div>
            </div>
        </div>

        <!-- Sidebar Tips -->
        <div class="col-lg-4">
            <div class="fl-settings-card">
                <h5 class="fw-bold text-dark mb-3">Profile Visibility</h5>
                <p class="text-muted small mb-4">A complete profile with a verified company and clear bio increases response rates by up to <strong>3.5x</strong>.</p>
                <div class="p-3 bg-light rounded-3 border mb-3">
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <i class="bi bi-shield-check text-success fs-5"></i>
                        <span class="fw-bold small text-dark">Identity Verification</span>
                    </div>
                    <p class="text-muted small mb-0" style="font-size: 0.8rem;">Your account is officially verified on FoundrLink.</p>
                </div>
                <div class="p-3 bg-light rounded-3 border">
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <i class="bi bi-bell text-teal fs-5"></i>
                        <span class="fw-bold small text-dark">Instant Notifications</span>
                    </div>
                    <p class="text-muted small mb-0" style="font-size: 0.8rem;">Enabled for collaboration requests and direct investor messages.</p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
