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
            pnlAlert.Visible = false;

            if (!IsPostBack)
            {
                LoadReports();
            }
        }

        private void LoadReports()
        {
            string search = txtSearch.Text.Trim();
            string status = ddlStatusFilter.SelectedValue;
            string priority = ddlPriorityFilter.SelectedValue;

            string sql = "SELECT ReportId, ReportCode, ReporterEmail, ReportedItem, ReportType, Priority, Details, Status, CreatedAt, ResolvedAt FROM ModerationReports WHERE 1=1";

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
            int reportId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Resolve")
            {
                string sql = "UPDATE ModerationReports SET Status = 'Resolved', ResolvedAt = GETDATE() WHERE ReportId = @Id";
                DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", reportId));

                litAlertMsg.Text = "Ticket successfully marked as <strong>Resolved</strong>.";
                pnlAlert.Visible = true;
                LoadReports();
            }
            else if (e.CommandName == "Dismiss")
            {
                string sql = "UPDATE ModerationReports SET Status = 'Dismissed', ResolvedAt = GETDATE() WHERE ReportId = @Id";
                DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", reportId));

                litAlertMsg.Text = "Ticket marked as <strong>Dismissed</strong>.";
                pnlAlert.Visible = true;
                LoadReports();
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
