using System;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class SiteMaster : MasterPage
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
            if (!IsPostBack)
            {
                bool loggedIn = SecurityHelper.IsUserLoggedIn();
                phAnonymous.Visible = !loggedIn;
                phLoggedIn.Visible = loggedIn;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SecurityHelper.Logout();
            Response.Redirect("~/Login.aspx");
        }
    }
}
