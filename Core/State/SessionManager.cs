using System;
using System.Web;
using FoundrLink.Core.Models;

namespace FoundrLink.Core.State
{
    /// <summary>
    /// Demonstrates Syllabus Unit 8: State Management (Server-Side Session State).
    /// Provides strongly-typed, safe access to ASP.NET Session state,
    /// abstracting raw Session object dictionary access and handling expiration gracefully.
    /// Uses classic C# CTS types and defensive null checks strictly following the syllabus.
    /// </summary>
    public static class SessionManager
    {
        private const string KeyUserId = "FoundrLink_UserId";
        private const string KeyCurrentUser = "FoundrLink_CurrentUser";
        private const string KeyUserRole = "FoundrLink_UserRole";
        private const string KeyFlashMessage = "FoundrLink_FlashMessage";
        private const string KeyFlashType = "FoundrLink_FlashType";

        private static HttpSessionStateBase Session
        {
            get
            {
                if (HttpContext.Current == null || HttpContext.Current.Session == null)
                {
                    return null;
                }
                return new HttpSessionStateWrapper(HttpContext.Current.Session);
            }
        }

        public static bool IsAuthenticated
        {
            get
            {
                if (Session != null && Session[KeyUserId] != null)
                {
                    int id = Convert.ToInt32(Session[KeyUserId]);
                    return id > 0;
                }
                return false;
            }
        }

        public static int CurrentUserId
        {
            get
            {
                if (Session != null && Session[KeyUserId] != null)
                {
                    if (Session[KeyUserId] is int)
                    {
                        return (int)Session[KeyUserId];
                    }
                    return Convert.ToInt32(Session[KeyUserId]);
                }
                return 0;
            }
            set
            {
                if (Session != null)
                {
                    Session[KeyUserId] = value;
                }
            }
        }

        public static BaseUser CurrentUser
        {
            get
            {
                if (Session != null && Session[KeyCurrentUser] != null)
                {
                    if (Session[KeyCurrentUser] is BaseUser)
                    {
                        return (BaseUser)Session[KeyCurrentUser];
                    }
                }
                return null;
            }
            set
            {
                if (Session != null)
                {
                    Session[KeyCurrentUser] = value;
                    if (value != null)
                    {
                        Session[KeyUserId] = value.UserId;
                        Session[KeyUserRole] = value.Role.ToString();
                    }
                    else
                    {
                        Session.Remove(KeyUserId);
                        Session.Remove(KeyUserRole);
                    }
                }
            }
        }

        public static string UserRole
        {
            get
            {
                if (Session != null && Session[KeyUserRole] != null)
                {
                    return Session[KeyUserRole].ToString();
                }
                return string.Empty;
            }
        }

        public static bool IsAdmin
        {
            get
            {
                return string.Equals(UserRole, "Admin", StringComparison.OrdinalIgnoreCase);
            }
        }

        public static void SetFlashMessage(string message, string type)
        {
            if (Session != null)
            {
                Session[KeyFlashMessage] = message;
                Session[KeyFlashType] = type;
            }
        }

        public static void SetFlashMessage(string message)
        {
            SetFlashMessage(message, "success");
        }

        public static FlashNotification GetFlashMessage()
        {
            if (Session == null || Session[KeyFlashMessage] == null)
            {
                return new FlashNotification();
            }

            string msg = Session[KeyFlashMessage] as string;
            string type = Session[KeyFlashType] as string;
            if (string.IsNullOrEmpty(type))
            {
                type = "info";
            }

            Session.Remove(KeyFlashMessage);
            Session.Remove(KeyFlashType);

            FlashNotification notification = new FlashNotification();
            notification.Message = msg;
            notification.Type = type;
            return notification;
        }

        public static void Clear()
        {
            if (Session != null)
            {
                Session.Clear();
                Session.Abandon();
            }
        }
    }

    public class FlashNotification
    {
        public string Message { get; set; }
        public string Type { get; set; }

        public FlashNotification()
        {
            Message = string.Empty;
            Type = "info";
        }
    }
}
