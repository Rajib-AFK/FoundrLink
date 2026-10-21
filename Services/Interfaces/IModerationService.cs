using System.Collections.Generic;
using System.Data;
using FoundrLink.Models;

namespace FoundrLink.Services.Interfaces
{
    public interface IModerationService
    {
        DataTable GetReportsDataTable(string search = null, string status = null, string priority = null);
        List<ModerationReport> GetReports(string search = null, string status = null, string priority = null);
        ServiceResult ResolveReport(int reportId);
        ServiceResult DismissReport(int reportId);
        ServiceResult SubmitTicket(string reporterEmail, string category, string priority, string subject, string details, out string reportCode);
    }
}
