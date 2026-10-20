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
                string status = ddlStatus.SelectedValue;

                string sql = @"
                    SELECT 
                        s.StartupId,
                        s.Name,
                        s.Tagline,
                        s.Industry,
                        s.Stage,
                        s.LogoUrl,
                        s.FundingGoal,
                        s.Status,
                        u.FullName AS FounderName,
                        u.Email AS FounderEmail
                    FROM dbo.Startups s
                    INNER JOIN dbo.Users u ON s.FounderId = u.UserId
                    WHERE 1=1
                ";

                if (!string.IsNullOrEmpty(search))
                {
                    sql += " AND (s.Name LIKE '%' + @Search + '%' OR s.Problem LIKE '%' + @Search + '%' OR s.Location LIKE '%' + @Search + '%' OR u.FullName LIKE '%' + @Search + '%')";
                }

                if (!string.IsNullOrEmpty(industry))
                {
                    sql += " AND s.Industry = @Industry";
                }

                if (!string.IsNullOrEmpty(status))
                {
                    sql += " AND s.Status = @Status";
                }

                sql += " ORDER BY s.StartupId DESC";

                SqlParameter[] p = new SqlParameter[]
                {
                    new SqlParameter("@Search", search),
                    new SqlParameter("@Industry", industry),
                    new SqlParameter("@Status", status)
                };

                DataTable dt = DbHelper.ExecuteDataTable(sql, p);
                rptStartups.DataSource = dt;
                rptStartups.DataBind();
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
            LoadStartups();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlIndustry.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            LoadStartups();
        }

        protected void rptStartups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!SecurityHelper.IsUserAdmin())
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
                                DELETE FROM dbo.ConnectionRequests WHERE StartupId = @Id;
                                DELETE FROM dbo.TeamMembers WHERE StartupId = @Id;
                                DELETE FROM dbo.OpenPositions WHERE StartupId = @Id;
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
