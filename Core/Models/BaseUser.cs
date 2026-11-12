using System;
using System.Text.RegularExpressions;
using FoundrLink.Core.Exceptions;

namespace FoundrLink.Core.Models
{
    /// <summary>
    /// Abstract user base class exhibiting Encapsulation with strict validation,
    /// and providing the foundation for Inheritance and Polymorphic behavior (Syllabus Unit 2 & 3).
    /// </summary>
    public abstract class BaseUser : BaseEntity
    {
        private string _fullName;
        private string _email;

        public int UserId
        {
            get { return Id; }
            set { Id = value; }
        }

        public string FullName
        {
            get { return _fullName; }
            set
            {
                if (string.IsNullOrWhiteSpace(value))
                {
                    throw new FoundrLinkValidationException("Full name cannot be empty.", "FullName");
                }
                _fullName = value.Trim();
            }
        }

        public string Email
        {
            get { return _email; }
            set
            {
                if (string.IsNullOrWhiteSpace(value))
                {
                    throw new FoundrLinkValidationException("Email address cannot be empty.", "Email");
                }

                string trimmed = value.Trim().ToLowerInvariant();
                if (!Regex.IsMatch(trimmed, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
                {
                    throw new FoundrLinkValidationException("Invalid email format.", "Email");
                }

                _email = trimmed;
            }
        }

        public string PasswordHash { get; set; }
        public UserRole Role { get; set; }
        public UserStatus Status { get; set; }

        public string Title { get; set; }
        public string Location { get; set; }
        public string Bio { get; set; }
        public string Company { get; set; }
        public string AvatarUrl { get; set; }
        public bool IsVerified { get; set; }

        protected BaseUser()
            : base()
        {
            _fullName = string.Empty;
            _email = string.Empty;
            PasswordHash = string.Empty;
            Role = UserRole.Founder;
            Status = UserStatus.Active;
            Title = string.Empty;
            Location = string.Empty;
            Bio = string.Empty;
            Company = string.Empty;
            AvatarUrl = string.Empty;
        }

        public string Initials
        {
            get
            {
                if (string.IsNullOrWhiteSpace(FullName))
                {
                    return "FL";
                }
                string[] parts = FullName.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length == 1)
                {
                    return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
                }
                return string.Format("{0}{1}", parts[0][0], parts[parts.Length - 1][0]).ToUpper();
            }
        }

        /// <summary>
        /// Polymorphic method returning specific CSS badge styling per user role (Syllabus Unit 2: Method Overriding).
        /// </summary>
        public abstract string GetRoleBadgeCssClass();

        /// <summary>
        /// Polymorphic authorization capability check.
        /// </summary>
        public virtual bool CanCreateStartup()
        {
            return false;
        }

        public virtual bool CanRequestDeck()
        {
            return false;
        }

        public virtual bool CanModerateContent()
        {
            return false;
        }
    }
}
