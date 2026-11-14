using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using FoundrLink.Core.Interfaces;
using FoundrLink.Core.Models;

namespace FoundrLink.DataAccess
{
    public class AdminRepository : IAdminRepository
    {
        public AdminDashboardMetrics GetDashboardMetrics()
        {
            var metrics = new AdminDashboardMetrics();
            const string sql = @"
                SELECT
                    (SELECT COUNT(*) FROM dbo.Users WHERE Status = 'Active') AS TotalUsers,
                    (SELECT COUNT(*) FROM dbo.Startups WHERE Status IN ('Active', 'Approved')) AS ActiveStartups,
                    (SELECT COUNT(*) FROM dbo.ModerationReports WHERE Status = 'Pending') AS PendingReports,
                    (SELECT COUNT(*) FROM dbo.ConnectionRequests) AS TotalMatchRequests,
                    (SELECT ISNULL(SUM(FundingRaised), 0) FROM dbo.Startups) AS TotalCapitalDeployed;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            using (var reader = cmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    metrics.TotalUsers = Convert.ToInt32(reader["TotalUsers"]);
                    metrics.ActiveStartups = Convert.ToInt32(reader["ActiveStartups"]);
                    metrics.PendingReports = Convert.ToInt32(reader["PendingReports"]);
                    metrics.TotalMatchRequests = Convert.ToInt32(reader["TotalMatchRequests"]);
                    metrics.TotalCapitalDeployed = Convert.ToDecimal(reader["TotalCapitalDeployed"]);
                }
            }
            return metrics;
        }

        public List<BaseUser> GetRecentRegistrations(int limit = 10)
        {
            var list = new List<BaseUser>();
            const string sql = @"
                SELECT TOP (@Limit) UserId, FullName, Email, Role, Title, Location, Bio, Company, AvatarUrl, IsVerified, Status, CreatedAt, UpdatedAt
                FROM dbo.Users
                ORDER BY CreatedAt DESC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Limit", limit);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(MapUser(reader));
                    }
                }
            }
            return list;
        }

        public List<Startup> GetStartupSubmissions(string status = null)
        {
            var list = new List<Startup>();
            var sql = @"
                SELECT s.StartupId, s.FounderId, s.Name, s.Tagline, s.Industry, s.Stage, s.LogoUrl,
                       s.ShortDescription, s.FullDescription, s.Problem, s.Solution, s.TeamSize,
                       s.RequiredSkills, s.Location, s.WebsiteUrl, s.Commitment, s.FoundedYear,
                       s.FundingRaised, s.FundingGoal, s.MRR, s.Status, s.CreatedAt, s.UpdatedAt,
                       u.FullName AS FounderName, u.Title AS FounderTitle, u.AvatarUrl AS FounderAvatar
                FROM dbo.Startups s
                INNER JOIN dbo.Users u ON s.FounderId = u.UserId ";

            if (!string.IsNullOrWhiteSpace(status) && !status.Equals("All", StringComparison.OrdinalIgnoreCase))
            {
                sql += " WHERE s.Status = @Status ";
            }
            sql += " ORDER BY s.CreatedAt DESC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (!string.IsNullOrWhiteSpace(status) && !status.Equals("All", StringComparison.OrdinalIgnoreCase))
                {
                    cmd.Parameters.AddWithValue("@Status", status.Trim());
                }

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new Startup
                        {
                            StartupId = Convert.ToInt32(reader["StartupId"]),
                            FounderId = Convert.ToInt32(reader["FounderId"]),
                            FounderName = reader["FounderName"]?.ToString() ?? string.Empty,
                            FounderTitle = reader["FounderTitle"]?.ToString() ?? string.Empty,
                            FounderAvatar = reader["FounderAvatar"]?.ToString() ?? string.Empty,
                            Name = reader["Name"].ToString(),
                            Tagline = reader["Tagline"]?.ToString() ?? string.Empty,
                            Industry = reader["Industry"]?.ToString() ?? "AI/ML",
                            Stage = reader["Stage"]?.ToString() ?? "Seed Stage",
                            LogoUrl = reader["LogoUrl"]?.ToString() ?? string.Empty,
                            ShortDescription = reader["ShortDescription"]?.ToString() ?? string.Empty,
                            FullDescription = reader["FullDescription"]?.ToString() ?? string.Empty,
                            Problem = reader["Problem"]?.ToString() ?? string.Empty,
                            Solution = reader["Solution"]?.ToString() ?? string.Empty,
                            TeamSize = Convert.ToInt32(reader["TeamSize"]),
                            RequiredSkills = reader["RequiredSkills"]?.ToString() ?? string.Empty,
                            Location = reader["Location"]?.ToString() ?? string.Empty,
                            WebsiteUrl = reader["WebsiteUrl"]?.ToString() ?? string.Empty,
                            Commitment = reader["Commitment"]?.ToString() ?? "Full-time / Equity",
                            FoundedYear = Convert.ToInt32(reader["FoundedYear"]),
                            FundingRaised = Convert.ToDecimal(reader["FundingRaised"]),
                            FundingGoal = Convert.ToDecimal(reader["FundingGoal"]),
                            MRR = Convert.ToDecimal(reader["MRR"]),
                            Status = reader["Status"]?.ToString() ?? "Active",
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"]),
                            UpdatedAt = Convert.ToDateTime(reader["UpdatedAt"])
                        });
                    }
                }
            }
            return list;
        }

        public bool UpdateStartupStatus(int startupId, string newStatus)
        {
            const string sql = "UPDATE dbo.Startups SET Status = @Status, UpdatedAt = SYSUTCDATETIME() WHERE StartupId = @StartupId;";
            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Status", newStatus.Trim());
                cmd.Parameters.AddWithValue("@StartupId", startupId);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public List<BaseUser> GetManageUsersList(string search = null, string role = null, string status = null)
        {
            var list = new List<BaseUser>();
            var sql = @"
                SELECT UserId, FullName, Email, Role, Title, Location, Bio, Company, AvatarUrl, IsVerified, Status, CreatedAt, UpdatedAt
                FROM dbo.Users
                WHERE 1=1 ";

            if (!string.IsNullOrWhiteSpace(search))
            {
                sql += " AND (FullName LIKE '%' + @Search + '%' OR Email LIKE '%' + @Search + '%') ";
            }
            if (!string.IsNullOrWhiteSpace(role) && !role.Equals("All Roles", StringComparison.OrdinalIgnoreCase))
            {
                sql += " AND Role = @Role ";
            }
            if (!string.IsNullOrWhiteSpace(status) && !status.Equals("All Statuses", StringComparison.OrdinalIgnoreCase))
            {
                sql += " AND Status = @Status ";
            }
            sql += " ORDER BY CreatedAt DESC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@Search", search.Trim());
                if (!string.IsNullOrWhiteSpace(role) && !role.Equals("All Roles", StringComparison.OrdinalIgnoreCase))
                    cmd.Parameters.AddWithValue("@Role", role.Trim());
                if (!string.IsNullOrWhiteSpace(status) && !status.Equals("All Statuses", StringComparison.OrdinalIgnoreCase))
                    cmd.Parameters.AddWithValue("@Status", status.Trim());

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(MapUser(reader));
                    }
                }
            }
            return list;
        }

        public bool UpdateUserStatus(int userId, string newStatus)
        {
            const string sql = "UPDATE dbo.Users SET Status = @Status, UpdatedAt = SYSUTCDATETIME() WHERE UserId = @UserId;";
            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Status", newStatus.Trim());
                cmd.Parameters.AddWithValue("@UserId", userId);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public List<ModerationReport> GetModerationReports(string typeFilter = "All")
        {
            var list = new List<ModerationReport>();
            var sql = @"
                SELECT ReportId, ReportCode, ReporterEmail, ReportedItem, ReportType, Priority, Details, Status, CreatedAt, ResolvedAt
                FROM dbo.ModerationReports ";

            if (!string.IsNullOrWhiteSpace(typeFilter) && !typeFilter.Equals("All", StringComparison.OrdinalIgnoreCase) && !typeFilter.Equals("All Types", StringComparison.OrdinalIgnoreCase))
            {
                sql += " WHERE ReportType = @Type ";
            }
            sql += " ORDER BY CASE WHEN Status = 'Pending' THEN 0 ELSE 1 END, CreatedAt DESC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (!string.IsNullOrWhiteSpace(typeFilter) && !typeFilter.Equals("All", StringComparison.OrdinalIgnoreCase) && !typeFilter.Equals("All Types", StringComparison.OrdinalIgnoreCase))
                {
                    cmd.Parameters.AddWithValue("@Type", typeFilter.Trim());
                }

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new ModerationReport
                        {
                            ReportId = Convert.ToInt32(reader["ReportId"]),
                            ReportCode = reader["ReportCode"].ToString(),
                            ReporterEmail = reader["ReporterEmail"].ToString(),
                            ReportedItem = reader["ReportedItem"].ToString(),
                            ReportType = reader["ReportType"].ToString(),
                            Priority = reader["Priority"]?.ToString() ?? "Medium",
                            Details = reader["Details"]?.ToString() ?? string.Empty,
                            Status = reader["Status"].ToString(),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"]),
                            ResolvedAt = reader["ResolvedAt"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(reader["ResolvedAt"]) : null
                        });
                    }
                }
            }
            return list;
        }

        public bool ResolveModerationReport(int reportId, string action)
        {
            const string sql = @"
                UPDATE dbo.ModerationReports
                SET Status = 'Resolved',
                    ResolvedAt = SYSUTCDATETIME(),
                    Details = ISNULL(Details, '') + ' [Action: ' + @Action + ']'
                WHERE ReportId = @ReportId;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ReportId", reportId);
                cmd.Parameters.AddWithValue("@Action", action);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        private static bool HasColumn(IDataRecord reader, string columnName)
        {
            for (int i = 0; i < reader.FieldCount; i++)
            {
                if (reader.GetName(i).Equals(columnName, StringComparison.OrdinalIgnoreCase))
                    return true;
            }
            return false;
        }

        private static BaseUser MapUser(SqlDataReader reader)
        {
            string roleStr = reader["Role"]?.ToString() ?? "Founder";
            BaseUser user;

            switch (roleStr)
            {
                case "Investor":
                    user = new Investor();
                    break;
                case "CoFounder":
                case "Co-Founder":
                    user = new CoFounderUser();
                    break;
                case "Admin":
                    user = new AdminUser();
                    break;
                case "Founder":
                default:
                    user = new Founder();
                    break;
            }

            user.UserId = Convert.ToInt32(reader["UserId"]);
            user.FullName = reader["FullName"]?.ToString() ?? string.Empty;
            user.Email = reader["Email"]?.ToString() ?? string.Empty;
            user.PasswordHash = HasColumn(reader, "PasswordHash") ? (reader["PasswordHash"]?.ToString() ?? string.Empty) : string.Empty;
            user.Title = reader["Title"]?.ToString() ?? string.Empty;
            user.Location = reader["Location"]?.ToString() ?? string.Empty;
            user.Bio = reader["Bio"]?.ToString() ?? string.Empty;
            user.Company = reader["Company"]?.ToString() ?? string.Empty;
            user.AvatarUrl = reader["AvatarUrl"]?.ToString() ?? string.Empty;
            user.IsVerified = reader["IsVerified"] != DBNull.Value && Convert.ToBoolean(reader["IsVerified"]);

            string statusStr = reader["Status"]?.ToString() ?? "Active";
            if (Enum.TryParse(statusStr, true, out UserStatus st))
                user.Status = st;
            else
                user.Status = UserStatus.Active;

            user.CreatedAt = Convert.ToDateTime(reader["CreatedAt"]);
            user.UpdatedAt = Convert.ToDateTime(reader["UpdatedAt"]);

            return user;
        }
    }
}
