using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;

namespace FoundrLink.Admin
{
    public partial class Dashboard : Page
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
                LoadStats();
                LoadStartups();
                LoadUsers();
            }
        }

        private void LoadStats()
        {
            try
            {
                // Total Users
                object userCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.Users");
                litTotalUsers.Text = userCount != null ? Convert.ToInt32(userCount).ToString("N0") : "0";

                // Active Startups
                object startupCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.Startups WHERE Status IN ('Published', 'Active', 'Approved')");
                litActiveStartups.Text = startupCount != null ? Convert.ToInt32(startupCount).ToString("N0") : "0";

                // Pending Reports
                object reportCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.ModerationReports WHERE Status = 'Pending'");
                litPendingReports.Text = reportCount != null ? Convert.ToInt32(reportCount).ToString("N0") : "0";

                // Total Connections
                object connCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.ConnectionRequests");
                litTotalConnections.Text = connCount != null ? Convert.ToInt32(connCount).ToString("N0") : "0";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Admin LoadStats error: " + ex);
            }
        }

        private void LoadStartups()
        {
            try
            {
                string sql = "SELECT TOP 5 StartupId, Name, Industry, Stage, Location, LogoUrl, Status FROM dbo.Startups ORDER BY StartupId DESC";
                DataTable dt = DbHelper.ExecuteDataTable(sql);
                rptStartups.DataSource = dt;
                rptStartups.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Admin LoadStartups error: " + ex);
            }
        }

        private void LoadUsers()
        {
            try
            {
                string sql = "SELECT TOP 5 UserId, FullName, Email, Role, AvatarUrl, Status FROM dbo.Users ORDER BY UserId DESC";
                DataTable dt = DbHelper.ExecuteDataTable(sql);
                rptUsers.DataSource = dt;
                rptUsers.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Admin LoadUsers error: " + ex);
            }
        }

        protected void rptStartups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!SecurityHelper.IsUserAdmin())
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            int startupId = Convert.ToInt32(e.CommandArgument);

            try
            {
                if (e.CommandName == "Approve")
                {
                    string sql = "UPDATE dbo.Startups SET Status = 'Published' WHERE StartupId = @Id";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", startupId));

                    litAlertMsg.Text = "Startup status updated to <strong>Published</strong>.";
                    pnlAlert.CssClass = "alert alert-success alert-dismissible fade show rounded-3 shadow-sm border-0";
                    pnlAlert.Visible = true;
                    LoadStartups();
                    LoadStats();
                }
                else if (e.CommandName == "Reject")
                {
                    string sql = "UPDATE dbo.Startups SET Status = 'Draft' WHERE StartupId = @Id";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", startupId));

                    litAlertMsg.Text = "Startup status set to <strong>Draft</strong>.";
                    pnlAlert.CssClass = "alert alert-success alert-dismissible fade show rounded-3 shadow-sm border-0";
                    pnlAlert.Visible = true;
                    LoadStartups();
                    LoadStats();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Admin rptStartups_ItemCommand error: " + ex);
                litAlertMsg.Text = "An error occurred while updating startup status.";
                pnlAlert.CssClass = "alert alert-danger alert-dismissible fade show rounded-3 shadow-sm border-0";
                pnlAlert.Visible = true;
            }
        }
    }
}
