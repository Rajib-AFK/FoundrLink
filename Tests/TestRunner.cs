using System;
using System.Collections.Generic;
using System.Data;
using FoundrLink.Helpers;
using FoundrLink.Services;
using FoundrLink.Services.Interfaces;

namespace FoundrLink.Tests
{
    public class TestResult
    {
        public string TestName { get; set; }
        public bool Passed { get; set; }
        public string ErrorMessage { get; set; }
        public long DurationMs { get; set; }
    }

    public static class TestRunner
    {
        public static List<TestResult> RunAllTests()
        {
            var results = new List<TestResult>();
            var tests = new Action<List<TestResult>>[]
            {
                RunCryptoTests,
                RunUrlSecurityTests,
                RunValidationTests,
                RunModerationTests,
                RunFallbackStoreTests
            };

            foreach (var testSuite in tests)
            {
                testSuite(results);
            }

            return results;
        }

        private static void ExecuteTest(string name, Action testAction, List<TestResult> results)
        {
            var sw = System.Diagnostics.Stopwatch.StartNew();
            var tr = new TestResult { TestName = name };
            try
            {
                testAction();
                tr.Passed = true;
            }
            catch (Exception ex)
            {
                tr.Passed = false;
                tr.ErrorMessage = ex.Message;
            }
            finally
            {
                sw.Stop();
                tr.DurationMs = sw.ElapsedMilliseconds;
                results.Add(tr);
            }
        }

        private static void RunCryptoTests(List<TestResult> results)
        {
            ExecuteTest("PBKDF2: Hash format conforms to {iterations}.{salt}.{hash}", () =>
            {
                string raw = "SecurePass123!";
                string hash = SecurityHelper.HashPassword(raw);
                var parts = hash.Split('.');
                if (parts.Length != 3) throw new Exception($"Expected 3 parts, got {parts.Length}");
                if (parts[0] != "60000") throw new Exception($"Expected 60000 iterations, got {parts[0]}");
                byte[] salt = Convert.FromBase64String(parts[1]);
                byte[] digest = Convert.FromBase64String(parts[2]);
                if (salt.Length != 16) throw new Exception($"Expected 16 byte salt, got {salt.Length}");
                if (digest.Length != 32) throw new Exception($"Expected 32 byte hash, got {digest.Length}");
            }, results);

            ExecuteTest("PBKDF2: Valid password verification succeeds", () =>
            {
                string raw = "P@ssw0rd2026!";
                string hash = SecurityHelper.HashPassword(raw);
                bool valid = SecurityHelper.VerifyPassword(raw, hash);
                if (!valid) throw new Exception("Expected valid verification to return true");
            }, results);

            ExecuteTest("PBKDF2: Invalid password verification fails", () =>
            {
                string raw = "P@ssw0rd2026!";
                string hash = SecurityHelper.HashPassword(raw);
                bool valid = SecurityHelper.VerifyPassword("WrongPass999!", hash);
                if (valid) throw new Exception("Expected invalid verification to return false");
            }, results);

            ExecuteTest("PBKDF2: Legacy SHA-256 fallback hash verification succeeds", () =>
            {
                // SHA256 of 'Password123' used in default seed data
                string legacyHash = "008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601";
                bool valid = SecurityHelper.VerifyPassword("Password123", legacyHash);
                if (!valid) throw new Exception("Expected legacy SHA-256 verification to succeed");
            }, results);
        }

        private static void RunUrlSecurityTests(List<TestResult> results)
        {
            ExecuteTest("Security: Open redirection protection allows legitimate local URLs", () =>
            {
                string[] validUrls = { "/Dashboard.aspx", "~/Profile.aspx", "/Admin/ManageUsers.aspx", "/" };
                foreach (var url in validUrls)
                {
                    if (!SecurityHelper.IsLocalUrl(url))
                        throw new Exception($"Expected '{url}' to be recognized as local URL.");
                }
            }, results);

            ExecuteTest("Security: Open redirection protection rejects malicious external URLs", () =>
            {
                string[] maliciousUrls = {
                    "http://evil.com/login",
                    "https://evil.com",
                    "//evil.com/phishing",
                    "/\\evil.com",
                    "\\\\evil.com\\share",
                    "javascript:alert(1)",
                    ""
                };
                foreach (var url in maliciousUrls)
                {
                    if (SecurityHelper.IsLocalUrl(url))
                        throw new Exception($"Expected '{url}' to be rejected as non-local URL.");
                }
            }, results);
        }

        private static void RunValidationTests(List<TestResult> results)
        {
            var validator = new ValidationService();

            ExecuteTest("Validation: Standard user registration parameters pass", () =>
            {
                bool ok = validator.ValidateRegistration(
                    "Jane Doe",
                    "jane@ripaldesign.studio",
                    "Founder",
                    "SecretPass123!",
                    "SecretPass123!",
                    out string err);

                if (!ok) throw new Exception($"Expected registration validation to pass. Error: {err}");
            }, results);

            ExecuteTest("Validation: Password under 8 characters is rejected", () =>
            {
                bool ok = validator.ValidatePassword("Short1!", out string err);
                if (ok) throw new Exception("Expected password < 8 characters to fail validation.");
            }, results);

            ExecuteTest("Validation: Password without digit/symbol is rejected", () =>
            {
                bool ok = validator.ValidatePassword("allletterspassword", out string err);
                if (ok) throw new Exception("Expected password without digit/symbol to fail validation.");
            }, results);

            ExecuteTest("Validation: Mismatched password confirmation is rejected", () =>
            {
                bool ok = validator.ValidateRegistration(
                    "Jane Doe",
                    "jane@ripaldesign.studio",
                    "Founder",
                    "SecretPass123!",
                    "Mismatch999!",
                    out string err);

                if (ok) throw new Exception("Expected password mismatch to fail validation.");
            }, results);

            ExecuteTest("Validation: Invalid email syntax is rejected", () =>
            {
                bool ok = validator.ValidateEmail("invalid-email-format", out string err);
                if (ok) throw new Exception("Expected malformed email to fail validation.");
            }, results);

            ExecuteTest("Validation: XSS sanitizer removes script tags", () =>
            {
                string raw = "<script>alert('xss')</script>Building next-gen AI";
                string cleaned = validator.SanitizeText(raw);
                if (cleaned.Contains("<script>")) throw new Exception("Sanitizer did not remove <script> tags.");
                if (!cleaned.Contains("Building next-gen AI")) throw new Exception("Sanitizer corrupted valid text.");
            }, results);
        }

        private static void RunModerationTests(List<TestResult> results)
        {
            ExecuteTest("ModerationService: Ticket submission assigns formatted TKT code", () =>
            {
                var modService = new ModerationService();
                var res = modService.SubmitTicket(
                    "test.reporter@ripaldesign.studio",
                    "Content Violation",
                    "High",
                    "Automated Test Ticket",
                    "Generated during CI test execution",
                    out string reportCode);

                if (!reportCode.StartsWith("TKT-"))
                    throw new Exception($"Expected reportCode to start with 'TKT-', got '{reportCode}'");
            }, results);
        }

        private static void RunFallbackStoreTests(List<TestResult> results)
        {
            ExecuteTest("FallbackStore: Default seed accounts are present in offline store", () =>
            {
                DataTable dt = LocalFallbackStore.Query("SELECT * FROM Users WHERE Email = 'admin@ripaldesign.studio'");
                if (dt == null || dt.Rows.Count == 0)
                    throw new Exception("Offline store does not contain admin@ripaldesign.studio");

                string role = dt.Rows[0]["Role"]?.ToString();
                if (role != "Admin")
                    throw new Exception($"Expected role 'Admin', got '{role}'");
            }, results);

            ExecuteTest("FallbackStore: Query returns valid non-empty scalar count", () =>
            {
                object count = LocalFallbackStore.Scalar("SELECT COUNT(1) FROM Users");
                if (count == null || Convert.ToInt32(count) <= 0)
                    throw new Exception("Offline store scalar user count was null or 0");
            }, results);
        }
    }
}
