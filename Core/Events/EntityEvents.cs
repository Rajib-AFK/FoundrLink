using System;
using FoundrLink.Core.Models;

namespace FoundrLink.Core.Events
{
    /// <summary>
    /// Demonstrates Syllabus Unit 3: Delegates and Events.
    /// Types of delegates: Single-cast and Multi-cast delegates, and event handling mechanism.
    /// </summary>
    
    // 1. Custom Delegate definition
    public delegate void StartupPublishedEventHandler(object sender, StartupEventArgs e);

    // 2. Custom Delegate for match calculation logging
    public delegate void MatchCalculatedEventHandler(object sender, MatchScoreEventArgs e);

    // 3. Custom EventArgs carrying strongly-typed event data
    public class StartupEventArgs : EventArgs
    {
        public Startup StartupItem { get; private set; }
        public DateTime PublishedAt { get; private set; }

        public StartupEventArgs(Startup startup)
        {
            StartupItem = startup;
            PublishedAt = DateTime.UtcNow;
        }
    }

    public class MatchScoreEventArgs : EventArgs
    {
        public int UserId { get; private set; }
        public int StartupId { get; private set; }
        public double Score { get; private set; }

        public MatchScoreEventArgs(int userId, int startupId, double score)
        {
            UserId = userId;
            StartupId = startupId;
            Score = score;
        }
    }

    /// <summary>
    /// Service demonstrating Event Publishing and Multicast Delegate subscriptions.
    /// </summary>
    public class StartupNotificationService
    {
        // Event declared using custom delegate
        public event StartupPublishedEventHandler StartupPublished;
        public event MatchCalculatedEventHandler MatchCalculated;

        public void NotifyStartupPublished(Startup startup)
        {
            if (startup != null && StartupPublished != null)
            {
                StartupPublished(this, new StartupEventArgs(startup));
            }
        }

        public void NotifyMatchCalculated(int userId, int startupId, double score)
        {
            if (MatchCalculated != null)
            {
                MatchCalculated(this, new MatchScoreEventArgs(userId, startupId, score));
            }
        }
    }
}
