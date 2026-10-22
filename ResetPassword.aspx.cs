using System;
using System.Data;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class ResetPassword : Page
    {
        private string TokenParam => Request.QueryString["token"]?.Trim();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ValidateResetToken();
            }
        }

        private bool ValidateResetToken(out int tokenId, out int userId)
        {
            tokenId = 0;
            userId = 0;

            if (string.IsNullOrWhiteSpace(TokenParam))
            {
                ShowTokenError("No reset token was supplied.");
                return false;
            }

            try
            {
                string tokenHash = SecurityHelper.HashToken(TokenParam);

                string sql = @"
                    SELECT TokenId, UserId, ExpiresAt, IsUsed 
                    FROM dbo.PasswordResetTokens 
                    WHERE TokenHash = @TokenHash";

                DataTable dt = DbHelper.ExecuteDataTable(sql, DbHelper.CreateParam("@TokenHash", SqlDbType.NVarChar, tokenHash));

                if (dt.Rows.Count == 0)
                {
                    ShowTokenError("The password reset token is invalid or does not exist.");
                    return false;
                }

                DataRow row = dt.Rows[0];
                bool isUsed = Convert.ToBoolean(row["IsUsed"]);
                DateTime expiresAt = Convert.ToDateTime(row["ExpiresAt"]);

                if (isUsed)
                {
                    ShowTokenError("This password reset token has already been used. Please request a new link.");
                    return false;
                }

                if (DateTime.UtcNow > expiresAt)
                {
                    ShowTokenError("This password reset link has expired. Reset links are only valid for 1 hour.");
                    return false;
                }

                tokenId = Convert.ToInt32(row["TokenId"]);
                userId = Convert.ToInt32(row["UserId"]);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("ValidateResetToken error: " + ex);
                ShowTokenError("An error occurred while validating the reset token. Please try again.");
                return false;
            }
        }

        private bool ValidateResetToken()
        {
            return ValidateResetToken(out _, out _);
        }

        private void ShowTokenError(string message)
        {
            pnlInvalidToken.Visible = true;
            litInvalidTokenMsg.Text = Server.HtmlEncode(message);
            pnlResetForm.Visible = false;
            pnlSuccess.Visible = false;
        }

        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            if (!ValidateResetToken(out int tokenId, out int userId))
            {
                return;
            }

            string newPassword = txtNewPassword.Text;
            if (string.IsNullOrEmpty(newPassword) || newPassword.Length < 8)
            {
                ShowTokenError("The password must be at least 8 characters long.");
                return;
            }

            try
            {
                // Generate secure PBKDF2 hash
                string passwordHash = SecurityHelper.HashPassword(newPassword);

                // Update user password and invalidate all tokens for this user
                DbHelper.ExecuteInTransaction((conn, tx) =>
                {
                    using (var updateCmd = conn.CreateCommand())
                    {
                        updateCmd.Transaction = tx;
                        updateCmd.CommandText = @"
                            UPDATE dbo.Users 
                            SET PasswordHash = @PasswordHash, UpdatedAt = SYSUTCDATETIME() 
                            WHERE UserId = @UserId;";
                        updateCmd.Parameters.Add(DbHelper.CreateParam("@PasswordHash", SqlDbType.NVarChar, passwordHash));
                        updateCmd.Parameters.Add(DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                        updateCmd.ExecuteNonQuery();
                    }

                    using (var tokenCmd = conn.CreateCommand())
                    {
                        tokenCmd.Transaction = tx;
                        tokenCmd.CommandText = @"
                            UPDATE dbo.PasswordResetTokens 
                            SET IsUsed = 1 
                            WHERE UserId = @UserId;";
                        tokenCmd.Parameters.Add(DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                        tokenCmd.ExecuteNonQuery();
                    }
                });

                pnlResetForm.Visible = false;
                pnlInvalidToken.Visible = false;
                pnlSuccess.Visible = true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("btnResetPassword error: " + ex);
                ShowTokenError("An error occurred while updating your password. Please try again.");
            }
        }
    }
}
