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

            // Server-side validation
            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(role))
            {
                ShowError("Please complete all required fields.");
                return;
            }

            if (password.Length < 8)
            {
                ShowError("Password must be at least 8 characters long.");
                return;
            }

            if (password != txtConfirmPassword.Text)
            {
                ShowError("Password and confirmation password do not match.");
                return;
            }

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
                int createdUserId = 0;

                // Atomic transaction: Insert User + Insert FounderProfile
                DbHelper.ExecuteInTransaction((conn, tx) =>
                {
                    string insertUserQuery = @"
                        INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status, CreatedAt, UpdatedAt)
                        OUTPUT INSERTED.UserId
                        VALUES (@FullName, @Email, @PasswordHash, @Role, @Title, @Location, @Bio, @AvatarUrl, @Company, 0, 'Active', SYSUTCDATETIME(), SYSUTCDATETIME());";

                    using (var cmdUser = new System.Data.SqlClient.SqlCommand(insertUserQuery, conn, tx))
                    {
                        cmdUser.Parameters.Add(new System.Data.SqlClient.SqlParameter("@FullName", SqlDbType.NVarChar) { Value = fullName });
                        cmdUser.Parameters.Add(new System.Data.SqlClient.SqlParameter("@Email", SqlDbType.NVarChar) { Value = email });
                        cmdUser.Parameters.Add(new System.Data.SqlClient.SqlParameter("@PasswordHash", SqlDbType.NVarChar) { Value = passwordHash });
                        cmdUser.Parameters.Add(new System.Data.SqlClient.SqlParameter("@Role", SqlDbType.NVarChar) { Value = role });
                        cmdUser.Parameters.Add(new System.Data.SqlClient.SqlParameter("@Title", SqlDbType.NVarChar) { Value = role == "Investor" ? "Angel Investor" : "Founder & CEO" });
                        cmdUser.Parameters.Add(new System.Data.SqlClient.SqlParameter("@Location", SqlDbType.NVarChar) { Value = "Mumbai, India" });
                        cmdUser.Parameters.Add(new System.Data.SqlClient.SqlParameter("@Bio", SqlDbType.NVarChar) { Value = "Passionate founder building next-gen scalable products." });
                        cmdUser.Parameters.Add(new System.Data.SqlClient.SqlParameter("@AvatarUrl", SqlDbType.NVarChar) { Value = defaultAvatar });
                        cmdUser.Parameters.Add(new System.Data.SqlClient.SqlParameter("@Company", SqlDbType.NVarChar) { Value = "FoundrLink" });

                        object newId = cmdUser.ExecuteScalar();
                        if (newId == null || !int.TryParse(newId.ToString(), out createdUserId))
                        {
                            throw new InvalidOperationException("Failed to obtain newly created user identity.");
                        }
                    }

                    // Create corresponding FounderProfile entry within the same transaction
                    string insertProfileQuery = @"
                        INSERT INTO dbo.FounderProfiles (UserId, PlatformImpactConnections, PlatformImpactIntros, PlatformImpactTeams, PlatformImpactSaved, Interests, Skills, Availability, BaseLocation, ProfileCompletionPercentage)
                        VALUES (@UserId, 0, 0, 0, 0, 'SaaS, FinTech, Early Stage', 'Product, Engineering', 'Full-time', 'India', 60);";

                    using (var cmdProfile = new System.Data.SqlClient.SqlCommand(insertProfileQuery, conn, tx))
                    {
                        cmdProfile.Parameters.Add(new System.Data.SqlClient.SqlParameter("@UserId", SqlDbType.Int) { Value = createdUserId });
                        cmdProfile.ExecuteNonQuery();
                    }
                });

                if (createdUserId > 0)
                {
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
                    ShowError("Registration could not be completed. Please try again.");
                }
            }
            catch (System.Data.SqlClient.SqlException sqlEx)
            {
                System.Diagnostics.Trace.TraceError("Registration SQL error: " + sqlEx);
                if (sqlEx.Number == 2627 || sqlEx.Number == 2601)
                {
                    ShowError("An account with this email address already exists. Please sign in instead.");
                }
                else
                {
                    ShowError("A database error occurred during registration. Please try again later.");
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
