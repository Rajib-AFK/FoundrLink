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
        public int CurrentPage
        {
            get => ViewState["CurrentPage"] is int p ? p : 1;
            set => ViewState["CurrentPage"] = value;
        }

        public const int PageSize = 6;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!string.IsNullOrEmpty(Request.QueryString["q"]))
                {
                    txtSearch.Text = Request.QueryString["q"].Trim();
                }
                LoadStartups();
            }
        }

        private void LoadStartups()
        {
            try
            {
                var sb = new StringBuilder(@"
                    SELECT s.StartupId, s.Name, s.Tagline, s.Industry, s.Stage, s.LogoUrl, s.ShortDescription, 
                           s.TeamSize, s.RequiredSkills, s.Location, s.WebsiteUrl,
                           u.FullName AS FounderName, u.Title AS FounderTitle, u.AvatarUrl AS FounderAvatar
                    FROM dbo.Startups s
                    JOIN dbo.Users u ON s.FounderId = u.UserId
                    WHERE s.Status IN ('Active', 'Approved', 'Published')");

                var parameters = new List<SqlParameter>();

                string search = txtSearch.Text.Trim();
                if (!string.IsNullOrEmpty(search))
                {
                    sb.Append(" AND (s.Name LIKE @Search OR s.Tagline LIKE @Search OR s.Industry LIKE @Search OR s.RequiredSkills LIKE @Search)");
                    parameters.Add(DbHelper.CreateParam("@Search", SqlDbType.NVarChar, "%" + search + "%"));
                }

                if (!string.IsNullOrEmpty(ddlIndustry.SelectedValue))
                {
                    sb.Append(" AND s.Industry = @Industry");
                    parameters.Add(DbHelper.CreateParam("@Industry", SqlDbType.NVarChar, ddlIndustry.SelectedValue));
                }

                if (!string.IsNullOrEmpty(ddlSkill.SelectedValue))
                {
                    sb.Append(" AND s.RequiredSkills LIKE @Skill");
                    parameters.Add(DbHelper.CreateParam("@Skill", SqlDbType.NVarChar, "%" + ddlSkill.SelectedValue + "%"));
                }

                if (!string.IsNullOrEmpty(ddlStage.SelectedValue))
                {
                    sb.Append(" AND s.Stage = @Stage");
                    parameters.Add(DbHelper.CreateParam("@Stage", SqlDbType.NVarChar, ddlStage.SelectedValue));
                }

                if (!string.IsNullOrEmpty(ddlTeamSize.SelectedValue))
                {
                    if (ddlTeamSize.SelectedValue == "1-5")
                        sb.Append(" AND s.TeamSize BETWEEN 1 AND 5");
                    else if (ddlTeamSize.SelectedValue == "6-15")
                        sb.Append(" AND s.TeamSize BETWEEN 6 AND 15");
                    else if (ddlTeamSize.SelectedValue == "16-50")
                        sb.Append(" AND s.TeamSize BETWEEN 16 AND 50");
                }

                if (ddlSort.SelectedValue == "newest")
                    sb.Append(" ORDER BY s.StartupId DESC");
                else if (ddlSort.SelectedValue == "size")
                    sb.Append(" ORDER BY s.TeamSize DESC");
                else
                    sb.Append(" ORDER BY s.StartupId ASC");

                DataTable dt = DbHelper.ExecuteDataTable(sb.ToString(), parameters.ToArray());
                
                // Syllabus Unit 7: ADO.NET Disconnected Architecture - DataView & PagedDataSource
                int totalRecords = dt.Rows.Count;
                int totalPages = (int)Math.Ceiling((double)totalRecords / PageSize);
                if (totalPages < 1) totalPages = 1;

                if (CurrentPage > totalPages) CurrentPage = totalPages;
                if (CurrentPage < 1) CurrentPage = 1;

                DataView dv = new DataView(dt);
                var pds = new PagedDataSource
                {
                    DataSource = dv,
                    AllowPaging = true,
                    PageSize = PageSize,
                    CurrentPageIndex = CurrentPage - 1
                };

                btnPrevPage.Enabled = !pds.IsFirstPage;
                btnNextPage.Enabled = !pds.IsLastPage;
                btnPrevPage.CssClass = pds.IsFirstPage ? "fl-page-btn text-muted disabled" : "fl-page-btn";
                btnNextPage.CssClass = pds.IsLastPage ? "fl-page-btn text-muted disabled" : "fl-page-btn";

                litMatchCount.Text = $"{totalRecords} startups found (Page {CurrentPage} of {totalPages})";
                rptStartups.DataSource = pds;
                rptStartups.DataBind();

                pnlPagination.Visible = totalPages > 1;
                pnlEmptyState.Visible = totalRecords == 0;
                rptStartups.Visible = totalRecords > 0;

                // Build Pager links
                var pages = new List<dynamic>();
                for (int i = 1; i <= totalPages; i++)
                {
                    pages.Add(new { PageIndex = i, PageText = i.ToString(), IsActive = (i == CurrentPage) });
                }
                rptPager.DataSource = pages;
                rptPager.DataBind();
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
            CurrentPage = 1;
            txtSearch.Text = "";
            ddlIndustry.SelectedIndex = 0;
            ddlSkill.SelectedIndex = 0;
            ddlStage.SelectedIndex = 0;
            ddlTeamSize.SelectedIndex = 0;
            ddlSort.SelectedIndex = 0;
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

        protected void rptPager_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (int.TryParse(e.CommandArgument?.ToString(), out int p))
            {
                CurrentPage = p;
                LoadStartups();
            }
        }

        protected string FormatLocation(object location)
        {
            if (location == null || location == DBNull.Value || string.IsNullOrWhiteSpace(location.ToString()))
                return "Remote / Flexible";
            return location.ToString().Trim();
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
