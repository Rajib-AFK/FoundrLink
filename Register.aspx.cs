using System;
using System.Web.UI;
using FoundrLink.Helpers;
using FoundrLink.Services;
using FoundrLink.Services.Interfaces;

namespace FoundrLink
{
    public partial class Register : Page
    {
        private readonly IValidationService _validationService;
        private readonly IUserService _userService;

        public Register()
        {
            _validationService = new ValidationService();
            _userService = new UserService();
        }

        public Register(IValidationService validationService, IUserService userService)
        {
            _validationService = validationService ?? new ValidationService();
            _userService = userService ?? new UserService();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (SecurityHelper.IsUserLoggedIn())
                {
                    Response.Redirect("~/Dashboard.aspx");
                }
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string fullName = _validationService.SanitizeText(txtFullName.Text);
            string email = txtEmail.Text.Trim();
            string role = ddlRole.SelectedValue;
            string password = txtPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            // Validate all inputs using centralized ValidationService
            if (!_validationService.ValidateRegistration(fullName, email, role, password, confirmPassword, out string validationError))
            {
                ShowError(validationError);
                return;
            }

            try
            {
                var regResult = _userService.RegisterUser(fullName, email, password, role);

                if (regResult.Success && regResult.Data > 0)
                {
                    int createdUserId = regResult.Data;
                    string defaultAvatar = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80";
                    SecurityHelper.SetUserSession(createdUserId, fullName, email, role, defaultAvatar);

                    if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
                    {
                        Response.Redirect("~/Admin/Dashboard.aspx");
                    }
                    else
                    {
                        Response.Redirect("~/Dashboard.aspx");
                    }
                }
                else
                {
                    ShowError(regResult.Message ?? "Registration could not be completed. Please try again.");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Registration error: " + ex);
                ShowError("An unexpected error occurred during registration. Please try again.");
            }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litErrorMessage.Text = message;
        }
    }
}
