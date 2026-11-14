using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using FoundrLink.Core.Interfaces;
using FoundrLink.Core.Models;
using FoundrLink.Helpers;

namespace FoundrLink.DataAccess
{
    public class StartupRepository : IStartupRepository
    {
        public Startup GetStartupById(int startupId)
        {
            const string sql = @"
                SELECT s.StartupId, s.FounderId, s.Name, s.Tagline, s.Industry, s.Stage, s.LogoUrl,
                       s.ShortDescription, s.FullDescription, s.Problem, s.Solution, s.TeamSize,
                       s.RequiredSkills, s.Location, s.WebsiteUrl, s.Commitment, s.FoundedYear,
                       s.FundingRaised, s.FundingGoal, s.MRR, s.Status, s.CreatedAt, s.UpdatedAt,
                       u.FullName AS FounderName, u.Title AS FounderTitle, u.AvatarUrl AS FounderAvatar
                FROM dbo.Startups s
                INNER JOIN dbo.Users u ON s.FounderId = u.UserId
                WHERE s.StartupId = @StartupId;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartupId", startupId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        var startup = MapStartup(reader);
                        reader.Close();

                        startup.OpenPositions = GetOpenPositionsInternal(startupId, conn);
                        startup.TeamMembers = GetTeamMembersInternal(startupId, conn);
                        return startup;
                    }
                }
            }
            return null;
        }

        public List<Startup> GetStartups(string search = null, string industry = null, string stage = null, string skill = null, string sortBy = "Best Match")
        {
            var list = new List<Startup>();
            var sql = @"
                SELECT s.StartupId, s.FounderId, s.Name, s.Tagline, s.Industry, s.Stage, s.LogoUrl,
                       s.ShortDescription, s.FullDescription, s.Problem, s.Solution, s.TeamSize,
                       s.RequiredSkills, s.Location, s.WebsiteUrl, s.Commitment, s.FoundedYear,
                       s.FundingRaised, s.FundingGoal, s.MRR, s.Status, s.CreatedAt, s.UpdatedAt,
                       u.FullName AS FounderName, u.Title AS FounderTitle, u.AvatarUrl AS FounderAvatar
                FROM dbo.Startups s
                INNER JOIN dbo.Users u ON s.FounderId = u.UserId
                WHERE s.Status IN ('Active', 'Approved') ";

            if (!string.IsNullOrWhiteSpace(search))
            {
                sql += " AND (s.Name LIKE '%' + @Search + '%' OR s.Tagline LIKE '%' + @Search + '%' OR s.ShortDescription LIKE '%' + @Search + '%' OR s.RequiredSkills LIKE '%' + @Search + '%')";
            }
            if (!string.IsNullOrWhiteSpace(industry) && !industry.Equals("All Industries", StringComparison.OrdinalIgnoreCase))
            {
                sql += " AND s.Industry = @Industry";
            }
            if (!string.IsNullOrWhiteSpace(stage) && !stage.Equals("All Stages", StringComparison.OrdinalIgnoreCase))
            {
                sql += " AND s.Stage = @Stage";
            }
            if (!string.IsNullOrWhiteSpace(skill) && !skill.Equals("All Skills", StringComparison.OrdinalIgnoreCase))
            {
                sql += " AND s.RequiredSkills LIKE '%' + @Skill + '%'";
            }

            switch (sortBy)
            {
                case "Team Size":
                    sql += " ORDER BY s.TeamSize DESC";
                    break;
                case "Newest":
                    sql += " ORDER BY s.CreatedAt DESC";
                    break;
                case "Funding":
                    sql += " ORDER BY s.FundingRaised DESC";
                    break;
                default: // Best Match / Default
                    sql += " ORDER BY s.FoundedYear DESC, s.FundingRaised DESC";
                    break;
            }

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@Search", search.Trim());
                if (!string.IsNullOrWhiteSpace(industry) && !industry.Equals("All Industries", StringComparison.OrdinalIgnoreCase))
                    cmd.Parameters.AddWithValue("@Industry", industry.Trim());
                if (!string.IsNullOrWhiteSpace(stage) && !stage.Equals("All Stages", StringComparison.OrdinalIgnoreCase))
                    cmd.Parameters.AddWithValue("@Stage", stage.Trim());
                if (!string.IsNullOrWhiteSpace(skill) && !skill.Equals("All Skills", StringComparison.OrdinalIgnoreCase))
                    cmd.Parameters.AddWithValue("@Skill", skill.Trim());

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(MapStartup(reader));
                    }
                }
            }
            return list;
        }

        public List<Startup> GetStartupsByFounder(int founderId)
        {
            var list = new List<Startup>();
            const string sql = @"
                SELECT s.StartupId, s.FounderId, s.Name, s.Tagline, s.Industry, s.Stage, s.LogoUrl,
                       s.ShortDescription, s.FullDescription, s.Problem, s.Solution, s.TeamSize,
                       s.RequiredSkills, s.Location, s.WebsiteUrl, s.Commitment, s.FoundedYear,
                       s.FundingRaised, s.FundingGoal, s.MRR, s.Status, s.CreatedAt, s.UpdatedAt,
                       u.FullName AS FounderName, u.Title AS FounderTitle, u.AvatarUrl AS FounderAvatar
                FROM dbo.Startups s
                INNER JOIN dbo.Users u ON s.FounderId = u.UserId
                WHERE s.FounderId = @FounderId
                ORDER BY s.CreatedAt DESC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@FounderId", founderId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(MapStartup(reader));
                    }
                }
            }
            return list;
        }

        public List<Startup> GetFeaturedStartups(int limit = 3)
        {
            var list = new List<Startup>();
            const string sql = @"
                SELECT TOP (@Limit) s.StartupId, s.FounderId, s.Name, s.Tagline, s.Industry, s.Stage, s.LogoUrl,
                       s.ShortDescription, s.FullDescription, s.Problem, s.Solution, s.TeamSize,
                       s.RequiredSkills, s.Location, s.WebsiteUrl, s.Commitment, s.FoundedYear,
                       s.FundingRaised, s.FundingGoal, s.MRR, s.Status, s.CreatedAt, s.UpdatedAt,
                       u.FullName AS FounderName, u.Title AS FounderTitle, u.AvatarUrl AS FounderAvatar
                FROM dbo.Startups s
                INNER JOIN dbo.Users u ON s.FounderId = u.UserId
                WHERE s.Status IN ('Active', 'Approved') AND s.FundingGoal > 0
                ORDER BY s.FundingRaised DESC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Limit", limit);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(MapStartup(reader));
                    }
                }
            }
            return list;
        }

        public int CreateStartup(Startup startup)
        {
            const string sql = @"
                INSERT INTO dbo.Startups
                (FounderId, Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, FullDescription, Problem, Solution, TeamSize, RequiredSkills, Location, WebsiteUrl, Commitment, FoundedYear, FundingRaised, FundingGoal, MRR, Status)
                VALUES
                (@FounderId, @Name, @Tagline, @Industry, @Stage, @LogoUrl, @ShortDescription, @FullDescription, @Problem, @Solution, @TeamSize, @RequiredSkills, @Location, @WebsiteUrl, @Commitment, @FoundedYear, @FundingRaised, @FundingGoal, @MRR, @Status);
                SELECT SCOPE_IDENTITY();";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var transaction = conn.BeginTransaction())
            {
                try
                {
                    using (var cmd = new SqlCommand(sql, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@FounderId", startup.FounderId);
                        cmd.Parameters.AddWithValue("@Name", startup.Name);
                        cmd.Parameters.AddWithValue("@Tagline", (object)startup.Tagline ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Industry", startup.Industry ?? "AI/ML");
                        cmd.Parameters.AddWithValue("@Stage", startup.Stage ?? "Seed Stage");
                        cmd.Parameters.AddWithValue("@LogoUrl", (object)startup.LogoUrl ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ShortDescription", (object)startup.ShortDescription ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@FullDescription", (object)startup.FullDescription ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Problem", (object)startup.Problem ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Solution", (object)startup.Solution ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@TeamSize", startup.TeamSize);
                        cmd.Parameters.AddWithValue("@RequiredSkills", (object)startup.RequiredSkills ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Location", (object)startup.Location ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@WebsiteUrl", (object)startup.WebsiteUrl ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Commitment", (object)startup.Commitment ?? "Full-time / Equity");
                        cmd.Parameters.AddWithValue("@FoundedYear", startup.FoundedYear);
                        cmd.Parameters.AddWithValue("@FundingRaised", startup.FundingRaised);
                        cmd.Parameters.AddWithValue("@FundingGoal", startup.FundingGoal);
                        cmd.Parameters.AddWithValue("@MRR", startup.MRR);
                        cmd.Parameters.AddWithValue("@Status", startup.Status ?? "Active");

                        int newId = Convert.ToInt32(cmd.ExecuteScalar());
                        startup.StartupId = newId;

                        // Add any open positions within same transaction
                        if (startup.OpenPositions != null && startup.OpenPositions.Count > 0)
                        {
                            const string posSql = @"
                                INSERT INTO dbo.OpenPositions (StartupId, Title, Location, PositionType)
                                VALUES (@StartupId, @Title, @Location, @Type);";

                            foreach (var pos in startup.OpenPositions)
                            {
                                using (var posCmd = new SqlCommand(posSql, conn, transaction))
                                {
                                    posCmd.Parameters.AddWithValue("@StartupId", newId);
                                    posCmd.Parameters.AddWithValue("@Title", pos.Title.Trim());
                                    posCmd.Parameters.AddWithValue("@Location", string.IsNullOrWhiteSpace(pos.Location) ? "Remote" : pos.Location.Trim());
                                    posCmd.Parameters.AddWithValue("@Type", string.IsNullOrWhiteSpace(pos.PositionType) ? "Full-time" : pos.PositionType.Trim());
                                    posCmd.ExecuteNonQuery();
                                }
                            }
                        }

                        transaction.Commit();
                        return newId;
                    }
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }
        }

        public bool UpdateStartup(Startup startup, int currentUserId = 0, bool isAdmin = false)
        {
            int effectiveUserId = currentUserId != 0 ? currentUserId : (SecurityHelper.GetCurrentUserId() ?? startup.FounderId);
            bool effectiveIsAdmin = isAdmin || SecurityHelper.IsUserAdmin();

            const string sql = @"
                UPDATE dbo.Startups
                SET Name = @Name,
                    Tagline = @Tagline,
                    Industry = @Industry,
                    Stage = @Stage,
                    LogoUrl = @LogoUrl,
                    ShortDescription = @ShortDescription,
                    FullDescription = @FullDescription,
                    Problem = @Problem,
                    Solution = @Solution,
                    TeamSize = @TeamSize,
                    RequiredSkills = @RequiredSkills,
                    Location = @Location,
                    WebsiteUrl = @WebsiteUrl,
                    Commitment = @Commitment,
                    Status = @Status,
                    UpdatedAt = SYSUTCDATETIME()
                WHERE StartupId = @StartupId AND (FounderId = @CurrentUserId OR @IsAdmin = 1);";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartupId", startup.StartupId);
                cmd.Parameters.AddWithValue("@CurrentUserId", effectiveUserId);
                cmd.Parameters.AddWithValue("@IsAdmin", effectiveIsAdmin ? 1 : 0);
                cmd.Parameters.AddWithValue("@Name", startup.Name);
                cmd.Parameters.AddWithValue("@Tagline", (object)startup.Tagline ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Industry", startup.Industry ?? "AI/ML");
                cmd.Parameters.AddWithValue("@Stage", startup.Stage ?? "Seed Stage");
                cmd.Parameters.AddWithValue("@LogoUrl", (object)startup.LogoUrl ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ShortDescription", (object)startup.ShortDescription ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@FullDescription", (object)startup.FullDescription ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Problem", (object)startup.Problem ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Solution", (object)startup.Solution ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TeamSize", startup.TeamSize);
                cmd.Parameters.AddWithValue("@RequiredSkills", (object)startup.RequiredSkills ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Location", (object)startup.Location ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@WebsiteUrl", (object)startup.WebsiteUrl ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Commitment", (object)startup.Commitment ?? "Full-time / Equity");
                cmd.Parameters.AddWithValue("@Status", startup.Status ?? "Active");

                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public bool DeleteStartup(int startupId, int currentUserId = 0, bool isAdmin = false)
        {
            int effectiveUserId = currentUserId != 0 ? currentUserId : (SecurityHelper.GetCurrentUserId() ?? 0);
            bool effectiveIsAdmin = isAdmin || SecurityHelper.IsUserAdmin();

            const string sql = "DELETE FROM dbo.Startups WHERE StartupId = @StartupId AND (FounderId = @CurrentUserId OR @IsAdmin = 1);";
            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartupId", startupId);
                cmd.Parameters.AddWithValue("@CurrentUserId", effectiveUserId);
                cmd.Parameters.AddWithValue("@IsAdmin", effectiveIsAdmin ? 1 : 0);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public List<OpenPosition> GetOpenPositions(int startupId)
        {
            using (var conn = DbConnectionFactory.OpenConnection())
            {
                return GetOpenPositionsInternal(startupId, conn);
            }
        }

        public List<TeamMember> GetTeamMembers(int startupId)
        {
            using (var conn = DbConnectionFactory.OpenConnection())
            {
                return GetTeamMembersInternal(startupId, conn);
            }
        }

        public List<StartupUpdate> GetStartupUpdates(int startupId)
        {
            var list = new List<StartupUpdate>();
            const string sql = @"
                SELECT UpdateId, StartupId, AuthorName, Content, CreatedAt
                FROM dbo.StartupUpdates
                WHERE StartupId = @StartupId
                ORDER BY CreatedAt DESC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartupId", startupId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new StartupUpdate
                        {
                            UpdateId = Convert.ToInt32(reader["UpdateId"]),
                            StartupId = Convert.ToInt32(reader["StartupId"]),
                            AuthorName = reader["AuthorName"].ToString(),
                            Content = reader["Content"].ToString(),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }
            return list;
        }

        public bool AddOpenPosition(int startupId, string title, string location, string type)
        {
            const string sql = @"
                INSERT INTO dbo.OpenPositions (StartupId, Title, Location, PositionType)
                VALUES (@StartupId, @Title, @Location, @Type);";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartupId", startupId);
                cmd.Parameters.AddWithValue("@Title", title.Trim());
                cmd.Parameters.AddWithValue("@Location", string.IsNullOrWhiteSpace(location) ? "Remote" : location.Trim());
                cmd.Parameters.AddWithValue("@Type", string.IsNullOrWhiteSpace(type) ? "Full-time" : type.Trim());
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public bool DeleteOpenPosition(int positionId)
        {
            const string sql = "DELETE FROM dbo.OpenPositions WHERE PositionId = @PositionId;";
            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@PositionId", positionId);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public bool AddTeamMember(int startupId, string name, string role, string avatarUrl)
        {
            const string sql = @"
                INSERT INTO dbo.TeamMembers (StartupId, Name, Role, AvatarUrl)
                VALUES (@StartupId, @Name, @Role, @AvatarUrl);";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartupId", startupId);
                cmd.Parameters.AddWithValue("@Name", name.Trim());
                cmd.Parameters.AddWithValue("@Role", role.Trim());
                cmd.Parameters.AddWithValue("@AvatarUrl", (object)avatarUrl ?? DBNull.Value);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public bool RequestToJoin(int senderUserId, int startupId, string note)
        {
            var startup = GetStartupById(startupId);
            if (startup == null) return false;

            const string sql = @"
                INSERT INTO dbo.ConnectionRequests (SenderId, ReceiverId, StartupId, Note, Status)
                VALUES (@SenderId, @ReceiverId, @StartupId, @Note, 'Pending');
                INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired)
                VALUES (@ReceiverId, N'New Join Request', @NotifMessage, 'Requests', 1);";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@SenderId", senderUserId);
                cmd.Parameters.AddWithValue("@ReceiverId", startup.FounderId);
                cmd.Parameters.AddWithValue("@StartupId", startupId);
                cmd.Parameters.AddWithValue("@Note", (object)note ?? "Interested in collaborating.");
                cmd.Parameters.AddWithValue("@NotifMessage", string.Format("A member requested to join {0}.", startup.Name));
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        private static List<OpenPosition> GetOpenPositionsInternal(int startupId, SqlConnection conn)
        {
            var list = new List<OpenPosition>();
            const string sql = "SELECT PositionId, StartupId, Title, Location, PositionType FROM dbo.OpenPositions WHERE StartupId = @StartupId;";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartupId", startupId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new OpenPosition
                        {
                            PositionId = Convert.ToInt32(reader["PositionId"]),
                            StartupId = Convert.ToInt32(reader["StartupId"]),
                            Title = reader["Title"].ToString(),
                            Location = reader["Location"].ToString(),
                            PositionType = reader["PositionType"].ToString()
                        });
                    }
                }
            }
            return list;
        }

        private static List<TeamMember> GetTeamMembersInternal(int startupId, SqlConnection conn)
        {
            var list = new List<TeamMember>();
            const string sql = "SELECT TeamMemberId, StartupId, UserId, Name, Role, AvatarUrl, JoinedDate FROM dbo.TeamMembers WHERE StartupId = @StartupId;";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartupId", startupId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new TeamMember
                        {
                            TeamMemberId = Convert.ToInt32(reader["TeamMemberId"]),
                            StartupId = Convert.ToInt32(reader["StartupId"]),
                            UserId = reader["UserId"] != DBNull.Value ? (int?)Convert.ToInt32(reader["UserId"]) : null,
                            Name = reader["Name"].ToString(),
                            Role = reader["Role"].ToString(),
                            AvatarUrl = reader["AvatarUrl"]?.ToString() ?? string.Empty,
                            JoinedDate = Convert.ToDateTime(reader["JoinedDate"])
                        });
                    }
                }
            }
            return list;
        }

        private static Startup MapStartup(SqlDataReader reader)
        {
            return new Startup
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
            };
        }
    }
}
