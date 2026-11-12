using System;
using System.Collections.Generic;
using System.Linq;

namespace FoundrLink.Core.Models
{
    public class FounderProfile : BaseEntity
    {
        public int ProfileId
        {
            get { return Id; }
            set { Id = value; }
        }

        public int UserId { get; set; }
        public int PlatformImpactConnections { get; set; }
        public int PlatformImpactIntros { get; set; }
        public int PlatformImpactTeams { get; set; }
        public int PlatformImpactSaved { get; set; }
        
        public string Interests { get; set; }
        public string Skills { get; set; }
        public string ICanOffer { get; set; }
        public string LookingFor { get; set; }
        public string Availability { get; set; }
        public string BaseLocation { get; set; }
        public int ProfileCompletionPercentage { get; set; }

        public FounderProfile()
            : base()
        {
            Interests = string.Empty;
            Skills = string.Empty;
            ICanOffer = string.Empty;
            LookingFor = string.Empty;
            Availability = "Full-time";
            BaseLocation = string.Empty;
            ProfileCompletionPercentage = 85;
        }

        public List<string> GetSkillsList()
        {
            if (string.IsNullOrWhiteSpace(Skills))
            {
                return new List<string>();
            }
            return Skills.Split(new char[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries)
                         .Select(s => s.Trim())
                         .Where(s => !string.IsNullOrEmpty(s))
                         .ToList();
        }

        public List<string> GetInterestsList()
        {
            if (string.IsNullOrWhiteSpace(Interests))
            {
                return new List<string>();
            }
            return Interests.Split(new char[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries)
                            .Select(s => s.Trim())
                            .Where(s => !string.IsNullOrEmpty(s))
                            .ToList();
        }

        public List<string> GetOffersList()
        {
            if (string.IsNullOrWhiteSpace(ICanOffer))
            {
                return new List<string>();
            }
            return ICanOffer.Split(new char[] { ';', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries)
                            .Select(s => s.Trim())
                            .Where(s => !string.IsNullOrEmpty(s))
                            .ToList();
        }

        public List<string> GetLookingForList()
        {
            if (string.IsNullOrWhiteSpace(LookingFor))
            {
                return new List<string>();
            }
            return LookingFor.Split(new char[] { ';', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries)
                            .Select(s => s.Trim())
                            .Where(s => !string.IsNullOrEmpty(s))
                            .ToList();
        }
    }
}
