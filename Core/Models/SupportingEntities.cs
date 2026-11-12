using System;

namespace FoundrLink.Core.Models
{
    public class OpenPosition : BaseEntity
    {
        public int PositionId
        {
            get { return Id; }
            set { Id = value; }
        }

        public int StartupId { get; set; }
        public string Title { get; set; }
        public string Location { get; set; }
        public string PositionType { get; set; }

        public OpenPosition()
            : base()
        {
            Title = string.Empty;
            Location = "Remote";
            PositionType = "Full-time";
        }
    }

    public class TeamMember : BaseEntity
    {
        public int TeamMemberId
        {
            get { return Id; }
            set { Id = value; }
        }

        public int StartupId { get; set; }
        public int? UserId { get; set; }
        public string Name { get; set; }
        public string Role { get; set; }
        public string AvatarUrl { get; set; }
        public DateTime JoinedDate { get; set; }

        public TeamMember()
            : base()
        {
            Name = string.Empty;
            Role = string.Empty;
            AvatarUrl = string.Empty;
            JoinedDate = DateTime.UtcNow;
        }
    }

    public class StartupUpdate : BaseEntity
    {
        public int UpdateId
        {
            get { return Id; }
            set { Id = value; }
        }

        public int StartupId { get; set; }
        public string AuthorName { get; set; }
        public string Content { get; set; }

        public StartupUpdate()
            : base()
        {
            AuthorName = string.Empty;
            Content = string.Empty;
        }
    }

    public class Conversation : BaseEntity
    {
        public int ConversationId
        {
            get { return Id; }
            set { Id = value; }
        }

        public int User1Id { get; set; }
        public int User2Id { get; set; }
        public string OtherUserName { get; set; }
        public string OtherUserTitle { get; set; }
        public string OtherUserAvatar { get; set; }
        public string LastMessageContent { get; set; }
        public DateTime LastMessageAt { get; set; }
        public int UnreadCount { get; set; }

        public Conversation()
            : base()
        {
            OtherUserName = string.Empty;
            OtherUserTitle = string.Empty;
            OtherUserAvatar = string.Empty;
            LastMessageContent = string.Empty;
            LastMessageAt = DateTime.UtcNow;
            UnreadCount = 0;
        }
    }

    public class Message : BaseEntity
    {
        public int MessageId
        {
            get { return Id; }
            set { Id = value; }
        }

        public int ConversationId { get; set; }
        public int SenderId { get; set; }
        public int ReceiverId { get; set; }
        public string Content { get; set; }
        public bool IsRead { get; set; }
        public DateTime SentAt { get; set; }

        public Message()
            : base()
        {
            Content = string.Empty;
            IsRead = false;
            SentAt = DateTime.UtcNow;
        }
    }

    public class Notification : BaseEntity
    {
        public int NotificationId
        {
            get { return Id; }
            set { Id = value; }
        }

        public int UserId { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
        public string NotificationType { get; set; }
        public bool ActionRequired { get; set; }
        public bool IsRead { get; set; }

        public Notification()
            : base()
        {
            Title = string.Empty;
            Message = string.Empty;
            NotificationType = "Activity";
            ActionRequired = false;
            IsRead = false;
        }
    }

    public class ConnectionRequest : BaseEntity
    {
        public int RequestId
        {
            get { return Id; }
            set { Id = value; }
        }

        public int SenderId { get; set; }
        public string SenderName { get; set; }
        public string SenderRole { get; set; }
        public int ReceiverId { get; set; }
        public int? StartupId { get; set; }
        public string StartupName { get; set; }
        public string Note { get; set; }
        public string Status { get; set; }

        public ConnectionRequest()
            : base()
        {
            SenderName = string.Empty;
            SenderRole = string.Empty;
            StartupName = string.Empty;
            Note = string.Empty;
            Status = "Pending";
        }
    }

    public class ModerationReport : BaseEntity
    {
        public int ReportId
        {
            get { return Id; }
            set { Id = value; }
        }

        public string ReportCode { get; set; }
        public string ReporterEmail { get; set; }
        public string ReportedItem { get; set; }
        public string ReportType { get; set; }
        public string Priority { get; set; }
        public string Details { get; set; }
        public string Status { get; set; }
        public DateTime? ResolvedAt { get; set; }

        public ModerationReport()
            : base()
        {
            ReportCode = string.Empty;
            ReporterEmail = string.Empty;
            ReportedItem = string.Empty;
            ReportType = "Spam";
            Priority = "Medium";
            Details = string.Empty;
            Status = "Pending";
        }

        public string GetPriorityBadgeClass()
        {
            string currentPriority = Priority != null ? Priority.ToLowerInvariant() : string.Empty;
            switch (currentPriority)
            {
                case "high":
                    return "badge-priority-high";
                case "medium":
                    return "badge-priority-medium";
                default:
                    return "badge-priority-low";
            }
        }
    }
}
