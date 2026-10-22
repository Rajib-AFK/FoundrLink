using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
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
                int? currentUserId = SecurityHelper.GetCurrentUserId();
                if (!currentUserId.HasValue)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                string sql = @"
                    SELECT StartupId, FounderId, Name, Tagline, Industry, Stage, LogoUrl, 
                           ShortDescription, FullDescription, Problem, Solution, TeamSize, 
                           RequiredSkills, Location, WebsiteUrl, Status 
                    FROM dbo.Startups 
                    WHERE StartupId = @StartupId";

                DataTable dt = DbHelper.ExecuteDataTable(sql, DbHelper.CreateParam("@StartupId", SqlDbType.Int, startupId));
                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    int founderId = Convert.ToInt32(r["FounderId"]);

                    if (founderId != currentUserId.Value && !SecurityHelper.IsUserAdmin())
                    {
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

                    ViewState["CurrentLogoUrl"] = r["LogoUrl"]?.ToString();

                    // Load open positions
                    DataTable dtRoles = DbHelper.ExecuteDataTable("SELECT Title FROM dbo.OpenPositions WHERE StartupId = @StartupId ORDER BY PositionId ASC",
                        DbHelper.CreateParam("@StartupId", SqlDbType.Int, startupId));
                    var roleList = new List<string>();
                    foreach (DataRow rr in dtRoles.Rows)
                    {
                        if (rr["Title"] != DBNull.Value && !string.IsNullOrWhiteSpace(rr["Title"].ToString()))
                            roleList.Add(rr["Title"].ToString().Trim());
                    }
                    txtOpenRole.Text = string.Join(", ", roleList);
                }
                else
                {
                    Response.Redirect("~/ExploreStartups.aspx");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadStartup error: " + ex);
                litSuccess.Text = "An error occurred while loading the startup data.";
                pnlSuccess.CssClass = "alert alert-danger py-2 small mb-4";
                pnlSuccess.Visible = true;
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
                Response.Redirect("~/Login.aspx");
                return;
            }
            int founderId = currentUserId.Value;

            if (_startupId.HasValue)
            {
                object ownerObj = DbHelper.ExecuteScalar("SELECT FounderId FROM dbo.Startups WHERE StartupId = @StartupId",
                    DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId.Value));
                if (ownerObj == null || ownerObj == DBNull.Value)
                {
                    litSuccess.Text = "The startup you are attempting to edit does not exist.";
                    pnlSuccess.CssClass = "alert alert-danger py-2 small mb-4";
                    pnlSuccess.Visible = true;
                    return;
                }
                int existingFounderId = Convert.ToInt32(ownerObj);
                if (existingFounderId != founderId && !SecurityHelper.IsUserAdmin())
                {
                    Response.Redirect("~/ExploreStartups.aspx");
                    return;
                }
            }

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

            string logoUrl = ViewState["CurrentLogoUrl"] as string ?? "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200";
            string newlySavedFilePath = null;

            if (fuLogo.HasFile)
            {
                if (!SecurityHelper.ValidateUploadedImage(fuLogo.PostedFile, 5 * 1024 * 1024, out string logoError))
                {
                    litSuccess.Text = logoError;
                    pnlSuccess.CssClass = "alert alert-danger py-2 small mb-4";
                    pnlSuccess.Visible = true;
                    return;
                }

                string ext = Path.GetExtension(fuLogo.FileName).ToLowerInvariant();
                string fileName = "startup_" + Guid.NewGuid().ToString("N").Substring(0, 8) + ext;
                string saveDir = Server.MapPath("~/Images/");
                if (!Directory.Exists(saveDir))
                {
                    Directory.CreateDirectory(saveDir);
                }
                newlySavedFilePath = Path.Combine(saveDir, fileName);
                fuLogo.SaveAs(newlySavedFilePath);
                logoUrl = "Images/" + fileName;
            }

            try
            {
                if (_startupId.HasValue)
                {
                    // Update
                    string updateSql = @"
                        UPDATE dbo.Startups 
                        SET Name = @Name, Tagline = @Tagline, Industry = @Industry, Stage = @Stage,
                            LogoUrl = @LogoUrl,
                            ShortDescription = @ShortDescription, FullDescription = @FullDescription,
                            Problem = @Problem, Solution = @Solution, TeamSize = @TeamSize,
                            RequiredSkills = @RequiredSkills, Location = @Location, WebsiteUrl = @WebsiteUrl,
                            Status = @Status, UpdatedAt = SYSUTCDATETIME()
                        WHERE StartupId = @StartupId";

                    DbHelper.ExecuteNonQuery(updateSql,
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
                        DbHelper.CreateParam("@Status", SqlDbType.NVarChar, status),
                        DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId.Value)
                    );

                    SaveOpenPositions(_startupId.Value, txtOpenRole.Text, location);

                    ViewState["CurrentLogoUrl"] = logoUrl;
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
                        SaveOpenPositions(sId, txtOpenRole.Text, location);
                        Response.Redirect("~/StartupDetails.aspx?id=" + sId);
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                if (newlySavedFilePath != null && File.Exists(newlySavedFilePath))
                {
                    try { File.Delete(newlySavedFilePath); } catch { }
                }
                System.Diagnostics.Trace.TraceError("SaveStartup error: " + ex);
                litSuccess.Text = "An unexpected error occurred while saving the startup. Please try again.";
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

                try
                {
                    object ownerObj = DbHelper.ExecuteScalar("SELECT FounderId FROM dbo.Startups WHERE StartupId = @StartupId",
                        DbHelper.CreateParam("@StartupId", SqlDbType.Int, _startupId.Value));
                    if (ownerObj == null || (Convert.ToInt32(ownerObj) != currentUserId.Value && !SecurityHelper.IsUserAdmin()))
                    {
                        Response.Redirect("~/ExploreStartups.aspx");
                        return;
                    }

                    DbHelper.ExecuteInTransaction((conn, trans) =>
                    {
                        using (var cmd = conn.CreateCommand())
                        {
                            cmd.Transaction = trans;
                            cmd.CommandText = @"
                                DELETE FROM dbo.CollaborationRequests WHERE StartupId = @StartupId;
                                DELETE FROM dbo.ConnectionRequests WHERE StartupId = @StartupId;
                                DELETE FROM dbo.TeamMembers WHERE StartupId = @StartupId;
                                DELETE FROM dbo.StartupMembers WHERE StartupId = @StartupId;
                                DELETE FROM dbo.OpenPositions WHERE StartupId = @StartupId;
                                DELETE FROM dbo.StartupOpenRoles WHERE StartupId = @StartupId;
                                DELETE FROM dbo.StartupUpdates WHERE StartupId = @StartupId;
                                DELETE FROM dbo.Startups WHERE StartupId = @StartupId;";
                            cmd.Parameters.Add(new SqlParameter("@StartupId", SqlDbType.Int) { Value = _startupId.Value });
                            cmd.ExecuteNonQuery();
                        }
                    });

                    Response.Redirect("~/ExploreStartups.aspx");
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("DeleteStartup error: " + ex);
                    litSuccess.Text = "An unexpected error occurred while deleting the startup. Please try again.";
                    pnlSuccess.CssClass = "alert alert-danger py-2 small mb-4";
                    pnlSuccess.Visible = true;
                }
            }
        }

        private void SaveOpenPositions(int startupId, string roleText, string startupLocation)
        {
            try
            {
                DbHelper.ExecuteNonQuery("DELETE FROM dbo.OpenPositions WHERE StartupId = @StartupId",
                    DbHelper.CreateParam("@StartupId", SqlDbType.Int, startupId));

                if (!string.IsNullOrWhiteSpace(roleText))
                {
                    var roles = roleText.Split(new[] { '\r', '\n', ',' }, StringSplitOptions.RemoveEmptyEntries);
                    foreach (var role in roles)
                    {
                        string trimmed = role.Trim();
                        if (!string.IsNullOrEmpty(trimmed))
                        {
                            string roleSql = @"
                                INSERT INTO dbo.OpenPositions (StartupId, Title, Location, PositionType, CreatedAt)
                                VALUES (@StartupId, @Title, @Location, 'Full-time', SYSUTCDATETIME());";

                            DbHelper.ExecuteNonQuery(roleSql,
                                DbHelper.CreateParam("@StartupId", SqlDbType.Int, startupId),
                                DbHelper.CreateParam("@Title", SqlDbType.NVarChar, trimmed),
                                DbHelper.CreateParam("@Location", SqlDbType.NVarChar, string.IsNullOrEmpty(startupLocation) ? "Remote" : startupLocation)
                            );
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("SaveOpenPositions error: " + ex);
            }
        }
    }
}
