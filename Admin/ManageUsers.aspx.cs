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
            if (!SecurityHelper.IsUserLoggedIn() || !SecurityHelper.IsUserAdmin())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            pnlAlert.Visible = false;

            if (!IsPostBack)
            {
                LoadUsers();
            }
        }

        private void LoadUsers()
        {
            try
            {
                string search = txtSearch.Text.Trim();
                string role = ddlRoleFilter.SelectedValue;
                string status = ddlStatusFilter.SelectedValue;

                string sql = "SELECT UserId, FullName, Email, Role, Title, Company, AvatarUrl, IsVerified, Status FROM dbo.Users WHERE 1=1";

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
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadUsers error: " + ex);
                litAlertMsg.Text = "An error occurred while loading users.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
        }

        protected void rptUsers_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var ddl = e.Item.FindControl("ddlRoleChange") as DropDownList;
                if (ddl != null)
                {
                    string role = DataBinder.Eval(e.Item.DataItem, "Role")?.ToString();
                    if (!string.IsNullOrEmpty(role) && ddl.Items.FindByValue(role) != null)
                    {
                        ddl.SelectedValue = role;
                    }
                }
            }
        }

        protected void ddlRoleChange_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserAdmin())
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            var ddl = sender as DropDownList;
            if (ddl == null) return;

            var item = ddl.NamingContainer as RepeaterItem;
            if (item == null) return;

            var hf = item.FindControl("hfRowUserId") as HiddenField;
            if (hf == null || !int.TryParse(hf.Value, out int userId)) return;

            string newRole = ddl.SelectedValue;

            try
            {
                string sql = "UPDATE dbo.Users SET Role = @Role WHERE UserId = @Id";
                DbHelper.ExecuteNonQuery(sql,
                    new SqlParameter("@Role", newRole),
                    new SqlParameter("@Id", userId));

                litAlertMsg.Text = $"User role updated to <strong>{Server.HtmlEncode(newRole)}</strong>.";
                pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                pnlAlert.Visible = true;
                LoadUsers();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("ddlRoleChange error: " + ex);
                litAlertMsg.Text = "An error occurred while updating the user role.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
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
            if (!SecurityHelper.IsUserAdmin())
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            int userId = Convert.ToInt32(e.CommandArgument);

            try
            {
                if (e.CommandName == "ToggleVerify")
                {
                    string sql = "UPDATE dbo.Users SET IsVerified = CASE WHEN IsVerified = 1 THEN 0 ELSE 1 END WHERE UserId = @Id";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", userId));

                    litAlertMsg.Text = "User verification status updated.";
                    pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    pnlAlert.Visible = true;
                    LoadUsers();
                }
                else if (e.CommandName == "ToggleStatus")
                {
                    string sql = "UPDATE dbo.Users SET Status = CASE WHEN Status = 'Active' THEN 'Inactive' ELSE 'Active' END WHERE UserId = @Id";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", userId));

                    litAlertMsg.Text = "User active status updated.";
                    pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    pnlAlert.Visible = true;
                    LoadUsers();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("rptUsers_ItemCommand error: " + ex);
                litAlertMsg.Text = "An error occurred while updating the user.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
        }

        protected void btnCreateUser_Click(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserAdmin())
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!Page.IsValid)
            {
                return;
            }

            string fullName = txtNewFullName.Text.Trim();
            string email = txtNewEmail.Text.Trim();
            string password = txtNewPassword.Text.Trim();
            string role = ddlNewRole.SelectedValue;
            bool isVerified = ddlNewVerified.SelectedValue == "1";

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password) || password.Length < 8)
            {
                litAlertMsg.Text = "Please enter valid information. Password must be at least 8 characters.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
                return;
            }

            try
            {
                // Check if email exists
                string checkSql = "SELECT COUNT(1) FROM dbo.Users WHERE Email = @Email";
                int exists = Convert.ToInt32(DbHelper.ExecuteScalar(checkSql, new SqlParameter("@Email", email)));
                if (exists > 0)
                {
                    litAlertMsg.Text = "A user with this email address already exists.";
                    pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                    pnlAlert.Visible = true;
                    return;
                }

                string passHash = SecurityHelper.HashPassword(password);
                string insertSql = @"
                    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, IsVerified, Status, AvatarUrl, CreatedAt)
                    VALUES (@FullName, @Email, @Hash, @Role, @Verified, 'Active', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100', SYSUTCDATETIME());
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

                litAlertMsg.Text = $"User <strong>{Server.HtmlEncode(fullName)}</strong> created successfully.";
                pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                pnlAlert.Visible = true;

                txtNewFullName.Text = string.Empty;
                txtNewEmail.Text = string.Empty;
                txtNewPassword.Text = "Password123";

                LoadUsers();
            }
            catch (SqlException ex) when (ex.Number == 2601 || ex.Number == 2627)
            {
                System.Diagnostics.Trace.TraceError("CreateUser duplicate key error: " + ex);
                litAlertMsg.Text = "A user with this email address already exists.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("CreateUser error: " + ex);
                litAlertMsg.Text = "An unexpected error occurred while creating the user.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
        }
    }
}
