using System;
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

                var dt = _userService.GetAllUsersDataTable(search, role, status);
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

            if (!Page.IsValid)
            {
                return;
            }

            string fullName = txtNewFullName.Text.Trim();
            string email = txtNewEmail.Text.Trim();
            string password = txtNewPassword.Text.Trim();
            string role = ddlNewRole.SelectedValue;
            bool isVerified = ddlNewVerified.SelectedValue == "1";

            var result = _userService.CreateUserByAdmin(fullName, email, password, role, isVerified);

            if (result.Success)
            {
                litAlertMsg.Text = result.Message;
                pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                pnlAlert.Visible = true;

                txtNewFullName.Text = string.Empty;
                txtNewEmail.Text = string.Empty;
                txtNewPassword.Text = "Password123";

                LoadUsers();
            }
            else
            {
                litAlertMsg.Text = Server.HtmlEncode(result.Message);
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
        }
    }
}
