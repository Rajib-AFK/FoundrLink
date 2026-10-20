using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class Dashboard : Page
    {
        public int CompletionPercentage = 85;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            if (!IsPostBack)
            {
                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            int? currentUserId = SecurityHelper.GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }
            int userId = currentUserId.Value;

            try
            {
                // 1. User details & profile
                string userQuery = @"
                    SELECT u.FullName, u.AvatarUrl, u.Title, p.ProfileCompletionPercentage
                    FROM dbo.Users u
                    LEFT JOIN dbo.FounderProfiles p ON u.UserId = p.UserId
                    WHERE u.UserId = @UserId";

                DataTable dtUser = DbHelper.ExecuteDataTable(userQuery, DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                if (dtUser.Rows.Count > 0)
                {
                    DataRow r = dtUser.Rows[0];
                    string name = r["FullName"]?.ToString() ?? "Founder";
                    litUserName.Text = name.Split(' ')[0]; // First name
                    litUserHeadline.Text = r["Title"]?.ToString() ?? "Technical Co-founder searching for seed funding.";
                    string avatar = r["AvatarUrl"]?.ToString();
                    if (!string.IsNullOrEmpty(avatar))
                    {
                        imgHeroAvatar.ImageUrl = avatar;
                    }

                    if (r["ProfileCompletionPercentage"] != DBNull.Value)
                    {
                        CompletionPercentage = Convert.ToInt32(r["ProfileCompletionPercentage"]);
                        litCompletionPct.Text = CompletionPercentage + "%";
                    }
                }

                // 2. Metric Counters
                object viewsObj = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.Users WHERE Role != 'Admin'");
                litProfileViews.Text = (viewsObj != null) ? (Convert.ToInt32(viewsObj) * 64).ToString() : "894";

                object msgObj = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.Messages WHERE ReceiverId = @UserId",
                    DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                litActiveMessages.Text = (msgObj != null && Convert.ToInt32(msgObj) > 0) ? msgObj.ToString() : "0";

                object teamObj = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.TeamMembers WHERE UserId = @UserId",
                    DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                litTeamsJoined.Text = (teamObj != null && Convert.ToInt32(teamObj) > 0) ? teamObj.ToString() : "0";

                // 3. Chart Data from ConnectionGrowth
                string growthQuery = @"
                    SELECT MonthLabel, CountValue 
                    FROM dbo.ConnectionGrowth 
                    WHERE UserId = @UserId 
                    ORDER BY MonthOrder ASC";

                DataTable dtGrowth = DbHelper.ExecuteDataTable(growthQuery, DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                if (dtGrowth.Rows.Count > 0)
                {
                    var labels = new List<string>();
                    var values = new List<string>();
                    foreach (DataRow row in dtGrowth.Rows)
                    {
                        labels.Add("'" + row["MonthLabel"].ToString() + "'");
                        values.Add(row["CountValue"].ToString());
                    }
                    hfChartLabels.Value = "[" + string.Join(",", labels) + "]";
                    hfChartData.Value = "[" + string.Join(",", values) + "]";
                }

                // 4. Recent Activity
                string activityQuery = @"
                    SELECT TOP 3 ActivityText, ActivityType, TimeAgo 
                    FROM dbo.ActivityLogs 
                    WHERE UserId = @UserId 
                    ORDER BY ActivityId DESC";

                DataTable dtActivity = DbHelper.ExecuteDataTable(activityQuery, DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                if (dtActivity.Rows.Count > 0)
                {
                    rptActivities.DataSource = dtActivity;
                    rptActivities.DataBind();
                }

                // 5. Deadlines
                string deadlineQuery = @"
                    SELECT TOP 2 Title, Description, MonthText, DayText 
                    FROM dbo.Deadlines 
                    WHERE UserId = @UserId 
                    ORDER BY DeadlineDate ASC";

                DataTable dtDeadlines = DbHelper.ExecuteDataTable(deadlineQuery, DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                if (dtDeadlines.Rows.Count > 0)
                {
                    rptDeadlines.DataSource = dtDeadlines;
                    rptDeadlines.DataBind();
                }

                // 6. Suggested Connections
                string suggestedQuery = @"
                    SELECT TOP 3 UserId, FullName, Role, AvatarUrl 
                    FROM dbo.Users 
                    WHERE UserId != @UserId AND Role != 'Admin' AND Status = 'Active'
                    ORDER BY UserId DESC";

                DataTable dtSuggested = DbHelper.ExecuteDataTable(suggestedQuery, DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                rptSuggested.DataSource = dtSuggested;
                rptSuggested.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Dashboard error: " + ex);
            }
        }

        protected void rptSuggested_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Connect")
            {
                int targetUserId = Convert.ToInt32(e.CommandArgument);
                int? currentUserId = SecurityHelper.GetCurrentUserId();
                if (!currentUserId.HasValue)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }
                int senderId = currentUserId.Value;

                if (senderId == targetUserId) return;

                try
                {
                    string insertReq = @"
                        IF NOT EXISTS (SELECT 1 FROM dbo.ConnectionRequests WHERE SenderId = @SenderId AND ReceiverId = @ReceiverId)
                        BEGIN
                            INSERT INTO dbo.ConnectionRequests (SenderId, ReceiverId, Note, Status, CreatedAt)
                            VALUES (@SenderId, @ReceiverId, 'Hi, I would love to connect with you on FoundrLink!', 'Pending', SYSUTCDATETIME());
                        END";

                    DbHelper.ExecuteNonQuery(insertReq,
                        DbHelper.CreateParam("@SenderId", SqlDbType.Int, senderId),
                        DbHelper.CreateParam("@ReceiverId", SqlDbType.Int, targetUserId));

                    // Refresh
                    LoadDashboardData();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("Connection request error: " + ex);
                }
            }
        }

        protected string GetActivityIcon(object type)
        {
            string t = type?.ToString() ?? "";
            switch (t.ToLowerInvariant())
            {
                case "like": return "bi bi-hand-thumbs-up-fill";
                case "join": return "bi bi-person-check-fill";
                case "message": return "bi bi-chat-left-text-fill";
                default: return "bi bi-bell-fill";
            }
        }

        protected string GetActivityIconClass(object type)
        {
            string t = type?.ToString() ?? "";
            switch (t.ToLowerInvariant())
            {
                case "like": return "fl-stat-icon-wrapper bg-dark text-white";
                case "join": return "fl-stat-icon-wrapper bg-teal-subtle text-teal";
                case "message": return "fl-stat-icon-wrapper bg-light text-dark border";
                default: return "fl-stat-icon-wrapper bg-light text-muted border";
            }
        }
    }
}
