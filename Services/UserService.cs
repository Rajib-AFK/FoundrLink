using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using FoundrLink.Helpers;
using FoundrLink.Models;
using FoundrLink.Services.Interfaces;

namespace FoundrLink.Services
{
    public class UserService : IUserService
    {
        public ServiceResult<User> Authenticate(string email, string password)
        {
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrEmpty(password))
                return ServiceResult<User>.Fail("Email and password are required.");

            try
            {
                string query = "SELECT UserId, FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status, CreatedAt, UpdatedAt FROM dbo.Users WHERE Email = @Email";
                DataTable dt = DbHelper.ExecuteDataTable(query, DbHelper.CreateParam("@Email", SqlDbType.NVarChar, email.Trim()));

                if (dt == null || dt.Rows.Count == 0)
                {
                    return ServiceResult<User>.Fail("Invalid email address or password. Please try again.");
                }

                DataRow row = dt.Rows[0];
                string status = row["Status"]?.ToString() ?? "Active";

                if (string.Equals(status, "Inactive", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(status, "Suspended", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(status, "Banned", StringComparison.OrdinalIgnoreCase))
                {
                    return ServiceResult<User>.Fail("Your account has been deactivated or suspended. Please contact support.");
                }

                string storedHash = row["PasswordHash"]?.ToString();
                if (!SecurityHelper.VerifyPassword(password, storedHash))
                {
                    return ServiceResult<User>.Fail("Invalid email address or password. Please try again.");
                }

                var user = MapUser(row);
                return ServiceResult<User>.Ok(user, "Authentication successful.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("UserService Authenticate error: " + ex);
                return ServiceResult<User>.Fail("An unexpected database error occurred during authentication.");
            }
        }

        public ServiceResult<int> RegisterUser(string fullName, string email, string password, string role)
        {
            if (string.IsNullOrWhiteSpace(fullName) || string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(role))
                return ServiceResult<int>.Fail("Please complete all required fields.");

            if (string.IsNullOrEmpty(password) || password.Length < 8)
                return ServiceResult<int>.Fail("Password must be at least 8 characters long.");

            try
            {
                if (EmailExists(email))
                {
                    return ServiceResult<int>.Fail("An account with this email address already exists. Please sign in instead.");
                }

                string passwordHash = SecurityHelper.HashPassword(password);
                string defaultAvatar = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80";
                int createdUserId = 0;

                DbHelper.ExecuteInTransaction((conn, tx) =>
                {
                    string insertUserQuery = @"
                        INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status, CreatedAt, UpdatedAt)
                        OUTPUT INSERTED.UserId
                        VALUES (@FullName, @Email, @PasswordHash, @Role, @Title, @Location, @Bio, @AvatarUrl, @Company, 0, 'Active', SYSUTCDATETIME(), SYSUTCDATETIME());";

                    using (var cmdUser = new SqlCommand(insertUserQuery, conn, tx))
                    {
                        cmdUser.Parameters.Add(new SqlParameter("@FullName", SqlDbType.NVarChar) { Value = fullName.Trim() });
                        cmdUser.Parameters.Add(new SqlParameter("@Email", SqlDbType.NVarChar) { Value = email.Trim() });
                        cmdUser.Parameters.Add(new SqlParameter("@PasswordHash", SqlDbType.NVarChar) { Value = passwordHash });
                        cmdUser.Parameters.Add(new SqlParameter("@Role", SqlDbType.NVarChar) { Value = role.Trim() });
                        cmdUser.Parameters.Add(new SqlParameter("@Title", SqlDbType.NVarChar) { Value = role == "Investor" ? "Angel Investor" : "Founder & CEO" });
                        cmdUser.Parameters.Add(new SqlParameter("@Location", SqlDbType.NVarChar) { Value = "Mumbai, India" });
                        cmdUser.Parameters.Add(new SqlParameter("@Bio", SqlDbType.NVarChar) { Value = "Passionate founder building next-gen scalable products." });
                        cmdUser.Parameters.Add(new SqlParameter("@AvatarUrl", SqlDbType.NVarChar) { Value = defaultAvatar });
                        cmdUser.Parameters.Add(new SqlParameter("@Company", SqlDbType.NVarChar) { Value = "FoundrLink" });

                        object newId = cmdUser.ExecuteScalar();
                        if (newId == null || !int.TryParse(newId.ToString(), out createdUserId))
                        {
                            throw new InvalidOperationException("Failed to obtain newly created user identity.");
                        }
                    }

                    string insertProfileQuery = @"
                        INSERT INTO dbo.FounderProfiles (UserId, PlatformImpactConnections, PlatformImpactIntros, PlatformImpactTeams, PlatformImpactSaved, Interests, Skills, Availability, BaseLocation, ProfileCompletionPercentage)
                        VALUES (@UserId, 0, 0, 0, 0, 'SaaS, FinTech, Early Stage', 'Product, Engineering', 'Full-time', 'India', 60);";

                    using (var cmdProfile = new SqlCommand(insertProfileQuery, conn, tx))
                    {
                        cmdProfile.Parameters.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = createdUserId });
                        cmdProfile.ExecuteNonQuery();
                    }
                });

                return createdUserId > 0
                    ? ServiceResult<int>.Ok(createdUserId, "User registration completed successfully.")
                    : ServiceResult<int>.Fail("Registration could not be completed.");
            }
            catch (SqlException sqlEx)
            {
                System.Diagnostics.Trace.TraceError("RegisterUser SQL exception: " + sqlEx);
                if (sqlEx.Number == 2627 || sqlEx.Number == 2601)
                {
                    return ServiceResult<int>.Fail("An account with this email address already exists. Please sign in instead.");
                }
                return ServiceResult<int>.Fail("A database error occurred during registration. Please try again later.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("RegisterUser exception: " + ex);
                return ServiceResult<int>.Fail("An unexpected error occurred during registration.");
            }
        }

        public bool EmailExists(string email)
        {
            if (string.IsNullOrWhiteSpace(email)) return false;

            object existing = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.Users WHERE Email = @Email",
                DbHelper.CreateParam("@Email", SqlDbType.NVarChar, email.Trim()));

            return existing != null && Convert.ToInt32(existing) > 0;
        }

        public User GetUserById(int userId)
        {
            if (userId <= 0) return null;

            string query = "SELECT UserId, FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status, CreatedAt, UpdatedAt FROM dbo.Users WHERE UserId = @Id";
            DataTable dt = DbHelper.ExecuteDataTable(query, DbHelper.CreateParam("@Id", SqlDbType.Int, userId));

            return (dt != null && dt.Rows.Count > 0) ? MapUser(dt.Rows[0]) : null;
        }

        public User GetUserByEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email)) return null;

            string query = "SELECT UserId, FullName, Email, PasswordHash, Role, Title, Location, Bio, AvatarUrl, Company, IsVerified, Status, CreatedAt, UpdatedAt FROM dbo.Users WHERE Email = @Email";
            DataTable dt = DbHelper.ExecuteDataTable(query, DbHelper.CreateParam("@Email", SqlDbType.NVarChar, email.Trim()));

            return (dt != null && dt.Rows.Count > 0) ? MapUser(dt.Rows[0]) : null;
        }

        public ServiceResult UpdateUserStatus(int userId, string status)
        {
            if (userId <= 0) return ServiceResult.Fail("Invalid user identifier.");
            if (string.IsNullOrWhiteSpace(status)) return ServiceResult.Fail("Status cannot be empty.");

            try
            {
                string sql = "UPDATE dbo.Users SET Status = @Status, UpdatedAt = SYSUTCDATETIME() WHERE UserId = @Id";
                int rows = DbHelper.ExecuteNonQuery(sql,
                    DbHelper.CreateParam("@Status", SqlDbType.NVarChar, status.Trim()),
                    DbHelper.CreateParam("@Id", SqlDbType.Int, userId));

                return rows > 0 ? ServiceResult.Ok("User status updated.") : ServiceResult.Fail("User not found or unchanged.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("UpdateUserStatus error: " + ex);
                return ServiceResult.Fail("Error updating user status: " + ex.Message);
            }
        }

        public DataTable GetAllUsersDataTable(string search = null, string role = null, string status = null)
        {
            string sql = "SELECT UserId, FullName, Email, Role, Title, Location, Company, IsVerified, Status, CreatedAt FROM dbo.Users WHERE 1=1";
            var paramList = new List<SqlParameter>();

            if (!string.IsNullOrWhiteSpace(search))
            {
                sql += " AND (FullName LIKE '%' + @Search + '%' OR Email LIKE '%' + @Search + '%' OR Company LIKE '%' + @Search + '%')";
                paramList.Add(new SqlParameter("@Search", search.Trim()));
            }

            if (!string.IsNullOrWhiteSpace(role))
            {
                sql += " AND Role = @Role";
                paramList.Add(new SqlParameter("@Role", role.Trim()));
            }

            if (!string.IsNullOrWhiteSpace(status))
            {
                sql += " AND Status = @Status";
                paramList.Add(new SqlParameter("@Status", status.Trim()));
            }

            sql += " ORDER BY UserId DESC";
            return DbHelper.ExecuteDataTable(sql, paramList.ToArray());
        }

        private static User MapUser(DataRow row)
        {
            return new User
            {
                UserId = Convert.ToInt32(row["UserId"]),
                FullName = row["FullName"]?.ToString(),
                Email = row["Email"]?.ToString(),
                PasswordHash = row["PasswordHash"]?.ToString(),
                Role = row["Role"]?.ToString(),
                Title = row["Title"]?.ToString(),
                Location = row["Location"]?.ToString(),
                Bio = row["Bio"]?.ToString(),
                AvatarUrl = row["AvatarUrl"]?.ToString(),
                Company = row["Company"]?.ToString(),
                IsVerified = row["IsVerified"] != DBNull.Value && Convert.ToBoolean(row["IsVerified"]),
                Status = row["Status"]?.ToString(),
                CreatedAt = row["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(row["CreatedAt"]) : DateTime.UtcNow,
                UpdatedAt = row["UpdatedAt"] != DBNull.Value ? Convert.ToDateTime(row["UpdatedAt"]) : DateTime.UtcNow
            };
        }
    }
}
