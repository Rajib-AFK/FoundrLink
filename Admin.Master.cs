using System;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class AdminMaster : MasterPage
    {
        protected void Page_Init(object sender, EventArgs e)
        {
            if (Session != null && !string.IsNullOrEmpty(Session.SessionID))
            {
                Page.ViewStateUserKey = Session.SessionID;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            string role = SecurityHelper.GetCurrentUserRole();
            if (!string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                // Non-admins can't access admin master pages
                Response.Redirect("~/Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string name = SecurityHelper.GetCurrentUserName();
                litAdminName.Text = name;
                litAdminTopName.Text = name;
                HighlightActiveNav();
            }
        }

        private void HighlightActiveNav()
        {
            string path = Request.AppRelativeCurrentExecutionFilePath.ToLowerInvariant();

            navAdminDash.Attributes["class"] = "fl-nav-link";
            navAdminUsers.Attributes["class"] = "fl-nav-link";
            navAdminStartups.Attributes["class"] = "fl-nav-link";
            navAdminReports.Attributes["class"] = "fl-nav-link";

            if (path.Contains("dashboard"))
                navAdminDash.Attributes["class"] = "fl-nav-link active";
            else if (path.Contains("manageusers"))
                navAdminUsers.Attributes["class"] = "fl-nav-link active";
            else if (path.Contains("managestartups"))
                navAdminStartups.Attributes["class"] = "fl-nav-link active";
            else if (path.Contains("reports"))
                navAdminReports.Attributes["class"] = "fl-nav-link active";
        }

        protected void btnAdminLogout_Click(object sender, EventArgs e)
        {
            SecurityHelper.Logout();
            Response.Redirect("~/Login.aspx");
        }
    }
}
