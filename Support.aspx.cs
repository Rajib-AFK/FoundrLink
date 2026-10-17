using System;
using System.Data.SqlClient;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class Support : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            pnlAlertSuccess.Visible = false;
        }

        protected void btnSubmitTicket_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = Session["Email"]?.ToString() ?? "user@foundrlink.com";
            string category = ddlCategory.SelectedValue;
            string priority = ddlPriority.SelectedValue;
            string subject = txtSubject.Text.Trim();
            string details = txtDetails.Text.Trim();
            string reportCode = "TKT-" + new Random().Next(1000, 9999);

            // Insert into ModerationReports table
            string sql = @"
                INSERT INTO ModerationReports 
                (ReportCode, ReporterEmail, ReportedItem, ReportType, Priority, Details, Status, CreatedAt)
                VALUES 
                (@ReportCode, @Email, @Subject, @Category, @Priority, @Details, 'Pending', GETDATE());
            ";

            SqlParameter[] p = new SqlParameter[]
            {
                new SqlParameter("@ReportCode", reportCode),
                new SqlParameter("@Email", email),
                new SqlParameter("@Subject", subject),
                new SqlParameter("@Category", category),
                new SqlParameter("@Priority", priority),
                new SqlParameter("@Details", details)
            };

            DbHelper.ExecuteNonQuery(sql, p);

            litAlertSuccess.Text = $"Your ticket <strong>{reportCode}</strong> has been logged. An operations representative has been assigned.";
            pnlAlertSuccess.Visible = true;

            txtSubject.Text = string.Empty;
            txtDetails.Text = string.Empty;
        }
    }
}
