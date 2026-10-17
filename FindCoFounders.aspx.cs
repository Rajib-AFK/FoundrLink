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
    public partial class FindCoFounders : Page
    {
        private string _activeSkill = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                chkRoleTech.Checked = true; // Default as shown in Figma reference
                _activeSkill = "React";
                ViewState["ActiveSkill"] = _activeSkill;
                LoadFounders();
            }
            else
            {
                _activeSkill = ViewState["ActiveSkill"]?.ToString() ?? "";
            }
        }

        private void LoadFounders()
        {
            try
            {
                var sb = new StringBuilder(@"
                    SELECT u.UserId, u.FullName, u.Title, u.Location, u.Bio, u.AvatarUrl,
                           p.Skills, p.Availability
                    FROM dbo.Users u
                    LEFT JOIN dbo.FounderProfiles p ON u.UserId = p.UserId
                    WHERE u.Role != 'Admin' AND u.Status = 'Active'");

                var parameters = new List<SqlParameter>();

                // Role filtering
                var roles = new List<string>();
                if (chkRoleTech.Checked) roles.Add("'Co-Founder'");
                if (chkRoleBiz.Checked) roles.Add("'Founder'");
                if (chkRoleMarketing.Checked) roles.Add("'Marketing'");

                if (roles.Count > 0)
                {
                    sb.Append(" AND (u.Role IN (" + string.Join(",", roles) + ") OR u.Title LIKE '%Engineer%' OR u.Title LIKE '%Architect%' OR u.Title LIKE '%Designer%')");
                    pnlFilterRole.Visible = true;
                    litFilterRoleName.Text = chkRoleTech.Checked ? "Technical" : (chkRoleBiz.Checked ? "Business" : "Marketing");
                }
                else
                {
                    pnlFilterRole.Visible = false;
                }

                // Skill filtering
                if (!string.IsNullOrEmpty(_activeSkill))
                {
                    sb.Append(" AND (p.Skills LIKE @Skill OR u.Bio LIKE @Skill OR u.Title LIKE @Skill)");
                    parameters.Add(DbHelper.CreateParam("@Skill", SqlDbType.NVarChar, "%" + _activeSkill + "%"));
                    pnlFilterSkill.Visible = true;
                    litFilterSkillName.Text = _activeSkill;
                }
                else
                {
                    pnlFilterSkill.Visible = false;
                }

                // Industry filtering
                if (!string.IsNullOrEmpty(ddlIndustry.SelectedValue))
                {
                    sb.Append(" AND (u.Company LIKE @Industry OR p.Interests LIKE @Industry)");
                    parameters.Add(DbHelper.CreateParam("@Industry", SqlDbType.NVarChar, "%" + ddlIndustry.SelectedValue + "%"));
                }

                // Availability filtering
                if (rbAvailFull.Checked)
                {
                    sb.Append(" AND (p.Availability = 'Full-time' OR p.Availability IS NULL)");
                }
                else if (rbAvailPart.Checked)
                {
                    sb.Append(" AND (p.Availability LIKE '%Part-time%' OR p.Availability LIKE '%Side%')");
                }

                sb.Append(" ORDER BY u.UserId ASC");

                DataTable dt = DbHelper.ExecuteDataTable(sb.ToString(), parameters.ToArray());
                litCount.Text = dt.Rows.Count.ToString();
                rptFounders.DataSource = dt;
                rptFounders.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("FindCoFounders error: " + ex.Message);
            }
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadFounders();
        }

        protected void btnSkill_Click(object sender, EventArgs e)
        {
            var btn = (LinkButton)sender;
            string arg = btn.CommandArgument;
            if (_activeSkill == arg)
            {
                _activeSkill = "";
            }
            else
            {
                _activeSkill = arg;
            }
            ViewState["ActiveSkill"] = _activeSkill;
            LoadFounders();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            chkRoleTech.Checked = false;
            chkRoleBiz.Checked = false;
            chkRoleMarketing.Checked = false;
            _activeSkill = "";
            ViewState["ActiveSkill"] = "";
            ddlIndustry.SelectedIndex = 0;
            rbAvailAll.Checked = true;
            LoadFounders();
        }

        protected void rptFounders_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Connect")
            {
                int receiverId = Convert.ToInt32(e.CommandArgument);
                int? currentUserId = SecurityHelper.GetCurrentUserId();
                int senderId = currentUserId ?? 2;

                try
                {
                    string sql = @"
                        IF NOT EXISTS (SELECT 1 FROM dbo.ConnectionRequests WHERE SenderId = @SenderId AND ReceiverId = @ReceiverId)
                        BEGIN
                            INSERT INTO dbo.ConnectionRequests (SenderId, ReceiverId, Note, Status, CreatedAt)
                            VALUES (@SenderId, @ReceiverId, 'Hi, I would love to connect with you on FoundrLink!', 'Pending', SYSUTCDATETIME());
                        END";

                    DbHelper.ExecuteNonQuery(sql,
                        DbHelper.CreateParam("@SenderId", SqlDbType.Int, senderId),
                        DbHelper.CreateParam("@ReceiverId", SqlDbType.Int, receiverId));

                    ScriptManager.RegisterStartupScript(this, GetType(), "connected", "alert('Connection request sent successfully!');", true);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Connect error: " + ex.Message);
                }
            }
        }

        protected string FormatSkillPills(object skills)
        {
            if (skills == null || skills == DBNull.Value) return "";
            string s = skills.ToString();
            var sb = new StringBuilder();
            foreach (var item in s.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries))
            {
                if (!string.IsNullOrWhiteSpace(item))
                {
                    sb.Append("<span class=\"badge bg-light text-dark border text-uppercase me-1 mb-1\" style=\"font-size: 0.7rem;\">" + Server.HtmlEncode(item.Trim()) + "</span>");
                }
            }
            return sb.ToString();
        }
    }
}
