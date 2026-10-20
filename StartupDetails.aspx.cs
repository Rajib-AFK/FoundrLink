using System;
using System.Data;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class StartupDetails : Page
    {
        private int _startupId = 8; // Default EcoTrack (Id 8)
        private int _founderId = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            if (!string.IsNullOrEmpty(Request.QueryString["id"]) && int.TryParse(Request.QueryString["id"], out int sId))
            {
                _startupId = sId;
            }

            lnkTeamDetails.HRef = "TeamDetails.aspx?id=" + _startupId;

            if (!IsPostBack)
            {
                LoadStartupDetails();
            }
        }

        private void LoadStartupDetails()
        {
            try
            {
                string query = @"
                    SELECT s.StartupId, s.FounderId, s.Name, s.Tagline, s.Industry, s.Stage, s.LogoUrl,
                           s.ShortDescription, s.FullDescription, s.Problem, s.Solution, s.TeamSize,
                           s.Location, s.Commitment, s.FoundedYear,
                           u.FullName AS FounderName, u.Email AS FounderEmail
                    FROM dbo.Startups s
                    JOIN dbo.Users u ON s.FounderId = u.UserId
                    WHERE s.StartupId = @StartupId";

                DataTable dt = DbHelper.ExecuteDataTable(query, DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId));
                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    _founderId = Convert.ToInt32(r["FounderId"]);

                    litStartupName.Text = r["Name"]?.ToString();
                    litStageBadge.Text = r["Stage"]?.ToString();
                    litTagline.Text = r["Tagline"]?.ToString();
                    litIndustry.Text = r["Industry"]?.ToString();
                    litFounder.Text = r["FounderName"]?.ToString() + " (Founder)";

                    string logo = r["LogoUrl"]?.ToString();
                    if (!string.IsNullOrEmpty(logo))
                    {
                        imgLogo.ImageUrl = logo;
                    }

                    string fullDesc = r["FullDescription"]?.ToString();
                    litAbout.Text = !string.IsNullOrEmpty(fullDesc) ? fullDesc : r["ShortDescription"]?.ToString();

                    litProblem.Text = r["Problem"]?.ToString() ?? "Enterprises lack standardized, low-barrier sustainability auditing.";
                    litSolution.Text = r["Solution"]?.ToString() ?? "An automated API-driven compliance and carbon footprint auditing platform.";

                    litMetaIndustry.Text = r["Industry"]?.ToString();
                    litMetaStage.Text = r["Stage"]?.ToString();
                    litMetaFounded.Text = r["FoundedYear"]?.ToString() ?? "2023";
                    litMetaTeamSize.Text = r["TeamSize"]?.ToString() + " Members";
                    litMetaLocation.Text = r["Location"]?.ToString() ?? "Remote";
                    litMetaCommitment.Text = r["Commitment"]?.ToString() ?? "Part-time / Equity";

                    int? currentUserId = SecurityHelper.GetCurrentUserId();
                    if (currentUserId.HasValue && currentUserId.Value == _founderId)
                    {
                        btnRequestJoin.Visible = false;
                    }
                }
                else
                {
                    Response.Redirect("~/ExploreStartups.aspx");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("StartupDetails error: " + ex);
            }
        }

        protected void btnRequestJoin_Click(object sender, EventArgs e)
        {
            int? currentUserId = SecurityHelper.GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }
            int senderId = currentUserId.Value;

            if (senderId == _founderId)
            {
                pnlAlert.CssClass = "alert alert-warning py-2 small mb-3";
                pnlAlert.Visible = true;
                litAlertMessage.Text = "You are the founder of this startup.";
                return;
            }

            try
            {
                // Check for existing pending request
                string checkSql = "SELECT COUNT(1) FROM dbo.CollaborationRequests WHERE SenderUserId = @SenderId AND StartupId = @StartupId AND Status = 'Pending'";
                int existing = Convert.ToInt32(DbHelper.ExecuteScalar(checkSql,
                    DbHelper.CreateParam("@SenderId", SqlDbType.Int, senderId),
                    DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId)));

                if (existing > 0)
                {
                    pnlAlert.CssClass = "alert alert-info py-2 small mb-3";
                    pnlAlert.Visible = true;
                    litAlertMessage.Text = "You have already sent a request to join this startup.";
                    return;
                }

                string insertReq = @"
                    INSERT INTO dbo.CollaborationRequests (SenderUserId, ReceiverUserId, StartupId, Message, Status, CreatedAt)
                    VALUES (@SenderId, @ReceiverId, @StartupId, 'I am excited about this project and would love to join your founding team.', 'Pending', SYSUTCDATETIME());";

                DbHelper.ExecuteNonQuery(insertReq,
                    DbHelper.CreateParam("@SenderId", SqlDbType.Int, senderId),
                    DbHelper.CreateParam("@ReceiverId", SqlDbType.Int, _founderId),
                    DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId));

                pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                pnlAlert.Visible = true;
                litAlertMessage.Text = "Your collaboration request has been submitted to the founder!";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("StartupDetails btnRequestJoin error: " + ex);
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
                litAlertMessage.Text = "An error occurred while submitting your request. Please try again.";
            }
        }
    }
}
