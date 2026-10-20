<%@ Page Title="Sign In" Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="FoundrLink.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sign In - FoundrLink</title>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <link href="~/Content/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="~/Content/foundrlink.css" rel="stylesheet" />
    <style>
        .fl-login-wrapper {
            min-height: 100vh;
            display: flex;
        }
        .fl-login-left {
            width: 50%;
            background-color: #0C1322;
            color: #FFFFFF;
            padding: 56px 64px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            background-image: 
                radial-gradient(circle at 80% 20%, rgba(2, 132, 199, 0.12), transparent 50%),
                radial-gradient(circle at 20% 80%, rgba(109, 245, 225, 0.08), transparent 50%);
        }
        .fl-login-right {
            width: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 48px 32px;
            background-color: #FFFFFF;
        }
        .fl-login-card {
            width: 100%;
            max-width: 440px;
        }
        .fl-brand-badge {
            width: 34px;
            height: 34px;
            background-color: #0284C7;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #FFFFFF;
            font-size: 18px;
        }
        .fl-testimonial-box {
            background-color: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 14px;
            padding: 24px;
            max-width: 460px;
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
            font-size: 1rem;
        }
        .fl-input-icon-wrapper input {
            padding-left: 42px !important;
            height: 46px;
            border-radius: 8px;
            border: 1px solid #E2E8F0;
            font-size: 0.9rem;
        }
        .fl-input-icon-wrapper input:focus {
            border-color: #0284C7;
            box-shadow: 0 0 0 2px rgba(2, 132, 199, 0.15);
        }
        .btn-fl-black {
            background-color: #000000;
            color: #FFFFFF;
            border-radius: 8px;
            height: 46px;
            font-weight: 600;
            font-size: 0.92rem;
            display: flex;
            align-items: center;
            justify-content: center;
            border: none;
            width: 100%;
            transition: background-color 0.15s ease;
        }
        .btn-fl-black:hover {
            background-color: #1F2937;
            color: #FFFFFF;
        }
        .btn-fl-google {
            background-color: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 8px;
            height: 46px;
            font-weight: 600;
            font-size: 0.9rem;
            color: #1E293B;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            width: 100%;
            transition: all 0.15s ease;
        }
        .btn-fl-google:hover {
            background-color: #F8FAFC;
            border-color: #CBD5E1;
            color: #0F172A;
        }
        @media (max-width: 991px) {
            .fl-login-left { display: none; }
            .fl-login-right { width: 100%; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="fl-login-wrapper">
        <!-- Left Branding Panel -->
        <div class="fl-login-left">
            <div>
                <a href="Default.aspx" class="d-inline-flex align-items-center gap-2 text-white text-decoration-none">
                    <div class="fl-brand-badge">
                        <i class="bi bi-diagram-3-fill"></i>
                    </div>
                    <span class="fs-4 fw-bold">FoundrLink</span>
                </a>
            </div>

            <div class="py-5">
                <h1 class="display-5 fw-extrabold text-white mb-4" style="line-height: 1.15; font-size: 3.25rem; letter-spacing: -0.03em;">
                    Find your perfect<br />co-founder.
                </h1>
                <p class="text-secondary lead fs-6 mb-0" style="line-height: 1.6; max-width: 440px; color: #94A3B8 !important;">
                    Connect with visionary entrepreneurs, technical experts, and investors. Build the next big thing, together.
                </p>
            </div>

            <div>
                <div class="fl-testimonial-box">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="d-flex align-items-center gap-3">
                            <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100" class="rounded-circle" width="44" height="44" style="object-fit:cover;" alt="Alex Chen" />
                            <div>
                                <div class="fw-bold text-white small">Alex Chen</div>
                                <div style="color: #94A3B8; font-size: 0.75rem;">Technical Co-founder</div>
                            </div>
                        </div>
                        <i class="bi bi-check-circle-fill text-info" style="color: #0284C7 !important; font-size: 1.25rem;"></i>
                    </div>
                    <p class="small fst-italic mb-0" style="color: #CBD5E1; line-height: 1.5;">
                        &ldquo;FoundrLink helped me find the business partner I needed to scale my MVP into a funded startup within months.&rdquo;
                    </p>
                </div>
            </div>
        </div>

        <!-- Right Form Panel -->
        <div class="fl-login-right">
            <div class="fl-login-card">
                <div class="mb-4 pb-1">
                    <h2 class="fw-extrabold text-dark mb-2" style="font-size: 2rem; letter-spacing: -0.02em;">Welcome back</h2>
                    <p class="text-muted small mb-0">Sign in to continue building with FoundrLink.</p>
                </div>

                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger py-2 small mb-3">
                    <asp:Literal ID="litErrorMessage" runat="server" />
                </asp:Panel>

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-dark mb-1">Email address</label>
                    <div class="fl-input-icon-wrapper">
                        <i class="bi bi-envelope"></i>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="you@ripaldesign.studio" TextMode="Email" />
                    </div>
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgLogin" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Invalid email address format." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgLogin" />
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-dark mb-1">Password</label>
                    <div class="fl-input-icon-wrapper">
                        <i class="bi bi-lock"></i>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••" />
                    </div>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Password is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgLogin" />
                </div>

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="form-check">
                        <asp:CheckBox ID="chkRememberMe" runat="server" CssClass="form-check-input" />
                        <label class="form-check-label small text-muted" for="chkRememberMe">Remember me</label>
                    </div>
                    <a href="#" class="small text-decoration-none fw-semibold" style="color: #0284C7;">Forgot password?</a>
                </div>

                <asp:Button ID="btnSignIn" runat="server" Text="Sign In" CssClass="btn-fl-black mb-4" OnClick="btnSignIn_Click" ValidationGroup="vgLogin" />

                <div class="d-flex align-items-center mb-4">
                    <hr class="flex-grow-1 my-0" style="border-color: #E2E8F0;" />
                    <span class="px-3 text-muted small">Or continue with</span>
                    <hr class="flex-grow-1 my-0" style="border-color: #E2E8F0;" />
                </div>

                <button type="button" class="btn-fl-google mb-4">
                    <svg width="18" height="18" viewBox="0 0 24 24"><path fill="#EA4335" d="M12 5c1.6 0 3 .6 4.1 1.6l3.1-3.1C17.3 1.7 14.8 1 12 1 7.5 1 3.7 3.6 1.9 7.4l3.7 2.9C6.5 7.4 9 5 12 5z"/><path fill="#4285F4" d="M23.5 12.3c0-.8-.1-1.7-.2-2.3H12v4.5h6.5c-.3 1.5-1.1 2.8-2.4 3.7l3.7 2.9c2.2-2 3.7-5.1 3.7-8.8z"/><path fill="#FBBC05" d="M5.6 14.7c-.2-.7-.4-1.5-.4-2.7s.1-2 .4-2.7L1.9 6.4C.7 8.8 0 10.4 0 12s.7 3.2 1.9 5.6l3.7-2.9z"/><path fill="#34A853" d="M12 23c3.2 0 6-1.1 8-3l-3.7-2.9c-1.1.7-2.5 1.2-4.3 1.2-3 0-5.5-2.4-6.4-5.3L1.9 16c1.8 3.8 5.6 7 10.1 7z"/></svg>
                    Google
                </button>

                <div class="text-center small text-muted">
                    Don't have an account? <a href="Register.aspx" class="fw-bold text-dark text-decoration-none">Create one</a>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
