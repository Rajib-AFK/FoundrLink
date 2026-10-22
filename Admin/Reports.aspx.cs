using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;
using FoundrLink.Services;
using FoundrLink.Services.Interfaces;

namespace FoundrLink.Admin
{
    public partial class Reports : Page
    {
        private readonly IModerationService _moderationService;

        public Reports()
        {
            _moderationService = new ModerationService();
        }

        public Reports(IModerationService moderationService)
        {
            _moderationService = moderationService ?? new ModerationService();
        }

        private int PageIndex
        {
            get { return ViewState["ReportPageIndex"] != null ? (int)ViewState["ReportPageIndex"] : 0; }
            set { ViewState["ReportPageIndex"] = value; }
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

                string countSql = "SELECT COUNT(1) FROM dbo.ModerationReports WHERE 1=1";
                string sql = "SELECT ReportId, ReportCode, ReporterEmail, ReportedItem, ReportType, Priority, Details, Status, CreatedAt, ResolvedAt, ResolutionNotes FROM dbo.ModerationReports WHERE 1=1";

                string filterSql = "";
                if (!string.IsNullOrEmpty(search))
                {
                    filterSql += " AND (ReportCode LIKE '%' + @Search + '%' OR ReporterEmail LIKE '%' + @Search + '%' OR ReportedItem LIKE '%' + @Search + '%' OR Details LIKE '%' + @Search + '%')";
                }

                if (!string.IsNullOrEmpty(status))
                {
                    filterSql += " AND Status = @Status";
                }

                if (!string.IsNullOrEmpty(priority))
                {
                    filterSql += " AND Priority = @Priority";
                }

                countSql += filterSql;
                sql += filterSql + " ORDER BY CASE WHEN Status = 'Pending' THEN 1 ELSE 2 END, CreatedAt DESC OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                int offset = PageIndex * PageSize;

                SqlParameter[] countParams = new SqlParameter[]
                {
                    new SqlParameter("@Search", search),
                    new SqlParameter("@Status", status),
                    new SqlParameter("@Priority", priority)
                };

                int totalCount = Convert.ToInt32(DbHelper.ExecuteScalar(countSql, countParams));

                SqlParameter[] p = new SqlParameter[]
                {
                    new SqlParameter("@Search", search),
                    new SqlParameter("@Status", status),
                    new SqlParameter("@Priority", priority),
                    new SqlParameter("@Offset", offset),
                    new SqlParameter("@PageSize", PageSize)
                };

                DataTable dt = DbHelper.ExecuteDataTable(sql, p);
                rptReports.DataSource = dt;
                rptReports.DataBind();

                pnlNoReports.Visible = (totalCount == 0);
                rptReports.Visible = (totalCount > 0);

                // Update pagination info & controls
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
                System.Diagnostics.Trace.TraceError("LoadReports error: " + ex);
                litAlertMsg.Text = "An error occurred while loading reports.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            PageIndex = 0;
            LoadReports();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            PageIndex = 0;
            txtSearch.Text = string.Empty;
            ddlStatusFilter.SelectedIndex = 0;
            ddlPriorityFilter.SelectedIndex = 0;
            LoadReports();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (PageIndex > 0)
            {
                PageIndex--;
                LoadReports();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            PageIndex++;
            LoadReports();
        }

        protected void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn() || !SecurityHelper.IsUserAdmin())
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            int reportId = Convert.ToInt32(e.CommandArgument);

            try
            {
                if (e.CommandName == "Resolve")
                {
                    string sql = "UPDATE dbo.ModerationReports SET Status = 'Resolved', ResolvedAt = SYSUTCDATETIME(), ResolutionNotes = 'Resolved by platform administrator' WHERE ReportId = @Id";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", reportId));

                    litAlertMsg.Text = "Ticket successfully marked as <strong>Resolved</strong>.";
                    pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    pnlAlert.Visible = true;
                    LoadReports();
                }
                else if (e.CommandName == "Dismiss")
                {
                    string sql = "UPDATE dbo.ModerationReports SET Status = 'Dismissed', ResolvedAt = SYSUTCDATETIME(), ResolutionNotes = 'Dismissed by platform administrator after review' WHERE ReportId = @Id";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", reportId));

                    litAlertMsg.Text = "Ticket marked as <strong>Dismissed</strong>.";
                    pnlAlert.CssClass = "alert alert-secondary py-2 small mb-3";
                    pnlAlert.Visible = true;
                    LoadReports();
                }
                else if (e.CommandName == "Reopen")
                {
                    string sql = "UPDATE dbo.ModerationReports SET Status = 'Pending', ResolvedAt = NULL, ResolutionNotes = 'Reopened for investigation' WHERE ReportId = @Id";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", reportId));

                    litAlertMsg.Text = "Ticket has been <strong>Reopened</strong> for investigation.";
                    pnlAlert.CssClass = "alert alert-warning py-2 small mb-3";
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

        public string GetStatusBadgeClass(object statusObj)
        {
            string status = statusObj?.ToString() ?? "";
            switch (status)
            {
                case "Pending": return "badge bg-warning-subtle text-warning border border-warning-subtle px-2 py-1 small fw-semibold";
                case "Resolved": return "badge bg-success-subtle text-success border border-success-subtle px-2 py-1 small fw-semibold";
                case "Dismissed": return "badge bg-secondary-subtle text-secondary border border-secondary-subtle px-2 py-1 small fw-semibold";
                default: return "badge bg-light text-secondary border px-2 py-1 small fw-semibold";
            }
        }
    }
}
