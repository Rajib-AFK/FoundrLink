using System;
using System.Data;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class TeamDetails : Page
    {
        private int _startupId = 4; // Default NeuroSync (Id 4)
        private int _founderId = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(Request.QueryString["id"]) && int.TryParse(Request.QueryString["id"], out int sId))
            {
                _startupId = sId;
            }

            lnkManageTeam.HRef = "ManageStartup.aspx?id=" + _startupId;

            if (!IsPostBack)
            {
                LoadTeamDetails();
            }
        }

        private void LoadTeamDetails()
        {
            try
            {
                // 1. Startup header & about
                string startupQuery = @"
                    SELECT StartupId, FounderId, Name, Tagline, Industry, Stage, LogoUrl, 
                           ShortDescription, FullDescription, TeamSize, Location
                    FROM dbo.Startups 
                    WHERE StartupId = @StartupId";

                DataTable dtStartup = DbHelper.ExecuteDataTable(startupQuery, DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId));
                if (dtStartup.Rows.Count > 0)
                {
                    DataRow sr = dtStartup.Rows[0];
                    _founderId = Convert.ToInt32(sr["FounderId"]);
                    litStartupName.Text = sr["Name"]?.ToString();
                    litTagline.Text = sr["Tagline"]?.ToString();
                    litStage.Text = sr["Stage"]?.ToString();
                    litLocation.Text = sr["Location"]?.ToString();
                    litTeamSize.Text = sr["TeamSize"]?.ToString() + " Members";

                    string logo = sr["LogoUrl"]?.ToString();
                    if (!string.IsNullOrEmpty(logo))
                    {
                        imgLogo.ImageUrl = logo;
                    }

                    string fullDesc = sr["FullDescription"]?.ToString();
                    litAbout.Text = !string.IsNullOrEmpty(fullDesc) ? fullDesc : sr["ShortDescription"]?.ToString();

                    int? currentUserId = SecurityHelper.GetCurrentUserId();
                    if (currentUserId.HasValue && (currentUserId.Value == _founderId || SecurityHelper.IsUserAdmin()))
                    {
                        lnkManageTeam.HRef = "ManageStartup.aspx?id=" + _startupId;
                        lnkManageTeam.InnerHtml = "<i class=\"bi bi-gear me-1\"></i> Manage Team";
                    }
                    else
                    {
                        lnkManageTeam.HRef = "StartupDetails.aspx?id=" + _startupId;
                        lnkManageTeam.InnerHtml = "<i class=\"bi bi-info-circle me-1\"></i> Startup Overview";
                    }
                }

                // 2. Team Members
                string membersQuery = @"
                    SELECT TeamMemberId, UserId, Name, Role, AvatarUrl 
                    FROM dbo.TeamMembers 
                    WHERE StartupId = @StartupId 
                    ORDER BY TeamMemberId ASC";

                DataTable dtMembers = DbHelper.ExecuteDataTable(membersQuery, DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId));
                if (dtMembers.Rows.Count == 0)
                {
                    // Fallback to founder
                    membersQuery = "SELECT UserId, FullName AS Name, Title AS Role, AvatarUrl FROM dbo.Users WHERE UserId = @FounderId";
                    dtMembers = DbHelper.ExecuteDataTable(membersQuery, DbHelper.CreateParam("@FounderId", SqlDbType.Int, _founderId));
                }
                rptMembers.DataSource = dtMembers;
                rptMembers.DataBind();

                // 3. Open Roles
                string rolesQuery = @"
                    SELECT PositionId, Title, Location, PositionType 
                    FROM dbo.OpenPositions 
                    WHERE StartupId = @StartupId 
                    ORDER BY PositionId ASC";

                DataTable dtRoles = DbHelper.ExecuteDataTable(rolesQuery, DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId));
                litRoleCount.Text = dtRoles.Rows.Count.ToString();
                rptRoles.DataSource = dtRoles;
                rptRoles.DataBind();

                // 4. Startup Updates / Activity
                string updatesQuery = @"
                    SELECT UpdateId, AuthorName, Content, '2 hours ago' AS TimeAgo 
                    FROM dbo.StartupUpdates 
                    WHERE StartupId = @StartupId 
                    ORDER BY UpdateId DESC";

                DataTable dtUpdates = DbHelper.ExecuteDataTable(updatesQuery, DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId));
                if (dtUpdates.Rows.Count == 0)
                {
                    // Create default presentation updates
                    dtUpdates.Columns.Add("AuthorName");
                    dtUpdates.Columns.Add("Content");
                    dtUpdates.Columns.Add("TimeAgo");

                    dtUpdates.Rows.Add("Ananya Iyer published an update", "Beta version 1.4 deployed to early access partners. Seeing 15% reduction in latency.", "2 hours ago");
                    dtUpdates.Rows.Add("Sneha Joshi joined the team", "Joined as Senior Machine Learning Engineer.", "Yesterday");
                    dtUpdates.Rows.Add("Rohan Malhotra opened a new position", "Now hiring: Full Stack Developer (Remote).", "3 days ago");
                }
                rptUpdates.DataSource = dtUpdates;
                rptUpdates.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("TeamDetails error: " + ex.Message);
            }
        }

        protected void btnMessageTeam_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Messages.aspx?partnerId=" + _founderId);
        }
    }
}
