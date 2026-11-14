using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using FoundrLink.Core.Interfaces;
using FoundrLink.Core.Models;
using FoundrLink.Helpers;

namespace FoundrLink.DataAccess
{
    public class UserRepository : IUserRepository
    {
        public BaseUser GetUserById(int userId)
        {
            const string sql = @"
                SELECT UserId, FullName, Email, Role, Title, Location, Bio, Company, AvatarUrl, IsVerified, Status, CreatedAt, UpdatedAt
                FROM dbo.Users
                WHERE UserId = @UserId;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return MapUser(reader);
                    }
                }
            }
            return null;
        }

        public BaseUser GetUserForAuth(int userId)
        {
            const string sql = @"
                SELECT UserId, FullName, Email, PasswordHash, Role, Title, Location, Bio, Company, AvatarUrl, IsVerified, Status, CreatedAt, UpdatedAt
                FROM dbo.Users
                WHERE UserId = @UserId;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return MapUser(reader);
                    }
                }
            }
            return null;
        }

        public BaseUser GetUserForAuth(string email)
        {
            if (string.IsNullOrWhiteSpace(email)) return null;

            const string sql = @"
                SELECT UserId, FullName, Email, PasswordHash, Role, Title, Location, Bio, Company, AvatarUrl, IsVerified, Status, CreatedAt, UpdatedAt
                FROM dbo.Users
                WHERE LOWER(Email) = LOWER(@Email);";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Email", email.Trim());
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return MapUser(reader);
                    }
                }
            }
            return null;
        }

        public BaseUser GetUserByEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email)) return null;

            const string sql = @"
                SELECT UserId, FullName, Email, Role, Title, Location, Bio, Company, AvatarUrl, IsVerified, Status, CreatedAt, UpdatedAt
                FROM dbo.Users
                WHERE LOWER(Email) = LOWER(@Email);";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Email", email.Trim());
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return MapUser(reader);
                    }
                }
            }
            return null;
        }

        public BaseUser Authenticate(string email, string password)
        {
            var user = GetUserForAuth(email);
            if (user == null) return null;

            if (SecurityHelper.VerifyPassword(password, user.PasswordHash, user.UserId, user.Email))
            {
                return user;
            }
            return null;
        }

        public int RegisterUser(string fullName, string email, string password, UserRole role, string title = null, string location = null)
        {
            string hash = SecurityHelper.HashPassword(password);
            const string sql = @"
                INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Status, IsVerified)
                VALUES (@FullName, @Email, @PasswordHash, @Role, @Title, @Location, 'Active', 0);
                SELECT SCOPE_IDENTITY();";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@FullName", fullName.Trim());
                cmd.Parameters.AddWithValue("@Email", email.Trim().ToLowerInvariant());
                cmd.Parameters.AddWithValue("@PasswordHash", hash);
                cmd.Parameters.AddWithValue("@Role", role.ToString());
                cmd.Parameters.AddWithValue("@Title", (object)title ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Location", (object)location ?? DBNull.Value);

                int newId = Convert.ToInt32(cmd.ExecuteScalar());

                // Auto-create blank FounderProfile
                const string profileSql = @"
                    INSERT INTO dbo.FounderProfiles (UserId, Interests, Skills, Availability, ProfileCompletionPercentage)
                    VALUES (@UserId, @Interests, @Skills, 'Full-time', 85);";
                using (var pCmd = new SqlCommand(profileSql, conn))
                {
                    pCmd.Parameters.AddWithValue("@UserId", newId);
                    pCmd.Parameters.AddWithValue("@Interests", "Startups, Networking");
                    pCmd.Parameters.AddWithValue("@Skills", role == UserRole.Founder ? "Strategy, Leadership" : "Engineering, React");
                    pCmd.ExecuteNonQuery();
                }

                return newId;
            }
        }

        public bool UpdateProfile(int userId, string fullName, string email, string company, string bio, string location, string title)
        {
            const string sql = @"
                UPDATE dbo.Users
                SET FullName = @FullName,
                    Email = @Email,
                    Company = @Company,
                    Bio = @Bio,
                    Location = @Location,
                    Title = @Title,
                    UpdatedAt = SYSUTCDATETIME()
                WHERE UserId = @UserId;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@FullName", fullName.Trim());
                cmd.Parameters.AddWithValue("@Email", email.Trim().ToLowerInvariant());
                cmd.Parameters.AddWithValue("@Company", (object)company ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Bio", (object)bio ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Location", (object)location ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Title", (object)title ?? DBNull.Value);

                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public bool ChangePassword(int userId, string oldPassword, string newPassword)
        {
            var user = GetUserForAuth(userId);
            if (user == null) return false;

            if (!SecurityHelper.VerifyPassword(oldPassword, user.PasswordHash, user.UserId, user.Email))
                return false;

            string newHash = SecurityHelper.HashPassword(newPassword);
            const string sql = "UPDATE dbo.Users SET PasswordHash = @Hash, UpdatedAt = SYSUTCDATETIME() WHERE UserId = @UserId;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Hash", newHash);
                cmd.Parameters.AddWithValue("@UserId", userId);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public FounderProfile GetFounderProfile(int userId)
        {
            const string sql = @"
                SELECT ProfileId, UserId, PlatformImpactConnections, PlatformImpactIntros, PlatformImpactTeams, PlatformImpactSaved,
                       Interests, Skills, ICanOffer, LookingFor, Availability, BaseLocation, ProfileCompletionPercentage
                FROM dbo.FounderProfiles
                WHERE UserId = @UserId;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return new FounderProfile
                        {
                            ProfileId = Convert.ToInt32(reader["ProfileId"]),
                            UserId = Convert.ToInt32(reader["UserId"]),
                            PlatformImpactConnections = Convert.ToInt32(reader["PlatformImpactConnections"]),
                            PlatformImpactIntros = Convert.ToInt32(reader["PlatformImpactIntros"]),
                            PlatformImpactTeams = Convert.ToInt32(reader["PlatformImpactTeams"]),
                            PlatformImpactSaved = Convert.ToInt32(reader["PlatformImpactSaved"]),
                            Interests = reader["Interests"]?.ToString() ?? string.Empty,
                            Skills = reader["Skills"]?.ToString() ?? string.Empty,
                            ICanOffer = reader["ICanOffer"]?.ToString() ?? string.Empty,
                            LookingFor = reader["LookingFor"]?.ToString() ?? string.Empty,
                            Availability = reader["Availability"]?.ToString() ?? "Full-time",
                            BaseLocation = reader["BaseLocation"]?.ToString() ?? string.Empty,
                            ProfileCompletionPercentage = Convert.ToInt32(reader["ProfileCompletionPercentage"])
                        };
                    }
                }
            }
            return null;
        }

        public bool SaveFounderProfile(FounderProfile profile)
        {
            const string sql = @"
                IF EXISTS (SELECT 1 FROM dbo.FounderProfiles WHERE UserId = @UserId)
                BEGIN
                    UPDATE dbo.FounderProfiles
                    SET Interests = @Interests,
                        Skills = @Skills,
                        ICanOffer = @ICanOffer,
                        LookingFor = @LookingFor,
                        Availability = @Availability,
                        BaseLocation = @BaseLocation,
                        ProfileCompletionPercentage = @Completion
                    WHERE UserId = @UserId;
                END
                ELSE
                BEGIN
                    INSERT INTO dbo.FounderProfiles (UserId, Interests, Skills, ICanOffer, LookingFor, Availability, BaseLocation, ProfileCompletionPercentage)
                    VALUES (@UserId, @Interests, @Skills, @ICanOffer, @LookingFor, @Availability, @BaseLocation, @Completion);
                END";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", profile.UserId);
                cmd.Parameters.AddWithValue("@Interests", (object)profile.Interests ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Skills", (object)profile.Skills ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ICanOffer", (object)profile.ICanOffer ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@LookingFor", (object)profile.LookingFor ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Availability", profile.Availability ?? "Full-time");
                cmd.Parameters.AddWithValue("@BaseLocation", (object)profile.BaseLocation ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Completion", profile.ProfileCompletionPercentage);

                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public List<BaseUser> SearchCoFounders(string roleFilter, string skillFilter, string availabilityFilter, string keyword)
        {
            var list = new List<BaseUser>();
            var sql = @"
                SELECT u.UserId, u.FullName, u.Email, u.Role, u.Title, u.Location, u.Bio, u.Company, u.AvatarUrl, u.IsVerified, u.Status, u.CreatedAt, u.UpdatedAt,
                       fp.Skills, fp.Availability
                FROM dbo.Users u
                LEFT JOIN dbo.FounderProfiles fp ON u.UserId = fp.UserId
                WHERE u.Status = 'Active' AND u.Role IN ('Co-Founder', 'Founder', 'Investor') ";

            if (!string.IsNullOrWhiteSpace(roleFilter))
            {
                sql += " AND (u.Role = @RoleFilter OR u.Title LIKE '%' + @RoleFilter + '%')";
            }
            if (!string.IsNullOrWhiteSpace(skillFilter))
            {
                sql += " AND (fp.Skills LIKE '%' + @SkillFilter + '%' OR u.Bio LIKE '%' + @SkillFilter + '%')";
            }
            if (!string.IsNullOrWhiteSpace(availabilityFilter))
            {
                sql += " AND fp.Availability = @AvailabilityFilter";
            }
            if (!string.IsNullOrWhiteSpace(keyword))
            {
                sql += " AND (u.FullName LIKE '%' + @Keyword + '%' OR u.Title LIKE '%' + @Keyword + '%' OR u.Bio LIKE '%' + @Keyword + '%')";
            }
            sql += " ORDER BY u.IsVerified DESC, u.CreatedAt DESC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (!string.IsNullOrWhiteSpace(roleFilter)) cmd.Parameters.AddWithValue("@RoleFilter", roleFilter);
                if (!string.IsNullOrWhiteSpace(skillFilter)) cmd.Parameters.AddWithValue("@SkillFilter", skillFilter);
                if (!string.IsNullOrWhiteSpace(availabilityFilter)) cmd.Parameters.AddWithValue("@AvailabilityFilter", availabilityFilter);
                if (!string.IsNullOrWhiteSpace(keyword)) cmd.Parameters.AddWithValue("@Keyword", keyword);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var u = MapUser(reader);
                        if (u is CoFounderUser cfu)
                        {
                            cfu.PrimarySkills = reader["Skills"]?.ToString() ?? string.Empty;
                        }
                        list.Add(u);
                    }
                }
            }
            return list;
        }

        public List<BaseUser> GetSuggestedConnections(int currentUserId, int limit = 3)
        {
            var list = new List<BaseUser>();
            const string sql = @"
                SELECT TOP (@Limit) u.UserId, u.FullName, u.Email, u.Role, u.Title, u.Location, u.Bio, u.Company, u.AvatarUrl, u.IsVerified, u.Status, u.CreatedAt, u.UpdatedAt
                FROM dbo.Users u
                WHERE u.UserId <> @CurrentUserId AND u.Status = 'Active'
                ORDER BY u.IsVerified DESC, u.UserId ASC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Limit", limit);
                cmd.Parameters.AddWithValue("@CurrentUserId", currentUserId);
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

        public int GetTotalUserCount()
        {
            const string sql = "SELECT COUNT(*) FROM dbo.Users WHERE Status = 'Active';";
            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                return Convert.ToInt32(cmd.ExecuteScalar());
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
