using System;

namespace FoundrLink.Models
{
    public class User
    {
        public int UserId { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string Role { get; set; }
        public string Title { get; set; }
        public string Location { get; set; }
        public string Bio { get; set; }
        public string AvatarUrl { get; set; }
        public string Company { get; set; }
        public bool IsVerified { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        public bool IsActive => string.Equals(Status, "Active", StringComparison.OrdinalIgnoreCase);
        public bool IsAdmin => string.Equals(Role, "Admin", StringComparison.OrdinalIgnoreCase);
    }
}
