using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using FoundrLink.Helpers;
using FoundrLink.Models;
using FoundrLink.Services.Interfaces;

namespace FoundrLink.Services
{
    public class StartupService : IStartupService
    {
        public DataTable GetPublishedStartups(string search = null, string industry = null, string stage = null)
        {
            string sql = @"
                SELECT s.StartupId, s.Name, s.Tagline, s.Industry, s.Stage, 
                       COALESCE(NULLIF(s.LogoUrl, ''), 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100') AS LogoUrl, 
                       s.ShortDescription, s.TeamSize, s.RequiredSkills, s.Location, s.WebsiteUrl,
                       COALESCE(u.FullName, 'Founder') AS FounderName, 
                       COALESCE(u.Title, 'Founder & CEO') AS FounderTitle, 
                       COALESCE(NULLIF(u.AvatarUrl, ''), 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100') AS FounderAvatar
                FROM dbo.Startups s
                LEFT JOIN dbo.Users u ON s.FounderId = u.UserId
                WHERE s.Status IN ('Active', 'Approved', 'Published')";

            var paramList = new List<SqlParameter>();

            if (!string.IsNullOrWhiteSpace(search))
            {
                sql += " AND (s.Name LIKE '%' + @Search + '%' OR s.Tagline LIKE '%' + @Search + '%' OR s.ShortDescription LIKE '%' + @Search + '%' OR s.RequiredSkills LIKE '%' + @Search + '%')";
                paramList.Add(new SqlParameter("@Search", search.Trim()));
            }

            if (!string.IsNullOrWhiteSpace(industry) && industry != "All")
            {
                sql += " AND s.Industry = @Industry";
                paramList.Add(new SqlParameter("@Industry", industry.Trim()));
            }

            if (!string.IsNullOrWhiteSpace(stage) && stage != "All")
            {
                sql += " AND s.Stage = @Stage";
                paramList.Add(new SqlParameter("@Stage", stage.Trim()));
            }

            sql += " ORDER BY s.StartupId DESC";
            return DbHelper.ExecuteDataTable(sql, paramList.ToArray());
        }

        public Startup GetStartupById(int startupId)
        {
            if (startupId <= 0) return null;

            string sql = @"
                SELECT s.StartupId, s.FounderId, s.Name, s.Tagline, s.Industry, s.Stage, s.LogoUrl, 
                       s.ShortDescription, s.FullPitch, s.PitchDeckUrl, s.WebsiteUrl, s.Location, 
                       s.TeamSize, s.FundingRaised, s.FundingGoal, s.RequiredSkills, s.Status, 
                       s.CreatedAt, s.UpdatedAt,
                       u.FullName AS FounderName, u.Title AS FounderTitle, u.AvatarUrl AS FounderAvatar
                FROM dbo.Startups s
                LEFT JOIN dbo.Users u ON s.FounderId = u.UserId
                WHERE s.StartupId = @Id";

            DataTable dt = DbHelper.ExecuteDataTable(sql, DbHelper.CreateParam("@Id", SqlDbType.Int, startupId));
            if (dt == null || dt.Rows.Count == 0) return null;

            DataRow r = dt.Rows[0];
            return new Startup
            {
                StartupId = Convert.ToInt32(r["StartupId"]),
                FounderId = r["FounderId"] != DBNull.Value ? Convert.ToInt32(r["FounderId"]) : 0,
                Name = r["Name"]?.ToString(),
                Tagline = r["Tagline"]?.ToString(),
                Industry = r["Industry"]?.ToString(),
                Stage = r["Stage"]?.ToString(),
                LogoUrl = r["LogoUrl"]?.ToString(),
                ShortDescription = r["ShortDescription"]?.ToString(),
                FullPitch = r["FullPitch"]?.ToString(),
                PitchDeckUrl = r["PitchDeckUrl"]?.ToString(),
                WebsiteUrl = r["WebsiteUrl"]?.ToString(),
                Location = r["Location"]?.ToString(),
                TeamSize = r["TeamSize"] != DBNull.Value ? Convert.ToInt32(r["TeamSize"]) : 1,
                FundingRaised = r["FundingRaised"] != DBNull.Value ? Convert.ToDecimal(r["FundingRaised"]) : 0m,
                FundingGoal = r["FundingGoal"] != DBNull.Value ? Convert.ToDecimal(r["FundingGoal"]) : 0m,
                RequiredSkills = r["RequiredSkills"]?.ToString(),
                Status = r["Status"]?.ToString(),
                CreatedAt = r["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(r["CreatedAt"]) : DateTime.UtcNow,
                UpdatedAt = r["UpdatedAt"] != DBNull.Value ? Convert.ToDateTime(r["UpdatedAt"]) : DateTime.UtcNow,
                FounderName = r["FounderName"]?.ToString(),
                FounderTitle = r["FounderTitle"]?.ToString(),
                FounderAvatar = r["FounderAvatar"]?.ToString()
            };
        }

        public ServiceResult UpdateStartupStatus(int startupId, string status)
        {
            if (startupId <= 0) return ServiceResult.Fail("Invalid startup identifier.");
            if (string.IsNullOrWhiteSpace(status)) return ServiceResult.Fail("Status cannot be empty.");

            try
            {
                string sql = "UPDATE dbo.Startups SET Status = @Status, UpdatedAt = SYSUTCDATETIME() WHERE StartupId = @Id";
                int rows = DbHelper.ExecuteNonQuery(sql,
                    DbHelper.CreateParam("@Status", SqlDbType.NVarChar, status.Trim()),
                    DbHelper.CreateParam("@Id", SqlDbType.Int, startupId));

                return rows > 0 ? ServiceResult.Ok("Startup status updated.") : ServiceResult.Fail("Startup not found or unchanged.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("UpdateStartupStatus error: " + ex);
                return ServiceResult.Fail("Error updating startup status: " + ex.Message);
            }
        }
    }
}
