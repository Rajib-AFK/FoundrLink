<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="FoundrLink.ForgotPassword" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Forgot Password - FoundrLink</title>

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
                        <h1 class="fw-bold display-6 mb-3">Account Recovery</h1>
                        <p class="text-secondary small lh-lg" style="color: #94A3B8 !important;">
                            Enter the email address registered with your FoundrLink account. We will generate a secure, single-use, time-limited token to restore access to your account.
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
                        <h2 class="fw-bold text-dark mb-2">Reset your password</h2>
                        <p class="text-muted small">Please provide your account email address below.</p>
                    </div>

                    <asp:Panel ID="pnlNotice" runat="server" Visible="false" CssClass="alert alert-info py-3 small mb-4">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-info-circle-fill fs-5"></i>
                            <div>
                                <asp:Literal ID="litNoticeMessage" runat="server" />
                            </div>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlDevResetLink" runat="server" Visible="false" CssClass="alert alert-warning py-3 small mb-4">
                        <div class="fw-bold mb-1"><i class="bi bi-gear-fill me-1"></i> Development Reset Link:</div>
                        <div class="text-break">
                            <asp:HyperLink ID="lnkDevReset" runat="server" CssClass="fw-semibold text-dark text-decoration-underline" />
                        </div>
                        <small class="text-muted d-block mt-1">Note: In production with SMTP configured, this link is delivered directly via email.</small>
                    </asp:Panel>

                    <asp:Panel ID="pnlForm" runat="server">
                        <div class="mb-4">
                            <label class="form-label small fw-semibold text-dark mb-1">Email address</label>
                            <div class="fl-input-icon-wrapper">
                                <i class="bi bi-envelope"></i>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="you@ripaldesign.studio" TextMode="Email" />
                            </div>
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgForgot" />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Invalid email address format." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgForgot" />
                        </div>

                        <asp:Button ID="btnSubmit" runat="server" Text="Request Password Reset" CssClass="btn-fl-black mb-4" OnClick="btnSubmit_Click" ValidationGroup="vgForgot" />
                    </asp:Panel>

                    <div class="text-center small text-muted">
                        Remember your password? <a href="Login.aspx" class="fw-bold text-dark text-decoration-none">Sign In</a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
