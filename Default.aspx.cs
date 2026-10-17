using System;
using System.Data;
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
                LoadRaisingStartups();
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
                    WHERE Status IN ('Active', 'Approved')
                    ORDER BY StartupId ASC";

                DataTable dt = DbHelper.ExecuteDataTable(query);
                rptRaisingStartups.DataSource = dt;
                rptRaisingStartups.DataBind();
            }
            catch (Exception ex)
            {
                // Graceful fallback if database connection has temporary issue
                System.Diagnostics.Debug.WriteLine("Error loading startups: " + ex.Message);
            }
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
