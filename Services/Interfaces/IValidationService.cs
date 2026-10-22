namespace FoundrLink.Services.Interfaces
{
    public interface IValidationService
    {
        bool ValidateEmail(string email, out string errorMessage);
        bool ValidatePassword(string password, out string errorMessage);
        bool ValidateRegistration(string fullName, string email, string role, string password, string confirmPassword, out string errorMessage);
        string SanitizeText(string input);
        bool ValidateUrl(string url, bool mustBeLocal, out string errorMessage);
    }
}
