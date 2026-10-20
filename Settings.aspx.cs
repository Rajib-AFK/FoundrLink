using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class Settings : Page
    {
        private int CurrentUserId;

        protected void Page_Load(object sender, EventArgs e)
        {
            int? loggedInUserId = SecurityHelper.GetCurrentUserId();
            if (!loggedInUserId.HasValue)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }
            CurrentUserId = loggedInUserId.Value;

            if (Page.Form != null)
            {
                Page.Form.Enctype = "multipart/form-data";
            }

            pnlAlertSuccess.Visible = false;
            pnlAlertError.Visible = false;

            if (!IsPostBack)
            {
                LoadUserData();
            }
        }

        private void LoadUserData()
        {
            try
            {
                string sql = "SELECT UserId, FullName, Email, Role, Title, Location, Bio, AvatarUrl, Company FROM Users WHERE UserId = @UserId";
                DataTable dt = DbHelper.ExecuteDataTable(sql, new SqlParameter("@UserId", CurrentUserId));

                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    txtFullName.Text = r["FullName"].ToString();
                    txtEmail.Text = r["Email"].ToString();
                    txtTitle.Text = r["Title"] != DBNull.Value ? r["Title"].ToString() : "";
                    txtCompany.Text = r["Company"] != DBNull.Value ? r["Company"].ToString() : "";
                    txtLocation.Text = r["Location"] != DBNull.Value ? r["Location"].ToString() : "";
                    txtBio.Text = r["Bio"] != DBNull.Value ? r["Bio"].ToString() : "";
                    txtAvatarUrl.Text = r["AvatarUrl"] != DBNull.Value ? r["AvatarUrl"].ToString() : "";

                    string role = r["Role"]?.ToString();
                    if (ddlRole.Items.FindByValue(role) != null)
                    {
                        ddlRole.SelectedValue = role;
                    }

                    imgAvatarPreview.ImageUrl = !string.IsNullOrEmpty(txtAvatarUrl.Text) 
                        ? txtAvatarUrl.Text 
                        : "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadUserData error: " + ex);
                litAlertError.Text = "An error occurred while loading profile data. Please refresh the page.";
                pnlAlertError.Visible = true;
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string title = txtTitle.Text.Trim();
            string company = txtCompany.Text.Trim();
            string location = txtLocation.Text.Trim();
            string bio = txtBio.Text.Trim();
            string avatarUrl = txtAvatarUrl.Text.Trim();
            string newSavedPhysicalPath = null;

            // Handle file upload if a file was provided
            if (fuAvatar.HasFile)
            {
                const int maxSizeBytes = 5 * 1024 * 1024;
                if (!SecurityHelper.ValidateUploadedImage(fuAvatar.PostedFile, maxSizeBytes, out string uploadError))
                {
                    litAlertError.Text = uploadError;
                    pnlAlertError.Visible = true;
                    return;
                }

                try
                {
                    string ext = Path.GetExtension(fuAvatar.FileName).ToLowerInvariant();
                    string folderVirtualPath = "~/Images/Avatars/";
                    string folderPhysicalPath = Server.MapPath(folderVirtualPath);
                    if (!Directory.Exists(folderPhysicalPath))
                    {
                        Directory.CreateDirectory(folderPhysicalPath);
                    }

                    string fileName = string.Format("avatar_{0}_{1:N}{2}", CurrentUserId, Guid.NewGuid(), ext);
                    string saveFullPath = Path.Combine(folderPhysicalPath, fileName);

                    fuAvatar.SaveAs(saveFullPath);
                    newSavedPhysicalPath = saveFullPath;

                    // Update avatar URL to new upload
                    avatarUrl = ResolveUrl(folderVirtualPath + fileName);
                    txtAvatarUrl.Text = avatarUrl;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("Avatar save error: " + ex);
                    litAlertError.Text = "An error occurred while saving the profile image. Previous photo has been preserved.";
                    pnlAlertError.Visible = true;
                    return;
                }
            }

            try
            {
                // Check if email already used by someone else
                string checkEmailSql = "SELECT COUNT(1) FROM Users WHERE Email = @Email AND UserId <> @UserId";
                int exists = Convert.ToInt32(DbHelper.ExecuteScalar(checkEmailSql, new SqlParameter("@Email", email), new SqlParameter("@UserId", CurrentUserId)));
                if (exists > 0)
                {
                    if (!string.IsNullOrEmpty(newSavedPhysicalPath) && File.Exists(newSavedPhysicalPath))
                    {
                        try { File.Delete(newSavedPhysicalPath); } catch { }
                    }

                    litAlertError.Text = "This email is already in use by another account.";
                    pnlAlertError.Visible = true;
                    return;
                }

                // Explicitly omitted Role from update to prevent unauthorized privilege escalation
                string updateSql = @"
                    UPDATE Users
                    SET FullName = @FullName,
                        Email = @Email,
                        Title = @Title,
                        Company = @Company,
                        Location = @Location,
                        Bio = @Bio,
                        AvatarUrl = @AvatarUrl,
                        UpdatedAt = SYSUTCDATETIME()
                    WHERE UserId = @UserId
                ";

                SqlParameter[] p = new SqlParameter[]
                {
                    new SqlParameter("@FullName", fullName),
                    new SqlParameter("@Email", email),
                    new SqlParameter("@Title", (object)title ?? DBNull.Value),
                    new SqlParameter("@Company", (object)company ?? DBNull.Value),
                    new SqlParameter("@Location", (object)location ?? DBNull.Value),
                    new SqlParameter("@Bio", (object)bio ?? DBNull.Value),
                    new SqlParameter("@AvatarUrl", (object)avatarUrl ?? DBNull.Value),
                    new SqlParameter("@UserId", CurrentUserId)
                };

                DbHelper.ExecuteNonQuery(updateSql, p);

                // Update session cache
                Session["FullName"] = fullName;
                Session["Email"] = email;
                if (!string.IsNullOrEmpty(avatarUrl)) Session["AvatarUrl"] = avatarUrl;

                imgAvatarPreview.ImageUrl = !string.IsNullOrEmpty(avatarUrl) ? avatarUrl : "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120";

                litAlertSuccess.Text = "Your profile information and photo have been saved successfully.";
                pnlAlertSuccess.Visible = true;
            }
            catch (Exception ex)
            {
                // Clean up orphaned file on database failure
                if (!string.IsNullOrEmpty(newSavedPhysicalPath) && File.Exists(newSavedPhysicalPath))
                {
                    try { File.Delete(newSavedPhysicalPath); } catch { }
                }

                System.Diagnostics.Trace.TraceError("SaveProfile error: " + ex);
                litAlertError.Text = "An error occurred while saving your profile. Please try again.";
                pnlAlertError.Visible = true;
            }
        }

        protected void btnUpdatePassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string currentPass = txtCurrentPassword.Text.Trim();
            string newPass = txtNewPassword.Text.Trim();

            if (string.IsNullOrEmpty(currentPass) || string.IsNullOrEmpty(newPass))
            {
                litAlertError.Text = "Please provide both your current and new password.";
                pnlAlertError.Visible = true;
                return;
            }

            if (newPass.Length < 8)
            {
                litAlertError.Text = "New password must be at least 8 characters long.";
                pnlAlertError.Visible = true;
                return;
            }

            if (newPass != txtConfirmPassword.Text.Trim())
            {
                litAlertError.Text = "New password and confirm password do not match.";
                pnlAlertError.Visible = true;
                return;
            }

            try
            {
                // Fetch stored password hash
                string sql = "SELECT PasswordHash FROM Users WHERE UserId = @UserId";
                object hashObj = DbHelper.ExecuteScalar(sql, new SqlParameter("@UserId", CurrentUserId));

                if (hashObj == null || !SecurityHelper.VerifyPassword(currentPass, hashObj.ToString()))
                {
                    litAlertError.Text = "The current password you entered is incorrect.";
                    pnlAlertError.Visible = true;
                    return;
                }

                // Hash and update
                string newHash = SecurityHelper.HashPassword(newPass);
                string updatePassSql = "UPDATE Users SET PasswordHash = @Hash, UpdatedAt = SYSUTCDATETIME() WHERE UserId = @UserId";
                DbHelper.ExecuteNonQuery(updatePassSql, new SqlParameter("@Hash", newHash), new SqlParameter("@UserId", CurrentUserId));

                txtCurrentPassword.Text = string.Empty;
                txtNewPassword.Text = string.Empty;
                txtConfirmPassword.Text = string.Empty;

                litAlertSuccess.Text = "Your password has been successfully updated.";
                pnlAlertSuccess.Visible = true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("UpdatePassword error: " + ex);
                litAlertError.Text = "An error occurred while updating your password. Please try again.";
                pnlAlertError.Visible = true;
            }
        }

        protected void btnDeactivate_Click(object sender, EventArgs e)
        {
            try
            {
                string sql = "UPDATE Users SET Status = 'Inactive', UpdatedAt = SYSUTCDATETIME() WHERE UserId = @UserId";
                DbHelper.ExecuteNonQuery(sql, new SqlParameter("@UserId", CurrentUserId));

                SecurityHelper.Logout();
                Response.Redirect("~/Login.aspx?deactivated=1");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Deactivate account error: " + ex);
                litAlertError.Text = "An error occurred while deactivating your account. Please try again.";
                pnlAlertError.Visible = true;
            }
        }
    }
}
