using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class ExploreStartups : Page
    {
        private const int PageSize = 6;

        public class PagerItem
        {
            public string PageText { get; set; }
            public int PageIndex { get; set; }
            public bool IsActive { get; set; }
        }

        private int CurrentPage
        {
            get
            {
                if (ViewState["CurrentPage"] != null && int.TryParse(ViewState["CurrentPage"].ToString(), out int page))
                {
                    return Math.Max(1, page);
                }
                return 1;
            }
            set
            {
                ViewState["CurrentPage"] = Math.Max(1, value);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!string.IsNullOrEmpty(Request.QueryString["q"]))
                {
                    txtSearch.Text = Request.QueryString["q"].Trim();
                }

                if (!string.IsNullOrEmpty(Request.QueryString["industry"]))
                {
                    var item = ddlIndustry.Items.FindByValue(Request.QueryString["industry"]);
                    if (item != null) ddlIndustry.SelectedValue = item.Value;
                }

                if (!string.IsNullOrEmpty(Request.QueryString["skill"]))
                {
                    var item = ddlSkill.Items.FindByValue(Request.QueryString["skill"]);
                    if (item != null) ddlSkill.SelectedValue = item.Value;
                }

                if (!string.IsNullOrEmpty(Request.QueryString["stage"]))
                {
                    var item = ddlStage.Items.FindByValue(Request.QueryString["stage"]);
                    if (item != null) ddlStage.SelectedValue = item.Value;
                }

                if (int.TryParse(Request.QueryString["page"], out int p) && p > 0)
                {
                    CurrentPage = p;
                }
                else
                {
                    CurrentPage = 1;
                }

                LoadStartups();
            }
        }

        private void LoadStartups()
        {
            try
            {
                var sb = new StringBuilder(@"
                    SELECT s.StartupId, s.Name, s.Tagline, s.Industry, s.Stage, 
                           COALESCE(NULLIF(s.LogoUrl, ''), 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100') AS LogoUrl, 
                           s.ShortDescription, 
                           s.TeamSize, s.RequiredSkills, s.Location, s.WebsiteUrl,
                           COALESCE(u.FullName, 'Founder') AS FounderName, 
                           COALESCE(u.Title, 'Founder & CEO') AS FounderTitle, 
                           COALESCE(NULLIF(u.AvatarUrl, ''), 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100') AS FounderAvatar
                    FROM dbo.Startups s
                    LEFT JOIN dbo.Users u ON s.FounderId = u.UserId
                    WHERE s.Status IN ('Active', 'Approved', 'Published')");

                var parameters = new List<SqlParameter>();
                var activeFilters = new List<string>();

                string search = txtSearch.Text.Trim();
                if (!string.IsNullOrEmpty(search))
                {
                    sb.Append(@" AND (
                        s.Name LIKE @Search 
                        OR s.Tagline LIKE @Search 
                        OR s.Industry LIKE @Search 
                        OR s.RequiredSkills LIKE @Search
                        OR s.ShortDescription LIKE @Search
                        OR s.Location LIKE @Search
                        OR u.FullName LIKE @Search
                        OR s.Stage LIKE @Search
                    )");
                    parameters.Add(DbHelper.CreateParam("@Search", SqlDbType.NVarChar, "%" + search + "%"));
                    activeFilters.Add("Keyword: \"" + Server.HtmlEncode(search) + "\"");
                }

                if (!string.IsNullOrEmpty(ddlIndustry.SelectedValue))
                {
                    sb.Append(" AND s.Industry LIKE @Industry");
                    parameters.Add(DbHelper.CreateParam("@Industry", SqlDbType.NVarChar, "%" + ddlIndustry.SelectedValue + "%"));
                    activeFilters.Add("Industry: " + ddlIndustry.SelectedItem.Text);
                }

                if (!string.IsNullOrEmpty(ddlSkill.SelectedValue))
                {
                    sb.Append(" AND s.RequiredSkills LIKE @Skill");
                    parameters.Add(DbHelper.CreateParam("@Skill", SqlDbType.NVarChar, "%" + ddlSkill.SelectedValue + "%"));
                    activeFilters.Add("Skill: " + ddlSkill.SelectedItem.Text);
                }

                if (!string.IsNullOrEmpty(ddlStage.SelectedValue))
                {
                    sb.Append(" AND (s.Stage = @Stage OR s.Stage LIKE @StageLike)");
                    parameters.Add(DbHelper.CreateParam("@Stage", SqlDbType.NVarChar, ddlStage.SelectedValue));
                    parameters.Add(DbHelper.CreateParam("@StageLike", SqlDbType.NVarChar, "%" + ddlStage.SelectedValue.Replace(" Stage", "") + "%"));
                    activeFilters.Add("Stage: " + ddlStage.SelectedItem.Text);
                }

                if (!string.IsNullOrEmpty(ddlTeamSize.SelectedValue))
                {
                    if (ddlTeamSize.SelectedValue == "1-5")
                    {
                        sb.Append(" AND s.TeamSize BETWEEN 1 AND 5");
                        activeFilters.Add("Team: 1-5");
                    }
                    else if (ddlTeamSize.SelectedValue == "6-15")
                    {
                        sb.Append(" AND s.TeamSize BETWEEN 6 AND 15");
                        activeFilters.Add("Team: 6-15");
                    }
                    else if (ddlTeamSize.SelectedValue == "16-50")
                    {
                        sb.Append(" AND s.TeamSize BETWEEN 16 AND 50");
                        activeFilters.Add("Team: 16-50");
                    }
                    else if (ddlTeamSize.SelectedValue == "50+")
                    {
                        sb.Append(" AND s.TeamSize > 50");
                        activeFilters.Add("Team: 50+");
                    }
                }

                // Sorting
                if (ddlSort.SelectedValue == "newest")
                    sb.Append(" ORDER BY s.StartupId DESC");
                else if (ddlSort.SelectedValue == "size")
                    sb.Append(" ORDER BY s.TeamSize DESC, s.StartupId DESC");
                else if (ddlSort.SelectedValue == "name")
                    sb.Append(" ORDER BY s.Name ASC");
                else
                    sb.Append(" ORDER BY s.StartupId ASC");

                // Update filter summary text
                if (activeFilters.Count > 0)
                {
                    litActiveFilterSummary.Text = "<span class=\"text-primary fw-semibold\"><i class=\"bi bi-funnel-fill me-1\"></i>Filtered by:</span> " + string.Join(" &bull; ", activeFilters);
                }
                else
                {
                    litActiveFilterSummary.Text = "";
                }

                DataTable dt = DbHelper.ExecuteDataTable(sb.ToString(), parameters.ToArray());
                int totalRecords = dt != null ? dt.Rows.Count : 0;

                if (totalRecords == 0)
                {
                    litMatchCount.Text = "Showing <strong class=\"text-dark\">0</strong> startups matching your criteria";
                    rptStartups.DataSource = null;
                    rptStartups.DataBind();
                    pnlEmptyState.Visible = true;
                    pnlPagination.Visible = false;
                    return;
                }

                pnlEmptyState.Visible = false;

                int totalPages = (int)Math.Ceiling((double)totalRecords / PageSize);
                if (totalPages < 1) totalPages = 1;

                if (CurrentPage > totalPages)
                {
                    CurrentPage = totalPages;
                }
                if (CurrentPage < 1)
                {
                    CurrentPage = 1;
                }

                int startIndex = (CurrentPage - 1) * PageSize;
                int endIndex = Math.Min(startIndex + PageSize, totalRecords);

                if (startIndex >= totalRecords)
                {
                    startIndex = 0;
                    CurrentPage = 1;
                    endIndex = Math.Min(PageSize, totalRecords);
                }

                litMatchCount.Text = string.Format("Showing <strong class=\"text-dark\">{0}-{1}</strong> of <strong class=\"text-dark\">{2}</strong> startups matching your criteria",
                    startIndex + 1, endIndex, totalRecords);

                // Slice page data
                DataTable pagedTable = dt.Clone();
                for (int i = startIndex; i < endIndex; i++)
                {
                    pagedTable.ImportRow(dt.Rows[i]);
                }

                rptStartups.DataSource = pagedTable;
                rptStartups.DataBind();

                // Setup pagination buttons
                if (totalPages > 1)
                {
                    pnlPagination.Visible = true;
                    btnPrevPage.Enabled = (CurrentPage > 1);
                    btnPrevPage.CssClass = CurrentPage > 1 ? "fl-page-btn" : "fl-page-btn disabled";

                    btnNextPage.Enabled = (CurrentPage < totalPages);
                    btnNextPage.CssClass = CurrentPage < totalPages ? "fl-page-btn" : "fl-page-btn disabled";

                    var pagerList = new List<PagerItem>();
                    for (int i = 1; i <= totalPages; i++)
                    {
                        pagerList.Add(new PagerItem
                        {
                            PageIndex = i,
                            PageText = i.ToString(),
                            IsActive = (i == CurrentPage)
                        });
                    }

                    rptPager.DataSource = pagerList;
                    rptPager.DataBind();
                }
                else
                {
                    pnlPagination.Visible = false;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ExploreStartups error: " + ex.Message);
            }
        }

        protected void btnApply_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            LoadStartups();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlIndustry.SelectedIndex = 0;
            ddlSkill.SelectedIndex = 0;
            ddlStage.SelectedIndex = 0;
            ddlTeamSize.SelectedIndex = 0;
            ddlSort.SelectedIndex = 0;
            CurrentPage = 1;
            LoadStartups();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            CurrentPage = 1;
            LoadStartups();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage--;
                LoadStartups();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            CurrentPage++;
            LoadStartups();
        }

        protected void rptPager_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Page" && int.TryParse(e.CommandArgument.ToString(), out int targetPage))
            {
                CurrentPage = targetPage;
                LoadStartups();
            }
        }

        protected string FormatLocation(object loc)
        {
            if (loc == null || loc == DBNull.Value || string.IsNullOrWhiteSpace(loc.ToString()))
            {
                return "Remote";
            }
            return loc.ToString().Trim();
        }

        protected string FormatSkills(object skills)
        {
            if (skills == null || skills == DBNull.Value) return "";
            string s = skills.ToString();
            var sb = new StringBuilder();
            foreach (var item in s.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries))
            {
                if (!string.IsNullOrWhiteSpace(item))
                {
                    sb.Append("<span class=\"fl-skill-chip\">" + Server.HtmlEncode(item.Trim()) + "</span> ");
                }
            }
            return sb.ToString();
        }
    }
}
