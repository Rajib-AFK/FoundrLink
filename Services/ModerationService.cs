using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using FoundrLink.Helpers;
using FoundrLink.Models;
using FoundrLink.Services.Interfaces;

namespace FoundrLink.Services
{
    public class ModerationService : IModerationService
    {
        public DataTable GetReportsDataTable(string search = null, string status = null, string priority = null)
        {
            string sql = "SELECT ReportId, ReportCode, ReporterEmail, ReportedItem, ReportType, Priority, Details, Status, CreatedAt, ResolvedAt FROM dbo.ModerationReports WHERE 1=1";

            var paramList = new List<SqlParameter>();

            if (!string.IsNullOrWhiteSpace(search))
            {
                sql += " AND (ReportCode LIKE '%' + @Search + '%' OR ReporterEmail LIKE '%' + @Search + '%' OR ReportedItem LIKE '%' + @Search + '%' OR Details LIKE '%' + @Search + '%')";
                paramList.Add(new SqlParameter("@Search", search.Trim()));
            }

            if (!string.IsNullOrWhiteSpace(status))
            {
                sql += " AND Status = @Status";
                paramList.Add(new SqlParameter("@Status", status.Trim()));
            }

            if (!string.IsNullOrWhiteSpace(priority))
            {
                sql += " AND Priority = @Priority";
                paramList.Add(new SqlParameter("@Priority", priority.Trim()));
            }

            sql += " ORDER BY CASE WHEN Status = 'Pending' THEN 1 ELSE 2 END, CreatedAt DESC";

            return DbHelper.ExecuteDataTable(sql, paramList.ToArray());
        }

        public List<ModerationReport> GetReports(string search = null, string status = null, string priority = null)
        {
            var dt = GetReportsDataTable(search, status, priority);
            var list = new List<ModerationReport>();

            if (dt != null)
            {
                foreach (DataRow row in dt.Rows)
                {
                    list.Add(new ModerationReport
                    {
                        ReportId = Convert.ToInt32(row["ReportId"]),
                        ReportCode = row["ReportCode"]?.ToString(),
                        ReporterEmail = row["ReporterEmail"]?.ToString(),
                        ReportedItem = row["ReportedItem"]?.ToString(),
                        ReportType = row["ReportType"]?.ToString(),
                        Priority = row["Priority"]?.ToString(),
                        Details = row["Details"]?.ToString(),
                        Status = row["Status"]?.ToString(),
                        CreatedAt = row["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(row["CreatedAt"]) : DateTime.UtcNow,
                        ResolvedAt = row["ResolvedAt"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(row["ResolvedAt"]) : null
                    });
                }
            }

            return list;
        }

        public ServiceResult ResolveReport(int reportId)
        {
            if (reportId <= 0)
                return ServiceResult.Fail("Invalid report identifier.");

            try
            {
                string sql = "UPDATE dbo.ModerationReports SET Status = 'Resolved', ResolvedAt = GETDATE() WHERE ReportId = @Id";
                int rows = DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", reportId));
                return rows > 0 
                    ? ServiceResult.Ok("Ticket marked as Resolved.") 
                    : ServiceResult.Fail("Report could not be found or was not updated.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("ResolveReport error: " + ex);
                return ServiceResult.Fail("An error occurred while resolving the report: " + ex.Message);
            }
        }

        public ServiceResult DismissReport(int reportId)
        {
            if (reportId <= 0)
                return ServiceResult.Fail("Invalid report identifier.");

            try
            {
                string sql = "UPDATE dbo.ModerationReports SET Status = 'Dismissed', ResolvedAt = GETDATE() WHERE ReportId = @Id";
                int rows = DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", reportId));
                return rows > 0 
                    ? ServiceResult.Ok("Ticket marked as Dismissed.") 
                    : ServiceResult.Fail("Report could not be found or was not updated.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("DismissReport error: " + ex);
                return ServiceResult.Fail("An error occurred while dismissing the report: " + ex.Message);
            }
        }

        public ServiceResult SubmitTicket(string reporterEmail, string category, string priority, string subject, string details, out string reportCode)
        {
            reportCode = "TKT-" + new Random().Next(1000, 9999);

            if (string.IsNullOrWhiteSpace(reporterEmail))
                reporterEmail = "user@ripaldesign.studio";

            if (string.IsNullOrWhiteSpace(subject))
                return ServiceResult.Fail("Ticket subject is required.");

            if (string.IsNullOrWhiteSpace(details))
                return ServiceResult.Fail("Ticket details are required.");

            try
            {
                string sql = @"
                    INSERT INTO dbo.ModerationReports 
                    (ReportCode, ReporterEmail, ReportedItem, ReportType, Priority, Details, Status, CreatedAt)
                    VALUES 
                    (@ReportCode, @Email, @Subject, @Category, @Priority, @Details, 'Pending', GETDATE());";

                SqlParameter[] p = new SqlParameter[]
                {
                    new SqlParameter("@ReportCode", reportCode),
                    new SqlParameter("@Email", reporterEmail.Trim()),
                    new SqlParameter("@Subject", subject.Trim()),
                    new SqlParameter("@Category", category ?? "General Inquiry"),
                    new SqlParameter("@Priority", priority ?? "Normal"),
                    new SqlParameter("@Details", details.Trim())
                };

                int rows = DbHelper.ExecuteNonQuery(sql, p);
                return rows > 0 
                    ? ServiceResult.Ok("Ticket submitted successfully.") 
                    : ServiceResult.Fail("Failed to persist ticket.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("SubmitTicket error: " + ex);
                return ServiceResult.Fail("An error occurred while logging the ticket: " + ex.Message);
            }
        }
    }
}
