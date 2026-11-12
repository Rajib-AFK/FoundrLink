using System;
using System.Collections.Generic;
using System.Linq;
using FoundrLink.Core.Exceptions;

namespace FoundrLink.Core.Models
{
    public class Startup : BaseEntity
    {
        private string _name;

        public int StartupId
        {
            get { return Id; }
            set { Id = value; }
        }

        public int FounderId { get; set; }
        public string FounderName { get; set; }
        public string FounderTitle { get; set; }
        public string FounderAvatar { get; set; }

        public string Name
        {
            get { return _name; }
            set
            {
                if (string.IsNullOrWhiteSpace(value))
                {
                    throw new FoundrLinkValidationException("Startup name cannot be empty.", "Name");
                }
                _name = value.Trim();
            }
        }

        public string Tagline { get; set; }
        public string Industry { get; set; }
        public string Stage { get; set; }
        public string LogoUrl { get; set; }
        public string ShortDescription { get; set; }
        public string FullDescription { get; set; }
        public string Problem { get; set; }
        public string Solution { get; set; }
        public int TeamSize { get; set; }
        public string RequiredSkills { get; set; }
        public string Location { get; set; }
        public string WebsiteUrl { get; set; }
        public string Commitment { get; set; }
        public int FoundedYear { get; set; }
        public decimal FundingRaised { get; set; }
        public decimal FundingGoal { get; set; }
        public decimal MRR { get; set; }
        public string Status { get; set; }

        public List<OpenPosition> OpenPositions { get; set; }
        public List<TeamMember> TeamMembers { get; set; }

        public Startup()
            : base()
        {
            _name = string.Empty;
            FounderName = string.Empty;
            FounderTitle = string.Empty;
            FounderAvatar = string.Empty;
            Tagline = string.Empty;
            Industry = "AI/ML";
            Stage = "Seed Stage";
            LogoUrl = string.Empty;
            ShortDescription = string.Empty;
            FullDescription = string.Empty;
            Problem = string.Empty;
            Solution = string.Empty;
            TeamSize = 1;
            RequiredSkills = string.Empty;
            Location = string.Empty;
            WebsiteUrl = string.Empty;
            Commitment = "Full-time / Equity";
            FoundedYear = 2024;
            FundingRaised = 0m;
            FundingGoal = 0m;
            MRR = 0m;
            Status = "Active";
            OpenPositions = new List<OpenPosition>();
            TeamMembers = new List<TeamMember>();
        }

        public double CalculateFundingPercentage()
        {
            if (FundingGoal <= 0)
            {
                return 0.0;
            }
            double pct = (double)(FundingRaised / FundingGoal) * 100.0;
            return Math.Min(100.0, Math.Round(pct, 1));
        }

        public string FormattedFundingRaised
        {
            get { return FormatCurrency(FundingRaised); }
        }

        public string FormattedFundingGoal
        {
            get { return FormatCurrency(FundingGoal); }
        }

        public string FormattedMRR
        {
            get { return FormatCurrency(MRR); }
        }

        public List<string> GetRequiredSkillsList()
        {
            if (string.IsNullOrWhiteSpace(RequiredSkills))
            {
                return new List<string>();
            }
            return RequiredSkills.Split(new char[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries)
                                 .Select(s => s.Trim())
                                 .Where(s => !string.IsNullOrEmpty(s))
                                 .ToList();
        }

        public string GetStageBadgeClass()
        {
            string currentStage = Stage != null ? Stage.ToLowerInvariant() : string.Empty;
            switch (currentStage)
            {
                case "pre-seed":
                    return "badge-stage-preseed";
                case "seed stage":
                case "seed":
                    return "badge-stage-seed";
                case "series a":
                    return "badge-stage-seriesa";
                case "mvp":
                    return "badge-stage-mvp";
                default:
                    return "badge-stage-default";
            }
        }

        private static string FormatCurrency(decimal amount)
        {
            if (amount >= 10000000m)
            {
                return string.Format("\u20B9{0:F1}Cr", amount / 10000000m);
            }
            if (amount >= 100000m)
            {
                return string.Format("\u20B9{0:F1}M", amount / 1000000m);
            }
            if (amount >= 1000m)
            {
                return string.Format("\u20B9{0:F0}k", amount / 1000m);
            }
            return string.Format("\u20B9{0:N0}", amount);
        }
    }
}
