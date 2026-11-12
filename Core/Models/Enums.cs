using System;

namespace FoundrLink.Core.Models
{
    public enum UserRole
    {
        Founder,
        Investor,
        CoFounder,
        Admin
    }

    public enum UserStatus
    {
        Active,
        Pending,
        Inactive,
        Suspended
    }

    public enum StartupStage
    {
        PreSeed,
        SeedStage,
        SeriesA,
        MVP
    }

    public enum StartupStatus
    {
        Active,
        Draft,
        UnderReview,
        Approved,
        Rejected
    }

    public enum NotificationType
    {
        Requests,
        Matches,
        Activity
    }

    public enum RequestStatus
    {
        Pending,
        Accepted,
        Declined
    }

    public enum ReportStatus
    {
        Pending,
        Resolved,
        Dismissed
    }

    public enum ReportPriority
    {
        High,
        Medium,
        Low
    }
}
