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
        private const int Iterations = 60000;

        /// <summary>
        /// Validates that a return URL is local to prevent open redirection attacks.
        /// </summary>
        public static bool IsLocalUrl(string url)
        {
            if (string.IsNullOrWhiteSpace(url))
                return false;

            // Reject full URLs or protocol-relative URLs
            if (url.IndexOf("://", StringComparison.Ordinal) >= 0 ||
                url.StartsWith("//", StringComparison.Ordinal) ||
                url.StartsWith("/\\", StringComparison.Ordinal) ||
                url.StartsWith("\\\\", StringComparison.Ordinal))
            {
                return false;
            }

            // Must begin with '/' and not a backslash or double slash, or begin with '~/'
            if (url.StartsWith("/") && (url.Length == 1 || (url[1] != '/' && url[1] != '\\')))
                return true;

            if (url.StartsWith("~/") && url.Length > 2 && url[2] != '/' && url[2] != '\\')
                return true;

            return false;
        }

        /// <summary>
        /// Validates that an uploaded file is a genuine image within size limits.
        /// Checks extension, MIME type, magic bytes, and parses through GDI+ when applicable.
        /// </summary>
        public static bool ValidateUploadedImage(HttpPostedFile file, int maxSizeBytes, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (file == null || file.ContentLength <= 0)
            {
                errorMessage = "No file was selected or the uploaded file is empty.";
                return false;
            }

            if (file.ContentLength > maxSizeBytes)
            {
                errorMessage = $"The uploaded image exceeds the maximum allowed size of {maxSizeBytes / (1024 * 1024)} MB.";
                return false;
            }

            string ext = System.IO.Path.GetExtension(file.FileName).ToLowerInvariant();
            string[] allowedExts = { ".jpg", ".jpeg", ".png", ".webp", ".gif" };
            bool hasValidExt = false;
            foreach (var e in allowedExts)
            {
                if (ext == e) { hasValidExt = true; break; }
            }
            if (!hasValidExt)
            {
                errorMessage = "Invalid file extension. Only JPG, PNG, WebP, and GIF images are allowed.";
                return false;
            }

            string mime = file.ContentType?.ToLowerInvariant() ?? "";
            string[] allowedMimes = { "image/jpeg", "image/pjpeg", "image/png", "image/x-png", "image/webp", "image/gif" };
            bool hasValidMime = false;
            foreach (var m in allowedMimes)
            {
                if (mime == m) { hasValidMime = true; break; }
            }
            if (!hasValidMime)
            {
                errorMessage = "Invalid image content type header.";
                return false;
            }

            // Inspect file magic bytes
            byte[] header = new byte[12];
            try
            {
                file.InputStream.Seek(0, System.IO.SeekOrigin.Begin);
                int bytesRead = file.InputStream.Read(header, 0, Math.Min(header.Length, file.ContentLength));
                file.InputStream.Seek(0, System.IO.SeekOrigin.Begin);

                if (bytesRead < 4)
                {
                    errorMessage = "File header is corrupted or incomplete.";
                    return false;
                }

                bool magicValid = false;

                // JPEG: FF D8 FF
                if (header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF)
                {
                    magicValid = true;
                }
                // PNG: 89 50 4E 47 0D 0A 1A 0A
                else if (bytesRead >= 8 && header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47 &&
                         header[4] == 0x0D && header[5] == 0x0A && header[6] == 0x1A && header[7] == 0x0A)
                {
                    magicValid = true;
                }
                // GIF: 47 49 46 38 ('GIF8')
                else if (header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x38)
                {
                    magicValid = true;
                }
                // WebP: RIFF (bytes 0..3) ... WEBP (bytes 8..11)
                else if (bytesRead >= 12 &&
                         header[0] == 0x52 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x46 &&
                         header[8] == 0x57 && header[9] == 0x45 && header[10] == 0x42 && header[11] == 0x50)
                {
                    magicValid = true;
                }

                if (!magicValid)
                {
                    errorMessage = "The file content does not match a valid image format.";
                    return false;
                }

                // If non-WebP, verify image structure with System.Drawing
                if (ext != ".webp")
                {
                    try
                    {
                        using (var img = System.Drawing.Image.FromStream(file.InputStream, false, false))
                        {
                            if (img.Width <= 0 || img.Height <= 0)
                            {
                                errorMessage = "Image dimensions are invalid.";
                                return false;
                            }
                        }
                    }
                    catch
                    {
                        errorMessage = "The image file appears damaged or corrupted.";
                        return false;
                    }
                    finally
                    {
                        file.InputStream.Seek(0, System.IO.SeekOrigin.Begin);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Image validation exception: " + ex);
                errorMessage = "An error occurred while validating the image file.";
                return false;
            }

            return true;
        }

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

        /// <summary>
        /// Generates a cryptographically secure random token for password resets and verification.
        /// </summary>
        public static string GenerateSecureToken(int byteLength = 32)
        {
            using (var rng = new RNGCryptoServiceProvider())
            {
                byte[] bytes = new byte[byteLength];
                rng.GetBytes(bytes);
                return BitConverter.ToString(bytes).Replace("-", "").ToLowerInvariant();
            }
        }

        /// <summary>
        /// Hashes a token using SHA-256 for secure database storage.
        /// </summary>
        public static string HashToken(string token)
        {
            if (string.IsNullOrEmpty(token)) return string.Empty;
            using (var sha = SHA256.Create())
            {
                byte[] hash = sha.ComputeHash(Encoding.UTF8.GetBytes(token));
                return BitConverter.ToString(hash).Replace("-", "").ToLowerInvariant();
            }
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
            return ctx?.Session?["Role"]?.ToString() ?? ctx?.Session?["UserRole"]?.ToString() ?? "";
        }

        public static bool IsUserAdmin()
        {
            var ctx = HttpContext.Current;
            if (ctx == null || ctx.Session == null) return false;
            string role = ctx.Session["Role"]?.ToString() ?? ctx.Session["UserRole"]?.ToString();
            return string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase);
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
                ctx.Session["UserRole"] = role;
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

            if (ctx?.Request?.Cookies["ASP.NET_SessionId"] != null)
            {
                var cookie = new System.Web.HttpCookie("ASP.NET_SessionId", "")
                {
                    Expires = DateTime.UtcNow.AddYears(-1),
                    HttpOnly = true
                };
                ctx.Response.Cookies.Add(cookie);
            }

            try
            {
                System.Web.Security.FormsAuthentication.SignOut();
            }
            catch { }
        }
    }
}
