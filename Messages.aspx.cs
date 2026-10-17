using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class Messages : Page
    {
        public int CurrentUserId { get; set; } = 1;
        public int ActivePartnerId { get; set; } = 4; // Default to Ananya Iyer (UserId 4) or first contact

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] != null)
            {
                CurrentUserId = Convert.ToInt32(Session["UserId"]);
            }

            if (!string.IsNullOrEmpty(Request.QueryString["partnerId"]))
            {
                if (int.TryParse(Request.QueryString["partnerId"], out int pId))
                {
                    ActivePartnerId = pId;
                }
            }

            if (!IsPostBack)
            {
                LoadThreads();
                LoadActivePartner();
                LoadMessages();
            }
        }

        private void LoadThreads()
        {
            string search = txtSearchThreads.Text.Trim();
            string sql = @"
                SELECT 
                    u.UserId AS PartnerUserId,
                    u.FullName,
                    u.AvatarUrl,
                    u.Role,
                    u.Company,
                    c.ConversationId,
                    c.LastMessageAt,
                    (SELECT TOP 1 Content FROM Messages WHERE ConversationId = c.ConversationId ORDER BY SentAt DESC) AS LastMessage,
                    (SELECT COUNT(1) FROM Messages WHERE ConversationId = c.ConversationId AND ReceiverId = @UserId AND IsRead = 0) AS UnreadCount,
                    FORMAT(ISNULL(c.LastMessageAt, GETDATE()), 'hh:mm tt') AS TimeText
                FROM Conversations c
                INNER JOIN Users u ON (CASE WHEN c.User1Id = @UserId THEN c.User2Id ELSE c.User1Id END) = u.UserId
                WHERE (c.User1Id = @UserId OR c.User2Id = @UserId)
            ";

            if (!string.IsNullOrEmpty(search))
            {
                sql += " AND (u.FullName LIKE '%' + @Search + '%' OR u.Company LIKE '%' + @Search + '%')";
            }

            sql += " ORDER BY c.LastMessageAt DESC";

            SqlParameter[] p = new SqlParameter[]
            {
                new SqlParameter("@UserId", CurrentUserId),
                new SqlParameter("@Search", search)
            };

            DataTable dt = DbHelper.ExecuteDataTable(sql, p);

            // If no conversations found, check if we need to load active partner or create one
            if (dt.Rows.Count > 0 && Request.QueryString["partnerId"] == null)
            {
                ActivePartnerId = Convert.ToInt32(dt.Rows[0]["PartnerUserId"]);
            }

            rptThreads.DataSource = dt;
            rptThreads.DataBind();
        }

        private void LoadActivePartner()
        {
            string sql = "SELECT UserId, FullName, Role, Company, AvatarUrl FROM Users WHERE UserId = @PartnerId";
            SqlParameter[] p = { new SqlParameter("@PartnerId", ActivePartnerId) };
            DataTable dt = DbHelper.ExecuteDataTable(sql, p);

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                litActivePartnerName.Text = r["FullName"].ToString();
                litActivePartnerRole.Text = $"{r["Role"]} @ {r["Company"]}";
                imgActivePartner.ImageUrl = !string.IsNullOrEmpty(r["AvatarUrl"]?.ToString()) 
                    ? r["AvatarUrl"].ToString() 
                    : "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100";
                lnkViewProfile.HRef = "Profile.aspx?id=" + ActivePartnerId;
            }
            else
            {
                litActivePartnerName.Text = "Team Member";
                litActivePartnerRole.Text = "FoundrLink Member";
            }
        }

        private void LoadMessages()
        {
            // Find or get conversation id
            int convId = GetOrCreateConversationId(CurrentUserId, ActivePartnerId);

            // Mark unread messages as read
            string markReadSql = "UPDATE Messages SET IsRead = 1 WHERE ConversationId = @ConvId AND ReceiverId = @UserId";
            DbHelper.ExecuteNonQuery(markReadSql, new SqlParameter("@ConvId", convId), new SqlParameter("@UserId", CurrentUserId));

            // Query messages
            string sql = @"
                SELECT 
                    MessageId,
                    ConversationId,
                    SenderId,
                    ReceiverId,
                    Content,
                    SentAt,
                    FORMAT(SentAt, 'hh:mm tt') AS TimeText
                FROM Messages
                WHERE ConversationId = @ConvId
                ORDER BY SentAt ASC
            ";

            DataTable dt = DbHelper.ExecuteDataTable(sql, new SqlParameter("@ConvId", convId));
            rptMessages.DataSource = dt;
            rptMessages.DataBind();
        }

        private int GetOrCreateConversationId(int u1, int u2)
        {
            string findSql = "SELECT ConversationId FROM Conversations WHERE (User1Id = @U1 AND User2Id = @U2) OR (User1Id = @U2 AND User2Id = @U1)";
            object obj = DbHelper.ExecuteScalar(findSql, new SqlParameter("@U1", u1), new SqlParameter("@U2", u2));

            if (obj != null && obj != DBNull.Value)
            {
                return Convert.ToInt32(obj);
            }

            // Create new conversation
            string insertSql = @"
                INSERT INTO Conversations (User1Id, User2Id, LastMessageAt)
                OUTPUT INSERTED.ConversationId
                VALUES (@U1, @U2, GETDATE())
            ";
            return Convert.ToInt32(DbHelper.ExecuteScalar(insertSql, new SqlParameter("@U1", u1), new SqlParameter("@U2", u2)));
        }

        protected void txtSearchThreads_TextChanged(object sender, EventArgs e)
        {
            LoadThreads();
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string msg = txtMessageInput.Text.Trim();
            if (string.IsNullOrEmpty(msg)) return;

            int convId = GetOrCreateConversationId(CurrentUserId, ActivePartnerId);

            string sql = @"
                INSERT INTO Messages (ConversationId, SenderId, ReceiverId, Content, IsRead, SentAt)
                VALUES (@ConvId, @SenderId, @ReceiverId, @Content, 0, GETDATE());

                UPDATE Conversations
                SET LastMessageAt = GETDATE()
                WHERE ConversationId = @ConvId;
            ";

            SqlParameter[] p = new SqlParameter[]
            {
                new SqlParameter("@ConvId", convId),
                new SqlParameter("@SenderId", CurrentUserId),
                new SqlParameter("@ReceiverId", ActivePartnerId),
                new SqlParameter("@Content", msg)
            };

            DbHelper.ExecuteNonQuery(sql, p);

            txtMessageInput.Text = string.Empty;

            LoadThreads();
            LoadMessages();
        }
    }
}
