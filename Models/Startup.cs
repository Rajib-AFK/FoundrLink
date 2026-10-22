using System;

namespace FoundrLink.Models
{
    public class Startup
    {
        public int StartupId { get; set; }
        public int FounderId { get; set; }
        public string Name { get; set; }
        public string Tagline { get; set; }
        public string Industry { get; set; }
        public string Stage { get; set; }
        public string LogoUrl { get; set; }
        public string ShortDescription { get; set; }
        public string FullPitch { get; set; }
        public string PitchDeckUrl { get; set; }
        public string WebsiteUrl { get; set; }
        public string Location { get; set; }
        public int TeamSize { get; set; }
        public decimal FundingRaised { get; set; }
        public decimal FundingGoal { get; set; }
        public string RequiredSkills { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        // Associated founder information (for projection / joins)
        public string FounderName { get; set; }
        public string FounderTitle { get; set; }
        public string FounderAvatar { get; set; }
    }
}
