using System;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class SiteMaster : MasterPage
    {
        public string ViewStateUserKey
        {
            get => Page?.ViewStateUserKey;
            set { if (Page != null) Page.ViewStateUserKey = value; }
        }

        protected void Page_Init(object sender, EventArgs e)
        {
            if (Context.User?.Identity?.IsAuthenticated == true || SecurityHelper.IsUserLoggedIn())
            {
                ViewStateUserKey = Session.SessionID;
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
