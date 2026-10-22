using System;
using System.Web.UI;
using FoundrLink.Services;
using FoundrLink.Services.Interfaces;

namespace FoundrLink
{
    public partial class Support : Page
    {
        private readonly IModerationService _moderationService;

        public Support()
        {
            _moderationService = new ModerationService();
        }

        public Support(IModerationService moderationService)
        {
            _moderationService = moderationService ?? new ModerationService();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            pnlAlertSuccess.Visible = false;
        }

        protected void btnSubmitTicket_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = Session["Email"]?.ToString() ?? "user@ripaldesign.studio";
            string category = ddlCategory.SelectedValue;
            string priority = ddlPriority.SelectedValue;
            string subject = txtSubject.Text.Trim();
            string details = txtDetails.Text.Trim();

            var result = _moderationService.SubmitTicket(email, category, priority, subject, details, out string reportCode);

            if (result.Success)
            {
                litAlertSuccess.Text = $"Your ticket <strong>{reportCode}</strong> has been logged. An operations representative has been assigned.";
                pnlAlertSuccess.Visible = true;
                txtSubject.Text = string.Empty;
                txtDetails.Text = string.Empty;
            }
        }
    }
}
