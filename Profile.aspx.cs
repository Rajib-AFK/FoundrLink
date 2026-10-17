using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using FoundrLink.Helpers;

namespace FoundrLink
{
    public partial class Profile : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int targetUserId = 1; // Default to Yash Vinchhi (UserId 1) as seen in Figma screenshot

                if (!string.IsNullOrEmpty(Request.QueryString["id"]) && int.TryParse(Request.QueryString["id"], out int qId))
                {
                    targetUserId = qId;
                }
                else if (SecurityHelper.GetCurrentUserId().HasValue)
                {
                    targetUserId = SecurityHelper.GetCurrentUserId().Value;
                }

                LoadProfile(targetUserId);
            }
        }

        private void LoadProfile(int userId)
        {
            try
            {
                string query = @"
                    SELECT u.UserId, u.FullName, u.Title, u.Location, u.Bio, u.AvatarUrl, u.IsVerified, u.Company,
                           p.PlatformImpactConnections, p.PlatformImpactIntros, p.PlatformImpactTeams, p.PlatformImpactSaved,
                           p.Interests, p.Skills, p.ICanOffer, p.LookingFor, p.BaseLocation
                    FROM dbo.Users u
                    LEFT JOIN dbo.FounderProfiles p ON u.UserId = p.UserId
                    WHERE u.UserId = @UserId";

                DataTable dt = DbHelper.ExecuteDataTable(query, DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    litFullName.Text = r["FullName"]?.ToString() ?? "Founder";
                    litHeadline.Text = r["Title"]?.ToString() ?? "Founder & CEO";
                    litLocation.Text = r["Location"]?.ToString() ?? "Mumbai, India";
                    litIndustry.Text = r["Company"]?.ToString() ?? "SaaS, FinTech";

                    bool isVerified = Convert.ToBoolean(r["IsVerified"] != DBNull.Value ? r["IsVerified"] : false);
                    pnlVerified.Visible = isVerified;

                    string avatar = r["AvatarUrl"]?.ToString();
                    if (!string.IsNullOrEmpty(avatar))
                    {
                        imgAvatar.ImageUrl = avatar;
                    }

                    string bioText = r["Bio"]?.ToString() ?? "Serial entrepreneur with a passion for building scalable infrastructure that empowers creators and small businesses.";
                    litBio.Text = bioText.Replace("\n", "<br/><br/>");

                    litImpactConnections.Text = (r["PlatformImpactConnections"] != DBNull.Value && Convert.ToInt32(r["PlatformImpactConnections"]) > 0)
                        ? r["PlatformImpactConnections"].ToString() : "342";
                    litImpactIntros.Text = (r["PlatformImpactIntros"] != DBNull.Value && Convert.ToInt32(r["PlatformImpactIntros"]) > 0)
                        ? r["PlatformImpactIntros"].ToString() : "14";
                    litImpactTeams.Text = (r["PlatformImpactTeams"] != DBNull.Value && Convert.ToInt32(r["PlatformImpactTeams"]) > 0)
                        ? r["PlatformImpactTeams"].ToString() : "3";
                    litImpactSaved.Text = (r["PlatformImpactSaved"] != DBNull.Value && Convert.ToInt32(r["PlatformImpactSaved"]) > 0)
                        ? r["PlatformImpactSaved"].ToString() : "8";

                    litBaseLocation.Text = r["BaseLocation"]?.ToString() ?? "San Francisco & Mumbai";

                    // Split I Can Offer
                    string canOfferStr = r["ICanOffer"]?.ToString();
                    var canOfferList = new List<string>();
                    if (!string.IsNullOrEmpty(canOfferStr))
                    {
                        foreach (var item in canOfferStr.Split(new[] { '\n', '\r', ';' }, StringSplitOptions.RemoveEmptyEntries))
                        {
                            if (!string.IsNullOrWhiteSpace(item)) canOfferList.Add(item.Trim());
                        }
                    }
                    if (canOfferList.Count == 0)
                    {
                        canOfferList.AddRange(new[] {
                            "Technical Architecture Review",
                            "Go-to-Market Strategy for B2B",
                            "Introductions to Seed Investors",
                            "Product-Led Growth Mentorship"
                        });
                    }
                    rptCanOffer.DataSource = canOfferList;
                    rptCanOffer.DataBind();

                    // Split Looking For
                    string lookingForStr = r["LookingFor"]?.ToString();
                    var lookingForList = new List<string>();
                    if (!string.IsNullOrEmpty(lookingForStr))
                    {
                        foreach (var item in lookingForStr.Split(new[] { '\n', '\r', ';' }, StringSplitOptions.RemoveEmptyEntries))
                        {
                            if (!string.IsNullOrWhiteSpace(item)) lookingForList.Add(item.Trim());
                        }
                    }
                    if (lookingForList.Count == 0)
                    {
                        lookingForList.AddRange(new[] {
                            "Series A Lead Investors",
                            "Head of Growth Marketing",
                            "Strategic Partnerships in FinTech",
                            "Peer Founders for Mastermind"
                        });
                    }
                    rptLookingFor.DataSource = lookingForList;
                    rptLookingFor.DataBind();

                    // Split Interests
                    string interestsStr = r["Interests"]?.ToString();
                    var interestsList = new List<string>();
                    if (!string.IsNullOrEmpty(interestsStr))
                    {
                        foreach (var item in interestsStr.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries))
                        {
                            if (!string.IsNullOrWhiteSpace(item)) interestsList.Add(item.Trim());
                        }
                    }
                    if (interestsList.Count == 0)
                    {
                        interestsList.AddRange(new[] { "B2B SaaS", "FinTech", "System Architecture", "Go-to-Market", "Bootstrapping", "Venture Capital" });
                    }
                    rptInterests.DataSource = interestsList;
                    rptInterests.DataBind();
                }

                // Load User's Startup Preview
                string startupQuery = @"
                    SELECT TOP 1 Name, Tagline, Industry, Stage, LogoUrl, ShortDescription, TeamSize, 
                                 WebsiteUrl, FoundedYear, FundingRaised, MRR
                    FROM dbo.Startups 
                    WHERE FounderId = @UserId 
                    ORDER BY StartupId ASC";

                DataTable dtStartup = DbHelper.ExecuteDataTable(startupQuery, DbHelper.CreateParam("@UserId", SqlDbType.Int, userId));
                if (dtStartup.Rows.Count > 0)
                {
                    DataRow sr = dtStartup.Rows[0];
                    string web = sr["WebsiteUrl"]?.ToString() ?? "nexustech.io";
                    litStartupWebsite.Text = web.Replace("https://", "").Replace("http://", "");
                    lnkStartupWebsite.HRef = web.StartsWith("http") ? web : "https://" + web;
                    litStartupStage.Text = sr["Stage"]?.ToString() ?? "SEED STAGE";
                    litFoundedYear.Text = sr["FoundedYear"]?.ToString() ?? "2022";
                    litTeamSize.Text = sr["TeamSize"]?.ToString() ?? "12";
                    litFunding.Text = "₹1.5M";
                    litMRR.Text = "₹45k";
                    litStartupDescription.Text = sr["ShortDescription"]?.ToString() ?? "Automating backend compliance and payment routing for marketplace platforms.";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Profile load error: " + ex.Message);
            }
        }
    }
}
