using System.Collections.Generic;
using System.Data;
using FoundrLink.Models;

namespace FoundrLink.Services.Interfaces
{
    public interface IStartupService
    {
        DataTable GetPublishedStartups(string search = null, string industry = null, string stage = null);
        Startup GetStartupById(int startupId);
        ServiceResult UpdateStartupStatus(int startupId, string status);
    }
}
