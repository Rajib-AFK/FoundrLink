using System;
using System.Collections.Generic;
using FoundrLink.Core.Models;

namespace FoundrLink.Core.Interfaces
{
    public interface IRepository<T> where T : BaseEntity
    {
        T GetById(int id);
        List<T> GetAll();
        int Add(T entity);
        bool Update(T entity);
        bool Delete(int id);
    }

    public interface IUserRepository
    {
        BaseUser GetUserById(int userId);
        BaseUser GetUserByEmail(string email);
        BaseUser Authenticate(string email, string password);
        int RegisterUser(string fullName, string email, string password, UserRole role, string title = null, string location = null);
        bool UpdateProfile(int userId, string fullName, string email, string company, string bio, string location, string title);
        bool ChangePassword(int userId, string oldPassword, string newPassword);
        FounderProfile GetFounderProfile(int userId);
        bool SaveFounderProfile(FounderProfile profile);
        List<BaseUser> SearchCoFounders(string roleFilter, string skillFilter, string availabilityFilter, string keyword);
        List<BaseUser> GetSuggestedConnections(int currentUserId, int limit = 3);
        int GetTotalUserCount();
    }

    public interface IStartupRepository
    {
        Startup GetStartupById(int startupId);
        List<Startup> GetStartups(string search = null, string industry = null, string stage = null, string skill = null, string sortBy = "Best Match");
        List<Startup> GetStartupsByFounder(int founderId);
        List<Startup> GetFeaturedStartups(int limit = 3);
        int CreateStartup(Startup startup);
        bool UpdateStartup(Startup startup);
        bool DeleteStartup(int startupId);
        List<OpenPosition> GetOpenPositions(int startupId);
        List<TeamMember> GetTeamMembers(int startupId);
        List<StartupUpdate> GetStartupUpdates(int startupId);
        bool AddOpenPosition(int startupId, string title, string location, string type);
        bool DeleteOpenPosition(int positionId);
        bool AddTeamMember(int startupId, string name, string role, string avatarUrl);
        bool RequestToJoin(int senderUserId, int startupId, string note);
    }

    public interface IMessagingRepository
    {
        List<Conversation> GetUserConversations(int userId);
        List<Message> GetConversationMessages(int conversationId, int currentUserId);
        int SendMessage(int conversationId, int senderId, int receiverId, string content);
        int GetOrCreateConversation(int user1Id, int user2Id);
        bool MarkMessagesAsRead(int conversationId, int currentUserId);
        int GetUnreadMessageCount(int userId);
    }

    public interface INotificationRepository
    {
        List<Notification> GetUserNotifications(int userId, string filterType = "All");
        int CreateNotification(int userId, string title, string message, string type, bool actionRequired);
        bool MarkAsRead(int notificationId);
        bool MarkAllAsRead(int userId);
        int GetUnreadNotificationCount(int userId);
        bool HandleCollaborationRequest(int notificationId, int userId, bool accept);
    }

    public interface IAdminRepository
    {
        AdminDashboardMetrics GetDashboardMetrics();
        List<BaseUser> GetRecentRegistrations(int limit = 10);
        List<Startup> GetStartupSubmissions(string status = null);
        bool UpdateStartupStatus(int startupId, string newStatus);
        List<BaseUser> GetManageUsersList(string search = null, string role = null, string status = null);
        bool UpdateUserStatus(int userId, string newStatus);
        List<ModerationReport> GetModerationReports(string typeFilter = "All");
        bool ResolveModerationReport(int reportId, string action);
    }

    public class AdminDashboardMetrics
    {
        public int TotalUsers { get; set; }
        public int ActiveStartups { get; set; }
        public int PendingReports { get; set; }
        public int TotalMatchRequests { get; set; }
        public decimal TotalCapitalDeployed { get; set; }
    }

    public interface IMatchmakingEngine
    {
        double CalculateMatchScore(FounderProfile profile, Startup startup);
        double CalculateFounderSynergy(BaseUser userA, FounderProfile profileA, BaseUser userB, FounderProfile profileB);
        List<Startup> RankStartupsForUser(FounderProfile userProfile, List<Startup> candidates);
    }
}
