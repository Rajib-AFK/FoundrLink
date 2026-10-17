using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class Settings : Page
    {
        private int CurrentUserId = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] != null)
            {
                CurrentUserId = Convert.ToInt32(Session["UserId"]);
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

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string title = txtTitle.Text.Trim();
            string company = txtCompany.Text.Trim();
            string location = txtLocation.Text.Trim();
            string role = ddlRole.SelectedValue;
            string bio = txtBio.Text.Trim();
            string avatarUrl = txtAvatarUrl.Text.Trim();

            // Check if email already used by someone else
            string checkEmailSql = "SELECT COUNT(1) FROM Users WHERE Email = @Email AND UserId <> @UserId";
            int exists = Convert.ToInt32(DbHelper.ExecuteScalar(checkEmailSql, new SqlParameter("@Email", email), new SqlParameter("@UserId", CurrentUserId)));
            if (exists > 0)
            {
                litAlertError.Text = "This email is already in use by another account.";
                pnlAlertError.Visible = true;
                return;
            }

            string updateSql = @"
                UPDATE Users
                SET FullName = @FullName,
                    Email = @Email,
                    Title = @Title,
                    Company = @Company,
                    Location = @Location,
                    Role = @Role,
                    Bio = @Bio,
                    AvatarUrl = @AvatarUrl
                WHERE UserId = @UserId
            ";

            SqlParameter[] p = new SqlParameter[]
            {
                new SqlParameter("@FullName", fullName),
                new SqlParameter("@Email", email),
                new SqlParameter("@Title", (object)title ?? DBNull.Value),
                new SqlParameter("@Company", (object)company ?? DBNull.Value),
                new SqlParameter("@Location", (object)location ?? DBNull.Value),
                new SqlParameter("@Role", role),
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

            litAlertSuccess.Text = "Your profile information has been saved successfully.";
            pnlAlertSuccess.Visible = true;
        }

        protected void btnUpdatePassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string currentPass = txtCurrentPassword.Text.Trim();
            string newPass = txtNewPassword.Text.Trim();

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
            string updatePassSql = "UPDATE Users SET PasswordHash = @Hash WHERE UserId = @UserId";
            DbHelper.ExecuteNonQuery(updatePassSql, new SqlParameter("@Hash", newHash), new SqlParameter("@UserId", CurrentUserId));

            txtCurrentPassword.Text = string.Empty;
            txtNewPassword.Text = string.Empty;
            txtConfirmPassword.Text = string.Empty;

            litAlertSuccess.Text = "Your password has been successfully updated.";
            pnlAlertSuccess.Visible = true;
        }

        protected void btnDeactivate_Click(object sender, EventArgs e)
        {
            string sql = "UPDATE Users SET Status = 'Inactive' WHERE UserId = @UserId";
            DbHelper.ExecuteNonQuery(sql, new SqlParameter("@UserId", CurrentUserId));

            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx?deactivated=1");
        }
    }
}
