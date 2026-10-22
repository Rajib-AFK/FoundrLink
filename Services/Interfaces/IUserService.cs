using System.Collections.Generic;
using System.Data;
using FoundrLink.Models;

namespace FoundrLink.Services.Interfaces
{
    public interface IUserService
    {
        ServiceResult<User> Authenticate(string email, string password);
        ServiceResult<int> RegisterUser(string fullName, string email, string password, string role);
        ServiceResult<int> CreateUserByAdmin(string fullName, string email, string password, string role, bool isVerified);
        User GetUserById(int userId);
        User GetUserByEmail(string email);
        bool EmailExists(string email);
        ServiceResult UpdateUserStatus(int userId, string status);
        ServiceResult ToggleStatus(int userId);
        ServiceResult ToggleVerification(int userId);
        ServiceResult UpdateUserRole(int userId, string newRole);
        DataTable GetAllUsersDataTable(string search = null, string role = null, string status = null);
    }
}
