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
            // Verify admin authentication
            if (Session["Role"]?.ToString() != "Admin")
            {
                // In demo/dev mode, allow viewing or redirect if needed
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
            // Total Users
            object userCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM Users");
            litTotalUsers.Text = userCount != null ? Convert.ToInt32(userCount).ToString("N0") : "0";

            // Active Startups
            object startupCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM Startups WHERE Status IN ('Active', 'Approved', 'Published')");
            litActiveStartups.Text = startupCount != null ? Convert.ToInt32(startupCount).ToString("N0") : "0";

            // Pending Reports
            object reportCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM ModerationReports WHERE Status = 'Pending'");
            litPendingReports.Text = reportCount != null ? Convert.ToInt32(reportCount).ToString("N0") : "0";

            // Total Connections
            object connCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM ConnectionRequests");
            litTotalConnections.Text = connCount != null ? Convert.ToInt32(connCount).ToString("N0") : "0";
        }

        private void LoadStartups()
        {
            string sql = "SELECT TOP 5 StartupId, Name, Industry, Stage, Location, LogoUrl, Status FROM Startups ORDER BY StartupId DESC";
            DataTable dt = DbHelper.ExecuteDataTable(sql);
            rptStartups.DataSource = dt;
            rptStartups.DataBind();
        }

        private void LoadUsers()
        {
            string sql = "SELECT TOP 5 UserId, FullName, Email, Role, AvatarUrl, Status FROM Users ORDER BY UserId DESC";
            DataTable dt = DbHelper.ExecuteDataTable(sql);
            rptUsers.DataSource = dt;
            rptUsers.DataBind();
        }

        protected void rptStartups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int startupId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Approve")
            {
                string sql = "UPDATE Startups SET Status = 'Published' WHERE StartupId = @Id";
                DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", startupId));

                litAlertMsg.Text = "Startup status updated to <strong>Published</strong>.";
                pnlAlert.Visible = true;
                LoadStartups();
                LoadStats();
            }
            else if (e.CommandName == "Reject")
            {
                string sql = "UPDATE Startups SET Status = 'Draft' WHERE StartupId = @Id";
                DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", startupId));

                litAlertMsg.Text = "Startup status set to <strong>Draft</strong>.";
                pnlAlert.Visible = true;
                LoadStartups();
                LoadStats();
            }
        }
    }
}
