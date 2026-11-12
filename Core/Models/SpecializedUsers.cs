using System;

namespace FoundrLink.Core.Models
{
    public class Founder : BaseUser
    {
        public Founder()
            : base()
        {
            Role = UserRole.Founder;
        }

        public override string GetRoleBadgeCssClass()
        {
            return "badge-founder";
        }

        public override bool CanCreateStartup()
        {
            return true;
        }

        public override bool CanRequestDeck()
        {
            return true;
        }
    }

    public class Investor : BaseUser
    {
        public decimal MaxCheckSize { get; set; }
        public string PreferredStages { get; set; }

        public Investor()
            : base()
        {
            Role = UserRole.Investor;
            PreferredStages = string.Empty;
        }

        public override string GetRoleBadgeCssClass()
        {
            return "badge-investor";
        }

        public override bool CanCreateStartup()
        {
            return false;
        }

        public override bool CanRequestDeck()
        {
            return true;
        }
    }

    public class CoFounderUser : BaseUser
    {
        public string PrimarySkills { get; set; }

        public CoFounderUser()
            : base()
        {
            Role = UserRole.CoFounder;
            PrimarySkills = string.Empty;
        }

        public override string GetRoleBadgeCssClass()
        {
            return "badge-cofounder";
        }

        public override bool CanCreateStartup()
        {
            return true;
        }

        public override bool CanRequestDeck()
        {
            return true;
        }
    }

    public class AdminUser : BaseUser
    {
        public AdminUser()
            : base()
        {
            Role = UserRole.Admin;
        }

        public override string GetRoleBadgeCssClass()
        {
            return "badge-admin";
        }

        public override bool CanCreateStartup()
        {
            return true;
        }

        public override bool CanRequestDeck()
        {
            return true;
        }

        public override bool CanModerateContent()
        {
            return true;
        }
    }
}
