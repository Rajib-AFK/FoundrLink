<%@ Page Title="Join Free" Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="FoundrLink.Register" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Join Free - FoundrLink</title>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <link href="~/Content/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="~/Content/foundrlink.css" rel="stylesheet" />
    <style>
        .fl-register-wrapper {
            min-height: 100vh;
            display: flex;
        }
        .fl-register-left {
            width: 42%;
            background-color: #0F172A;
            color: #FFFFFF;
            padding: 48px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            background-image: radial-gradient(circle at 70% 50%, rgba(16, 185, 129, 0.12), transparent 70%);
        }
        .fl-register-right {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 48px 24px;
            background-color: #FAFAFA;
        }
        .fl-register-card {
            width: 100%;
            max-width: 480px;
            background-color: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        }
        @media (max-width: 991px) {
            .fl-register-left { display: none; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="fl-register-wrapper">
        <!-- Left Hero Panel -->
        <div class="fl-register-left">
            <div>
                <a href="Default.aspx" class="d-flex align-items-center gap-2 text-white text-decoration-none">
                    <div class="fl-brand-logo bg-dark text-teal border border-secondary border-opacity-50">
                        <i class="bi bi-hexagon-fill"></i>
                    </div>
                    <span class="fs-4 fw-bold">FoundrLink</span>
                </a>
            </div>

            <div class="my-auto py-5">
                <h1 class="display-5 fw-extrabold text-white mb-3" style="line-height: 1.15;">
                    Join the community of founders and builders.
                </h1>
                <p class="text-secondary lead fs-6 mb-0" style="line-height: 1.6;">
                    Accelerate your startup journey by connecting with vetted co-founders, investors, and early-stage talent.
                </p>
            </div>

            <div class="text-secondary small">
                &copy; <%: DateTime.Now.Year %> FoundrLink Inc.
            </div>
        </div>

        <!-- Right Register Card -->
        <div class="fl-register-right">
            <div>
                <div class="fl-register-card">
                    <div class="mb-4">
                        <h2 class="fw-bold mb-1 fs-3">Create your FoundrLink account</h2>
                        <p class="text-muted small">Build your profile and find the right people for your next idea.</p>
                    </div>

                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger py-2 small mb-3">
                        <asp:Literal ID="litErrorMessage" runat="server" />
                    </asp:Panel>

                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-dark mb-1">Full Name</label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="e.g. Jatin Das" />
                        <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Full Name is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-dark mb-1">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="jadas@example.com" TextMode="Email" />
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                        <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Invalid email address format." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-dark mb-1">Primary Role</label>
                        <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select">
                            <asp:ListItem Value="" Text="Select your role" />
                            <asp:ListItem Value="Founder" Text="Founder / Co-Founder" />
                            <asp:ListItem Value="Investor" Text="Investor / Angel" />
                            <asp:ListItem Value="Technical" Text="Technical Specialist / Engineer" />
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvRole" runat="server" ControlToValidate="ddlRole" InitialValue="" ErrorMessage="Please select a primary role." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                    </div>

                    <div class="row g-2 mb-3">
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold text-dark mb-1">Password</label>
                            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••" />
                            <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Password required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold text-dark mb-1">Confirm Password</label>
                            <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••" />
                            <asp:RequiredFieldValidator ID="rfvConfirm" runat="server" ControlToValidate="txtConfirmPassword" ErrorMessage="Confirm password required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                            <asp:CompareValidator ID="cvPasswords" runat="server" ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword" ErrorMessage="Passwords do not match." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                        </div>
                    </div>

                    <p class="text-muted" style="font-size: 0.75rem;">
                        By creating an account, you agree to the FoundrLink terms.
                    </p>

                    <asp:Button ID="btnRegister" runat="server" Text="Create Account" CssClass="btn btn-fl-primary w-100 py-2 fw-semibold mb-3" OnClick="btnRegister_Click" ValidationGroup="vgRegister" />

                    <div class="text-center small text-muted">
                        Already have an account? <a href="Login.aspx" class="fw-bold text-dark text-decoration-none">Sign In</a>
                    </div>
                </div>

                <div class="d-flex justify-content-center gap-3 mt-4 text-muted small">
                    <a href="#" class="text-muted text-decoration-none">Terms</a>
                    <span>&bull;</span>
                    <a href="#" class="text-muted text-decoration-none">Privacy</a>
                    <span>&bull;</span>
                    <a href="#" class="text-muted text-decoration-none">Support</a>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
