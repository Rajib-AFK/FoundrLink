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
            background-color: #0C1322;
            color: #FFFFFF;
            padding: 56px 64px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            background-image: 
                radial-gradient(circle at 60% 40%, rgba(2, 132, 199, 0.15), transparent 60%),
                radial-gradient(circle at 20% 80%, rgba(109, 245, 225, 0.1), transparent 50%);
        }
        .fl-register-right {
            flex: 1;
            display: flex;
            flex-direction: column;
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
            border-radius: 14px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
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
        .btn-fl-create {
            background-color: #006591;
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
            cursor: pointer;
        }
        .btn-fl-create:hover {
            background-color: #005073;
            color: #FFFFFF;
        }
        @media (max-width: 991px) {
            .fl-register-left { display: none; }
            .fl-register-right { padding: 32px 16px; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="fl-register-wrapper">
        <!-- Left Hero Panel -->
        <div class="fl-register-left">
            <div>
                <a href="Default.aspx" class="d-inline-flex align-items-center gap-2 text-white text-decoration-none">
                    <div class="fl-brand-badge">
                        <i class="bi bi-diagram-3-fill"></i>
                    </div>
                    <span class="fs-4 fw-bold">FoundrLink</span>
                </a>
            </div>

            <div class="my-auto py-5">
                <h1 class="display-5 fw-extrabold text-white mb-4" style="line-height: 1.15; font-size: 3rem; letter-spacing: -0.03em;">
                    Join the community<br />of founders and<br />builders.
                </h1>
                <p class="text-secondary lead fs-6 mb-0" style="line-height: 1.6; max-width: 440px; color: #94A3B8 !important;">
                    Accelerate your startup journey by connecting with vetted co-founders, investors, and early-stage talent.
                </p>
            </div>

            <div class="text-secondary small" style="color: #64748B !important;">
                &copy; <%: DateTime.Now.Year %> FoundrLink Inc.
            </div>
        </div>

        <!-- Right Register Card -->
        <div class="fl-register-right">
            <div class="fl-register-card">
                <div class="mb-4">
                    <h2 class="fw-bold mb-2 text-dark" style="font-size: 1.65rem; letter-spacing: -0.02em;">Create your FoundrLink account</h2>
                    <p class="text-muted small mb-0">Build your profile and find the right people for your next idea.</p>
                </div>

                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger py-2 small mb-3">
                    <asp:Literal ID="litErrorMessage" runat="server" />
                </asp:Panel>

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-dark mb-1">Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="e.g. Jatin Das" style="height: 44px;" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Full Name is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-dark mb-1">Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="alex@ripaldesign.studio" TextMode="Email" style="height: 44px;" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Invalid email address format." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-dark mb-1">Primary Role</label>
                    <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select" style="height: 44px;">
                        <asp:ListItem Value="" Text="Select your role" />
                        <asp:ListItem Value="Founder" Text="Founder / Co-Founder" />
                        <asp:ListItem Value="Investor" Text="Investor / Angel" />
                        <asp:ListItem Value="Technical" Text="Technical Specialist / Engineer" />
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="rfvRole" runat="server" ControlToValidate="ddlRole" InitialValue="" ErrorMessage="Please select a primary role." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                </div>

                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <label class="form-label small fw-semibold text-dark mb-1">Password</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••" style="height: 44px;" />
                        <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Password required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                        <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword" ValidationExpression=".{8,}" ErrorMessage="Must be at least 8 characters." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                    </div>
                    <div class="col-6">
                        <label class="form-label small fw-semibold text-dark mb-1">Confirm Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••" style="height: 44px;" />
                        <asp:RequiredFieldValidator ID="rfvConfirm" runat="server" ControlToValidate="txtConfirmPassword" ErrorMessage="Confirm required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                        <asp:CompareValidator ID="cvPasswords" runat="server" ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword" ErrorMessage="Passwords do not match." CssClass="text-danger small" Display="Dynamic" ValidationGroup="vgRegister" />
                    </div>
                </div>

                <p class="text-muted mb-4" style="font-size: 0.76rem;">
                    By creating an account, you agree to the FoundrLink terms.
                </p>

                <asp:Button ID="btnRegister" runat="server" Text="Create Account" CssClass="btn-fl-create mb-4" OnClick="btnRegister_Click" ValidationGroup="vgRegister" />

                <div class="text-center small text-muted">
                    Already have an account? <a href="Login.aspx" class="fw-bold text-decoration-none" style="color: #006591;">Sign In</a>
                </div>
            </div>

            <div class="d-flex justify-content-center gap-3 mt-4 text-muted" style="font-size: 0.78rem;">
                <a href="#" class="text-muted text-decoration-none">Terms</a>
                <a href="#" class="text-muted text-decoration-none">Privacy</a>
                <a href="#" class="text-muted text-decoration-none">Support</a>
            </div>
        </div>
    </form>
</body>
</html>
