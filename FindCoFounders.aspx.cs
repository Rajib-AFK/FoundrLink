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
            string skill = btn.CommandArgument;

            if (_activeSkill.Equals(skill, StringComparison.OrdinalIgnoreCase))
            {
                _activeSkill = "";
            }
            else
            {
                _activeSkill = skill;
            }
            ViewState["ActiveSkill"] = _activeSkill;
            LoadFounders();
        }

        protected void btnAddSkill_Click(object sender, EventArgs e)
        {
            string custom = txtCustomSkill.Text.Trim();
            if (!string.IsNullOrEmpty(custom))
            {
                _activeSkill = custom;
                ViewState["ActiveSkill"] = _activeSkill;
                txtCustomSkill.Text = string.Empty;
                LoadFounders();
            }
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            chkRoleTech.Checked = false;
            chkRoleBiz.Checked = false;
            chkRoleMarketing.Checked = false;
            _activeSkill = "";
            ViewState["ActiveSkill"] = "";
            txtCustomSkill.Text = string.Empty;
            ddlIndustry.SelectedIndex = 0;
            rbAvailAll.Checked = true;
            LoadFounders();
        }

        protected void rptFounders_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Connect")
            {
                int? currentUserId = SecurityHelper.GetCurrentUserId();
                if (!currentUserId.HasValue)
                {
                    Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                    return;
                }

                int senderId = currentUserId.Value;
                int receiverId = Convert.ToInt32(e.CommandArgument);

                if (senderId == receiverId)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "selfConnect", "alert('You cannot connect with yourself.');", true);
                    return;
                }

                try
                {
                    string sql = @"
                        IF NOT EXISTS (SELECT 1 FROM dbo.ConnectionRequests WHERE SenderId = @SenderId AND ReceiverId = @ReceiverId AND Status = 'Pending')
                        BEGIN
                            INSERT INTO dbo.ConnectionRequests (SenderId, ReceiverId, Note, Status, CreatedAt)
                            VALUES (@SenderId, @ReceiverId, 'Hi, I would love to connect with you on FoundrLink!', 'Pending', SYSUTCDATETIME());

                            INSERT INTO dbo.Notifications (UserId, Title, Message, NotificationType, ActionRequired, IsRead, CreatedAt)
                            VALUES (@ReceiverId, 'New Connection Request', @SenderName + ' sent you a connection request.', 'Requests', 1, 0, SYSUTCDATETIME());
                        END";

                    string senderName = SecurityHelper.GetCurrentUserName();
                    DbHelper.ExecuteNonQuery(sql,
                        DbHelper.CreateParam("@SenderId", SqlDbType.Int, senderId),
                        DbHelper.CreateParam("@ReceiverId", SqlDbType.Int, receiverId),
                        DbHelper.CreateParam("@SenderName", SqlDbType.NVarChar, senderName));

                    ScriptManager.RegisterStartupScript(this, GetType(), "connected", "alert('Connection request sent successfully!');", true);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("Connect error: " + ex);
                    ScriptManager.RegisterStartupScript(this, GetType(), "connectErr", "alert('Unable to send connection request. Please try again.');", true);
                }
            }
        }

        protected string FormatSkillPills(object skills)
        {
            if (skills == null || skills == DBNull.Value) return "";
            string s = skills.ToString();
            var sb = new StringBuilder();
            int idx = 0;
            foreach (var item in s.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries))
            {
                if (!string.IsNullOrWhiteSpace(item))
                {
                    string trimmed = item.Trim();
                    string chipClass = (idx == 0 || trimmed.Equals("React", StringComparison.OrdinalIgnoreCase)) ? "fl-skill-chip-blue" : "fl-skill-chip-gray";
                    sb.Append("<span class=\"" + chipClass + " me-1 mb-1\">" + Server.HtmlEncode(trimmed.ToUpperInvariant()) + "</span>");
                    idx++;
                }
            }
            return sb.ToString();
        }

        protected int CalculateMatchScore(object skills)
        {
            if (skills == null || skills == DBNull.Value) return 75;
            string s = skills.ToString().ToLowerInvariant();
            int score = 70;
            string[] keywords = { "react", "python", "typescript", "architecture", "c#", "node", "figma", "ai", "cloud" };
            int matches = 0;
            foreach (var kw in keywords)
            {
                if (s.Contains(kw)) matches++;
            }
            score += Math.Min(matches * 6, 28);
            return Math.Min(score, 98);
        }
    }
}
