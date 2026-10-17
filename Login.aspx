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
        .fl-auth-wrapper {
            min-height: 100vh;
            display: flex;
        }
        .fl-auth-left {
            width: 45%;
            background-color: #0F172A;
            color: #FFFFFF;
            padding: 48px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .fl-auth-right {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 48px;
            background-color: #FFFFFF;
        }
        .fl-auth-card {
            width: 100%;
            max-width: 420px;
        }
        @media (max-width: 991px) {
            .fl-auth-left { display: none; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="fl-auth-wrapper">
        <!-- Left Branding Panel -->
        <div class="fl-auth-left">
            <div>
                <a href="Default.aspx" class="d-flex align-items-center gap-2 text-white text-decoration-none">
                    <div class="fl-brand-logo bg-dark text-teal border border-secondary border-opacity-50">
                        <i class="bi bi-hexagon-fill"></i>
                    </div>
                    <span class="fs-4 fw-bold">FoundrLink</span>
                </a>
            </div>

            <div class="py-5">
                <h1 class="display-5 fw-extrabold text-white mb-3" style="line-height: 1.15;">
                    Find your perfect co-founder.
                </h1>
                <p class="text-secondary lead fs-6 mb-0" style="line-height: 1.6;">
                    Connect with visionary entrepreneurs, technical experts, and investors. Build the next big thing, together.
                </p>
            </div>

            <div>
                <div class="p-4 rounded-3 border border-secondary border-opacity-25" style="background-color: rgba(255, 255, 255, 0.03);">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="d-flex align-items-center gap-3">
                            <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100" class="rounded-circle" width="42" height="42" />
                            <div>
                                <div class="fw-bold text-white small">Alex Chen</div>
                                <div class="text-secondary" style="font-size: 0.75rem;">Technical Co-founder</div>
                            </div>
                        </div>
                        <i class="bi bi-check-circle-fill text-teal"></i>
                    </div>
                    <p class="text-light text-opacity-75 small fst-italic mb-0">
                        &ldquo;FoundrLink helped me find the business partner I needed to scale my MVP into a funded startup within months.&rdquo;
                    </p>
                </div>
            </div>
        </div>

        <!-- Right Form Panel -->
        <div class="fl-auth-right">
            <div class="fl-auth-card">
                <div class="mb-4">
                    <h2 class="fw-bold mb-1">Welcome back</h2>
                    <p class="text-muted small">Sign in to continue building with FoundrLink.</p>
                </div>

                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger py-2 small mb-3">
                    <asp:Literal ID="litErrorMessage" runat="server" />
                </asp:Panel>

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-dark">Email address</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-envelope"></i></span>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="you@startup.com" TextMode="Email" />
                    </div>
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgLogin" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Invalid email address format." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgLogin" />
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-dark">Password</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control border-start-0 ps-0" TextMode="Password" placeholder="••••••••" />
                    </div>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Password is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgLogin" />
                </div>

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="form-check">
                        <asp:CheckBox ID="chkRememberMe" runat="server" CssClass="form-check-input" />
                        <label class="form-check-label small text-muted" for="chkRememberMe">Remember me</label>
                    </div>
                    <a href="#" class="small text-decoration-none fw-semibold text-primary">Forgot password?</a>
                </div>

                <asp:Button ID="btnSignIn" runat="server" Text="Sign In" CssClass="btn btn-dark w-100 py-2 fw-semibold mb-4" OnClick="btnSignIn_Click" ValidationGroup="vgLogin" />

                <div class="d-flex align-items-center mb-4">
                    <hr class="flex-grow-1 my-0 text-muted" />
                    <span class="px-3 text-muted small">Or continue with</span>
                    <hr class="flex-grow-1 my-0 text-muted" />
                </div>

                <button type="button" class="btn btn-outline-secondary w-100 py-2 d-flex align-items-center justify-content-center gap-2 mb-4 small fw-semibold">
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
