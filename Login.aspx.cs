using System;
using System.Web.UI;
using FoundrLink.Helpers;
using FoundrLink.Services;
using FoundrLink.Services.Interfaces;

namespace FoundrLink
{
    public partial class Login : Page
    {
        private readonly IUserService _userService;

        public Login()
        {
            _userService = new UserService();
        }

        public Login(IUserService userService)
        {
            _userService = userService ?? new UserService();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (SecurityHelper.IsUserLoggedIn())
                {
                    RedirectByRole();
                }
            }
        }

        protected void btnSignIn_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            // ASVS V2.4 & V6.3: Basic anti-automation / brute-force lockout protection
            string attemptKey = "LoginFailures_" + email.ToLowerInvariant();
            int failedAttempts = Session[attemptKey] != null ? Convert.ToInt32(Session[attemptKey]) : 0;
            DateTime? lockoutUntil = Session[attemptKey + "_Lockout"] as DateTime?;

            if (lockoutUntil.HasValue && DateTime.UtcNow < lockoutUntil.Value)
            {
                var remaining = (lockoutUntil.Value - DateTime.UtcNow).Minutes + 1;
                ShowError($"Too many failed sign-in attempts. Account access is temporarily locked for security. Please try again in {remaining} minute(s).");
                return;
            }

            try
            {
                var authResult = _userService.Authenticate(email, password);

                if (authResult.Success && authResult.Data != null)
                {
                    // Clear failed attempts counter upon successful authentication
                    Session.Remove(attemptKey);
                    Session.Remove(attemptKey + "_Lockout");

                    var user = authResult.Data;
                    SecurityHelper.SetUserSession(user.UserId, user.FullName, user.Email, user.Role, user.AvatarUrl);

                    string returnUrl = Request.QueryString["returnUrl"];
                    if (SecurityHelper.IsLocalUrl(returnUrl))
                    {
                        Response.Redirect(returnUrl);
                    }
                    else
                    {
                        RedirectByRole();
                    }
                    return;
                }

                failedAttempts++;
                Session[attemptKey] = failedAttempts;
                if (failedAttempts >= 5)
                {
                    Session[attemptKey + "_Lockout"] = DateTime.UtcNow.AddMinutes(5);
                    System.Diagnostics.Trace.TraceWarning($"Multiple failed login attempts for {email}. Temporary 5-minute lockout triggered.");
                    ShowError("Too many consecutive failed login attempts. Your account access has been temporarily locked for 5 minutes.");
                }
                else
                {
                    ShowError(authResult.Message ?? "Invalid email address or password. Please try again.");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Login error: " + ex);
                ShowError("An unexpected error occurred while signing in. Please try again.");
            }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litErrorMessage.Text = message;
        }

        private void RedirectByRole()
        {
            string role = SecurityHelper.GetCurrentUserRole();
            if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/Admin/Dashboard.aspx");
            }
            else
            {
                Response.Redirect("~/Dashboard.aspx");
            }
        }
    }
}
