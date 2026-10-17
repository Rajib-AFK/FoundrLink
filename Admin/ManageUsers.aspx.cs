using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;

namespace FoundrLink.Admin
{
    public partial class ManageUsers : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;

            if (!IsPostBack)
            {
                LoadUsers();
            }
        }

        private void LoadUsers()
        {
            string search = txtSearch.Text.Trim();
            string role = ddlRoleFilter.SelectedValue;
            string status = ddlStatusFilter.SelectedValue;

            string sql = "SELECT UserId, FullName, Email, Role, Title, Company, AvatarUrl, IsVerified, Status FROM Users WHERE 1=1";

            if (!string.IsNullOrEmpty(search))
            {
                sql += " AND (FullName LIKE '%' + @Search + '%' OR Email LIKE '%' + @Search + '%' OR Company LIKE '%' + @Search + '%')";
            }

            if (!string.IsNullOrEmpty(role))
            {
                sql += " AND Role = @Role";
            }

            if (!string.IsNullOrEmpty(status))
            {
                sql += " AND Status = @Status";
            }

            sql += " ORDER BY UserId DESC";

            SqlParameter[] p = new SqlParameter[]
            {
                new SqlParameter("@Search", search),
                new SqlParameter("@Role", role),
                new SqlParameter("@Status", status)
            };

            DataTable dt = DbHelper.ExecuteDataTable(sql, p);
            rptUsers.DataSource = dt;
            rptUsers.DataBind();
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadUsers();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlRoleFilter.SelectedIndex = 0;
            ddlStatusFilter.SelectedIndex = 0;
            LoadUsers();
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int userId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ToggleVerify")
            {
                string sql = "UPDATE Users SET IsVerified = CASE WHEN IsVerified = 1 THEN 0 ELSE 1 END WHERE UserId = @Id";
                DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", userId));

                litAlertMsg.Text = "User verification status updated.";
                pnlAlert.Visible = true;
                LoadUsers();
            }
            else if (e.CommandName == "ToggleStatus")
            {
                string sql = "UPDATE Users SET Status = CASE WHEN Status = 'Active' THEN 'Inactive' ELSE 'Active' END WHERE UserId = @Id";
                DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", userId));

                litAlertMsg.Text = "User active status updated.";
                pnlAlert.Visible = true;
                LoadUsers();
            }
        }

        protected void btnCreateUser_Click(object sender, EventArgs e)
        {
            string fullName = txtNewFullName.Text.Trim();
            string email = txtNewEmail.Text.Trim();
            string password = txtNewPassword.Text.Trim();
            string role = ddlNewRole.SelectedValue;
            bool isVerified = ddlNewVerified.SelectedValue == "1";

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                return;
            }

            // Check if email exists
            string checkSql = "SELECT COUNT(1) FROM Users WHERE Email = @Email";
            int exists = Convert.ToInt32(DbHelper.ExecuteScalar(checkSql, new SqlParameter("@Email", email)));
            if (exists > 0)
            {
                litAlertMsg.Text = "Error: A user with this email address already exists.";
                pnlAlert.Visible = true;
                return;
            }

            string passHash = SecurityHelper.HashPassword(password);
            string insertSql = @"
                INSERT INTO Users (FullName, Email, PasswordHash, Role, IsVerified, Status, AvatarUrl)
                VALUES (@FullName, @Email, @Hash, @Role, @Verified, 'Active', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100')
            ";

            SqlParameter[] p = new SqlParameter[]
            {
                new SqlParameter("@FullName", fullName),
                new SqlParameter("@Email", email),
                new SqlParameter("@Hash", passHash),
                new SqlParameter("@Role", role),
                new SqlParameter("@Verified", isVerified)
            };

            DbHelper.ExecuteNonQuery(insertSql, p);

            litAlertMsg.Text = $"User <strong>{fullName}</strong> created successfully.";
            pnlAlert.Visible = true;

            txtNewFullName.Text = string.Empty;
            txtNewEmail.Text = string.Empty;

            LoadUsers();
        }
    }
}
