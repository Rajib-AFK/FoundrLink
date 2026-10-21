using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class ExploreStartups : Page
    {
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
                litMatchCount.Text = dt.Rows.Count.ToString();
                rptStartups.DataSource = dt;
                rptStartups.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ExploreStartups error: " + ex.Message);
            }
        }

        protected void btnApply_Click(object sender, EventArgs e)
        {
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
            LoadStartups();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadStartups();
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
