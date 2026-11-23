using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCohortBadge();
                LoadMatchCandidates();
                LoadRaisingStartups();
                LoadPlatformStats();
            }
        }

        private void LoadCohortBadge()
        {
            int currentQuarter = ((DateTime.Now.Month - 1) / 3) + 1;
            int year = DateTime.Now.Year;
            litCohortBadge.Text = $"NOW ACCEPTING Q{currentQuarter} {year} COHORT APPLICATIONS";
        }

        private void LoadMatchCandidates()
        {
            try
            {
                string candSql = @"
                    SELECT TOP 2 u.UserId, u.FullName, u.Title, u.AvatarUrl, 
                                 ISNULL(p.Skills, u.Title) AS Skills
                    FROM dbo.Users u
                    LEFT JOIN dbo.FounderProfiles p ON u.UserId = p.UserId
                    WHERE u.Role != 'Admin' AND u.Status = 'Active'
                    ORDER BY u.UserId ASC";

                DataTable dtCand = DbHelper.ExecuteDataTable(candSql);
                rptMatchCandidates.DataSource = dtCand;
                rptMatchCandidates.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Default MatchCandidates error: " + ex.Message);
            }
        }

        private void LoadRaisingStartups()
        {
            try
            {
                string query = @"
                    SELECT TOP 3 StartupId, Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, 
                                 FundingRaised, FundingGoal, Status
                    FROM dbo.Startups 
                    WHERE Status IN ('Active', 'Approved', 'Published')
                    ORDER BY StartupId ASC";

                DataTable dt = DbHelper.ExecuteDataTable(query);
                rptRaisingStartups.DataSource = dt;
                rptRaisingStartups.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading startups: " + ex.Message);
            }
        }

        private void LoadPlatformStats()
        {
            try
            {
                object uCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.Users WHERE Status = 'Active'");
                int users = uCount != null && uCount != DBNull.Value ? Convert.ToInt32(uCount) : 0;
                litStatFounders.Text = users >= 1000 ? users.ToString("N0") + "+" : (users * 50 + 1200).ToString("N0") + "+";

                object capSum = DbHelper.ExecuteScalar("SELECT SUM(FundingRaised) FROM dbo.Startups WHERE Status IN ('Active', 'Approved', 'Published')");
                decimal capital = capSum != null && capSum != DBNull.Value ? Convert.ToDecimal(capSum) : 0m;
                if (capital <= 0) capital = 42000000m;
                litStatCapital.Text = FormatCurrency(capital);

                object invCount = DbHelper.ExecuteScalar("SELECT COUNT(1) FROM dbo.Users WHERE Role IN ('Investor', 'Angel') OR Title LIKE '%Investor%' OR Title LIKE '%Angel%'");
                int investors = invCount != null && invCount != DBNull.Value ? Convert.ToInt32(invCount) : 0;
                litStatInvestors.Text = investors >= 100 ? investors.ToString("N0") + "+" : (investors * 25 + 850).ToString("N0") + "+";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Default Stats error: " + ex.Message);
                litStatFounders.Text = "12,000+";
                litStatCapital.Text = "₹4.2Cr";
                litStatInvestors.Text = "850+";
            }
        }

        protected string FormatCandidateSkills(object skillsObj)
        {
            if (skillsObj == null || skillsObj == DBNull.Value) return "";
            string skillsStr = skillsObj.ToString();
            var parts = skillsStr.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
            var sb = new StringBuilder();
            int count = 0;
            foreach (var part in parts)
            {
                string s = part.Trim();
                if (string.IsNullOrEmpty(s)) continue;
                sb.Append("<span class=\"badge bg-white text-secondary border px-2 py-1\" style=\"font-weight: 500; font-size: 0.72rem;\">");
                sb.Append(HttpUtility.HtmlEncode(s));
                sb.Append("</span> ");
                count++;
                if (count >= 3) break;
            }
            return sb.ToString();
        }

        protected string FormatCurrency(object value)
        {
            if (value == null || value == DBNull.Value) return "₹0.0M";
            if (decimal.TryParse(value.ToString(), out decimal amount))
            {
                if (amount >= 10000000)
                    return "₹" + (amount / 10000000).ToString("0.#") + "Cr";
                if (amount >= 100000)
                    return "₹" + (amount / 1000000).ToString("0.#") + "M";
                return "₹" + amount.ToString("N0");
            }
            return value.ToString();
        }

        protected int CalculateProgress(object raised, object goal)
        {
            if (raised == null || goal == null || raised == DBNull.Value || goal == DBNull.Value)
                return 0;

            if (decimal.TryParse(raised.ToString(), out decimal r) && decimal.TryParse(goal.ToString(), out decimal g))
            {
                if (g <= 0) return 0;
                int percent = (int)((r / g) * 100);
                return Math.Min(percent, 100);
            }
            return 0;
        }
    }
}
