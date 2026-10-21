using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;
using FoundrLink.Services;
using FoundrLink.Services.Interfaces;

namespace FoundrLink.Admin
{
    public partial class Reports : Page
    {
        private readonly IModerationService _moderationService;

        public Reports()
        {
            _moderationService = new ModerationService();
        }

        public Reports(IModerationService moderationService)
        {
            _moderationService = moderationService ?? new ModerationService();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SecurityHelper.IsUserLoggedIn() || !SecurityHelper.IsUserAdmin())
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            pnlAlert.Visible = false;

            if (!IsPostBack)
            {
                LoadReports();
            }
        }

        private void LoadReports()
        {
            try
            {
                string search = txtSearch.Text.Trim();
                string status = ddlStatusFilter.SelectedValue;
                string priority = ddlPriorityFilter.SelectedValue;

                var dt = _moderationService.GetReportsDataTable(search, status, priority);
                rptReports.DataSource = dt;
                rptReports.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadReports error: " + ex);
                litAlertMsg.Text = "An error occurred while loading reports.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadReports();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlStatusFilter.SelectedIndex = 0;
            ddlPriorityFilter.SelectedIndex = 0;
            LoadReports();
        }

        protected void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!SecurityHelper.IsUserAdmin())
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            int reportId = Convert.ToInt32(e.CommandArgument);

            try
            {
                if (e.CommandName == "Resolve")
                {
                    var result = _moderationService.ResolveReport(reportId);
                    if (result.Success)
                    {
                        litAlertMsg.Text = "Ticket successfully marked as <strong>Resolved</strong>.";
                        pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    }
                    else
                    {
                        litAlertMsg.Text = Server.HtmlEncode(result.Message);
                        pnlAlert.CssClass = "alert alert-warning py-2 small mb-3";
                    }
                    pnlAlert.Visible = true;
                    LoadReports();
                }
                else if (e.CommandName == "Dismiss")
                {
                    var result = _moderationService.DismissReport(reportId);
                    if (result.Success)
                    {
                        litAlertMsg.Text = "Ticket marked as <strong>Dismissed</strong>.";
                        pnlAlert.CssClass = "alert alert-success py-2 small mb-3";
                    }
                    else
                    {
                        litAlertMsg.Text = Server.HtmlEncode(result.Message);
                        pnlAlert.CssClass = "alert alert-warning py-2 small mb-3";
                    }
                    pnlAlert.Visible = true;
                    LoadReports();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("rptReports_ItemCommand error: " + ex);
                litAlertMsg.Text = "An error occurred while updating the report status.";
                pnlAlert.CssClass = "alert alert-danger py-2 small mb-3";
                pnlAlert.Visible = true;
            }
        }

        public string GetPriorityBadgeClass(string priority)
        {
            switch (priority)
            {
                case "Urgent": return "badge bg-danger-subtle text-danger";
                case "High": return "badge bg-warning-subtle text-warning";
                case "Normal": return "badge bg-primary-subtle text-primary";
                default: return "badge bg-light text-secondary border";
            }
        }
    }
}
