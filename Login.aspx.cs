using System;
using System.Data;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class Login : Page
    {
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
                string query = "SELECT UserId, FullName, Email, PasswordHash, Role, AvatarUrl, Status FROM dbo.Users WHERE Email = @Email";
                DataTable dt = DbHelper.ExecuteDataTable(query, DbHelper.CreateParam("@Email", SqlDbType.NVarChar, email));

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    string status = row["Status"]?.ToString() ?? "Active";

                    if (string.Equals(status, "Inactive", StringComparison.OrdinalIgnoreCase))
                    {
                        ShowError("Your account has been deactivated. Please contact support.");
                        return;
                    }

                    string storedHash = row["PasswordHash"]?.ToString();
                    if (SecurityHelper.VerifyPassword(password, storedHash))
                    {
                        int userId = Convert.ToInt32(row["UserId"]);
                        string fullName = row["FullName"]?.ToString();
                        string userEmail = row["Email"]?.ToString();
                        string role = row["Role"]?.ToString();
                        string avatar = row["AvatarUrl"]?.ToString();

                        SecurityHelper.SetUserSession(userId, fullName, userEmail, role, avatar);

                        string returnUrl = Request.QueryString["returnUrl"];
                        if (!string.IsNullOrEmpty(returnUrl) && !returnUrl.Contains("://"))
                        {
                            Response.Redirect(returnUrl);
                        }
                        else
                        {
                            RedirectByRole();
                        }
                        return;
                    }
                }

                ShowError("Invalid email address or password. Please try again.");
            }
            catch (Exception ex)
            {
                ShowError("A database connection error occurred: " + ex.Message);
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
