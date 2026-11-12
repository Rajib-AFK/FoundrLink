using System;
using System.Web;
using System.Web.UI;

namespace FoundrLink
{
    public class Global : HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            // Unobtrusive validation fallback
            ValidationSettings.UnobtrusiveValidationMode = UnobtrusiveValidationMode.None;

            // Application State Management (CE545 Unit 8)
            Application["PlatformName"] = "FoundrLink";
            Application["SystemStatus"] = "Optimal";
            Application["ActiveSessionCount"] = 0;
            Application["PlatformStartTime"] = DateTime.UtcNow;
        }

        protected void Session_Start(object sender, EventArgs e)
        {
            Application.Lock();
            int current = Convert.ToInt32(Application["ActiveSessionCount"] ?? 0);
            Application["ActiveSessionCount"] = current + 1;
            Application.UnLock();
        }

        protected void Session_End(object sender, EventArgs e)
        {
            Application.Lock();
            int current = Convert.ToInt32(Application["ActiveSessionCount"] ?? 1);
            Application["ActiveSessionCount"] = Math.Max(0, current - 1);
            Application.UnLock();
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            Exception ex = Server.GetLastError();
            if (ex != null)
            {
                System.Diagnostics.Debug.WriteLine("Application error: " + ex.Message);
            }
        }
    }
}
