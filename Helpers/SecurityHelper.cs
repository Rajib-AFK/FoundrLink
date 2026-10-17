using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace FoundrLink.Helpers
{
    public static class SecurityHelper
    {
        private const int SaltSize = 16;
        private const int HashSize = 32;
        private const int Iterations = 10000;

        /// <summary>
        /// Generates a PBKDF2 hash with a random cryptographic salt.
        /// Stored format: {iterations}.{base64Salt}.{base64Hash}
        /// </summary>
        public static string HashPassword(string password)
        {
            if (string.IsNullOrEmpty(password))
                throw new ArgumentNullException(nameof(password));

            using (var rng = new RNGCryptoServiceProvider())
            {
                byte[] salt = new byte[SaltSize];
                rng.GetBytes(salt);

                using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations))
                {
                    byte[] hash = pbkdf2.GetBytes(HashSize);
                    return $"{Iterations}.{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}";
                }
            }
        }

        /// <summary>
        /// Verifies whether the supplied plaintext password matches the stored hash.
        /// Also supports legacy plain SHA-256 for backward compatibility.
        /// </summary>
        public static bool VerifyPassword(string password, string storedHash)
        {
            if (string.IsNullOrEmpty(password) || string.IsNullOrEmpty(storedHash))
                return false;

            var parts = storedHash.Split('.');
            if (parts.Length == 3)
            {
                int iterations = int.Parse(parts[0]);
                byte[] salt = Convert.FromBase64String(parts[1]);
                byte[] hash = Convert.FromBase64String(parts[2]);

                using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, iterations))
                {
                    byte[] testHash = pbkdf2.GetBytes(hash.Length);
                    return SlowEquals(hash, testHash);
                }
            }

            // Fallback SHA256 if not PBKDF2 formatted
            using (var sha = SHA256.Create())
            {
                byte[] testBytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                string hex = BitConverter.ToString(testBytes).Replace("-", "").ToLowerInvariant();
                return string.Equals(hex, storedHash, StringComparison.OrdinalIgnoreCase);
            }
        }

        private static bool SlowEquals(byte[] a, byte[] b)
        {
            uint diff = (uint)a.Length ^ (uint)b.Length;
            for (int i = 0; i < a.Length && i < b.Length; i++)
            {
                diff |= (uint)(a[i] ^ b[i]);
            }
            return diff == 0;
        }

        public static bool IsUserLoggedIn()
        {
            var ctx = HttpContext.Current;
            return ctx != null && ctx.Session != null && ctx.Session["UserId"] != null;
        }

        public static int? GetCurrentUserId()
        {
            var ctx = HttpContext.Current;
            if (ctx != null && ctx.Session != null && ctx.Session["UserId"] != null)
            {
                if (int.TryParse(ctx.Session["UserId"].ToString(), out int id))
                {
                    return id;
                }
            }
            return null;
        }

        public static string GetCurrentUserName()
        {
            var ctx = HttpContext.Current;
            return ctx?.Session?["FullName"]?.ToString() ?? "User";
        }

        public static string GetCurrentUserRole()
        {
            var ctx = HttpContext.Current;
            return ctx?.Session?["Role"]?.ToString() ?? "Founder";
        }

        public static string GetCurrentUserAvatar()
        {
            var ctx = HttpContext.Current;
            return ctx?.Session?["AvatarUrl"]?.ToString() ?? "";
        }

        public static void SetUserSession(int userId, string fullName, string email, string role, string avatarUrl)
        {
            var ctx = HttpContext.Current;
            if (ctx?.Session != null)
            {
                ctx.Session["UserId"] = userId;
                ctx.Session["FullName"] = fullName;
                ctx.Session["Email"] = email;
                ctx.Session["Role"] = role;
                ctx.Session["AvatarUrl"] = avatarUrl ?? "";
            }
        }

        public static void Logout()
        {
            var ctx = HttpContext.Current;
            if (ctx?.Session != null)
            {
                ctx.Session.Clear();
                ctx.Session.Abandon();
            }
        }
    }
}
