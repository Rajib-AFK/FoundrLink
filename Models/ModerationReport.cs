using System;

namespace FoundrLink.Models
{
    public class ModerationReport
    {
        public int ReportId { get; set; }
        public string ReportCode { get; set; }
        public string ReporterEmail { get; set; }
        public string ReportedItem { get; set; }
        public string ReportType { get; set; }
        public string Priority { get; set; }
        public string Details { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ResolvedAt { get; set; }

        public bool IsPending => string.Equals(Status, "Pending", StringComparison.OrdinalIgnoreCase);
        public bool IsResolved => string.Equals(Status, "Resolved", StringComparison.OrdinalIgnoreCase);
        public bool IsDismissed => string.Equals(Status, "Dismissed", StringComparison.OrdinalIgnoreCase);
    }
}
