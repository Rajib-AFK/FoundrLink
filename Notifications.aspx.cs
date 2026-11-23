using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class Notifications : Page
    {
        private int CurrentUserId;
        private string CurrentFilter
        {
            get => ViewState["CurrentFilter"] as string ?? "All";
            set => ViewState["CurrentFilter"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            int? currentUserId = SecurityHelper.GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }
            CurrentUserId = currentUserId.Value;

            if (!IsPostBack)
            {
                string filterParam = Request.QueryString["filter"];
                if (!string.IsNullOrEmpty(filterParam))
                {
                    CurrentFilter = filterParam;
                }
                LoadNotifications();
            }
        }

        private void LoadNotifications()
        {
            try
            {
                string sql = "SELECT NotificationId, UserId, Title, Message, NotificationType, ActionRequired, IsRead, CreatedAt FROM dbo.Notifications WHERE UserId = @UserId";

                switch (CurrentFilter)
                {
                    case "Unread":
                        sql += " AND IsRead = 0";
                        break;
                    case "Requests":
                        sql += " AND (NotificationType = 'Request' OR ActionRequired = 1)";
                        break;
                    case "Matches":
                        sql += " AND (NotificationType = 'Match' OR Title LIKE '%Match%')";
                        break;
                    case "Activity":
                        sql += " AND (NotificationType = 'Activity' OR NotificationType = 'System')";
                        break;
                }

                sql += " ORDER BY CreatedAt DESC";

                DataTable dt = DbHelper.ExecuteDataTable(sql, new SqlParameter("@UserId", CurrentUserId));

                if (dt.Rows.Count > 0)
                {
                    rptNotifications.Visible = true;
                    pnlEmpty.Visible = false;
                    rptNotifications.DataSource = dt;
                    rptNotifications.DataBind();
                }
                else
                {
                    rptNotifications.Visible = false;
                    pnlEmpty.Visible = true;
                }

                UpdateFilterPillStyles();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadNotifications error: " + ex);
            }
        }

        private void UpdateFilterPillStyles()
        {
            string activeCls = "btn btn-sm btn-dark rounded-pill px-3";
            string inactiveCls = "btn btn-sm btn-outline-secondary rounded-pill px-3";

            btnFilterAll.CssClass = CurrentFilter == "All" ? activeCls : inactiveCls;
            btnFilterUnread.CssClass = CurrentFilter == "Unread" ? activeCls : inactiveCls;
            btnFilterRequests.CssClass = CurrentFilter == "Requests" ? activeCls : inactiveCls;
            btnFilterMatches.CssClass = CurrentFilter == "Matches" ? activeCls : inactiveCls;
            btnFilterActivity.CssClass = CurrentFilter == "Activity" ? activeCls : inactiveCls;
        }

        protected void Filter_Click(object sender, EventArgs e)
        {
            if (sender is LinkButton btn)
            {
                CurrentFilter = btn.CommandArgument;
                LoadNotifications();
            }
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            try
            {
                string sql = "UPDATE dbo.Notifications SET IsRead = 1 WHERE UserId = @UserId";
                DbHelper.ExecuteNonQuery(sql, new SqlParameter("@UserId", CurrentUserId));

                litSuccessMsg.Text = "All notifications marked as read.";
                pnlSuccessAlert.Visible = true;

                LoadNotifications();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("btnMarkAllRead error: " + ex);
            }
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int notifId = Convert.ToInt32(e.CommandArgument);

            try
            {
                if (e.CommandName == "Dismiss")
                {
                    string sql = "DELETE FROM dbo.Notifications WHERE NotificationId = @Id AND UserId = @UserId";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", notifId), new SqlParameter("@UserId", CurrentUserId));
                    LoadNotifications();
                }
                else if (e.CommandName == "Accept")
                {
                    DbHelper.ExecuteInTransaction((conn, tx) =>
                    {
                        // 1. Fetch notification details
                        string notifTitle = string.Empty;
                        string notifMessage = string.Empty;
                        DateTime notifCreatedAt = DateTime.UtcNow;

                        using (var cmd = conn.CreateCommand())
                        {
                            cmd.Transaction = tx;
                            cmd.CommandText = "SELECT Title, Message, CreatedAt FROM dbo.Notifications WHERE NotificationId = @Id AND UserId = @UserId";
                            cmd.Parameters.Add(new SqlParameter("@Id", notifId));
                            cmd.Parameters.Add(new SqlParameter("@UserId", CurrentUserId));
                            using (var rdr = cmd.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    notifTitle = rdr["Title"]?.ToString() ?? string.Empty;
                                    notifMessage = rdr["Message"]?.ToString() ?? string.Empty;
                                    if (rdr["CreatedAt"] != DBNull.Value)
                                    {
                                        notifCreatedAt = Convert.ToDateTime(rdr["CreatedAt"]);
                                    }
                                }
                            }
                        }

                        // 2. Mark notification read
                        using (var cmd = conn.CreateCommand())
                        {
                            cmd.Transaction = tx;
                            cmd.CommandText = "UPDATE dbo.Notifications SET IsRead = 1, ActionRequired = 0 WHERE NotificationId = @Id AND UserId = @UserId";
                            cmd.Parameters.Add(new SqlParameter("@Id", notifId));
                            cmd.Parameters.Add(new SqlParameter("@UserId", CurrentUserId));
                            cmd.ExecuteNonQuery();
                        }

                        // 3. Find specific matching request (Collaboration or Connection)
                        var match = FindMatchingRequest(conn, tx, notifTitle, notifMessage, notifCreatedAt);
                        if (match != null)
                        {
                            string currentUserName = SecurityHelper.GetCurrentUserName();

                            if (match.IsCollaboration)
                            {
                                // Update collaboration request
                                using (var cmd = conn.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = "UPDATE dbo.CollaborationRequests SET Status = 'Accepted' WHERE RequestId = @RequestId AND Status = 'Pending'";
                                    cmd.Parameters.Add(new SqlParameter("@RequestId", match.RequestId));
                                    cmd.ExecuteNonQuery();
                                }

                                // Add to TeamMembers
                                using (var cmd = conn.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = @"
                                        IF NOT EXISTS (SELECT 1 FROM dbo.TeamMembers WHERE StartupId = @StartupId AND UserId = @SenderId)
                                        BEGIN
                                            INSERT INTO dbo.TeamMembers (StartupId, UserId, Name, Role, JoinedDate)
                                            VALUES (@StartupId, @SenderId, @SenderName, 'Co-Founder', SYSUTCDATETIME());
                                        END";
                                    cmd.Parameters.Add(new SqlParameter("@StartupId", match.StartupId));
                                    cmd.Parameters.Add(new SqlParameter("@SenderId", match.SenderUserId));
                                    cmd.Parameters.Add(new SqlParameter("@SenderName", match.SenderName));
                                    cmd.ExecuteNonQuery();
                                }

                                // Add to Connections
                                using (var cmd = conn.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = @"
                                        IF NOT EXISTS (SELECT 1 FROM dbo.Connections WHERE (RequesterUserId = @U1 AND ReceiverUserId = @U2) OR (RequesterUserId = @U2 AND ReceiverUserId = @U1))
                                        BEGIN
                                            INSERT INTO dbo.Connections (RequesterUserId, ReceiverUserId, Status, CreatedAt)
                                            VALUES (@U1, @U2, 'Connected', SYSUTCDATETIME());
                                        END";
                                    cmd.Parameters.Add(new SqlParameter("@U1", CurrentUserId));
                                    cmd.Parameters.Add(new SqlParameter("@U2", match.SenderUserId));
                                    cmd.ExecuteNonQuery();
                                }

                                // Notify the sender
                                using (var cmd = conn.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = @"
                                        INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, IsRead, CreatedAt)
                                        VALUES (@UserId, 'Collaboration Request Accepted!', @FounderName + ' accepted your request to collaborate on ' + @StartupName + '.', 'Matches', 0, 0, SYSUTCDATETIME());";
                                    cmd.Parameters.Add(new SqlParameter("@UserId", match.SenderUserId));
                                    cmd.Parameters.Add(new SqlParameter("@FounderName", currentUserName));
                                    cmd.Parameters.Add(new SqlParameter("@StartupName", match.StartupName));
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            else
                            {
                                // Update connection request
                                using (var cmd = conn.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = "UPDATE dbo.ConnectionRequests SET Status = 'Accepted' WHERE RequestId = @RequestId AND Status = 'Pending'";
                                    cmd.Parameters.Add(new SqlParameter("@RequestId", match.RequestId));
                                    cmd.ExecuteNonQuery();
                                }

                                // Add to Connections
                                using (var cmd = conn.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = @"
                                        IF NOT EXISTS (SELECT 1 FROM dbo.Connections WHERE (RequesterUserId = @U1 AND ReceiverUserId = @U2) OR (RequesterUserId = @U2 AND ReceiverUserId = @U1))
                                        BEGIN
                                            INSERT INTO dbo.Connections (RequesterUserId, ReceiverUserId, Status, CreatedAt)
                                            VALUES (@U1, @U2, 'Connected', SYSUTCDATETIME());
                                        END";
                                    cmd.Parameters.Add(new SqlParameter("@U1", CurrentUserId));
                                    cmd.Parameters.Add(new SqlParameter("@U2", match.SenderUserId));
                                    cmd.ExecuteNonQuery();
                                }

                                // Notify the sender
                                using (var cmd = conn.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = @"
                                        INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, IsRead, CreatedAt)
                                        VALUES (@UserId, 'Connection Request Accepted!', @ReceiverName + ' accepted your connection request.', 'Matches', 0, 0, SYSUTCDATETIME());";
                                    cmd.Parameters.Add(new SqlParameter("@UserId", match.SenderUserId));
                                    cmd.Parameters.Add(new SqlParameter("@ReceiverName", currentUserName));
                                    cmd.ExecuteNonQuery();
                                }
                            }
                        }
                    });

                    litSuccessMsg.Text = "Request successfully accepted! The team and connection have been updated.";
                    pnlSuccessAlert.Visible = true;
                    LoadNotifications();
                }
                else if (e.CommandName == "Decline")
                {
                    DbHelper.ExecuteInTransaction((conn, tx) =>
                    {
                        // 1. Fetch notification details
                        string notifTitle = string.Empty;
                        string notifMessage = string.Empty;
                        DateTime notifCreatedAt = DateTime.UtcNow;

                        using (var cmd = conn.CreateCommand())
                        {
                            cmd.Transaction = tx;
                            cmd.CommandText = "SELECT Title, Message, CreatedAt FROM dbo.Notifications WHERE NotificationId = @Id AND UserId = @UserId";
                            cmd.Parameters.Add(new SqlParameter("@Id", notifId));
                            cmd.Parameters.Add(new SqlParameter("@UserId", CurrentUserId));
                            using (var rdr = cmd.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    notifTitle = rdr["Title"]?.ToString() ?? string.Empty;
                                    notifMessage = rdr["Message"]?.ToString() ?? string.Empty;
                                    if (rdr["CreatedAt"] != DBNull.Value)
                                    {
                                        notifCreatedAt = Convert.ToDateTime(rdr["CreatedAt"]);
                                    }
                                }
                            }
                        }

                        // 2. Mark notification read and clear action required
                        using (var cmd = conn.CreateCommand())
                        {
                            cmd.Transaction = tx;
                            cmd.CommandText = "UPDATE dbo.Notifications SET IsRead = 1, ActionRequired = 0 WHERE NotificationId = @Id AND UserId = @UserId";
                            cmd.Parameters.Add(new SqlParameter("@Id", notifId));
                            cmd.Parameters.Add(new SqlParameter("@UserId", CurrentUserId));
                            cmd.ExecuteNonQuery();
                        }

                        // 3. Find specific matching request (Collaboration or Connection) without bulk declining
                        var match = FindMatchingRequest(conn, tx, notifTitle, notifMessage, notifCreatedAt);
                        if (match != null)
                        {
                            if (match.IsCollaboration)
                            {
                                using (var cmd = conn.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = "UPDATE dbo.CollaborationRequests SET Status = 'Declined' WHERE RequestId = @RequestId AND Status = 'Pending'";
                                    cmd.Parameters.Add(new SqlParameter("@RequestId", match.RequestId));
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            else
                            {
                                using (var cmd = conn.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = "UPDATE dbo.ConnectionRequests SET Status = 'Declined' WHERE RequestId = @RequestId AND Status = 'Pending'";
                                    cmd.Parameters.Add(new SqlParameter("@RequestId", match.RequestId));
                                    cmd.ExecuteNonQuery();
                                }
                            }
                        }
                    });

                    litSuccessMsg.Text = "Request declined.";
                    pnlSuccessAlert.Visible = true;
                    LoadNotifications();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("rptNotifications_ItemCommand error: " + ex);
            }
        }

        public string GetIconClass(string type)
        {
            switch (type)
            {
                case "Match": return "bg-success-subtle text-success";
                case "Request": return "bg-primary-subtle text-primary";
                case "System": return "bg-warning-subtle text-warning";
                default: return "bg-info-subtle text-info";
            }
        }

        public string GetIcon(string type)
        {
            switch (type)
            {
                case "Match": return "bi bi-stars";
                case "Request": return "bi bi-person-plus-fill";
                case "System": return "bi bi-shield-check";
                default: return "bi bi-bell-fill";
            }
        }

        public string FormatTime(object dateObj)
        {
            if (dateObj == null || dateObj == DBNull.Value) return "";
            DateTime dt = Convert.ToDateTime(dateObj);
            TimeSpan span = DateTime.Now - dt;

            if (span.TotalMinutes < 1) return "Just now";
            if (span.TotalMinutes < 60) return $"{(int)span.TotalMinutes}m ago";
            if (span.TotalHours < 24) return $"{(int)span.TotalHours}h ago";
            if (span.TotalDays < 7) return $"{(int)span.TotalDays}d ago";
            return dt.ToString("MMM dd");
        }

        private PendingRequestMatch FindMatchingRequest(SqlConnection conn, SqlTransaction tx, string notifTitle, string notifMessage, DateTime notifCreatedAt)
        {
            bool isConnHint = notifTitle.IndexOf("Connection", StringComparison.OrdinalIgnoreCase) >= 0
                           || notifMessage.IndexOf("connection", StringComparison.OrdinalIgnoreCase) >= 0;

            bool isCollabHint = notifTitle.IndexOf("Collaboration", StringComparison.OrdinalIgnoreCase) >= 0
                             || notifTitle.IndexOf("Join", StringComparison.OrdinalIgnoreCase) >= 0
                             || notifMessage.IndexOf("collaborat", StringComparison.OrdinalIgnoreCase) >= 0
                             || notifMessage.IndexOf("join", StringComparison.OrdinalIgnoreCase) >= 0;

            string collabSql = @"
                SELECT TOP 1 cr.RequestId, cr.SenderUserId, cr.StartupId, s.Name AS StartupName, u.FullName AS SenderName,
                       CASE WHEN @Message LIKE '%' + u.FullName + '%' THEN 1 ELSE 0 END AS NameMatched,
                       ABS(DATEDIFF(second, cr.CreatedAt, @CreatedAt)) AS TimeDiff
                FROM dbo.CollaborationRequests cr
                JOIN dbo.Startups s ON cr.StartupId = s.StartupId
                JOIN dbo.Users u ON cr.SenderUserId = u.UserId
                WHERE cr.ReceiverUserId = @UserId AND cr.Status = 'Pending'
                ORDER BY 
                    CASE WHEN @Message LIKE '%' + u.FullName + '%' THEN 0 ELSE 1 END,
                    ABS(DATEDIFF(second, cr.CreatedAt, @CreatedAt)) ASC,
                    cr.RequestId DESC";

            string connSql = @"
                SELECT TOP 1 cr.RequestId, cr.SenderId, u.FullName AS SenderName,
                       CASE WHEN @Message LIKE '%' + u.FullName + '%' THEN 1 ELSE 0 END AS NameMatched,
                       ABS(DATEDIFF(second, cr.CreatedAt, @CreatedAt)) AS TimeDiff
                FROM dbo.ConnectionRequests cr
                JOIN dbo.Users u ON cr.SenderId = u.UserId
                WHERE cr.ReceiverId = @UserId AND cr.Status = 'Pending'
                ORDER BY 
                    CASE WHEN @Message LIKE '%' + u.FullName + '%' THEN 0 ELSE 1 END,
                    ABS(DATEDIFF(second, cr.CreatedAt, @CreatedAt)) ASC,
                    cr.RequestId DESC";

            if (isCollabHint && !isConnHint)
            {
                var collabMatch = QueryCollabMatch(conn, tx, collabSql, notifMessage, notifCreatedAt);
                if (collabMatch != null) return collabMatch;
                return QueryConnMatch(conn, tx, connSql, notifMessage, notifCreatedAt);
            }

            if (isConnHint && !isCollabHint)
            {
                var connMatch = QueryConnMatch(conn, tx, connSql, notifMessage, notifCreatedAt);
                if (connMatch != null) return connMatch;
                return QueryCollabMatch(conn, tx, collabSql, notifMessage, notifCreatedAt);
            }

            var cMatch = QueryCollabMatch(conn, tx, collabSql, notifMessage, notifCreatedAt);
            var kMatch = QueryConnMatch(conn, tx, connSql, notifMessage, notifCreatedAt);

            if (cMatch != null && kMatch != null)
            {
                if (cMatch.NameMatched && !kMatch.NameMatched) return cMatch;
                if (kMatch.NameMatched && !cMatch.NameMatched) return kMatch;
                return cMatch.TimeDiffSeconds <= kMatch.TimeDiffSeconds ? cMatch : kMatch;
            }

            return cMatch ?? kMatch;
        }

        private PendingRequestMatch QueryCollabMatch(SqlConnection conn, SqlTransaction tx, string sql, string message, DateTime createdAt)
        {
            using (var cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = sql;
                cmd.Parameters.Add(new SqlParameter("@UserId", CurrentUserId));
                cmd.Parameters.Add(new SqlParameter("@Message", message ?? string.Empty));
                cmd.Parameters.Add(new SqlParameter("@CreatedAt", createdAt));

                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        return new PendingRequestMatch
                        {
                            IsCollaboration = true,
                            RequestId = Convert.ToInt32(rdr["RequestId"]),
                            SenderUserId = Convert.ToInt32(rdr["SenderUserId"]),
                            StartupId = Convert.ToInt32(rdr["StartupId"]),
                            StartupName = rdr["StartupName"]?.ToString() ?? string.Empty,
                            SenderName = rdr["SenderName"]?.ToString() ?? string.Empty,
                            NameMatched = Convert.ToInt32(rdr["NameMatched"]) == 1,
                            TimeDiffSeconds = Convert.ToDouble(rdr["TimeDiff"])
                        };
                    }
                }
            }
            return null;
        }

        private PendingRequestMatch QueryConnMatch(SqlConnection conn, SqlTransaction tx, string sql, string message, DateTime createdAt)
        {
            using (var cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = sql;
                cmd.Parameters.Add(new SqlParameter("@UserId", CurrentUserId));
                cmd.Parameters.Add(new SqlParameter("@Message", message ?? string.Empty));
                cmd.Parameters.Add(new SqlParameter("@CreatedAt", createdAt));

                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        return new PendingRequestMatch
                        {
                            IsCollaboration = false,
                            RequestId = Convert.ToInt32(rdr["RequestId"]),
                            SenderUserId = Convert.ToInt32(rdr["SenderId"]),
                            StartupId = 0,
                            StartupName = string.Empty,
                            SenderName = rdr["SenderName"]?.ToString() ?? string.Empty,
                            NameMatched = Convert.ToInt32(rdr["NameMatched"]) == 1,
                            TimeDiffSeconds = Convert.ToDouble(rdr["TimeDiff"])
                        };
                    }
                }
            }
            return null;
        }

        private class PendingRequestMatch
        {
            public bool IsCollaboration { get; set; }
            public int RequestId { get; set; }
            public int SenderUserId { get; set; }
            public string SenderName { get; set; }
            public int StartupId { get; set; }
            public string StartupName { get; set; }
            public bool NameMatched { get; set; }
            public double TimeDiffSeconds { get; set; }
        }
    }
}
