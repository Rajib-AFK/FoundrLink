using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;

namespace FoundrLink.Helpers
{
    public static class LocalFallbackStore
    {
        private static readonly object _syncLock = new object();
        private static Dictionary<string, object> _cache;
        private static DateTime _lastLoaded = DateTime.MinValue;

        private static string JsonFilePath
        {
            get
            {
                if (HttpContext.Current != null)
                {
                    return HttpContext.Current.Server.MapPath("~/App_Data/foundrlink_local_db.json");
                }

                string candidateCurrent = Path.Combine(Environment.CurrentDirectory, "App_Data", "foundrlink_local_db.json");
                if (File.Exists(candidateCurrent)) return candidateCurrent;

                string candidateBase = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App_Data", "foundrlink_local_db.json");
                if (File.Exists(candidateBase)) return candidateBase;

                string asmDir = Path.GetDirectoryName(typeof(LocalFallbackStore).Assembly.Location);
                if (!string.IsNullOrEmpty(asmDir))
                {
                    string candidateAsmParent = Path.Combine(asmDir, "..", "App_Data", "foundrlink_local_db.json");
                    if (File.Exists(candidateAsmParent)) return Path.GetFullPath(candidateAsmParent);
                }

                return candidateCurrent;
            }
        }

        private static void EnsureLoaded()
        {
            if (_cache != null && (DateTime.UtcNow - _lastLoaded).TotalMinutes < 5)
                return;

            lock (_syncLock)
            {
                if (!File.Exists(JsonFilePath))
                {
                    _cache = CreateDefaultFallbackCache();
                    try
                    {
                        string dir = Path.GetDirectoryName(JsonFilePath);
                        if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
                            Directory.CreateDirectory(dir);
                        var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
                        File.WriteAllText(JsonFilePath, serializer.Serialize(_cache));
                    }
                    catch { }
                    _lastLoaded = DateTime.UtcNow;
                    return;
                }

                try
                {
                    string json = File.ReadAllText(JsonFilePath);
                    var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
                    _cache = serializer.Deserialize<Dictionary<string, object>>(json) ?? CreateDefaultFallbackCache();
                    _lastLoaded = DateTime.UtcNow;
                }
                catch
                {
                    _cache = CreateDefaultFallbackCache();
                }
            }
        }

        private static Dictionary<string, object> CreateDefaultFallbackCache()
        {
            var users = new System.Collections.ArrayList
            {
                new Dictionary<string, object>
                {
                    { "UserId", 1 },
                    { "FullName", "Platform Admin" },
                    { "Email", "admin@ripaldesign.studio" },
                    { "Role", "Admin" },
                    { "Title", "Platform Administrator" },
                    { "Location", "Mumbai, India" },
                    { "Bio", "Platform administrator managing system integrity and verification." },
                    { "AvatarUrl", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100" },
                    { "Status", "Active" },
                    { "IsVerified", true }
                },
                new Dictionary<string, object>
                {
                    { "UserId", 2 },
                    { "FullName", "Startup Founder" },
                    { "Email", "founder@ripaldesign.studio" },
                    { "Role", "Founder" },
                    { "Title", "Founder & CEO" },
                    { "Location", "Bangalore, India" },
                    { "Bio", "Building next-generation B2B SaaS platform." },
                    { "AvatarUrl", "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100" },
                    { "Status", "Active" },
                    { "IsVerified", true }
                },
                new Dictionary<string, object>
                {
                    { "UserId", 3 },
                    { "FullName", "Technical Co-Founder" },
                    { "Email", "cofounder@ripaldesign.studio" },
                    { "Role", "Technical" },
                    { "Title", "Chief Technology Officer" },
                    { "Location", "San Francisco, CA" },
                    { "Bio", "Full-stack cloud architect specializing in distributed microservices." },
                    { "AvatarUrl", "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100" },
                    { "Status", "Active" },
                    { "IsVerified", true }
                },
                new Dictionary<string, object>
                {
                    { "UserId", 4 },
                    { "FullName", "Angel Investor" },
                    { "Email", "investor@ripaldesign.studio" },
                    { "Role", "Investor" },
                    { "Title", "Angel Investor & Mentor" },
                    { "Location", "Singapore" },
                    { "Bio", "Early-stage angel investor backing ambitious fintech and enterprise AI founders." },
                    { "AvatarUrl", "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100" },
                    { "Status", "Active" },
                    { "IsVerified", true }
                }
            };

            var startups = new System.Collections.ArrayList
            {
                new Dictionary<string, object>
                {
                    { "StartupId", 1 },
                    { "FounderId", 2 },
                    { "Name", "FoundrLink Enterprise" },
                    { "Tagline", "Intelligent co-founder matching infrastructure" },
                    { "Industry", "SaaS" },
                    { "Stage", "Seed Stage" },
                    { "Location", "Bangalore, India" },
                    { "Status", "Published" },
                    { "RequiredSkills", "React, ASP.NET, SQL Server" }
                }
            };

            return new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase)
            {
                { "Users", users },
                { "Startups", startups },
                { "FounderProfiles", new System.Collections.ArrayList() }
            };
        }

        private static List<Dictionary<string, object>> GetTable(string tableName)
        {
            EnsureLoaded();
            if (_cache != null)
            {
                foreach (var key in _cache.Keys)
                {
                    if (string.Equals(key, tableName, StringComparison.OrdinalIgnoreCase))
                    {
                        var list = _cache[key] as System.Collections.ArrayList;
                        if (list != null)
                        {
                            var result = new List<Dictionary<string, object>>();
                            foreach (var item in list)
                            {
                                if (item is Dictionary<string, object> dict)
                                    result.Add(dict);
                            }
                            return result;
                        }
                        var objList = _cache[key] as object[];
                        if (objList != null)
                        {
                            var result = new List<Dictionary<string, object>>();
                            foreach (var item in objList)
                            {
                                if (item is Dictionary<string, object> dict)
                                    result.Add(dict);
                            }
                            return result;
                        }
                    }
                }
            }
            return new List<Dictionary<string, object>>();
        }

        public static DataTable Query(string query, params SqlParameter[] parameters)
        {
            var dt = new DataTable();
            if (string.IsNullOrWhiteSpace(query)) return dt;

            string q = query.ToUpperInvariant();
            var paramDict = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
            if (parameters != null)
            {
                foreach (var p in parameters)
                {
                    if (p != null)
                        paramDict[p.ParameterName.TrimStart('@')] = p.Value;
                }
            }

            if (q.Contains("USERS") && (q.Contains("FOUNDERPROFILES") || q.Contains("JOIN")))
            {
                var users = GetTable("Users");
                var profiles = GetTable("FounderProfiles");
                return BuildJoinedFounders(users, profiles, paramDict);
            }
            if (q.Contains("STARTUPS") && q.Contains("USERS"))
            {
                var startups = GetTable("Startups");
                var users = GetTable("Users");
                return BuildJoinedStartups(startups, users, paramDict);
            }
            if (q.Contains("STARTUPS"))
            {
                return FilterToTable(GetTable("Startups"), paramDict, "StartupId");
            }
            if (q.Contains("USERS"))
            {
                return FilterToTable(GetTable("Users"), paramDict, "UserId");
            }
            if (q.Contains("FOUNDERPROFILES"))
            {
                return FilterToTable(GetTable("FounderProfiles"), paramDict, "UserId");
            }
            if (q.Contains("OPENPOSITIONS"))
            {
                return FilterToTable(GetTable("OpenPositions"), paramDict, "StartupId");
            }
            if (q.Contains("TEAMMEMBERS"))
            {
                return FilterToTable(GetTable("TeamMembers"), paramDict, "StartupId");
            }
            if (q.Contains("STARTUPUPDATES"))
            {
                return FilterToTable(GetTable("StartupUpdates"), paramDict, "StartupId");
            }
            if (q.Contains("NOTIFICATIONS"))
            {
                return FilterToTable(GetTable("Notifications"), paramDict, "UserId");
            }
            if (q.Contains("MESSAGES"))
            {
                return FilterToTable(GetTable("Messages"), paramDict, "ConversationId");
            }
            if (q.Contains("CONVERSATIONS"))
            {
                return FilterToTable(GetTable("Conversations"), paramDict, "User1Id");
            }
            if (q.Contains("ACTIVITYLOGS"))
            {
                return FilterToTable(GetTable("ActivityLogs"), paramDict, "UserId");
            }
            if (q.Contains("CONNECTIONGROWTH"))
            {
                return FilterToTable(GetTable("ConnectionGrowth"), paramDict, "UserId");
            }
            if (q.Contains("MODERATIONREPORTS") || q.Contains("REPORTS"))
            {
                return FilterToTable(GetTable("ModerationReports"), paramDict, "");
            }

            return dt;
        }

        public static object Scalar(string query, params SqlParameter[] parameters)
        {
            if (string.IsNullOrWhiteSpace(query)) return 0;
            string q = query.ToUpperInvariant();

            var paramDict = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
            if (parameters != null)
            {
                foreach (var p in parameters)
                {
                    if (p != null)
                        paramDict[p.ParameterName.TrimStart('@')] = p.Value;
                }
            }

            if (q.Contains("COUNT(1)") || q.Contains("COUNT(*)"))
            {
                var dt = Query(query, parameters);
                return dt.Rows.Count;
            }

            if (q.Contains("INSERT") && (q.Contains("OUTPUT INSERTED") || q.Contains("SCOPE_IDENTITY")))
            {
                return new Random().Next(100, 9999);
            }

            var resDt = Query(query, parameters);
            if (resDt.Rows.Count > 0 && resDt.Columns.Count > 0)
            {
                return resDt.Rows[0][0];
            }

            return null;
        }

        public static int NonQuery(string query, params SqlParameter[] parameters)
        {
            // Successfully simulated in-memory
            return 1;
        }

        private static DataTable FilterToTable(List<Dictionary<string, object>> rows, Dictionary<string, object> parameters, string keyFilter)
        {
            var dt = new DataTable();
            if (rows.Count == 0) return dt;

            foreach (var col in rows[0].Keys)
            {
                dt.Columns.Add(col, typeof(object));
            }

            foreach (var item in rows)
            {
                bool match = true;
                foreach (var kvp in parameters)
                {
                    string pName = kvp.Key;
                    object pVal = kvp.Value;
                    if (pVal == null || pVal == DBNull.Value) continue;

                    string strVal = pVal.ToString().Trim('%');
                    if (item.ContainsKey(pName))
                    {
                        string itemStr = item[pName]?.ToString() ?? "";
                        if (!itemStr.Equals(strVal, StringComparison.OrdinalIgnoreCase) &&
                            !itemStr.ToLowerInvariant().Contains(strVal.ToLowerInvariant()))
                        {
                            match = false;
                            break;
                        }
                    }
                    else if (pName.Equals("Search", StringComparison.OrdinalIgnoreCase) || pName.Equals("q", StringComparison.OrdinalIgnoreCase))
                    {
                        bool foundAny = false;
                        foreach (var val in item.Values)
                        {
                            if (val != null && val.ToString().ToLowerInvariant().Contains(strVal.ToLowerInvariant()))
                            {
                                foundAny = true;
                                break;
                            }
                        }
                        if (!foundAny) { match = false; break; }
                    }
                }

                if (match)
                {
                    var r = dt.NewRow();
                    foreach (var col in dt.Columns.Cast<DataColumn>())
                    {
                        r[col.ColumnName] = item.ContainsKey(col.ColumnName) ? item[col.ColumnName] ?? DBNull.Value : DBNull.Value;
                    }
                    dt.Rows.Add(r);
                }
            }

            return dt;
        }

        private static DataTable BuildJoinedFounders(List<Dictionary<string, object>> users, List<Dictionary<string, object>> profiles, Dictionary<string, object> parameters)
        {
            var dt = new DataTable();
            dt.Columns.Add("UserId", typeof(int));
            dt.Columns.Add("FullName", typeof(string));
            dt.Columns.Add("Email", typeof(string));
            dt.Columns.Add("PasswordHash", typeof(string));
            dt.Columns.Add("Role", typeof(string));
            dt.Columns.Add("Title", typeof(string));
            dt.Columns.Add("Location", typeof(string));
            dt.Columns.Add("Bio", typeof(string));
            dt.Columns.Add("AvatarUrl", typeof(string));
            dt.Columns.Add("Company", typeof(string));
            dt.Columns.Add("IsVerified", typeof(bool));
            dt.Columns.Add("Status", typeof(string));
            dt.Columns.Add("Skills", typeof(string));
            dt.Columns.Add("Availability", typeof(string));
            dt.Columns.Add("Interests", typeof(string));
            dt.Columns.Add("ICanOffer", typeof(string));
            dt.Columns.Add("LookingFor", typeof(string));
            dt.Columns.Add("BaseLocation", typeof(string));
            dt.Columns.Add("PlatformImpactConnections", typeof(int));
            dt.Columns.Add("PlatformImpactIntros", typeof(int));
            dt.Columns.Add("PlatformImpactTeams", typeof(int));
            dt.Columns.Add("PlatformImpactSaved", typeof(int));
            dt.Columns.Add("ProfileCompletionPercentage", typeof(int));

            foreach (var u in users)
            {
                int uId = Convert.ToInt32(u["UserId"]);
                var prof = profiles.FirstOrDefault(p => Convert.ToInt32(p["UserId"]) == uId);

                var r = dt.NewRow();
                r["UserId"] = uId;
                r["FullName"] = u.ContainsKey("FullName") ? u["FullName"] : "";
                r["Email"] = u.ContainsKey("Email") ? u["Email"] : "";
                r["PasswordHash"] = u.ContainsKey("PasswordHash") ? u["PasswordHash"] : "";
                r["Role"] = u.ContainsKey("Role") ? u["Role"] : "Founder";
                r["Title"] = u.ContainsKey("Title") ? u["Title"] : "";
                r["Location"] = u.ContainsKey("Location") ? u["Location"] : "";
                r["Bio"] = u.ContainsKey("Bio") ? u["Bio"] : "";
                r["AvatarUrl"] = u.ContainsKey("AvatarUrl") ? u["AvatarUrl"] : "";
                r["Company"] = u.ContainsKey("Company") ? u["Company"] : "";
                r["IsVerified"] = u.ContainsKey("IsVerified") ? u["IsVerified"] : false;
                r["Status"] = u.ContainsKey("Status") ? u["Status"] : "Active";

                if (prof != null)
                {
                    r["Skills"] = prof.ContainsKey("Skills") ? prof["Skills"] : "";
                    r["Availability"] = prof.ContainsKey("Availability") ? prof["Availability"] : "Full-time";
                    r["Interests"] = prof.ContainsKey("Interests") ? prof["Interests"] : "";
                    r["ICanOffer"] = prof.ContainsKey("ICanOffer") ? prof["ICanOffer"] : "";
                    r["LookingFor"] = prof.ContainsKey("LookingFor") ? prof["LookingFor"] : "";
                    r["BaseLocation"] = prof.ContainsKey("BaseLocation") ? prof["BaseLocation"] : "";
                    r["PlatformImpactConnections"] = prof.ContainsKey("PlatformImpactConnections") ? prof["PlatformImpactConnections"] : 0;
                    r["PlatformImpactIntros"] = prof.ContainsKey("PlatformImpactIntros") ? prof["PlatformImpactIntros"] : 0;
                    r["PlatformImpactTeams"] = prof.ContainsKey("PlatformImpactTeams") ? prof["PlatformImpactTeams"] : 0;
                    r["PlatformImpactSaved"] = prof.ContainsKey("PlatformImpactSaved") ? prof["PlatformImpactSaved"] : 0;
                    r["ProfileCompletionPercentage"] = prof.ContainsKey("ProfileCompletionPercentage") ? prof["ProfileCompletionPercentage"] : 85;
                }

                bool match = true;
                if (parameters.ContainsKey("Skill"))
                {
                    string sk = parameters["Skill"]?.ToString()?.Trim('%')?.ToLowerInvariant() ?? "";
                    string rowSkills = (r["Skills"]?.ToString() ?? "").ToLowerInvariant();
                    string rowBio = (r["Bio"]?.ToString() ?? "").ToLowerInvariant();
                    string rowTitle = (r["Title"]?.ToString() ?? "").ToLowerInvariant();
                    if (!rowSkills.Contains(sk) && !rowBio.Contains(sk) && !rowTitle.Contains(sk))
                        match = false;
                }
                if (parameters.ContainsKey("UserId"))
                {
                    if (Convert.ToInt32(parameters["UserId"]) != uId)
                        match = false;
                }

                if (match)
                    dt.Rows.Add(r);
            }

            return dt;
        }

        private static DataTable BuildJoinedStartups(List<Dictionary<string, object>> startups, List<Dictionary<string, object>> users, Dictionary<string, object> parameters)
        {
            var dt = new DataTable();
            dt.Columns.Add("StartupId", typeof(int));
            dt.Columns.Add("FounderId", typeof(int));
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("Tagline", typeof(string));
            dt.Columns.Add("Industry", typeof(string));
            dt.Columns.Add("Stage", typeof(string));
            dt.Columns.Add("LogoUrl", typeof(string));
            dt.Columns.Add("ShortDescription", typeof(string));
            dt.Columns.Add("FullDescription", typeof(string));
            dt.Columns.Add("Problem", typeof(string));
            dt.Columns.Add("Solution", typeof(string));
            dt.Columns.Add("TeamSize", typeof(int));
            dt.Columns.Add("RequiredSkills", typeof(string));
            dt.Columns.Add("Location", typeof(string));
            dt.Columns.Add("WebsiteUrl", typeof(string));
            dt.Columns.Add("Commitment", typeof(string));
            dt.Columns.Add("FoundedYear", typeof(int));
            dt.Columns.Add("FundingRaised", typeof(decimal));
            dt.Columns.Add("FundingGoal", typeof(decimal));
            dt.Columns.Add("MRR", typeof(decimal));
            dt.Columns.Add("Status", typeof(string));
            dt.Columns.Add("FounderName", typeof(string));
            dt.Columns.Add("FounderTitle", typeof(string));
            dt.Columns.Add("FounderAvatar", typeof(string));
            dt.Columns.Add("FounderEmail", typeof(string));

            foreach (var s in startups)
            {
                int fId = Convert.ToInt32(s["FounderId"]);
                var u = users.FirstOrDefault(user => Convert.ToInt32(user["UserId"]) == fId);

                var r = dt.NewRow();
                r["StartupId"] = s["StartupId"];
                r["FounderId"] = fId;
                r["Name"] = s["Name"];
                r["Tagline"] = s.ContainsKey("Tagline") ? s["Tagline"] : "";
                r["Industry"] = s.ContainsKey("Industry") ? s["Industry"] : "";
                r["Stage"] = s.ContainsKey("Stage") ? s["Stage"] : "Seed Stage";
                r["LogoUrl"] = s.ContainsKey("LogoUrl") ? s["LogoUrl"] : "";
                r["ShortDescription"] = s.ContainsKey("ShortDescription") ? s["ShortDescription"] : "";
                r["FullDescription"] = s.ContainsKey("FullDescription") ? s["FullDescription"] : "";
                r["Problem"] = s.ContainsKey("Problem") ? s["Problem"] : "";
                r["Solution"] = s.ContainsKey("Solution") ? s["Solution"] : "";
                r["TeamSize"] = s.ContainsKey("TeamSize") ? s["TeamSize"] : 1;
                r["RequiredSkills"] = s.ContainsKey("RequiredSkills") ? s["RequiredSkills"] : "";
                r["Location"] = s.ContainsKey("Location") ? s["Location"] : "";
                r["WebsiteUrl"] = s.ContainsKey("WebsiteUrl") ? s["WebsiteUrl"] : "";
                r["Commitment"] = s.ContainsKey("Commitment") ? s["Commitment"] : "Full-time / Equity";
                r["FoundedYear"] = s.ContainsKey("FoundedYear") ? s["FoundedYear"] : 2024;
                r["FundingRaised"] = s.ContainsKey("FundingRaised") ? Convert.ToDecimal(s["FundingRaised"]) : 0m;
                r["FundingGoal"] = s.ContainsKey("FundingGoal") ? Convert.ToDecimal(s["FundingGoal"]) : 0m;
                r["MRR"] = s.ContainsKey("MRR") ? Convert.ToDecimal(s["MRR"]) : 0m;
                r["Status"] = s.ContainsKey("Status") ? s["Status"] : "Published";

                if (u != null)
                {
                    r["FounderName"] = u.ContainsKey("FullName") ? u["FullName"] : "Founder";
                    r["FounderTitle"] = u.ContainsKey("Title") ? u["Title"] : "CEO";
                    r["FounderAvatar"] = u.ContainsKey("AvatarUrl") ? u["AvatarUrl"] : "";
                    r["FounderEmail"] = u.ContainsKey("Email") ? u["Email"] : "";
                }

                bool match = true;
                if (parameters.ContainsKey("StartupId"))
                {
                    if (Convert.ToInt32(parameters["StartupId"]) != Convert.ToInt32(s["StartupId"]))
                        match = false;
                }
                if (parameters.ContainsKey("Search"))
                {
                    string search = parameters["Search"].ToString().Trim('%').ToLowerInvariant();
                    string name = r["Name"]?.ToString()?.ToLowerInvariant() ?? "";
                    string tag = r["Tagline"]?.ToString()?.ToLowerInvariant() ?? "";
                    string ind = r["Industry"]?.ToString()?.ToLowerInvariant() ?? "";
                    string req = r["RequiredSkills"]?.ToString()?.ToLowerInvariant() ?? "";
                    if (!name.Contains(search) && !tag.Contains(search) && !ind.Contains(search) && !req.Contains(search))
                        match = false;
                }

                if (match)
                    dt.Rows.Add(r);
            }

            return dt;
        }
    }
}
