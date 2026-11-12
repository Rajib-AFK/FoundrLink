using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using FoundrLink.Core.Interfaces;
using FoundrLink.Core.Models;

namespace FoundrLink.DataAccess
{
    public class MessagingRepository : IMessagingRepository
    {
        public List<Conversation> GetUserConversations(int userId)
        {
            var list = new List<Conversation>();
            const string sql = @"
                SELECT c.ConversationId, c.User1Id, c.User2Id, c.LastMessageAt,
                       otherUser.UserId AS OtherUserId,
                       otherUser.FullName AS OtherUserName,
                       otherUser.Title AS OtherUserTitle,
                       otherUser.AvatarUrl AS OtherUserAvatar,
                       (SELECT TOP 1 Content FROM dbo.Messages WHERE ConversationId = c.ConversationId ORDER BY SentAt DESC) AS LastMessageContent,
                       (SELECT COUNT(*) FROM dbo.Messages WHERE ConversationId = c.ConversationId AND ReceiverId = @UserId AND IsRead = 0) AS UnreadCount
                FROM dbo.Conversations c
                CROSS APPLY (
                    SELECT UserId, FullName, Title, AvatarUrl
                    FROM dbo.Users
                    WHERE UserId = CASE WHEN c.User1Id = @UserId THEN c.User2Id ELSE c.User1Id END
                ) otherUser
                WHERE c.User1Id = @UserId OR c.User2Id = @UserId
                ORDER BY c.LastMessageAt DESC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new Conversation
                        {
                            ConversationId = Convert.ToInt32(reader["ConversationId"]),
                            User1Id = Convert.ToInt32(reader["User1Id"]),
                            User2Id = Convert.ToInt32(reader["User2Id"]),
                            OtherUserName = reader["OtherUserName"]?.ToString() ?? "User",
                            OtherUserTitle = reader["OtherUserTitle"]?.ToString() ?? string.Empty,
                            OtherUserAvatar = reader["OtherUserAvatar"]?.ToString() ?? string.Empty,
                            LastMessageContent = reader["LastMessageContent"]?.ToString() ?? string.Empty,
                            LastMessageAt = Convert.ToDateTime(reader["LastMessageAt"]),
                            UnreadCount = Convert.ToInt32(reader["UnreadCount"])
                        });
                    }
                }
            }
            return list;
        }

        public List<Message> GetConversationMessages(int conversationId, int currentUserId)
        {
            var list = new List<Message>();
            const string sql = @"
                SELECT MessageId, ConversationId, SenderId, ReceiverId, Content, IsRead, SentAt
                FROM dbo.Messages
                WHERE ConversationId = @ConversationId
                ORDER BY SentAt ASC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ConversationId", conversationId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new Message
                        {
                            MessageId = Convert.ToInt32(reader["MessageId"]),
                            ConversationId = Convert.ToInt32(reader["ConversationId"]),
                            SenderId = Convert.ToInt32(reader["SenderId"]),
                            ReceiverId = Convert.ToInt32(reader["ReceiverId"]),
                            Content = reader["Content"].ToString(),
                            IsRead = Convert.ToBoolean(reader["IsRead"]),
                            SentAt = Convert.ToDateTime(reader["SentAt"])
                        });
                    }
                }
            }

            // Mark unread messages as read
            MarkMessagesAsRead(conversationId, currentUserId);

            return list;
        }

        public int SendMessage(int conversationId, int senderId, int receiverId, string content)
        {
            if (string.IsNullOrWhiteSpace(content)) return 0;

            const string sql = @"
                INSERT INTO dbo.Messages (ConversationId, SenderId, ReceiverId, Content, IsRead, SentAt)
                VALUES (@ConversationId, @SenderId, @ReceiverId, @Content, 0, SYSUTCDATETIME());
                UPDATE dbo.Conversations SET LastMessageAt = SYSUTCDATETIME() WHERE ConversationId = @ConversationId;
                SELECT SCOPE_IDENTITY();";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ConversationId", conversationId);
                cmd.Parameters.AddWithValue("@SenderId", senderId);
                cmd.Parameters.AddWithValue("@ReceiverId", receiverId);
                cmd.Parameters.AddWithValue("@Content", content.Trim());

                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public int GetOrCreateConversation(int user1Id, int user2Id)
        {
            const string findSql = @"
                SELECT ConversationId FROM dbo.Conversations
                WHERE (User1Id = @U1 AND User2Id = @U2) OR (User1Id = @U2 AND User2Id = @U1);";

            using (var conn = DbConnectionFactory.OpenConnection())
            {
                using (var cmd = new SqlCommand(findSql, conn))
                {
                    cmd.Parameters.AddWithValue("@U1", user1Id);
                    cmd.Parameters.AddWithValue("@U2", user2Id);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        return Convert.ToInt32(result);
                    }
                }

                const string createSql = @"
                    INSERT INTO dbo.Conversations (User1Id, User2Id, LastMessageAt)
                    VALUES (@U1, @U2, SYSUTCDATETIME());
                    SELECT SCOPE_IDENTITY();";

                using (var cmd = new SqlCommand(createSql, conn))
                {
                    cmd.Parameters.AddWithValue("@U1", user1Id);
                    cmd.Parameters.AddWithValue("@U2", user2Id);
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
        }

        public bool MarkMessagesAsRead(int conversationId, int currentUserId)
        {
            const string sql = @"
                UPDATE dbo.Messages
                SET IsRead = 1
                WHERE ConversationId = @ConversationId AND ReceiverId = @UserId AND IsRead = 0;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ConversationId", conversationId);
                cmd.Parameters.AddWithValue("@UserId", currentUserId);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public int GetUnreadMessageCount(int userId)
        {
            const string sql = "SELECT COUNT(*) FROM dbo.Messages WHERE ReceiverId = @UserId AND IsRead = 0;";
            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }

    public class NotificationRepository : INotificationRepository
    {
        public List<Notification> GetUserNotifications(int userId, string filterType = "All")
        {
            var list = new List<Notification>();
            var sql = @"
                SELECT NotificationId, UserId, Title, Message, NotificationType, ActionRequired, IsRead, CreatedAt
                FROM dbo.Notifications
                WHERE UserId = @UserId ";

            if (!string.IsNullOrWhiteSpace(filterType) && !filterType.Equals("All", StringComparison.OrdinalIgnoreCase))
            {
                if (filterType.Equals("Unread", StringComparison.OrdinalIgnoreCase))
                {
                    sql += " AND IsRead = 0 ";
                }
                else
                {
                    sql += " AND NotificationType = @FilterType ";
                }
            }
            sql += " ORDER BY CreatedAt DESC;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                if (!string.IsNullOrWhiteSpace(filterType) && !filterType.Equals("All", StringComparison.OrdinalIgnoreCase) && !filterType.Equals("Unread", StringComparison.OrdinalIgnoreCase))
                {
                    cmd.Parameters.AddWithValue("@FilterType", filterType.Trim());
                }

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new Notification
                        {
                            NotificationId = Convert.ToInt32(reader["NotificationId"]),
                            UserId = Convert.ToInt32(reader["UserId"]),
                            Title = reader["Title"].ToString(),
                            Message = reader["Message"].ToString(),
                            NotificationType = reader["NotificationType"].ToString(),
                            ActionRequired = Convert.ToBoolean(reader["ActionRequired"]),
                            IsRead = Convert.ToBoolean(reader["IsRead"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }
            return list;
        }

        public int CreateNotification(int userId, string title, string message, string type, bool actionRequired)
        {
            const string sql = @"
                INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, IsRead, CreatedAt)
                VALUES (@UserId, @Title, @Message, @Type, @ActionRequired, 0, SYSUTCDATETIME());
                SELECT SCOPE_IDENTITY();";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@Title", title.Trim());
                cmd.Parameters.AddWithValue("@Message", message.Trim());
                cmd.Parameters.AddWithValue("@Type", string.IsNullOrWhiteSpace(type) ? "Activity" : type.Trim());
                cmd.Parameters.AddWithValue("@ActionRequired", actionRequired);

                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public bool MarkAsRead(int notificationId)
        {
            const string sql = "UPDATE dbo.Notifications SET IsRead = 1 WHERE NotificationId = @NotificationId;";
            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public bool MarkAllAsRead(int userId)
        {
            const string sql = "UPDATE dbo.Notifications SET IsRead = 1 WHERE UserId = @UserId AND IsRead = 0;";
            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public int GetUnreadNotificationCount(int userId)
        {
            const string sql = "SELECT COUNT(*) FROM dbo.Notifications WHERE UserId = @UserId AND IsRead = 0;";
            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public bool HandleCollaborationRequest(int notificationId, int userId, bool accept)
        {
            // Update notification action
            const string sql = @"
                UPDATE dbo.Notifications
                SET ActionRequired = 0, IsRead = 1,
                    Message = Message + ' [' + @Status + ']'
                WHERE NotificationId = @NotificationId AND UserId = @UserId;";

            using (var conn = DbConnectionFactory.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@Status", accept ? "Accepted" : "Declined");
                return cmd.ExecuteNonQuery() > 0;
            }
        }
    }
}
