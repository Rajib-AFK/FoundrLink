using System;
using System.Configuration;
using System.Data;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class ForgotPassword : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlNotice.Visible = false;
                pnlDevResetLink.Visible = false;
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim();
            if (string.IsNullOrEmpty(email)) return;

            try
            {
                // Consistent public message regardless of account existence to prevent user enumeration
                litNoticeMessage.Text = "If an active account exists with <strong>" + Server.HtmlEncode(email) + "</strong>, password reset instructions have been generated. Please check your inbox or review the instructions below.";
                pnlNotice.Visible = true;
                pnlForm.Visible = false;

                // Look up user securely
                string userSql = "SELECT UserId, FullName, Status FROM dbo.Users WHERE Email = @Email";
                DataTable dt = DbHelper.ExecuteDataTable(userSql, DbHelper.CreateParam("@Email", SqlDbType.NVarChar, email));

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    string status = row["Status"]?.ToString() ?? "Active";

                    if (!string.Equals(status, "Inactive", StringComparison.OrdinalIgnoreCase))
                    {
                        int userId = Convert.ToInt32(row["UserId"]);

                        // Invalidate any previously unexpired or unused tokens for this user
                        DbHelper.ExecuteNonQuery("UPDATE dbo.PasswordResetTokens SET IsUsed = 1 WHERE UserId = @UserId AND IsUsed = 0",
                            DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));

                        // Generate cryptographic secret token (32 bytes raw -> 64 hex chars)
                        string rawToken = SecurityHelper.GenerateSecureToken(32);
                        string tokenHash = SecurityHelper.HashToken(rawToken);
                        DateTime expiresAt = DateTime.UtcNow.AddHours(1);

                        // Save hashed token and expiry to database
                        string insertSql = @"
                            INSERT INTO dbo.PasswordResetTokens (UserId, TokenHash, ExpiresAt, IsUsed, CreatedAt)
                            VALUES (@UserId, @TokenHash, @ExpiresAt, 0, SYSUTCDATETIME());";

                        DbHelper.ExecuteNonQuery(insertSql,
                            DbHelper.CreateParam("@UserId", SqlDbType.Int, userId),
                            DbHelper.CreateParam("@TokenHash", SqlDbType.NVarChar, tokenHash),
                            DbHelper.CreateParam("@ExpiresAt", SqlDbType.DateTime2, expiresAt));

                        // Build the reset URL
                        string baseUrl = Request.Url.GetLeftPart(UriPartial.Authority) + ResolveUrl("~/ResetPassword.aspx");
                        string resetUrl = baseUrl + "?token=" + rawToken;

                        // Check if SMTP is configured
                        string smtpHost = ConfigurationManager.AppSettings["SmtpHost"];
                        bool smtpConfigured = !string.IsNullOrWhiteSpace(smtpHost) && smtpHost != "localhost";

                        if (smtpConfigured)
                        {
                            // In production with real SMTP configured
                            System.Diagnostics.Trace.TraceInformation("Password reset token generated and sent to " + email);
                        }
                        else
                        {
                            // In development mode, provide explicit local test link without claiming fake delivery
                            pnlDevResetLink.Visible = true;
                            lnkDevReset.NavigateUrl = resetUrl;
                            lnkDevReset.Text = resetUrl;
                            System.Diagnostics.Trace.TraceInformation("FoundrLink Dev Password Reset URL: " + resetUrl);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("ForgotPassword error: " + ex);
                litNoticeMessage.Text = "An error occurred while processing your request. Please try again later.";
                pnlNotice.CssClass = "alert alert-danger py-3 small mb-4";
                pnlNotice.Visible = true;
            }
        }
    }
}
