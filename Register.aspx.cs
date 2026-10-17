using System;
using System.Data;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class Register : Page
    {
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

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string role = ddlRole.SelectedValue;
            string password = txtPassword.Text;

            try
            {
                // Check if email already exists
                object existing = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.Users WHERE Email = @Email",
                    DbHelper.CreateParam("@Email", SqlDbType.NVarChar, email));

                if (existing != null && Convert.ToInt32(existing) > 0)
                {
                    ShowError("An account with this email address already exists. Please sign in instead.");
                    return;
                }

                // Hash password securely with PBKDF2
                string passwordHash = SecurityHelper.HashPassword(password);
                string defaultAvatar = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80";

                string insertUserQuery = @"
                    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status, CreatedAt, UpdatedAt)
                    OUTPUT INSERTED.UserId
                    VALUES (@FullName, @Email, @PasswordHash, @Role, @Title, @Location, @Bio, @AvatarUrl, @Company, 0, 'Active', SYSUTCDATETIME(), SYSUTCDATETIME());";

                object newId = DbHelper.ExecuteScalar(insertUserQuery,
                    DbHelper.CreateParam("@FullName", SqlDbType.NVarChar, fullName),
                    DbHelper.CreateParam("@Email", SqlDbType.NVarChar, email),
                    DbHelper.CreateParam("@PasswordHash", SqlDbType.NVarChar, passwordHash),
                    DbHelper.CreateParam("@Role", SqlDbType.NVarChar, role),
                    DbHelper.CreateParam("@Title", SqlDbType.NVarChar, role == "Investor" ? "Angel Investor" : "Founder & CEO"),
                    DbHelper.CreateParam("@Location", SqlDbType.NVarChar, "Mumbai, India"),
                    DbHelper.CreateParam("@Bio", SqlDbType.NVarChar, "Passionate founder building next-gen scalable products."),
                    DbHelper.CreateParam("@AvatarUrl", SqlDbType.NVarChar, defaultAvatar),
                    DbHelper.CreateParam("@Company", SqlDbType.NVarChar, "FoundrLink")
                );

                if (newId != null && int.TryParse(newId.ToString(), out int userId))
                {
                    // Create corresponding FounderProfile entry
                    string insertProfileQuery = @"
                        INSERT INTO dbo.FounderProfiles (UserId, PlatformImpactConnections, PlatformImpactIntros, PlatformImpactTeams, PlatformImpactSaved, Interests, Skills, Availability, BaseLocation, ProfileCompletionPercentage)
                        VALUES (@UserId, 0, 0, 0, 0, 'SaaS, FinTech, Early Stage', 'Product, Engineering', 'Full-time', 'India', 60)";

                    DbHelper.ExecuteNonQuery(insertProfileQuery, DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));

                    // Set session and redirect to dashboard
                    SecurityHelper.SetUserSession(userId, fullName, email, role, defaultAvatar);
                    Response.Redirect("~/Dashboard.aspx");
                }
                else
                {
                    ShowError("Registration could not be completed. Please try again.");
                }
            }
            catch (Exception ex)
            {
                ShowError("An error occurred during registration: " + ex.Message);
            }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litErrorMessage.Text = message;
        }
    }
}
