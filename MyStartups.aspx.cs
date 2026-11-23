using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class MyStartups : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            pnlAlert.Visible = false;

            if (!IsPostBack)
            {
                LoadMyStartups();
            }
        }

        private void LoadMyStartups()
        {
            int? currentUserId = SecurityHelper.GetCurrentUserId();
            if (!currentUserId.HasValue) return;

            int founderId = currentUserId.Value;

            try
            {
                // 1. Load Summary Metrics
                object countObj = DbHelper.ExecuteScalar(
                    "SELECT COUNT(1) FROM dbo.Startups WHERE FounderId = @FounderId",
                    DbHelper.CreateParam("@FounderId", SqlDbType.Int, founderId));
                int totalVentures = countObj != null && countObj != DBNull.Value ? Convert.ToInt32(countObj) : 0;
                litTotalVentures.Text = totalVentures.ToString();

                object teamObj = DbHelper.ExecuteScalar(@"
                    SELECT COUNT(1) 
                    FROM dbo.TeamMembers tm
                    INNER JOIN dbo.Startups s ON tm.StartupId = s.StartupId
                    WHERE s.FounderId = @FounderId",
                    DbHelper.CreateParam("@FounderId", SqlDbType.Int, founderId));
                int totalTeam = teamObj != null && teamObj != DBNull.Value ? Convert.ToInt32(teamObj) : 0;
                litTotalTeamMembers.Text = totalTeam.ToString();

                object reqObj = DbHelper.ExecuteScalar(
                    "SELECT COUNT(1) FROM dbo.CollaborationRequests WHERE ReceiverUserId = @UserId AND Status = 'Pending'",
                    DbHelper.CreateParam("@UserId", SqlDbType.Int, founderId));
                int pendingReqs = reqObj != null && reqObj != DBNull.Value ? Convert.ToInt32(reqObj) : 0;
                litPendingRequests.Text = pendingReqs.ToString();

                // 2. Query Startups with Subquery Counts
                string sql = @"
                    SELECT s.StartupId, s.Name, s.Tagline, s.Industry, s.Stage, s.LogoUrl, s.Location, s.Status,
                           s.FoundedYear, s.FundingGoal, s.FundingRaised, s.MRR,
                           (SELECT COUNT(1) FROM dbo.TeamMembers WHERE StartupId = s.StartupId) AS TeamCount,
                           (SELECT COUNT(1) FROM dbo.OpenPositions WHERE StartupId = s.StartupId) AS OpenPositionsCount,
                           (SELECT COUNT(1) FROM dbo.CollaborationRequests WHERE StartupId = s.StartupId AND Status = 'Pending') AS PendingRequestCount
                    FROM dbo.Startups s
                    WHERE s.FounderId = @FounderId
                    ORDER BY s.StartupId DESC";

                DataTable dt = DbHelper.ExecuteDataTable(sql, DbHelper.CreateParam("@FounderId", SqlDbType.Int, founderId));

                if (dt.Rows.Count > 0)
                {
                    rptStartups.Visible = true;
                    pnlEmpty.Visible = false;
                    rptStartups.DataSource = dt;
                    rptStartups.DataBind();
                }
                else
                {
                    rptStartups.Visible = false;
                    pnlEmpty.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadMyStartups error: " + ex);
                ShowAlert("An error occurred while loading your startups. Please try again.", "danger");
            }
        }

        protected void rptStartups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int? currentUserId = SecurityHelper.GetCurrentUserId();
            if (!currentUserId.HasValue) return;

            int founderId = currentUserId.Value;
            int startupId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteStartup")
            {
                try
                {
                    bool isAdmin = SecurityHelper.IsUserAdmin();

                    DbHelper.ExecuteInTransaction((conn, trans) =>
                    {
                        using (var cmd = conn.CreateCommand())
                        {
                            cmd.Transaction = trans;
                            cmd.CommandText = @"
                                DELETE FROM dbo.CollaborationRequests WHERE StartupId = @Id;
                                DELETE FROM dbo.ConnectionRequests WHERE StartupId = @Id;
                                DELETE FROM dbo.TeamMembers WHERE StartupId = @Id;
                                DELETE FROM dbo.StartupMembers WHERE StartupId = @Id;
                                DELETE FROM dbo.OpenPositions WHERE StartupId = @Id;
                                DELETE FROM dbo.StartupOpenRoles WHERE StartupId = @Id;
                                DELETE FROM dbo.StartupUpdates WHERE StartupId = @Id;
                                DELETE FROM dbo.Startups WHERE StartupId = @Id AND (FounderId = @FounderId OR @IsAdmin = 1);";

                            cmd.Parameters.Add(new SqlParameter("@Id", SqlDbType.Int) { Value = startupId });
                            cmd.Parameters.Add(new SqlParameter("@FounderId", SqlDbType.Int) { Value = founderId });
                            cmd.Parameters.Add(new SqlParameter("@IsAdmin", SqlDbType.Bit) { Value = isAdmin ? 1 : 0 });

                            int rows = cmd.ExecuteNonQuery();
                            if (rows == 0)
                            {
                                throw new UnauthorizedAccessException("You do not have permission to delete this startup.");
                            }
                        }
                    });

                    ShowAlert("Startup and all associated team & position records were successfully deleted.", "success");
                    LoadMyStartups();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("MyStartups Delete error: " + ex);
                    ShowAlert("Unable to delete startup: " + ex.Message, "danger");
                }
            }
        }

        protected string FormatCurrency(object value)
        {
            if (value == null || value == DBNull.Value) return "₹0";
            if (decimal.TryParse(value.ToString(), out decimal amount))
            {
                if (amount >= 10000000)
                    return "₹" + (amount / 10000000).ToString("0.#") + " Cr";
                if (amount >= 100000)
                    return "₹" + (amount / 100000).ToString("0.#") + " L";
                return "₹" + amount.ToString("N0");
            }
            return "₹0";
        }

        private void ShowAlert(string msg, string type)
        {
            litAlertMessage.Text = msg;
            pnlAlert.CssClass = $"alert alert-{type} alert-dismissible fade show mb-4";
            pnlAlert.Visible = true;
        }
    }
}
