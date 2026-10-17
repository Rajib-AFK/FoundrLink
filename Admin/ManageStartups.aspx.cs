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
            pnlAlert.Visible = false;

            if (!IsPostBack)
            {
                LoadStartups();
            }
        }

        private void LoadStartups()
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
                FROM Startups s
                INNER JOIN Users u ON s.FounderId = u.UserId
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
            int startupId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "TogglePublish")
            {
                string sql = "UPDATE Startups SET Status = CASE WHEN Status = 'Published' THEN 'Draft' ELSE 'Published' END WHERE StartupId = @Id";
                DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", startupId));

                litAlertMsg.Text = "Startup visibility status updated successfully.";
                pnlAlert.Visible = true;
                LoadStartups();
            }
            else if (e.CommandName == "DeleteStartup")
            {
                // Delete references first
                DbHelper.ExecuteNonQuery("DELETE FROM TeamMembers WHERE StartupId = @Id", new SqlParameter("@Id", startupId));
                DbHelper.ExecuteNonQuery("DELETE FROM OpenPositions WHERE StartupId = @Id", new SqlParameter("@Id", startupId));
                DbHelper.ExecuteNonQuery("DELETE FROM ConnectionRequests WHERE StartupId = @Id", new SqlParameter("@Id", startupId));
                DbHelper.ExecuteNonQuery("DELETE FROM Startups WHERE StartupId = @Id", new SqlParameter("@Id", startupId));

                litAlertMsg.Text = "Startup and related records permanently deleted.";
                pnlAlert.Visible = true;
                LoadStartups();
            }
        }
    }
}
