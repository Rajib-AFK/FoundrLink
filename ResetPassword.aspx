<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="FoundrLink.ResetPassword" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Set New Password - FoundrLink</title>

    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <link href="~/Content/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="~/Content/foundrlink.css" rel="stylesheet" />

    <style>
        .fl-auth-wrapper {
            min-height: 100vh;
            display: flex;
        }
        .fl-auth-left {
            background-color: #0F172A;
            color: #FFFFFF;
            width: 45%;
            padding: 60px 80px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
        }
        .fl-auth-right {
            width: 55%;
            background-color: #FFFFFF;
            padding: 60px 100px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        @media (max-width: 991px) {
            .fl-auth-left { display: none; }
            .fl-auth-right { width: 100%; padding: 40px 24px; }
        }
        .btn-fl-black {
            background-color: #0F172A;
            color: #FFFFFF;
            font-weight: 600;
            border-radius: 8px;
            padding: 12px;
            border: none;
            width: 100%;
            transition: all 0.2s ease;
        }
        .btn-fl-black:hover {
            background-color: #1E293B;
            color: #FFFFFF;
        }
        .fl-input-icon-wrapper {
            position: relative;
        }
        .fl-input-icon-wrapper i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #94A3B8;
        }
        .fl-input-icon-wrapper .form-control {
            padding-left: 42px;
            height: 46px;
            border-radius: 8px;
            border-color: #E2E8F0;
        }
        .fl-input-icon-wrapper .form-control:focus {
            border-color: #0284C7;
            box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.15);
        }
    </style>
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div class="fl-auth-wrapper">
            <!-- Left Branding Pane -->
            <div class="fl-auth-left">
                <div>
                    <a href="Default.aspx" class="d-flex align-items-center gap-2 text-decoration-none text-white mb-5">
                        <div style="width: 38px; height: 38px; background: #0284C7; border-radius: 9px; display: flex; align-items: center; justify-content: center;">
                            <i class="bi bi-hexagon-fill" style="color: #6DF5E1; font-size: 1.25rem;"></i>
                        </div>
                        <span class="fs-4 fw-bold">FoundrLink</span>
                    </a>

                    <div style="max-width: 420px; margin-top: 100px;">
                        <h1 class="fw-bold display-6 mb-3">Security &amp; Passwords</h1>
                        <p class="text-secondary small lh-lg" style="color: #94A3B8 !important;">
                            Create a strong, unique password with at least 8 characters. We use salted PBKDF2 cryptography to ensure your account credentials remain strictly confidential.
                        </p>
                    </div>
                </div>

                <div class="small" style="color: #64748B;">
                    &copy; 2024 FoundrLink Inc. Built for verified builders.
                </div>
            </div>

            <!-- Right Content Pane -->
            <div class="fl-auth-right">
                <div style="max-width: 440px; width: 100%; margin: 0 auto;">
                    <div class="mb-4">
                        <h2 class="fw-bold text-dark mb-2">Create New Password</h2>
                        <p class="text-muted small">Please choose a secure new password for your account.</p>
                    </div>

                    <!-- Token Invalid/Expired Alert -->
                    <asp:Panel ID="pnlInvalidToken" runat="server" Visible="false" CssClass="alert alert-danger py-3 small mb-4">
                        <div class="d-flex align-items-start gap-2">
                            <i class="bi bi-exclamation-triangle-fill fs-5 mt-1"></i>
                            <div>
                                <div class="fw-bold mb-1">Invalid or Expired Link</div>
                                <asp:Literal ID="litInvalidTokenMsg" runat="server" Text="This password reset link is invalid, has expired, or has already been used." />
                                <div class="mt-2">
                                    <a href="ForgotPassword.aspx" class="btn btn-sm btn-outline-danger">Request New Reset Link</a>
                                </div>
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- Success Alert -->
                    <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="alert alert-success py-3 small mb-4">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-check-circle-fill fs-5"></i>
                            <div>
                                <asp:Literal ID="litSuccessMsg" runat="server" Text="Your password has been reset successfully!" />
                            </div>
                        </div>
                        <div class="mt-3">
                            <a href="Login.aspx" class="btn btn-sm btn-dark px-4">Sign In Now</a>
                        </div>
                    </asp:Panel>

                    <!-- Reset Password Form -->
                    <asp:Panel ID="pnlResetForm" runat="server">
                        <div class="mb-3">
                            <label class="form-label small fw-semibold text-dark mb-1">New Password</label>
                            <div class="fl-input-icon-wrapper">
                                <i class="bi bi-lock"></i>
                                <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••" />
                            </div>
                            <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" ControlToValidate="txtNewPassword" ErrorMessage="New password is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgReset" />
                            <asp:RegularExpressionValidator ID="revNewPassword" runat="server" ControlToValidate="txtNewPassword" ValidationExpression=".{8,}" ErrorMessage="Password must be at least 8 characters long." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgReset" />
                        </div>

                        <div class="mb-4">
                            <label class="form-label small fw-semibold text-dark mb-1">Confirm New Password</label>
                            <div class="fl-input-icon-wrapper">
                                <i class="bi bi-lock-fill"></i>
                                <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••" />
                            </div>
                            <asp:RequiredFieldValidator ID="rfvConfirm" runat="server" ControlToValidate="txtConfirmPassword" ErrorMessage="Confirm password is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgReset" />
                            <asp:CompareValidator ID="cvPasswords" runat="server" ControlToValidate="txtConfirmPassword" ControlToCompare="txtNewPassword" ErrorMessage="Passwords do not match." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgReset" />
                        </div>

                        <asp:Button ID="btnResetPassword" runat="server" Text="Update Password" CssClass="btn-fl-black mb-4" OnClick="btnResetPassword_Click" ValidationGroup="vgReset" />
                    </asp:Panel>

                    <div class="text-center small text-muted">
                        Return to <a href="Login.aspx" class="fw-bold text-dark text-decoration-none">Sign In</a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
