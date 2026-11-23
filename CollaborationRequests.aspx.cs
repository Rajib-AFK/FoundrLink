using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class CollaborationRequests : Page
    {
        public string ActiveTab
        {
            get => ViewState["ActiveTab"] as string ?? "Received";
            set => ViewState["ActiveTab"] = value;
        }

        public string ActiveFilter
        {
            get => ViewState["ActiveFilter"] as string ?? "All";
            set => ViewState["ActiveFilter"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            pnlAlert.Visible = false;

            if (!IsPostBack)
            {
                string tabParam = Request.QueryString["tab"];
                if (!string.IsNullOrEmpty(tabParam) && (tabParam.Equals("Sent", StringComparison.OrdinalIgnoreCase) || tabParam.Equals("Received", StringComparison.OrdinalIgnoreCase)))
                {
                    ActiveTab = tabParam;
                }
                LoadRequests();
            }
        }

        private void LoadRequests()
        {
            int? currentUserId = SecurityHelper.GetCurrentUserId();
            if (!currentUserId.HasValue) return;

            int userId = currentUserId.Value;

            try
            {
                // Tab styling
                string activeTabCls = "pb-3 px-4 fw-bold text-decoration-none border-bottom border-2 border-dark text-dark";
                string inactiveTabCls = "pb-3 px-4 fw-medium text-decoration-none text-muted";

                btnTabReceived.CssClass = ActiveTab == "Received" ? activeTabCls : inactiveTabCls;
                btnTabSent.CssClass = ActiveTab == "Sent" ? activeTabCls : inactiveTabCls;

                // Pill styling
                string activePill = "btn btn-sm btn-dark rounded-pill px-3 py-1 fw-medium";
                string inactivePill = "btn btn-sm btn-outline-secondary rounded-pill px-3 py-1 fw-medium";

                btnFilterAll.CssClass = ActiveFilter == "All" ? activePill : inactivePill;
                btnFilterPending.CssClass = ActiveFilter == "Pending" ? activePill : inactivePill;
                btnFilterAccepted.CssClass = ActiveFilter == "Accepted" ? activePill : inactivePill;
                btnFilterDeclined.CssClass = ActiveFilter == "Declined" ? activePill : inactivePill;
                btnFilterWithdrawn.CssClass = ActiveFilter == "Withdrawn" ? activePill : inactivePill;

                // Load Counts
                object recCount = DbHelper.ExecuteScalar(@"
                    SELECT 
                        (SELECT COUNT(1) FROM dbo.CollaborationRequests WHERE ReceiverUserId = @UserId AND Status = 'Pending') +
                        (SELECT COUNT(1) FROM dbo.ConnectionRequests WHERE ReceiverId = @UserId AND Status = 'Pending')",
                    DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                litReceivedCount.Text = recCount?.ToString() ?? "0";

                object sentCount = DbHelper.ExecuteScalar(@"
                    SELECT 
                        (SELECT COUNT(1) FROM dbo.CollaborationRequests WHERE SenderUserId = @UserId AND Status = 'Pending') +
                        (SELECT COUNT(1) FROM dbo.ConnectionRequests WHERE SenderId = @UserId AND Status = 'Pending')",
                    DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                litSentCount.Text = sentCount?.ToString() ?? "0";

                // Query requests
                string sql;
                if (ActiveTab == "Received")
                {
                    sql = @"
                        SELECT 'Startup' AS ReqType, 'Startup Application' AS ReqTypeLabel, cr.RequestId, cr.StartupId, cr.Message, cr.Status, cr.CreatedAt,
                               u.UserId AS PartnerUserId, u.FullName AS PartnerName, u.Title AS PartnerTitle, u.AvatarUrl AS PartnerAvatar,
                               s.Name AS StartupName
                        FROM dbo.CollaborationRequests cr
                        INNER JOIN dbo.Users u ON cr.SenderUserId = u.UserId
                        INNER JOIN dbo.Startups s ON cr.StartupId = s.StartupId
                        WHERE cr.ReceiverUserId = @UserId" + (ActiveFilter != "All" ? " AND cr.Status = @Status" : "") + @"

                        UNION ALL

                        SELECT 'Connection' AS ReqType, 'Co-Founder Connection' AS ReqTypeLabel, con.RequestId, COALESCE(con.StartupId, 0) AS StartupId, con.Note AS Message, con.Status, con.CreatedAt,
                               u.UserId AS PartnerUserId, u.FullName AS PartnerName, u.Title AS PartnerTitle, u.AvatarUrl AS PartnerAvatar,
                               COALESCE(s.Name, 'Direct Connection') AS StartupName
                        FROM dbo.ConnectionRequests con
                        INNER JOIN dbo.Users u ON con.SenderId = u.UserId
                        LEFT JOIN dbo.Startups s ON con.StartupId = s.StartupId
                        WHERE con.ReceiverId = @UserId" + (ActiveFilter != "All" ? " AND con.Status = @Status" : "") + @"

                        ORDER BY CreatedAt DESC";
                }
                else
                {
                    sql = @"
                        SELECT 'Startup' AS ReqType, 'Startup Application' AS ReqTypeLabel, cr.RequestId, cr.StartupId, cr.Message, cr.Status, cr.CreatedAt,
                               u.UserId AS PartnerUserId, u.FullName AS PartnerName, u.Title AS PartnerTitle, u.AvatarUrl AS PartnerAvatar,
                               s.Name AS StartupName
                        FROM dbo.CollaborationRequests cr
                        INNER JOIN dbo.Users u ON cr.ReceiverUserId = u.UserId
                        INNER JOIN dbo.Startups s ON cr.StartupId = s.StartupId
                        WHERE cr.SenderUserId = @UserId" + (ActiveFilter != "All" ? " AND cr.Status = @Status" : "") + @"

                        UNION ALL

                        SELECT 'Connection' AS ReqType, 'Co-Founder Connection' AS ReqTypeLabel, con.RequestId, COALESCE(con.StartupId, 0) AS StartupId, con.Note AS Message, con.Status, con.CreatedAt,
                               u.UserId AS PartnerUserId, u.FullName AS PartnerName, u.Title AS PartnerTitle, u.AvatarUrl AS PartnerAvatar,
                               COALESCE(s.Name, 'Direct Connection') AS StartupName
                        FROM dbo.ConnectionRequests con
                        INNER JOIN dbo.Users u ON con.ReceiverId = u.UserId
                        LEFT JOIN dbo.Startups s ON con.StartupId = s.StartupId
                        WHERE con.SenderId = @UserId" + (ActiveFilter != "All" ? " AND con.Status = @Status" : "") + @"

                        ORDER BY CreatedAt DESC";
                }

                DataTable dt;
                if (ActiveFilter != "All")
                {
                    dt = DbHelper.ExecuteDataTable(sql,
                        DbHelper.CreateParam("@UserId", SqlDbType.Int, userId),
                        DbHelper.CreateParam("@Status", SqlDbType.NVarChar, ActiveFilter));
                }
                else
                {
                    dt = DbHelper.ExecuteDataTable(sql, DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                }

                if (dt.Rows.Count > 0)
                {
                    rptRequests.Visible = true;
                    pnlEmpty.Visible = false;
                    rptRequests.DataSource = dt;
                    rptRequests.DataBind();
                }
                else
                {
                    rptRequests.Visible = false;
                    pnlEmpty.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("CollaborationRequests error: " + ex);
            }
        }

        protected void Tab_Click(object sender, EventArgs e)
        {
            if (sender is LinkButton btn)
            {
                ActiveTab = btn.CommandArgument;
                ActiveFilter = "All";
                LoadRequests();
            }
        }

        protected void Filter_Click(object sender, EventArgs e)
        {
            if (sender is LinkButton btn)
            {
                ActiveFilter = btn.CommandArgument;
                LoadRequests();
            }
        }

        protected void rptRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int? currentUserId = SecurityHelper.GetCurrentUserId();
            if (!currentUserId.HasValue) return;

            int userId = currentUserId.Value;
            string rawArg = e.CommandArgument?.ToString() ?? "";
            string reqType = "Startup";
            int requestId = 0;

            if (rawArg.Contains(":"))
            {
                var parts = rawArg.Split(':');
                reqType = parts[0];
                int.TryParse(parts[1], out requestId);
            }
            else
            {
                int.TryParse(rawArg, out requestId);
            }

            if (requestId == 0) return;

            try
            {
                if (e.CommandName == "Accept")
                {
                    if (reqType == "Connection")
                    {
                        // Handle peer co-founder connection
                        string conQuery = @"
                            SELECT con.RequestId, con.SenderId, con.ReceiverId, u.FullName AS SenderName
                            FROM dbo.ConnectionRequests con
                            JOIN dbo.Users u ON con.SenderId = u.UserId
                            WHERE con.RequestId = @Id AND con.ReceiverId = @UserId AND con.Status = 'Pending'";

                        DataTable dt = DbHelper.ExecuteDataTable(conQuery,
                            DbHelper.CreateParam("@Id", SqlDbType.Int, requestId),
                            DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));

                        if (dt.Rows.Count == 0)
                        {
                            ShowAlert("The connection request could not be found or has already been resolved.", "warning");
                            LoadRequests();
                            return;
                        }

                        int senderId = Convert.ToInt32(dt.Rows[0]["SenderId"]);
                        string senderName = dt.Rows[0]["SenderName"]?.ToString();
                        string currentUserName = SecurityHelper.GetCurrentUserName();

                        DbHelper.ExecuteInTransaction((conn, tx) =>
                        {
                            // 1. Update ConnectionRequests
                            using (var cmd = conn.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = "UPDATE dbo.ConnectionRequests SET Status = 'Accepted' WHERE RequestId = @Id";
                                cmd.Parameters.Add(DbHelper.CreateParam("@Id", SqlDbType.Int, requestId));
                                cmd.ExecuteNonQuery();
                            }

                            // 2. Add to Connections
                            using (var cmd = conn.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    IF NOT EXISTS (SELECT 1 FROM dbo.Connections WHERE (RequesterUserId = @U1 AND ReceiverUserId = @U2) OR (RequesterUserId = @U2 AND ReceiverUserId = @U1))
                                    BEGIN
                                        INSERT INTO dbo.Connections (RequesterUserId, ReceiverUserId, Status, CreatedAt)
                                        VALUES (@U1, @U2, 'Connected', SYSUTCDATETIME());
                                    END";
                                cmd.Parameters.Add(DbHelper.CreateParam("@U1", SqlDbType.Int, userId));
                                cmd.Parameters.Add(DbHelper.CreateParam("@U2", SqlDbType.Int, senderId));
                                cmd.ExecuteNonQuery();
                            }

                            // 3. Notify requester
                            using (var cmd = conn.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, IsRead, CreatedAt)
                                    VALUES (@UserId, 'Connection Request Accepted!', @FounderName + ' accepted your connection request.', 'Matches', 0, 0, SYSUTCDATETIME());";
                                cmd.Parameters.Add(DbHelper.CreateParam("@UserId", SqlDbType.Int, senderId));
                                cmd.Parameters.Add(DbHelper.CreateParam("@FounderName", SqlDbType.NVarChar, currentUserName));
                                cmd.ExecuteNonQuery();
                            }

                            // 4. Mark pending notification read for receiver
                            using (var cmd = conn.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = "UPDATE dbo.Notifications SET IsRead = 1, ActionRequired = 0 WHERE UserId = @UserId AND NotificationType = 'Requests' AND Message LIKE '%' + @SenderName + '%'";
                                cmd.Parameters.Add(DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                                cmd.Parameters.Add(DbHelper.CreateParam("@SenderName", SqlDbType.NVarChar, senderName));
                                cmd.ExecuteNonQuery();
                            }
                        });

                        ShowAlert("Connection accepted! You and " + Server.HtmlEncode(senderName) + " are now connected.", "success");
                        LoadRequests();
                        return;
                    }
                    else
                    {
                        // Startup Collaboration
                        string reqQuery = @"
                            SELECT cr.RequestId, cr.SenderUserId, cr.ReceiverUserId, cr.StartupId, s.Name AS StartupName,
                                   u.FullName AS SenderName, u.Title AS SenderRole, u.AvatarUrl AS SenderAvatar
                            FROM dbo.CollaborationRequests cr
                            JOIN dbo.Startups s ON cr.StartupId = s.StartupId
                            JOIN dbo.Users u ON cr.SenderUserId = u.UserId
                            WHERE cr.RequestId = @Id AND cr.ReceiverUserId = @UserId AND cr.Status = 'Pending'";

                        DataTable dt = DbHelper.ExecuteDataTable(reqQuery,
                            DbHelper.CreateParam("@Id", SqlDbType.Int, requestId),
                            DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));

                        if (dt.Rows.Count == 0)
                        {
                            ShowAlert("The request could not be found or has already been resolved.", "warning");
                            LoadRequests();
                            return;
                        }

                        DataRow row = dt.Rows[0];
                        int senderId = Convert.ToInt32(row["SenderUserId"]);
                        int startupId = Convert.ToInt32(row["StartupId"]);
                        string startupName = row["StartupName"]?.ToString();
                        string senderName = row["SenderName"]?.ToString();
                        string senderRole = row["SenderRole"]?.ToString() ?? "Co-Founder";
                        string senderAvatar = row["SenderAvatar"]?.ToString();
                        string currentUserName = SecurityHelper.GetCurrentUserName();

                        DbHelper.ExecuteInTransaction((conn, tx) =>
                        {
                            // 1. Update CollaborationRequests status
                            using (var cmd = conn.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = "UPDATE dbo.CollaborationRequests SET Status = 'Accepted' WHERE RequestId = @Id";
                                cmd.Parameters.Add(DbHelper.CreateParam("@Id", SqlDbType.Int, requestId));
                                cmd.ExecuteNonQuery();
                            }

                            // 2. Add to TeamMembers
                            using (var cmd = conn.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    IF NOT EXISTS (SELECT 1 FROM dbo.TeamMembers WHERE StartupId = @StartupId AND UserId = @UserId)
                                    BEGIN
                                        INSERT INTO dbo.TeamMembers (StartupId, UserId, Name, Role, AvatarUrl, JoinedDate)
                                        VALUES (@StartupId, @UserId, @Name, @Role, @AvatarUrl, SYSUTCDATETIME());
                                    END";
                                cmd.Parameters.Add(DbHelper.CreateParam("@StartupId", SqlDbType.Int, startupId));
                                cmd.Parameters.Add(DbHelper.CreateParam("@UserId", SqlDbType.Int, senderId));
                                cmd.Parameters.Add(DbHelper.CreateParam("@Name", SqlDbType.NVarChar, senderName));
                                cmd.Parameters.Add(DbHelper.CreateParam("@Role", SqlDbType.NVarChar, senderRole));
                                cmd.Parameters.Add(DbHelper.CreateParam("@AvatarUrl", SqlDbType.NVarChar, senderAvatar));
                                cmd.ExecuteNonQuery();
                            }

                            // 3. Add to Connections
                            using (var cmd = conn.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    IF NOT EXISTS (SELECT 1 FROM dbo.Connections WHERE (RequesterUserId = @U1 AND ReceiverUserId = @U2) OR (RequesterUserId = @U2 AND ReceiverUserId = @U1))
                                    BEGIN
                                        INSERT INTO dbo.Connections (RequesterUserId, ReceiverUserId, Status, CreatedAt)
                                        VALUES (@U1, @U2, 'Connected', SYSUTCDATETIME());
                                    END";
                                cmd.Parameters.Add(DbHelper.CreateParam("@U1", SqlDbType.Int, userId));
                                cmd.Parameters.Add(DbHelper.CreateParam("@U2", SqlDbType.Int, senderId));
                                cmd.ExecuteNonQuery();
                            }

                            // 4. Notify requester
                            using (var cmd = conn.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, IsRead, CreatedAt)
                                    VALUES (@UserId, 'Collaboration Request Accepted!', @FounderName + ' accepted your request to collaborate on ' + @StartupName + '.', 'Matches', 0, 0, SYSUTCDATETIME());";
                                cmd.Parameters.Add(DbHelper.CreateParam("@UserId", SqlDbType.Int, senderId));
                                cmd.Parameters.Add(DbHelper.CreateParam("@FounderName", SqlDbType.NVarChar, currentUserName));
                                cmd.Parameters.Add(DbHelper.CreateParam("@StartupName", SqlDbType.NVarChar, startupName));
                                cmd.ExecuteNonQuery();
                            }

                            // 5. Mark pending notification read for receiver
                            using (var cmd = conn.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = "UPDATE dbo.Notifications SET IsRead = 1, ActionRequired = 0 WHERE UserId = @UserId AND NotificationType = 'Requests' AND Message LIKE '%' + @SenderName + '%'";
                                cmd.Parameters.Add(DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                                cmd.Parameters.Add(DbHelper.CreateParam("@SenderName", SqlDbType.NVarChar, senderName));
                                cmd.ExecuteNonQuery();
                            }
                        });

                        ShowAlert("Request accepted successfully! " + Server.HtmlEncode(senderName) + " is now part of " + Server.HtmlEncode(startupName) + ".", "success");
                        LoadRequests();
                    }
                }
                else if (e.CommandName == "Decline")
                {
                    if (reqType == "Connection")
                    {
                        string sql = @"
                            UPDATE dbo.ConnectionRequests 
                            SET Status = 'Declined' 
                            WHERE RequestId = @Id AND ReceiverId = @UserId AND Status = 'Pending';";

                        DbHelper.ExecuteNonQuery(sql,
                            DbHelper.CreateParam("@Id", SqlDbType.Int, requestId),
                            DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                    }
                    else
                    {
                        string sql = @"
                            UPDATE dbo.CollaborationRequests 
                            SET Status = 'Declined' 
                            WHERE RequestId = @Id AND ReceiverUserId = @UserId AND Status = 'Pending';";

                        DbHelper.ExecuteNonQuery(sql,
                            DbHelper.CreateParam("@Id", SqlDbType.Int, requestId),
                            DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                    }

                    ShowAlert("Request has been declined.", "info");
                    LoadRequests();
                }
                else if (e.CommandName == "Withdraw")
                {
                    if (reqType == "Connection")
                    {
                        string sql = @"
                            UPDATE dbo.ConnectionRequests 
                            SET Status = 'Declined' 
                            WHERE RequestId = @Id AND SenderId = @UserId AND Status = 'Pending';";

                        DbHelper.ExecuteNonQuery(sql,
                            DbHelper.CreateParam("@Id", SqlDbType.Int, requestId),
                            DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                    }
                    else
                    {
                        string sql = @"
                            UPDATE dbo.CollaborationRequests 
                            SET Status = 'Withdrawn' 
                            WHERE RequestId = @Id AND SenderUserId = @UserId AND Status = 'Pending';";

                        DbHelper.ExecuteNonQuery(sql,
                            DbHelper.CreateParam("@Id", SqlDbType.Int, requestId),
                            DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                    }

                    ShowAlert("Your request has been withdrawn.", "info");
                    LoadRequests();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("rptRequests_ItemCommand error: " + ex);
                ShowAlert("An error occurred while updating the request. Please try again.", "danger");
            }
        }

        private void ShowAlert(string msg, string type)
        {
            litAlertMessage.Text = msg;
            pnlAlert.CssClass = $"alert alert-{type} alert-dismissible fade show mb-4";
            pnlAlert.Visible = true;
        }
    }
}
