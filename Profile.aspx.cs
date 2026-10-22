using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class Profile : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int targetUserId = 1; // Default to Yash Vinchhi (UserId 1) as seen in Figma screenshot

                if (!string.IsNullOrEmpty(Request.QueryString["id"]) && int.TryParse(Request.QueryString["id"], out int qId))
                {
                    targetUserId = qId;
                }
                else if (SecurityHelper.GetCurrentUserId().HasValue)
                {
                    targetUserId = SecurityHelper.GetCurrentUserId().Value;
                }

                LoadProfile(targetUserId);
            }
        }

        private void LoadProfile(int userId)
        {
            try
            {
                string query = @"
                    SELECT u.UserId, u.FullName, u.Title, u.Location, u.Bio, u.AvatarUrl, u.IsVerified, u.Company,
                           p.PlatformImpactConnections, p.PlatformImpactIntros, p.PlatformImpactTeams, p.PlatformImpactSaved,
                           p.Interests, p.Skills, p.ICanOffer, p.LookingFor, p.BaseLocation
                    FROM dbo.Users u
                    LEFT JOIN dbo.FounderProfiles p ON u.UserId = p.UserId
                    WHERE u.UserId = @UserId";

                DataTable dt = DbHelper.ExecuteDataTable(query, DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    litFullName.Text = r["FullName"]?.ToString() ?? "Founder";
                    litHeadline.Text = r["Title"]?.ToString() ?? "Founder & CEO";
                    litLocation.Text = r["Location"]?.ToString() ?? "Mumbai, India";
                    litIndustry.Text = r["Company"]?.ToString() ?? "SaaS, FinTech";

                    bool isVerified = Convert.ToBoolean(r["IsVerified"] != DBNull.Value ? r["IsVerified"] : false);
                    pnlVerified.Visible = isVerified;

                    string avatar = r["AvatarUrl"]?.ToString();
                    if (!string.IsNullOrEmpty(avatar))
                    {
                        imgAvatar.ImageUrl = avatar;
                    }

                    string bioText = r["Bio"]?.ToString() ?? "No bio provided yet.";
                    litBio.Text = Server.HtmlEncode(bioText).Replace("\n", "<br/>");

                    // Real database-derived platform impact metrics
                    object connCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.Connections WHERE (RequesterUserId = @UserId OR ReceiverUserId = @UserId) AND Status = 'Connected'",
                        DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                    int conns = connCount != null ? Convert.ToInt32(connCount) : 0;
                    if (conns == 0 && r["PlatformImpactConnections"] != DBNull.Value) conns = Convert.ToInt32(r["PlatformImpactConnections"]);
                    litImpactConnections.Text = conns.ToString();

                    object introCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.ConnectionRequests WHERE (SenderId = @UserId OR ReceiverId = @UserId) AND Status = 'Accepted'",
                        DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                    int intros = introCount != null ? Convert.ToInt32(introCount) : 0;
                    if (intros == 0 && r["PlatformImpactIntros"] != DBNull.Value) intros = Convert.ToInt32(r["PlatformImpactIntros"]);
                    litImpactIntros.Text = intros.ToString();

                    object teamCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.TeamMembers WHERE UserId = @UserId",
                        DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                    int teams = teamCount != null ? Convert.ToInt32(teamCount) : 0;
                    if (teams == 0 && r["PlatformImpactTeams"] != DBNull.Value) teams = Convert.ToInt32(r["PlatformImpactTeams"]);
                    litImpactTeams.Text = teams.ToString();

                    int saved = (r["PlatformImpactSaved"] != DBNull.Value) ? Convert.ToInt32(r["PlatformImpactSaved"]) : 0;
                    litImpactSaved.Text = saved.ToString();

                    string baseLoc = r["BaseLocation"]?.ToString();
                    litBaseLocation.Text = !string.IsNullOrWhiteSpace(baseLoc) ? baseLoc : (!string.IsNullOrWhiteSpace(r["Location"]?.ToString()) ? r["Location"].ToString() : "Location Not Specified");

                    // Split I Can Offer
                    string canOfferStr = r["ICanOffer"]?.ToString();
                    var canOfferList = new List<string>();
                    if (!string.IsNullOrEmpty(canOfferStr))
                    {
                        foreach (var item in canOfferStr.Split(new[] { '\n', '\r', ';' }, StringSplitOptions.RemoveEmptyEntries))
                        {
                            if (!string.IsNullOrWhiteSpace(item)) canOfferList.Add(item.Trim());
                        }
                    }
                    if (canOfferList.Count == 0)
                    {
                        canOfferList.Add("No specific offerings listed yet.");
                    }
                    rptCanOffer.DataSource = canOfferList;
                    rptCanOffer.DataBind();

                    // Split Looking For
                    string lookingForStr = r["LookingFor"]?.ToString();
                    var lookingForList = new List<string>();
                    if (!string.IsNullOrEmpty(lookingForStr))
                    {
                        foreach (var item in lookingForStr.Split(new[] { '\n', '\r', ';' }, StringSplitOptions.RemoveEmptyEntries))
                        {
                            if (!string.IsNullOrWhiteSpace(item)) lookingForList.Add(item.Trim());
                        }
                    }
                    if (lookingForList.Count == 0)
                    {
                        lookingForList.Add("Open to co-founder and startup connections.");
                    }
                    rptLookingFor.DataSource = lookingForList;
                    rptLookingFor.DataBind();

                    // Split Interests
                    string interestsStr = r["Interests"]?.ToString();
                    var interestsList = new List<string>();
                    if (!string.IsNullOrEmpty(interestsStr))
                    {
                        foreach (var item in interestsStr.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries))
                        {
                            if (!string.IsNullOrWhiteSpace(item)) interestsList.Add(item.Trim());
                        }
                    }
                    if (interestsList.Count == 0)
                    {
                        interestsList.Add("Startups");
                    }
                    rptInterests.DataSource = interestsList;
                    rptInterests.DataBind();
                }

                // Load User's Startup Preview
                string startupQuery = @"
                    SELECT TOP 1 StartupId, Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, TeamSize, 
                                 WebsiteUrl, FoundedYear, FundingRaised, MRR
                    FROM dbo.Startups 
                    WHERE FounderId = @UserId 
                    ORDER BY StartupId ASC";

                DataTable dtStartup = DbHelper.ExecuteDataTable(startupQuery, DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                if (dtStartup.Rows.Count > 0)
                {
                    DataRow sr = dtStartup.Rows[0];
                    int sId = Convert.ToInt32(sr["StartupId"]);
                    string web = sr["WebsiteUrl"]?.ToString();
                    if (!string.IsNullOrWhiteSpace(web))
                    {
                        litStartupWebsite.Text = web.Replace("https://", "").Replace("http://", "");
                        lnkStartupWebsite.HRef = web.StartsWith("http") ? web : "https://" + web;
                    }
                    else
                    {
                        litStartupWebsite.Text = sr["Name"]?.ToString() ?? "Startup Details";
                        lnkStartupWebsite.HRef = "StartupDetails.aspx?id=" + sId;
                    }

                    litStartupStage.Text = sr["Stage"]?.ToString() ?? "SEED STAGE";
                    litFoundedYear.Text = sr["FoundedYear"]?.ToString() ?? "-";
                    litTeamSize.Text = sr["TeamSize"]?.ToString() ?? "1";

                    decimal funding = (sr["FundingRaised"] != DBNull.Value) ? Convert.ToDecimal(sr["FundingRaised"]) : 0m;
                    decimal mrr = (sr["MRR"] != DBNull.Value) ? Convert.ToDecimal(sr["MRR"]) : 0m;
                    litFunding.Text = funding > 0 ? "₹" + funding.ToString("N0") : "₹0";
                    litMRR.Text = mrr > 0 ? "₹" + mrr.ToString("N0") : "₹0";

                    litStartupDescription.Text = sr["ShortDescription"]?.ToString() ?? sr["Tagline"]?.ToString() ?? "Innovative venture on FoundrLink.";
                }
                else
                {
                    litStartupWebsite.Text = "Create / Explore Startups";
                    lnkStartupWebsite.HRef = "ExploreStartups.aspx";
                    litStartupStage.Text = "NONE";
                    litFoundedYear.Text = "-";
                    litTeamSize.Text = "-";
                    litFunding.Text = "₹0";
                    litMRR.Text = "₹0";
                    litStartupDescription.Text = "This member has not published an active startup profile yet.";
                }

                TargetUserId = userId;
                int? currentUserId = SecurityHelper.GetCurrentUserId();
                bool isOwnProfile = currentUserId.HasValue && currentUserId.Value == userId;
                lnkEditProfile.Visible = isOwnProfile;
                pnlVisitorActions.Visible = !isOwnProfile;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Profile load error: " + ex.Message);
            }
        }

        private int TargetUserId
        {
            get { return ViewState["TargetProfileUserId"] != null ? (int)ViewState["TargetProfileUserId"] : 0; }
            set { ViewState["TargetProfileUserId"] = value; }
        }

        protected void btnConnect_Click(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            int currentUserId = SecurityHelper.GetCurrentUserId().Value;
            if (currentUserId == TargetUserId) return;

            try
            {
                string insertSql = @"
                    IF NOT EXISTS (SELECT 1 FROM dbo.ConnectionRequests WHERE SenderId = @SenderId AND ReceiverId = @ReceiverId)
                    BEGIN
                        INSERT INTO dbo.ConnectionRequests (SenderId, ReceiverId, Note, Status, CreatedAt)
                        VALUES (@SenderId, @ReceiverId, 'Hi, I would love to connect with you on FoundrLink!', 'Pending', SYSUTCDATETIME());
                    END";

                DbHelper.ExecuteNonQuery(insertSql,
                    DbHelper.CreateParam("@SenderId", SqlDbType.Int, currentUserId),
                    DbHelper.CreateParam("@ReceiverId", SqlDbType.Int, TargetUserId));

                pnlProfileAlert.CssClass = "alert alert-success alert-dismissible fade show rounded-3 shadow-sm mb-4";
                pnlProfileAlert.Visible = true;
                litProfileAlertMessage.Text = "Connection request sent successfully!";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Profile connect error: " + ex);
            }
        }

        protected void btnMessage_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Messages.aspx?partnerId=" + TargetUserId);
        }

        protected void btnOpenReportProfile_Click(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }
            pnlReportUser.Visible = !pnlReportUser.Visible;
            txtReportUserDetails.Text = string.Empty;
        }

        protected void btnCancelReportUser_Click(object sender, EventArgs e)
        {
            pnlReportUser.Visible = false;
            txtReportUserDetails.Text = string.Empty;
        }

        protected void btnSubmitReportUser_Click(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            int currentUserId = SecurityHelper.GetCurrentUserId().Value;
            if (currentUserId == TargetUserId)
            {
                pnlProfileAlert.CssClass = "alert alert-warning alert-dismissible fade show rounded-3 shadow-sm mb-4";
                pnlProfileAlert.Visible = true;
                litProfileAlertMessage.Text = "You cannot report your own profile.";
                pnlReportUser.Visible = false;
                return;
            }

            string details = txtReportUserDetails.Text.Trim();
            if (string.IsNullOrWhiteSpace(details))
            {
                pnlProfileAlert.CssClass = "alert alert-danger alert-dismissible fade show rounded-3 shadow-sm mb-4";
                pnlProfileAlert.Visible = true;
                litProfileAlertMessage.Text = "Please provide an explanation describing the issue.";
                return;
            }

            if (details.Length > 500) details = details.Substring(0, 500);

            string category = ddlReportUserCategory.SelectedValue;
            string email = Session["Email"]?.ToString();
            if (string.IsNullOrEmpty(email))
            {
                object emailObj = DbHelper.ExecuteScalar("SELECT Email FROM dbo.Users WHERE UserId = @UserId",
                    DbHelper.CreateParam("@UserId", SqlDbType.Int, currentUserId));
                email = emailObj?.ToString() ?? "user@ripaldesign.studio";
            }

            string reportedItemIdentifier = "User: " + litFullName.Text + " (ID: " + TargetUserId + ")";

            try
            {
                string checkDuplicateSql = @"
                    SELECT COUNT(1) FROM dbo.ModerationReports 
                    WHERE ReporterEmail = @Email AND ReportedItem = @ReportedItem AND Status = 'Pending'";

                int existingPending = Convert.ToInt32(DbHelper.ExecuteScalar(checkDuplicateSql,
                    DbHelper.CreateParam("@Email", SqlDbType.NVarChar, email),
                    DbHelper.CreateParam("@ReportedItem", SqlDbType.NVarChar, reportedItemIdentifier)));

                if (existingPending > 0)
                {
                    pnlProfileAlert.CssClass = "alert alert-info alert-dismissible fade show rounded-3 shadow-sm mb-4";
                    pnlProfileAlert.Visible = true;
                    litProfileAlertMessage.Text = "You have already submitted a pending report for this user profile. Our moderation desk is currently reviewing it.";
                    pnlReportUser.Visible = false;
                    return;
                }

                string reportCode = "#RPT-" + Guid.NewGuid().ToString("N").Substring(0, 6).ToUpper();
                string priority = (category == "Suspicious Activity" || category == "Harassment") ? "High" : "Normal";

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

                pnlReportUser.Visible = false;
                txtReportUserDetails.Text = string.Empty;
                pnlProfileAlert.CssClass = "alert alert-success alert-dismissible fade show rounded-3 shadow-sm mb-4";
                pnlProfileAlert.Visible = true;
                litProfileAlertMessage.Text = $"Thank you. Your report (Ticket <strong>{reportCode}</strong>) has been submitted to platform moderation for review.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Submit user report error: " + ex);
                pnlProfileAlert.CssClass = "alert alert-danger alert-dismissible fade show rounded-3 shadow-sm mb-4";
                pnlProfileAlert.Visible = true;
                litProfileAlertMessage.Text = "An error occurred while submitting your report. Please try again later.";
            }
        }
    }
}
