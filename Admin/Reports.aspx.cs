using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;

namespace FoundrLink.Admin
{
    public partial class Reports : Page
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
                LoadReports();
            }
        }

        private void LoadReports()
        {
            try
            {
                string search = txtSearch.Text.Trim();
                string status = ddlStatusFilter.SelectedValue;
                string priority = ddlPriorityFilter.SelectedValue;

                string sql = "SELECT ReportId, ReportCode, ReporterEmail, ReportedItem, ReportType, Priority, Details, Status, CreatedAt, ResolvedAt FROM dbo.ModerationReports WHERE 1=1";

                if (!string.IsNullOrEmpty(search))
                {
                    sql += " AND (ReportCode LIKE '%' + @Search + '%' OR ReporterEmail LIKE '%' + @Search + '%' OR ReportedItem LIKE '%' + @Search + '%' OR Details LIKE '%' + @Search + '%')";
                }

                if (!string.IsNullOrEmpty(status))
                {
                    sql += " AND Status = @Status";
                }

                if (!string.IsNullOrEmpty(priority))
                {
                    sql += " AND Priority = @Priority";
                }

                sql += " ORDER BY CASE WHEN Status = 'Pending' THEN 1 ELSE 2 END, CreatedAt DESC";

                SqlParameter[] p = new SqlParameter[]
                {
                    new SqlParameter("@Search", search),
                    new SqlParameter("@Status", status),
                    new SqlParameter("@Priority", priority)
                };

                DataTable dt = DbHelper.ExecuteDataTable(sql, p);
                rptReports.DataSource = dt;
                rptReports.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadReports error: " + ex);
                litAlertMsg.Text = "An error occurred while loading reports.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadReports();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlStatusFilter.SelectedIndex = 0;
            ddlPriorityFilter.SelectedIndex = 0;
            LoadReports();
        }

        protected void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!SecurityHelper.IsUserAdmin())
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            int reportId = Convert.ToInt32(e.CommandArgument);

            try
            {
                if (e.CommandName == "Resolve")
                {
                    string sql = "UPDATE dbo.ModerationReports SET Status = 'Resolved', ResolvedAt = GETDATE() WHERE ReportId = @Id";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", reportId));

                    litAlertMsg.Text = "Ticket successfully marked as <strong>Resolved</strong>.";
                    pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    pnlAlert.Visible = true;
                    LoadReports();
                }
                else if (e.CommandName == "Dismiss")
                {
                    string sql = "UPDATE dbo.ModerationReports SET Status = 'Dismissed', ResolvedAt = GETDATE() WHERE ReportId = @Id";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", reportId));

                    litAlertMsg.Text = "Ticket marked as <strong>Dismissed</strong>.";
                    pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    pnlAlert.Visible = true;
                    LoadReports();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("rptReports_ItemCommand error: " + ex);
                litAlertMsg.Text = "An error occurred while updating the report status.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
        }

        public string GetPriorityBadgeClass(string priority)
        {
            switch (priority)
            {
                case "Urgent": return "badge bg-danger-subtle text-danger";
                case "High": return "badge bg-warning-subtle text-warning";
                case "Normal": return "badge bg-primary-subtle text-primary";
                default: return "badge bg-light text-secondary border";
            }
        }
    }
}
