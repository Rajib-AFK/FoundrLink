using System;
using System.Text.RegularExpressions;
using System.Web;
using FoundrLink.Helpers;
using FoundrLink.Services.Interfaces;

namespace FoundrLink.Services
{
    public class ValidationService : IValidationService
    {
        private static readonly Regex EmailRegex = new Regex(
            @"^[^@\s]+@[^@\s]+\.[^@\s]+$",
            RegexOptions.Compiled | RegexOptions.IgnoreCase);

        public bool ValidateEmail(string email, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (string.IsNullOrWhiteSpace(email))
            {
                errorMessage = "Email address is required.";
                return false;
            }

            string trimmed = email.Trim();
            if (trimmed.Length > 254)
            {
                errorMessage = "Email address cannot exceed 254 characters.";
                return false;
            }

            if (!EmailRegex.IsMatch(trimmed))
            {
                errorMessage = "Please enter a valid email address format (e.g. you@ripaldesign.studio).";
                return false;
            }

            return true;
        }

        public bool ValidatePassword(string password, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (string.IsNullOrEmpty(password))
            {
                errorMessage = "Password is required.";
                return false;
            }

            if (password.Length < 8)
            {
                errorMessage = "Password must be at least 8 characters long.";
                return false;
            }

            if (password.Length > 128)
            {
                errorMessage = "Password cannot exceed 128 characters.";
                return false;
            }

            // Check that password contains at least one digit or symbol
            bool hasDigitOrSymbol = false;
            foreach (char c in password)
            {
                if (char.IsDigit(c) || char.IsPunctuation(c) || char.IsSymbol(c))
                {
                    hasDigitOrSymbol = true;
                    break;
                }
            }

            if (!hasDigitOrSymbol)
            {
                errorMessage = "Password must contain at least one digit or special character.";
                return false;
            }

            return true;
        }

        public bool ValidateRegistration(string fullName, string email, string role, string password, string confirmPassword, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (string.IsNullOrWhiteSpace(fullName) || fullName.Trim().Length < 2)
            {
                errorMessage = "Please provide your full legal or professional name (minimum 2 characters).";
                return false;
            }

            if (!ValidateEmail(email, out errorMessage))
            {
                return false;
            }

            if (string.IsNullOrWhiteSpace(role))
            {
                errorMessage = "Please select an account role.";
                return false;
            }

            if (!ValidatePassword(password, out errorMessage))
            {
                return false;
            }

            if (!string.Equals(password, confirmPassword, StringComparison.Ordinal))
            {
                errorMessage = "Password and confirmation password do not match.";
                return false;
            }

            return true;
        }

        public string SanitizeText(string input)
        {
            if (string.IsNullOrEmpty(input)) return string.Empty;

            // Strip potentially dangerous executable markup tags while preserving standard punctuation
            string cleaned = Regex.Replace(input, @"<script[\s\S]*?>[\s\S]*?<\/script>", string.Empty, RegexOptions.IgnoreCase);
            cleaned = Regex.Replace(cleaned, @"javascript:", string.Empty, RegexOptions.IgnoreCase);
            cleaned = Regex.Replace(cleaned, @"vbscript:", string.Empty, RegexOptions.IgnoreCase);
            cleaned = Regex.Replace(cleaned, @"onload\s*=", string.Empty, RegexOptions.IgnoreCase);
            cleaned = Regex.Replace(cleaned, @"onerror\s*=", string.Empty, RegexOptions.IgnoreCase);

            return cleaned.Trim();
        }

        public bool ValidateUrl(string url, bool mustBeLocal, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (string.IsNullOrWhiteSpace(url))
            {
                errorMessage = "URL cannot be empty.";
                return false;
            }

            if (mustBeLocal)
            {
                if (!SecurityHelper.IsLocalUrl(url))
                {
                    errorMessage = "The provided return URL is external or malformed.";
                    return false;
                }
                return true;
            }

            if (Uri.TryCreate(url, UriKind.Absolute, out Uri uriResult))
            {
                if (uriResult.Scheme == Uri.UriSchemeHttp || uriResult.Scheme == Uri.UriSchemeHttps)
                {
                    return true;
                }
            }

            errorMessage = "Invalid absolute web URL format.";
            return false;
        }
    }
}
