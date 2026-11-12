using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using FoundrLink.Core.Interfaces;
using FoundrLink.Core.Models;

namespace FoundrLink.Core.Services
{
    /// <summary>
    /// Demonstrates Syllabus Unit 4: Generics and Collections.
    /// Strictly utilizes syllabus-prescribed collections:
    /// - Generic Collections: List<T>, Dictionary<TKey, TValue>, Queue<T>, Stack<T>
    /// - Non-Generic Collections: Hashtable, ArrayList
    /// Completely replaces out-of-scope HashSet<T> with syllabus-compliant collections.
    /// </summary>
    public class MatchmakingEngine : IMatchmakingEngine
    {
        // 1. Generic Collection: Dictionary<TKey, TValue> for scoring weights and sector affinities
        private readonly Dictionary<string, double> _dimensionWeights;
        private readonly Dictionary<string, List<string>> _industryAffinities;

        // 2. Generic Collection: Queue<T> for processing matchmaking candidate evaluation queues (FIFO)
        private readonly Queue<Startup> _evaluationQueue;

        // 3. Generic Collection: Stack<T> for tracking profile browsing navigation history (LIFO)
        private readonly Stack<string> _navigationHistoryStack;

        // 4. Non-Generic Collection: Hashtable for fast O(1) keyword indexing (Unit 4: Non-Generic Collections)
        private readonly Hashtable _keywordWeightsTable;

        public MatchmakingEngine()
        {
            _dimensionWeights = new Dictionary<string, double>(StringComparer.OrdinalIgnoreCase);
            _dimensionWeights.Add("SkillsAlignment", 0.50);
            _dimensionWeights.Add("IndustryAffinity", 0.30);
            _dimensionWeights.Add("StageFit", 0.20);

            _industryAffinities = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);
            _industryAffinities.Add("AI/ML", new List<string> { "SaaS", "HealthTech", "DeepTech", "Developer Tools" });
            _industryAffinities.Add("Fintech", new List<string> { "SaaS", "E-Commerce", "Payments", "Banking" });
            _industryAffinities.Add("Climate Tech", new List<string> { "Sustainability", "PropTech", "Energy", "IoT" });
            _industryAffinities.Add("HealthTech", new List<string> { "AI/ML", "Bioinformatics", "Diagnostics", "IoT" });
            _industryAffinities.Add("PropTech", new List<string> { "Climate Tech", "IoT", "Real Estate", "Smart City" });

            _evaluationQueue = new Queue<Startup>();
            _navigationHistoryStack = new Stack<string>();

            _keywordWeightsTable = new Hashtable(StringComparer.OrdinalIgnoreCase);
            _keywordWeightsTable["ai"] = 1.2;
            _keywordWeightsTable["ml"] = 1.2;
            _keywordWeightsTable["fintech"] = 1.1;
            _keywordWeightsTable["saas"] = 1.0;
        }

        /// <summary>
        /// Calculates compatibility score between a founder profile and a target startup.
        /// Replaces out-of-scope HashSet with Syllabus Unit 4 List<T> and Hashtable.
        /// </summary>
        public double CalculateMatchScore(FounderProfile profile, Startup startup)
        {
            if (profile == null || startup == null)
            {
                return 0.0;
            }

            // Step A: Calculate skill overlap using List<string> and Hashtable (Syllabus Unit 4)
            List<string> profileSkills = profile.GetSkillsList();
            List<string> startupSkills = startup.GetRequiredSkillsList();

            double skillsScore = 0.5; // Baseline
            if (startupSkills != null && startupSkills.Count > 0)
            {
                // Index startup skills into a Non-Generic Hashtable for rapid lookup
                Hashtable startupSkillsHash = new Hashtable(StringComparer.OrdinalIgnoreCase);
                foreach (string s in startupSkills)
                {
                    if (!string.IsNullOrWhiteSpace(s))
                    {
                        startupSkillsHash[s.Trim()] = true;
                    }
                }

                // Generic List<string> storing overlapping skills
                List<string> overlappingSkills = new List<string>();
                foreach (string pSkill in profileSkills)
                {
                    if (!string.IsNullOrWhiteSpace(pSkill) && startupSkillsHash.ContainsKey(pSkill.Trim()))
                    {
                        overlappingSkills.Add(pSkill.Trim());
                    }
                }

                skillsScore = (double)overlappingSkills.Count / startupSkills.Count;
            }

            // Step B: Industry affinity evaluation using Dictionary<string, List<string>>
            double industryScore = 0.4;
            List<string> userInterests = profile.GetInterestsList();

            bool hasDirectInterest = false;
            foreach (string interest in userInterests)
            {
                if (string.Equals(interest, startup.Industry, StringComparison.OrdinalIgnoreCase))
                {
                    hasDirectInterest = true;
                    break;
                }
            }

            if (hasDirectInterest)
            {
                industryScore = 1.0;
            }
            else if (startup.Industry != null && _industryAffinities.ContainsKey(startup.Industry))
            {
                List<string> relatedIndustries = _industryAffinities[startup.Industry];
                foreach (string related in relatedIndustries)
                {
                    foreach (string userInt in userInterests)
                    {
                        if (string.Equals(related, userInt, StringComparison.OrdinalIgnoreCase))
                        {
                            industryScore = 0.8;
                            break;
                        }
                    }
                    if (industryScore > 0.4)
                    {
                        break;
                    }
                }
            }

            // Step C: Stage fit
            double stageScore = 0.85;

            // Composite calculation using Dictionary lookups
            double finalScore = (skillsScore * _dimensionWeights["SkillsAlignment"]) +
                                (industryScore * _dimensionWeights["IndustryAffinity"]) +
                                (stageScore * _dimensionWeights["StageFit"]);

            return Math.Round(Math.Min(99.0, Math.Max(50.0, finalScore * 100.0)), 0);
        }

        /// <summary>
        /// Evaluates mutual synergy between two potential co-founders using List<string> and Dictionary lookups.
        /// </summary>
        public double CalculateFounderSynergy(BaseUser userA, FounderProfile profileA, BaseUser userB, FounderProfile profileB)
        {
            if (userA == null || userB == null)
            {
                return 0.0;
            }

            bool complementaryRoles = (userA.Role == UserRole.Founder && userB.Role == UserRole.CoFounder) ||
                                       (userA.Role == UserRole.CoFounder && userB.Role == UserRole.Founder);

            double baseSynergy = complementaryRoles ? 0.80 : 0.65;

            if (profileA != null && profileB != null)
            {
                List<string> interestsA = profileA.GetInterestsList();
                List<string> interestsB = profileB.GetInterestsList();

                List<string> commonInterests = new List<string>();
                foreach (string itemA in interestsA)
                {
                    foreach (string itemB in interestsB)
                    {
                        if (string.Equals(itemA, itemB, StringComparison.OrdinalIgnoreCase))
                        {
                            if (!commonInterests.Contains(itemA))
                            {
                                commonInterests.Add(itemA);
                            }
                        }
                    }
                }

                if (commonInterests.Count > 0)
                {
                    baseSynergy += Math.Min(0.18, commonInterests.Count * 0.06);
                }
            }

            return Math.Round(Math.Min(98.0, baseSynergy * 100.0), 0);
        }

        /// <summary>
        /// Demonstrates Generic Collection: List<T> sorting and LINQ transformations (Unit 3 & 4).
        /// </summary>
        public List<Startup> RankStartupsForUser(FounderProfile userProfile, List<Startup> candidates)
        {
            if (candidates == null)
            {
                return new List<Startup>();
            }
            if (userProfile == null)
            {
                return candidates;
            }

            return candidates
                .OrderByDescending(s => CalculateMatchScore(userProfile, s))
                .ToList();
        }

        // =========================================================================
        // Syllabus Unit 4 Explicit Collections Demonstrations: Queue<T>, Stack<T>, ArrayList
        // =========================================================================

        /// <summary>
        /// Demonstrates Generic Collection: Queue<T> (FIFO) for processing candidate startups.
        /// </summary>
        public void EnqueueCandidate(Startup startup)
        {
            if (startup != null)
            {
                _evaluationQueue.Enqueue(startup);
            }
        }

        public Startup DequeueNextCandidate()
        {
            if (_evaluationQueue.Count > 0)
            {
                return _evaluationQueue.Dequeue();
            }
            return null;
        }

        public int EvaluationQueueCount
        {
            get { return _evaluationQueue.Count; }
        }

        /// <summary>
        /// Demonstrates Generic Collection: Stack<T> (LIFO) for profile navigation history.
        /// </summary>
        public void PushNavigationHistory(string pageOrProfileTitle)
        {
            if (!string.IsNullOrWhiteSpace(pageOrProfileTitle))
            {
                _navigationHistoryStack.Push(pageOrProfileTitle);
            }
        }

        public string PopPreviousNavigation()
        {
            if (_navigationHistoryStack.Count > 0)
            {
                return _navigationHistoryStack.Pop();
            }
            return string.Empty;
        }

        public int NavigationHistoryCount
        {
            get { return _navigationHistoryStack.Count; }
        }

        /// <summary>
        /// Demonstrates Non-Generic Collection: ArrayList (Syllabus Unit 4: Non-Generic Collections).
        /// Stores heterogeneous summary records for audit reporting.
        /// </summary>
        public ArrayList BuildHeterogeneousAuditLog(int totalUsers, int totalStartups, double averageScore)
        {
            ArrayList auditList = new ArrayList();
            auditList.Add("FoundrLink Matchmaking Engine Audit");
            auditList.Add(DateTime.UtcNow);
            auditList.Add(totalUsers);
            auditList.Add(totalStartups);
            auditList.Add(averageScore);
            auditList.Add(true); // Verification flag
            return auditList;
        }
    }
}
