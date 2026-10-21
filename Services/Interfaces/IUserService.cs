using System.Collections.Generic;
using System.Data;
using FoundrLink.Models;

namespace FoundrLink.Services.Interfaces
{
    public interface IUserService
    {
        ServiceResult<User> Authenticate(string email, string password);
        ServiceResult<int> RegisterUser(string fullName, string email, string password, string role);
        User GetUserById(int userId);
        User GetUserByEmail(string email);
        bool EmailExists(string email);
        ServiceResult UpdateUserStatus(int userId, string status);
        DataTable GetAllUsersDataTable(string search = null, string role = null, string status = null);
    }
}
