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
                    if (currentUserId.HasValue)
                    {
                        if (currentUserId.Value == _founderId)
                        {
                            btnRequestJoin.Visible = false;
                            btnWithdrawJoin.Visible = false;
                            pnlTeamMemberBadge.Visible = false;
                        }
                        else
                        {
                            // Check if already an accepted team member
                            string memSql = "SELECT COUNT(1) FROM dbo.TeamMembers WHERE StartupId = @StartupId AND UserId = @UserId";
                            int isMember = Convert.ToInt32(DbHelper.ExecuteScalar(memSql,
                                DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId),
                                DbHelper.CreateParam("@UserId", SqlDbType.Int, currentUserId.Value)));

                            if (isMember > 0)
                            {
                                btnRequestJoin.Visible = false;
                                btnWithdrawJoin.Visible = false;
                                pnlTeamMemberBadge.Visible = true;
                            }
                            else
                            {
                                pnlTeamMemberBadge.Visible = false;
                                // Check if pending request exists
                                string reqSql = "SELECT RequestId FROM dbo.CollaborationRequests WHERE SenderUserId = @SenderId AND StartupId = @StartupId AND Status = 'Pending'";
                                object reqObj = DbHelper.ExecuteScalar(reqSql,
                                    DbHelper.CreateParam("@SenderId", SqlDbType.Int, currentUserId.Value),
                                    DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId));

                                if (reqObj != null && reqObj != DBNull.Value)
                                {
                                    btnRequestJoin.Visible = true;
                                    btnRequestJoin.Text = "Request Pending";
                                    btnRequestJoin.Enabled = false;
                                    btnRequestJoin.CssClass = "btn btn-secondary px-4";
                                    btnWithdrawJoin.Visible = true;
                                }
                                else
                                {
                                    btnRequestJoin.Visible = true;
                                    btnRequestJoin.Text = "Request to Join";
                                    btnRequestJoin.Enabled = true;
                                    btnRequestJoin.CssClass = "btn-fl-primary px-4";
                                    btnWithdrawJoin.Visible = false;
                                }
                            }
                        }
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
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
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
                    litAlertMessage.Text = "You already have a pending request to join this startup.";
                    LoadStartupDetails();
                    return;
                }

                string senderName = SecurityHelper.GetCurrentUserName();
                string startupName = litStartupName.Text;

                string insertReq = @"
                    INSERT INTO dbo.CollaborationRequests (SenderUserId, ReceiverUserId, StartupId, Message, Status, CreatedAt)
                    VALUES (@SenderId, @ReceiverId, @StartupId, 'I am excited about this project and would love to join your founding team.', 'Pending', SYSUTCDATETIME());

                    INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, IsRead, CreatedAt)
                    VALUES (@ReceiverId, 'New Collaboration Request', @SenderName + ' requested to collaborate on ' + @StartupName, 'Requests', 1, 0, SYSUTCDATETIME());";

                DbHelper.ExecuteNonQuery(insertReq,
                    DbHelper.CreateParam("@SenderId", SqlDbType.Int, senderId),
                    DbHelper.CreateParam("@ReceiverId", SqlDbType.Int, _founderId),
                    DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId),
                    DbHelper.CreateParam("@SenderName", SqlDbType.NVarChar, senderName),
                    DbHelper.CreateParam("@StartupName", SqlDbType.NVarChar, startupName));

                pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                pnlAlert.Visible = true;
                litAlertMessage.Text = "Your collaboration request has been submitted to the founder!";
                LoadStartupDetails();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("StartupDetails btnRequestJoin error: " + ex);
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
                litAlertMessage.Text = "An error occurred while submitting your request. Please try again.";
            }
        }

        protected void btnWithdrawJoin_Click(object sender, EventArgs e)
        {
            int? currentUserId = SecurityHelper.GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            try
            {
                string withdrawSql = @"
                    UPDATE dbo.CollaborationRequests 
                    SET Status = 'Withdrawn' 
                    WHERE SenderUserId = @SenderId AND StartupId = @StartupId AND Status = 'Pending'";

                int rows = DbHelper.ExecuteNonQuery(withdrawSql,
                    DbHelper.CreateParam("@SenderId", SqlDbType.Int, currentUserId.Value),
                    DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId));

                if (rows > 0)
                {
                    pnlAlert.CssClass = "alert alert-info py-2 small mb-3";
                    pnlAlert.Visible = true;
                    litAlertMessage.Text = "Your collaboration request has been withdrawn.";
                    LoadStartupDetails();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("StartupDetails btnWithdrawJoin error: " + ex);
            }
        }

        protected void btnContactFounder_Click(object sender, EventArgs e)
        {
            if (_founderId > 0)
            {
                Response.Redirect("~/Messages.aspx?partnerId=" + _founderId);
            }
            else
            {
                Response.Redirect("~/Messages.aspx");
            }
        }

        protected void btnOpenReport_Click(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            pnlReportStartup.Visible = !pnlReportStartup.Visible;
            txtReportDetails.Text = string.Empty;
        }

        protected void btnCancelReport_Click(object sender, EventArgs e)
        {
            pnlReportStartup.Visible = false;
            txtReportDetails.Text = string.Empty;
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            int? currentUserId = SecurityHelper.GetCurrentUserId();
            string email = Session["Email"]?.ToString();
            if (string.IsNullOrEmpty(email))
            {
                object emailObj = DbHelper.ExecuteScalar("SELECT Email FROM dbo.Users WHERE UserId = @UserId",
                    DbHelper.CreateParam("@UserId", SqlDbType.Int, currentUserId.Value));
                email = emailObj?.ToString() ?? "user@ripaldesign.studio";
            }

            // Check self-reporting
            if (_founderId == currentUserId.Value)
            {
                pnlAlert.CssClass = "alert alert-warning py-2 small mb-3";
                pnlAlert.Visible = true;
                litAlertMessage.Text = "You cannot submit a moderation report on your own startup listing.";
                pnlReportStartup.Visible = false;
                return;
            }

            string category = ddlReportCategory.SelectedValue;
            string details = txtReportDetails.Text.Trim();

            if (string.IsNullOrWhiteSpace(details))
            {
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
                litAlertMessage.Text = "Please provide an explanation or description of the issue.";
                return;
            }

            if (details.Length > 500)
            {
                details = details.Substring(0, 500);
            }

            try
            {
                // Prevent duplicate pending reports for this startup by this reporter
                string reportedItemIdentifier = "Startup: " + litStartupName.Text + " (ID: " + _startupId + ")";
                string checkDuplicateSql = @"
                    SELECT COUNT(1) FROM dbo.ModerationReports 
                    WHERE ReporterEmail = @Email AND ReportedItem = @ReportedItem AND Status = 'Pending'";

                int existingPending = Convert.ToInt32(DbHelper.ExecuteScalar(checkDuplicateSql,
                    DbHelper.CreateParam("@Email", SqlDbType.NVarChar, email),
                    DbHelper.CreateParam("@ReportedItem", SqlDbType.NVarChar, reportedItemIdentifier)));

                if (existingPending > 0)
                {
                    pnlAlert.CssClass = "alert alert-info py-2 small mb-3";
                    pnlAlert.Visible = true;
                    litAlertMessage.Text = "You have already submitted a report for this startup. Our moderation desk is currently reviewing it.";
                    pnlReportStartup.Visible = false;
                    return;
                }

                string reportCode = "#RPT-" + Guid.NewGuid().ToString("N").Substring(0, 6).ToUpper();
                string priority = (category == "Suspicious Activity" || category == "Content Violation") ? "High" : "Normal";

                string insertSql = @"
                    INSERT INTO dbo.ModerationReports 
                    (ReportCode, ReporterEmail, ReportedItem, ReportType, Priority, Details, Status, CreatedAt)
                    VALUES 
                    (@ReportCode, @Email, @ReportedItem, @Category, @Priority, @Details, 'Pending', SYSUTCDATETIME());";

                DbHelper.ExecuteNonQuery(insertSql,
                    DbHelper.CreateParam("@ReportCode", SqlDbType.NVarChar, reportCode),
                    DbHelper.CreateParam("@Email", SqlDbType.NVarChar, email),
                    DbHelper.CreateParam("@ReportedItem", SqlDbType.NVarChar, reportedItemIdentifier),
                    DbHelper.CreateParam("@Category", SqlDbType.NVarChar, category),
                    DbHelper.CreateParam("@Priority", SqlDbType.NVarChar, priority),
                    DbHelper.CreateParam("@Details", SqlDbType.NVarChar, details));

                pnlReportStartup.Visible = false;
                txtReportDetails.Text = string.Empty;
                pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                pnlAlert.Visible = true;
                litAlertMessage.Text = $"Thank you for helping keep FoundrLink safe. Your report (Ticket <strong>{reportCode}</strong>) has been submitted for review.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Submit report error: " + ex);
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
                litAlertMessage.Text = "An error occurred while submitting your report. Please try again later.";
            }
        }
    }
}
