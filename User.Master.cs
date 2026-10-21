using System;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class UserMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn())
            {
                // If not logged in, redirect to Login
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            if (!IsPostBack)
            {
                LoadUserData();
                HighlightActiveNav();
            }
        }

        private void LoadUserData()
        {
            string name = SecurityHelper.GetCurrentUserName();
            string role = SecurityHelper.GetCurrentUserRole();
            string avatar = SecurityHelper.GetCurrentUserAvatar();

            litSidebarUserName.Text = name;
            litSidebarUserRole.Text = role;
            litTopbarUserName.Text = name;
            litTopbarRole.Text = role == "Founder" ? "Entrepreneur" : role;

            if (!string.IsNullOrEmpty(avatar))
            {
                imgSidebarAvatar.ImageUrl = avatar;
                imgTopbarAvatar.ImageUrl = avatar;
            }
            else
            {
                imgSidebarAvatar.ImageUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80";
                imgTopbarAvatar.ImageUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80";
            }

            // Check unread count
            int? userId = SecurityHelper.GetCurrentUserId();
            if (userId.HasValue)
            {
                try
                {
                    object notifCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM Notifications WHERE UserId = @u AND IsRead = 0",
                        DbHelper.CreateParam("@u", System.Data.SqlDbType.Int, userId.Value));
                    if (notifCount != null && Convert.ToInt32(notifCount) > 0)
                    {
                        pnlUnreadNotif.Visible = true;
                    }

                    object msgCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM Messages WHERE ReceiverId = @u AND IsRead = 0",
                        DbHelper.CreateParam("@u", System.Data.SqlDbType.Int, userId.Value));
                    if (msgCount != null && Convert.ToInt32(msgCount) > 0)
                    {
                        pnlUnreadMsg.Visible = true;
                    }
                }
                catch
                {
                    // DB might not be initialized yet
                }
            }
        }

        private void HighlightActiveNav()
        {
            string path = Request.AppRelativeCurrentExecutionFilePath.ToLowerInvariant();

            navDashboard.Attributes["class"] = "fl-nav-link";
            navDiscover.Attributes["class"] = "fl-nav-link";
            navFounders.Attributes["class"] = "fl-nav-link";
            navStartups.Attributes["class"] = "fl-nav-link";
            navSettings.Attributes["class"] = "fl-nav-link";
            navSupport.Attributes["class"] = "fl-nav-link";

            if (path.Contains("dashboard"))
                navDashboard.Attributes["class"] = "fl-nav-link active";
            else if (path.Contains("explorestartups") || path.Contains("startupdetails"))
                navDiscover.Attributes["class"] = "fl-nav-link active";
            else if (path.Contains("findcofounders") || path.Contains("profile"))
                navFounders.Attributes["class"] = "fl-nav-link active";
            else if (path.Contains("managestartup") || path.Contains("teamdetails"))
                navStartups.Attributes["class"] = "fl-nav-link active";
            else if (path.Contains("settings"))
                navSettings.Attributes["class"] = "fl-nav-link active";
            else if (path.Contains("support"))
                navSupport.Attributes["class"] = "fl-nav-link active";
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(txtSearch.Text))
            {
                Response.Redirect("~/ExploreStartups.aspx?q=" + Server.UrlEncode(txtSearch.Text.Trim()));
            }
        }

        protected void btnSidebarLogout_Click(object sender, EventArgs e)
        {
            SecurityHelper.Logout();
            Response.Redirect("~/Login.aspx");
        }
    }
}
