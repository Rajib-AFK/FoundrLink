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
                    // Mark notification read and add activity
                    string sql = "UPDATE dbo.Notifications SET IsRead = 1, ActionRequired = 0 WHERE NotificationId = @Id AND UserId = @UserId";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", notifId), new SqlParameter("@UserId", CurrentUserId));

                    litSuccessMsg.Text = "Request successfully accepted! They have been notified.";
                    pnlSuccessAlert.Visible = true;
                    LoadNotifications();
                }
                else if (e.CommandName == "Decline")
                {
                    string sql = "UPDATE dbo.Notifications SET IsRead = 1, ActionRequired = 0 WHERE NotificationId = @Id AND UserId = @UserId";
                    DbHelper.ExecuteNonQuery(sql, new SqlParameter("@Id", notifId), new SqlParameter("@UserId", CurrentUserId));

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
    }
}
