using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;
using FoundrLink.Services;
using FoundrLink.Services.Interfaces;

namespace FoundrLink.Admin
{
    public partial class ManageUsers : Page
    {
        private readonly IUserService _userService;

        public ManageUsers()
        {
            _userService = new UserService();
        }

        public ManageUsers(IUserService userService)
        {
            _userService = userService ?? new UserService();
        }

        private int PageIndex
        {
            get { return ViewState["UserPageIndex"] != null ? (int)ViewState["UserPageIndex"] : 0; }
            set { ViewState["UserPageIndex"] = value; }
        }

        private const int PageSize = 10;

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

                string countSql = "SELECT COUNT(1) FROM dbo.Users WHERE 1=1";
                string sql = "SELECT UserId, FullName, Email, Role, Title, Company, AvatarUrl, IsVerified, Status, CreatedAt FROM dbo.Users WHERE 1=1";

                string filterSql = "";
                if (!string.IsNullOrEmpty(search))
                {
                    filterSql += " AND (FullName LIKE '%' + @Search + '%' OR Email LIKE '%' + @Search + '%' OR Company LIKE '%' + @Search + '%')";
                }

                if (!string.IsNullOrEmpty(role))
                {
                    filterSql += " AND Role = @Role";
                }

                if (!string.IsNullOrEmpty(status))
                {
                    filterSql += " AND Status = @Status";
                }

                countSql += filterSql;
                sql += filterSql + " ORDER BY UserId DESC OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                int offset = PageIndex * PageSize;

                SqlParameter[] countParams = new SqlParameter[]
                {
                    new SqlParameter("@Search", search),
                    new SqlParameter("@Role", role),
                    new SqlParameter("@Status", status)
                };

                int totalCount = Convert.ToInt32(DbHelper.ExecuteScalar(countSql, countParams));

                SqlParameter[] p = new SqlParameter[]
                {
                    new SqlParameter("@Search", search),
                    new SqlParameter("@Role", role),
                    new SqlParameter("@Status", status),
                    new SqlParameter("@Offset", offset),
                    new SqlParameter("@PageSize", PageSize)
                };

                DataTable dt = DbHelper.ExecuteDataTable(sql, p);
                rptUsers.DataSource = dt;
                rptUsers.DataBind();

                pnlNoUsers.Visible = (totalCount == 0);
                rptUsers.Visible = (totalCount > 0);

                int startEntry = totalCount == 0 ? 0 : offset + 1;
                int endEntry = Math.Min(offset + PageSize, totalCount);
                litPaginationInfo.Text = $"Showing {startEntry} to {endEntry} of {totalCount} entries";

                btnPrevPage.Enabled = (PageIndex > 0);
                btnPrevPage.CssClass = PageIndex > 0 ? "fl-page-btn-dark" : "fl-page-btn-dark text-muted opacity-50";

                int maxPage = (int)Math.Ceiling((double)totalCount / PageSize) - 1;
                if (maxPage < 0) maxPage = 0;
                btnNextPage.Enabled = (PageIndex < maxPage);
                btnNextPage.CssClass = PageIndex < maxPage ? "fl-page-btn-dark" : "fl-page-btn-dark text-muted opacity-50";
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
            if (!SecurityHelper.IsUserLoggedIn() || !SecurityHelper.IsUserAdmin())
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
            int currentAdminId = SecurityHelper.GetCurrentUserId().Value;

            if (userId == currentAdminId && newRole != "Admin")
            {
                litAlertMsg.Text = "You cannot remove the administrator role from your own active session.";
                pnlAlert.CssClass = "alert alert-warning py-2 small mb-3";
                pnlAlert.Visible = true;
                LoadUsers();
                return;
            }

            try
            {
                var result = _userService.UpdateUserRole(userId, newRole);
                if (result.Success)
                {
                    litAlertMsg.Text = $"User role updated to <strong>{Server.HtmlEncode(newRole)}</strong>.";
                    pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                }
                else
                {
                    litAlertMsg.Text = Server.HtmlEncode(result.Message);
                    pnlAlert.CssClass = "alert alert-warning py-2 small mb-3";
                }

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
            PageIndex = 0;
            LoadUsers();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            PageIndex = 0;
            txtSearch.Text = string.Empty;
            ddlRoleFilter.SelectedIndex = 0;
            ddlStatusFilter.SelectedIndex = 0;
            LoadUsers();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (PageIndex > 0)
            {
                PageIndex--;
                LoadUsers();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            PageIndex++;
            LoadUsers();
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn() || !SecurityHelper.IsUserAdmin())
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            int userId = Convert.ToInt32(e.CommandArgument);
            int currentAdminId = SecurityHelper.GetCurrentUserId().Value;

            try
            {
                if (e.CommandName == "ToggleVerify")
                {
                    var result = _userService.ToggleVerification(userId);
                    if (result.Success)
                    {
                        litAlertMsg.Text = "User verification status updated.";
                        pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    }
                    else
                    {
                        litAlertMsg.Text = Server.HtmlEncode(result.Message);
                        pnlAlert.CssClass = "alert alert-warning py-2 small mb-3";
                    }
                    pnlAlert.Visible = true;
                    LoadUsers();
                }
                else if (e.CommandName == "ToggleStatus")
                {
                    if (userId == currentAdminId)
                    {
                        litAlertMsg.Text = "You cannot deactivate your own active administrator account.";
                        pnlAlert.CssClass = "alert alert-warning py-2 small mb-3";
                        pnlAlert.Visible = true;
                        return;
                    }

                    var result = _userService.ToggleStatus(userId);
                    if (result.Success)
                    {
                        litAlertMsg.Text = "User active status updated.";
                        pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    }
                    else
                    {
                        litAlertMsg.Text = Server.HtmlEncode(result.Message);
                        pnlAlert.CssClass = "alert alert-warning py-2 small mb-3";
                    }
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

            if (!Page.IsValid) return;

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
                var result = _userService.CreateUserByAdmin(fullName, email, password, role, isVerified);
                if (result.Success)
                {
                    litAlertMsg.Text = result.Message;
                    pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    pnlAlert.Visible = true;

                    // Clear fields
                    txtNewFullName.Text = "";
                    txtNewEmail.Text = "";
                    txtNewPassword.Text = "Password123";
                    ddlNewRole.SelectedIndex = 0;

                    PageIndex = 0;
                    LoadUsers();
                }
                else
                {
                    litAlertMsg.Text = result.Message;
                    pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                    pnlAlert.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("btnCreateUser_Click error: " + ex);
                litAlertMsg.Text = "An unexpected error occurred while creating the user.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
        }

        public string GetAvatarUrl(object avatarUrlObj, object nameObj)
        {
            string url = avatarUrlObj?.ToString();
            if (!string.IsNullOrEmpty(url)) return ResolveUrl(url);

            string name = nameObj?.ToString() ?? "User";
            return $"https://ui-avatars.com/api/?name={Server.UrlEncode(name)}&background=0F172A&color=fff";
        }
    }
}
