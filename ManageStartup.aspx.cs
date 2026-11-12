using System;
using System.Data;
using System.IO;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class ManageStartup : Page
    {
        private int? _startupId = null;

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

            if (!IsPostBack)
            {
                if (_startupId.HasValue)
                {
                    LoadStartupData(_startupId.Value);
                    btnDelete.Visible = true;
                }
            }
        }

        private void LoadStartupData(int startupId)
        {
            try
            {
                int currentUserId = SecurityHelper.GetCurrentUserId().Value;
                bool isAdmin = SecurityHelper.IsUserAdmin();

                string sql = "SELECT * FROM dbo.Startups WHERE StartupId = @StartupId";
                DataTable dt = DbHelper.ExecuteDataTable(sql, DbHelper.CreateParam("@StartupId", SqlDbType.Int, startupId));
                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    int founderId = Convert.ToInt32(r["FounderId"]);

                    // ASVS V8: Enforce object-level authorization (IDOR protection)
                    if (founderId != currentUserId && !isAdmin)
                    {
                        System.Diagnostics.Trace.TraceWarning($"IDOR attempt: User {currentUserId} attempted to view/edit Startup {startupId} owned by {founderId}.");
                        Response.Redirect("~/ExploreStartups.aspx");
                        return;
                    }

                    txtName.Text = r["Name"]?.ToString();
                    txtTagline.Text = r["Tagline"]?.ToString();
                    if (ddlIndustry.Items.FindByValue(r["Industry"]?.ToString()) != null)
                        ddlIndustry.SelectedValue = r["Industry"].ToString();
                    if (ddlStage.Items.FindByValue(r["Stage"]?.ToString()) != null)
                        ddlStage.SelectedValue = r["Stage"].ToString();
                    txtShortDesc.Text = r["ShortDescription"]?.ToString();
                    txtFullDesc.Text = r["FullDescription"]?.ToString();
                    txtProblem.Text = r["Problem"]?.ToString();
                    txtSolution.Text = r["Solution"]?.ToString();
                    txtTeamSize.Text = r["TeamSize"]?.ToString();
                    txtSkills.Text = r["RequiredSkills"]?.ToString();
                    txtLocation.Text = r["Location"]?.ToString();
                    txtWebsite.Text = r["WebsiteUrl"]?.ToString();
                    litStatusBadge.Text = r["Status"]?.ToString() ?? "Draft";
                }
                else
                {
                    Response.Redirect("~/ExploreStartups.aspx");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadStartup error: " + ex);
                Response.Redirect("~/ExploreStartups.aspx");
            }
        }

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            SaveStartup("Draft");
        }

        protected void btnPublish_Click(object sender, EventArgs e)
        {
            SaveStartup("Active");
        }

        private void SaveStartup(string status)
        {
            if (!Page.IsValid) return;

            int? currentUserId = SecurityHelper.GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            int founderId = currentUserId.Value;
            bool isAdmin = SecurityHelper.IsUserAdmin();

            string name = txtName.Text.Trim();
            string tagline = txtTagline.Text.Trim();
            string industry = ddlIndustry.SelectedValue;
            string stage = !string.IsNullOrEmpty(ddlStage.SelectedValue) ? ddlStage.SelectedValue : "Seed Stage";
            string shortDesc = txtShortDesc.Text.Trim();
            string fullDesc = txtFullDesc.Text.Trim();
            string problem = txtProblem.Text.Trim();
            string solution = txtSolution.Text.Trim();
            int.TryParse(txtTeamSize.Text.Trim(), out int teamSize);
            if (teamSize < 1) teamSize = 1;
            string skills = txtSkills.Text.Trim();
            string location = txtLocation.Text.Trim();
            string website = txtWebsite.Text.Trim();

            string logoUrl = "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200";

            if (fuLogo.HasFile)
            {
                // ASVS V5: Strict file upload validation (no SVG, magic byte checks, size limit)
                const int maxSizeBytes = 5 * 1024 * 1024;
                if (!SecurityHelper.ValidateUploadedImage(fuLogo.PostedFile, maxSizeBytes, out string uploadError))
                {
                    litSuccess.Text = Server.HtmlEncode(uploadError);
                    pnlSuccess.CssClass = "alert alert-danger py-2 small mb-4";
                    pnlSuccess.Visible = true;
                    return;
                }

                try
                {
                    string ext = Path.GetExtension(fuLogo.FileName).ToLowerInvariant();
                    string fileName = "startup_" + Guid.NewGuid().ToString("N").Substring(0, 8) + ext;
                    string directoryPath = Server.MapPath("~/Images/");
                    if (!Directory.Exists(directoryPath))
                    {
                        Directory.CreateDirectory(directoryPath);
                    }
                    string savePath = Path.Combine(directoryPath, fileName);
                    fuLogo.SaveAs(savePath);
                    logoUrl = "Images/" + fileName;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("Logo upload failed: " + ex);
                    litSuccess.Text = "An error occurred while uploading the logo.";
                    pnlSuccess.CssClass = "alert alert-danger py-2 small mb-4";
                    pnlSuccess.Visible = true;
                    return;
                }
            }

            try
            {
                if (_startupId.HasValue)
                {
                    // ASVS V8: Enforce authorization on update (must be owner or Admin)
                    string updateSql = @"
                        UPDATE dbo.Startups 
                        SET Name = @Name, Tagline = @Tagline, Industry = @Industry, Stage = @Stage,
                            ShortDescription = @ShortDescription, FullDescription = @FullDescription,
                            Problem = @Problem, Solution = @Solution, TeamSize = @TeamSize,
                            RequiredSkills = @RequiredSkills, Location = @Location, WebsiteUrl = @WebsiteUrl,
                            Status = @Status, UpdatedAt = SYSUTCDATETIME()
                        WHERE StartupId = @StartupId AND (FounderId = @CurrentUserId OR @IsAdmin = 1)";

                    int rows = DbHelper.ExecuteNonQuery(updateSql,
                        DbHelper.CreateParam("@Name", SqlDbType.NVarChar, name),
                        DbHelper.CreateParam("@Tagline", SqlDbType.NVarChar, tagline),
                        DbHelper.CreateParam("@Industry", SqlDbType.NVarChar, industry),
                        DbHelper.CreateParam("@Stage", SqlDbType.NVarChar, stage),
                        DbHelper.CreateParam("@ShortDescription", SqlDbType.NVarChar, shortDesc),
                        DbHelper.CreateParam("@FullDescription", SqlDbType.NVarChar, fullDesc),
                        DbHelper.CreateParam("@Problem", SqlDbType.NVarChar, problem),
                        DbHelper.CreateParam("@Solution", SqlDbType.NVarChar, solution),
                        DbHelper.CreateParam("@TeamSize", SqlDbType.Int, teamSize),
                        DbHelper.CreateParam("@RequiredSkills", SqlDbType.NVarChar, skills),
                        DbHelper.CreateParam("@Location", SqlDbType.NVarChar, location),
                        DbHelper.CreateParam("@WebsiteUrl", SqlDbType.NVarChar, website),
                        DbHelper.CreateParam("@Status", SqlDbType.NVarChar, status),
                        DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId.Value),
                        DbHelper.CreateParam("@CurrentUserId", SqlDbType.Int, founderId),
                        DbHelper.CreateParam("@IsAdmin", SqlDbType.Bit, isAdmin ? 1 : 0)
                    );

                    if (rows == 0)
                    {
                        litSuccess.Text = "You do not have permission to modify this startup listing.";
                        pnlSuccess.CssClass = "alert alert-danger py-2 small mb-4";
                        pnlSuccess.Visible = true;
                        return;
                    }

                    litSuccess.Text = "Startup updated successfully!";
                    pnlSuccess.CssClass = "alert alert-success py-2 small mb-4";
                    pnlSuccess.Visible = true;
                }
                else
                {
                    // Insert
                    string insertSql = @"
                        INSERT INTO dbo.Startups (FounderId, Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, FullDescription, Problem, Solution, TeamSize, RequiredSkills, Location, WebsiteUrl, Status, CreatedAt, UpdatedAt)
                        OUTPUT INSERTED.StartupId
                        VALUES (@FounderId, @Name, @Tagline, @Industry, @Stage, @LogoUrl, @ShortDescription, @FullDescription, @Problem, @Solution, @TeamSize, @RequiredSkills, @Location, @WebsiteUrl, @Status, SYSUTCDATETIME(), SYSUTCDATETIME());";

                    object newId = DbHelper.ExecuteScalar(insertSql,
                        DbHelper.CreateParam("@FounderId", SqlDbType.Int, founderId),
                        DbHelper.CreateParam("@Name", SqlDbType.NVarChar, name),
                        DbHelper.CreateParam("@Tagline", SqlDbType.NVarChar, tagline),
                        DbHelper.CreateParam("@Industry", SqlDbType.NVarChar, industry),
                        DbHelper.CreateParam("@Stage", SqlDbType.NVarChar, stage),
                        DbHelper.CreateParam("@LogoUrl", SqlDbType.NVarChar, logoUrl),
                        DbHelper.CreateParam("@ShortDescription", SqlDbType.NVarChar, shortDesc),
                        DbHelper.CreateParam("@FullDescription", SqlDbType.NVarChar, fullDesc),
                        DbHelper.CreateParam("@Problem", SqlDbType.NVarChar, problem),
                        DbHelper.CreateParam("@Solution", SqlDbType.NVarChar, solution),
                        DbHelper.CreateParam("@TeamSize", SqlDbType.Int, teamSize),
                        DbHelper.CreateParam("@RequiredSkills", SqlDbType.NVarChar, skills),
                        DbHelper.CreateParam("@Location", SqlDbType.NVarChar, location),
                        DbHelper.CreateParam("@WebsiteUrl", SqlDbType.NVarChar, website),
                        DbHelper.CreateParam("@Status", SqlDbType.NVarChar, status)
                    );

                    if (newId != null && int.TryParse(newId.ToString(), out int sId))
                    {
                        if (!string.IsNullOrEmpty(txtOpenRole.Text.Trim()))
                        {
                            string roleSql = @"
                                INSERT INTO dbo.OpenPositions (StartupId, Title, Location, PositionType, CreatedAt)
                                VALUES (@StartupId, @Title, @Location, 'Full-time', SYSUTCDATETIME());";

                            DbHelper.ExecuteNonQuery(roleSql,
                                DbHelper.CreateParam("@StartupId", SqlDbType.Int, sId),
                                DbHelper.CreateParam("@Title", SqlDbType.NVarChar, txtOpenRole.Text.Trim()),
                                DbHelper.CreateParam("@Location", SqlDbType.NVarChar, string.IsNullOrEmpty(location) ? "Remote" : location)
                            );
                        }

                        Response.Redirect("~/StartupDetails.aspx?id=" + sId);
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("SaveStartup error: " + ex);
                litSuccess.Text = "An error occurred while saving the startup.";
                pnlSuccess.CssClass = "alert alert-danger py-2 small mb-4";
                pnlSuccess.Visible = true;
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (_startupId.HasValue)
            {
                int? currentUserId = SecurityHelper.GetCurrentUserId();
                if (!currentUserId.HasValue)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                bool isAdmin = SecurityHelper.IsUserAdmin();

                try
                {
                    // ASVS V8: Enforce authorization on delete (must be owner or Admin)
                    string deleteSql = @"
                        DELETE FROM dbo.Startups 
                        WHERE StartupId = @StartupId AND (FounderId = @CurrentUserId OR @IsAdmin = 1)";

                    int rows = DbHelper.ExecuteNonQuery(deleteSql,
                        DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId.Value),
                        DbHelper.CreateParam("@CurrentUserId", SqlDbType.Int, currentUserId.Value),
                        DbHelper.CreateParam("@IsAdmin", SqlDbType.Bit, isAdmin ? 1 : 0));

                    if (rows > 0)
                    {
                        Response.Redirect("~/ExploreStartups.aspx");
                    }
                    else
                    {
                        litSuccess.Text = "You do not have permission to delete this startup.";
                        pnlSuccess.CssClass = "alert alert-danger py-2 small mb-4";
                        pnlSuccess.Visible = true;
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("DeleteStartup error: " + ex);
                    litSuccess.Text = "Error deleting startup: " + ex.Message;
                    pnlSuccess.CssClass = "alert alert-danger py-2 small mb-4";
                    pnlSuccess.Visible = true;
                }
            }
        }
    }
}
