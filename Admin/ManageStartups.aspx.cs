using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;

namespace FoundrLink.Admin
{
    public partial class ManageStartups : Page
    {
        private int PageIndex
        {
            get { return ViewState["StartupPageIndex"] != null ? (int)ViewState["StartupPageIndex"] : 0; }
            set { ViewState["StartupPageIndex"] = value; }
        }

        private const int PageSize = 8;

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
                LoadStartups();
            }
        }

        private void LoadStartups()
        {
            try
            {
                string search = txtSearch.Text.Trim();
                string industry = ddlIndustry.SelectedValue;
                string stage = ddlStage.SelectedValue;
                string status = ddlStatus.SelectedValue;

                string countSql = @"
                    SELECT COUNT(1) 
                    FROM dbo.Startups s
                    INNER JOIN dbo.Users u ON s.FounderId = u.UserId
                    WHERE 1=1";

                string sql = @"
                    SELECT 
                        s.StartupId,
                        s.Name,
                        s.Tagline,
                        s.Industry,
                        s.Stage,
                        s.LogoUrl,
                        s.FundingGoal,
                        s.TeamSize,
                        s.Status,
                        s.CreatedAt,
                        u.FullName AS FounderName,
                        u.Email AS FounderEmail,
                        u.AvatarUrl AS FounderAvatarUrl
                    FROM dbo.Startups s
                    INNER JOIN dbo.Users u ON s.FounderId = u.UserId
                    WHERE 1=1";

                string filterSql = "";
                if (!string.IsNullOrEmpty(search))
                {
                    filterSql += " AND (s.Name LIKE '%' + @Search + '%' OR s.Problem LIKE '%' + @Search + '%' OR s.Location LIKE '%' + @Search + '%' OR u.FullName LIKE '%' + @Search + '%')";
                }

                if (!string.IsNullOrEmpty(industry))
                {
                    filterSql += " AND s.Industry = @Industry";
                }

                if (!string.IsNullOrEmpty(stage))
                {
                    filterSql += " AND s.Stage = @Stage";
                }

                if (!string.IsNullOrEmpty(status))
                {
                    filterSql += " AND s.Status = @Status";
                }

                countSql += filterSql;
                sql += filterSql + " ORDER BY s.StartupId DESC OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                int offset = PageIndex * PageSize;

                SqlParameter[] countParams = new SqlParameter[]
                {
                    new SqlParameter("@Search", search),
                    new SqlParameter("@Industry", industry),
                    new SqlParameter("@Stage", stage),
                    new SqlParameter("@Status", status)
                };

                int totalCount = Convert.ToInt32(DbHelper.ExecuteScalar(countSql, countParams));

                SqlParameter[] p = new SqlParameter[]
                {
                    new SqlParameter("@Search", search),
                    new SqlParameter("@Industry", industry),
                    new SqlParameter("@Stage", stage),
                    new SqlParameter("@Status", status),
                    new SqlParameter("@Offset", offset),
                    new SqlParameter("@PageSize", PageSize)
                };

                DataTable dt = DbHelper.ExecuteDataTable(sql, p);
                rptStartups.DataSource = dt;
                rptStartups.DataBind();

                pnlNoStartups.Visible = (totalCount == 0);
                rptStartups.Visible = (totalCount > 0);

                int startEntry = totalCount == 0 ? 0 : offset + 1;
                int endEntry = Math.Min(offset + PageSize, totalCount);
                litPaginationInfo.Text = $"Showing {startEntry} to {endEntry} of {totalCount} entries";

                btnPrevPage.Enabled = (PageIndex > 0);
                btnPrevPage.CssClass = PageIndex > 0 ? "fl-page-btn" : "fl-page-btn text-muted opacity-50";

                int maxPage = (int)Math.Ceiling((double)totalCount / PageSize) - 1;
                if (maxPage < 0) maxPage = 0;
                btnNextPage.Enabled = (PageIndex < maxPage);
                btnNextPage.CssClass = PageIndex < maxPage ? "fl-page-btn" : "fl-page-btn text-muted opacity-50";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadStartups error: " + ex);
                litAlertMsg.Text = "An error occurred while loading startups.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            PageIndex = 0;
            LoadStartups();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            PageIndex = 0;
            txtSearch.Text = string.Empty;
            ddlIndustry.SelectedIndex = 0;
            ddlStage.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            LoadStartups();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (PageIndex > 0)
            {
                PageIndex--;
                LoadStartups();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            PageIndex++;
            LoadStartups();
        }

        protected void rptStartups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn() || !SecurityHelper.IsUserAdmin())
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            int startupId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "TogglePublish")
            {
                try
                {
                    string sql = "UPDATE dbo.Startups SET Status = CASE WHEN Status = 'Published' THEN 'Draft' ELSE 'Published' END WHERE StartupId = @Id";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", startupId));

                    litAlertMsg.Text = "Startup visibility status updated successfully.";
                    pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    pnlAlert.Visible = true;
                    LoadStartups();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("TogglePublish error: " + ex);
                    litAlertMsg.Text = "An error occurred while updating startup status.";
                    pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                    pnlAlert.Visible = true;
                }
            }
            else if (e.CommandName == "DeleteStartup")
            {
                try
                {
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
                                DELETE FROM dbo.Startups WHERE StartupId = @Id;";
                            cmd.Parameters.Add(new SqlParameter("@Id", SqlDbType.Int) { Value = startupId });
                            cmd.ExecuteNonQuery();
                        }
                    });

                    litAlertMsg.Text = "Startup and related records permanently deleted.";
                    pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    pnlAlert.Visible = true;
                    LoadStartups();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("DeleteStartup error: " + ex);
                    litAlertMsg.Text = "An error occurred while deleting the startup.";
                    pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                    pnlAlert.Visible = true;
                }
            }
        }
    }
}
