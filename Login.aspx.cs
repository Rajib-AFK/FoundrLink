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

            try
            {
                var authResult = _userService.Authenticate(email, password);

                if (authResult.Success && authResult.Data != null)
                {
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

                ShowError(authResult.Message ?? "Invalid email address or password. Please try again.");
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
