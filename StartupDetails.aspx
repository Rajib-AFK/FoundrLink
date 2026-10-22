<%@ Page Title="Startup Details" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="StartupDetails.aspx.cs" Inherits="FoundrLink.StartupDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-detail-meta-table td {
            padding: 14px 0;
            border-bottom: 1px solid #F1F5F9;
            font-size: 0.88rem;
        }
        .fl-detail-meta-table tr:last-child td {
            border-bottom: none;
        }
        .fl-startup-icon-box {
            width: 72px;
            height: 72px;
            border-radius: 12px;
            border: 1px solid #E2E8F0;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #FFFFFF;
            overflow: hidden;
            flex-shrink: 0;
            box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row g-4">
        <!-- Left Column -->
        <div class="col-lg-8">
            <!-- Header Card -->
            <div class="fl-card mb-4 p-4">
                <div class="d-flex align-items-center gap-4 mb-3">
                    <div class="fl-startup-icon-box">
                        <asp:Image ID="imgLogo" runat="server" Width="64" Height="64" style="object-fit:cover; border-radius:8px;" ImageUrl="https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=150" />
                    </div>
                    <div>
                        <div class="d-flex align-items-center gap-2 mb-1">
                            <h2 class="fw-bold mb-0 text-dark" style="font-size: 2rem; letter-spacing: -0.02em;">
                                <asp:Literal ID="litStartupName" runat="server" Text="EcoTrack" />
                            </h2>
                            <span class="badge bg-light text-muted border text-uppercase fw-bold px-2 py-1" style="font-size: 0.72rem; border-radius: 4px;">
                                <asp:Literal ID="litStageBadge" runat="server" Text="MVP" />
                            </span>
                        </div>
                        <p class="text-secondary mb-2" style="font-size: 0.95rem; color: #475569 !important;">
                            <asp:Literal ID="litTagline" runat="server" Text="Helping small businesses reduce environmental impact" />
                        </p>
                        <div class="d-flex align-items-center gap-3 text-muted small" style="font-size: 0.8rem;">
                            <span><i class="bi bi-shield-check me-1" style="color: #10B981;"></i><asp:Literal ID="litIndustry" runat="server" Text="Sustainability" /></span>
                            <span>&bull;</span>
                            <span><i class="bi bi-person me-1"></i><asp:Literal ID="litFounder" runat="server" Text="Rajibul Sheikh(Founder)" /></span>
                        </div>
                    </div>
                </div>

                <div class="pt-4 border-top d-flex flex-wrap gap-3 align-items-center" style="border-color: #F1F5F9 !important;">
                    <asp:Button ID="btnRequestJoin" runat="server" Text="Request to Join" CssClass="btn-fl-primary px-4" OnClick="btnRequestJoin_Click" />
                    <asp:Button ID="btnWithdrawJoin" runat="server" Text="Withdraw Request" CssClass="btn btn-outline-danger px-3" OnClick="btnWithdrawJoin_Click" Visible="false" />
                    <asp:Panel ID="pnlTeamMemberBadge" runat="server" Visible="false" CssClass="badge bg-success-subtle text-success border border-success-subtle px-3 py-2 fs-6">
                        <i class="bi bi-check-circle-fill me-1"></i> You are a Team Member
                    </asp:Panel>
                    <asp:Button ID="btnContactFounder" runat="server" Text="Contact Founder" CssClass="btn-fl-outline px-4" OnClick="btnContactFounder_Click" />
                    <a id="lnkTeamDetails" runat="server" href="#" class="btn-fl-outline ms-auto">
                        <i class="bi bi-people me-1"></i> View Team &amp; Careers
                    </a>
                    <asp:LinkButton ID="btnOpenReport" runat="server" CssClass="text-muted small text-decoration-none ms-2" OnClick="btnOpenReport_Click" ToolTip="Report this startup listing">
                        <i class="bi bi-flag"></i> Report
                    </asp:LinkButton>
                </div>

                <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success mt-3 py-2 small">
                    <asp:Literal ID="litAlertMessage" runat="server" />
                </asp:Panel>

                <!-- User-Facing Report Panel -->
                <asp:Panel ID="pnlReportStartup" runat="server" Visible="false" CssClass="card border-warning-subtle bg-light p-3 mt-3 rounded-3">
                    <h6 class="fw-bold text-dark mb-1"><i class="bi bi-flag-fill text-danger me-1"></i> Report this Startup Listing</h6>
                    <p class="text-muted small mb-2" style="font-size:0.8rem;">Reports are confidential and reviewed directly by FoundrLink platform operations within 24 hours.</p>
                    <div class="row g-2 mb-2">
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold text-dark mb-1">Reason for Report <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlReportCategory" runat="server" CssClass="form-select form-select-sm">
                                <asp:ListItem Text="Spam or Misleading Information" Value="Spam" />
                                <asp:ListItem Text="Suspicious or Fraudulent Activity" Value="Suspicious Activity" />
                                <asp:ListItem Text="Intellectual Property / Copyright" Value="Content Violation" />
                                <asp:ListItem Text="Inappropriate Content" Value="Inappropriate Content" />
                                <asp:ListItem Text="Other Terms Violation" Value="Other" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-semibold text-dark mb-1">Explanation <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtReportDetails" runat="server" TextMode="MultiLine" Rows="3" MaxLength="500" CssClass="form-control form-control-sm" placeholder="Please provide specific details explaining the violation (max 500 characters)..." />
                        </div>
                    </div>
                    <div class="d-flex gap-2">
                        <asp:Button ID="btnSubmitReport" runat="server" Text="Submit Report" CssClass="btn btn-sm btn-danger px-3" OnClick="btnSubmitReport_Click" />
                        <asp:Button ID="btnCancelReport" runat="server" Text="Cancel" CssClass="btn btn-sm btn-outline-secondary px-3" OnClick="btnCancelReport_Click" />
                    </div>
                </asp:Panel>
            </div>

            <!-- About Card -->
            <div class="fl-card mb-4 p-4">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <i class="bi bi-info-circle text-dark fs-5"></i>
                    <h5 class="fw-bold mb-0 text-dark">About</h5>
                </div>
                <div class="text-secondary lh-base" style="font-size: 0.92rem; color: #475569 !important; line-height: 1.65;">
                    <asp:Literal ID="litAbout" runat="server" Text="EcoTrack is an integrated platform designed to help small to medium-sized businesses seamlessly track, analyze, and offset their carbon footprint. We are building a comprehensive dashboard that integrates with existing supply chain management tools to provide real-time sustainability metrics." />
                </div>
            </div>

            <!-- The Problem & The Solution -->
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="fl-card h-100 p-4">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <i class="bi bi-exclamation-triangle text-dark fs-5"></i>
                            <h5 class="fw-bold mb-0 text-dark">The Problem</h5>
                        </div>
                        <p class="text-secondary small mb-0 lh-base" style="font-size: 0.85rem; color: #475569 !important; line-height: 1.6;">
                            <asp:Literal ID="litProblem" runat="server" Text="SMBs face increasing pressure to report on environmental impact, but lack affordable, easy-to-use tools. Current solutions are enterprise-focused, expensive, and require specialized sustainability officers." />
                        </p>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="fl-card h-100 p-4">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <i class="bi bi-lightbulb text-dark fs-5"></i>
                            <h5 class="fw-bold mb-0 text-dark">The Solution</h5>
                        </div>
                        <p class="text-secondary small mb-0 lh-base" style="font-size: 0.85rem; color: #475569 !important; line-height: 1.6;">
                            <asp:Literal ID="litSolution" runat="server" Text="A streamlined, AI-driven web application that automatically calculates emissions based on basic input data and utility bills, providing actionable reduction strategies and certified offset options." />
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column: Metadata Sidebar -->
        <div class="col-lg-4">
            <div class="fl-card p-4">
                <div class="text-uppercase tracking-wider fw-bold text-dark mb-3" style="font-size: 0.8rem; letter-spacing: 0.06em;">
                    STARTUP DETAILS
                </div>

                <table class="w-100 fl-detail-meta-table">
                    <tr>
                        <td class="text-muted">Industry</td>
                        <td class="fw-bold text-dark text-end"><asp:Literal ID="litMetaIndustry" runat="server" Text="Sustainability" /></td>
                    </tr>
                    <tr>
                        <td class="text-muted">Stage</td>
                        <td class="fw-bold text-dark text-end"><asp:Literal ID="litMetaStage" runat="server" Text="MVP" /></td>
                    </tr>
                    <tr>
                        <td class="text-muted">Founded</td>
                        <td class="fw-bold text-dark text-end"><asp:Literal ID="litMetaFounded" runat="server" Text="2023" /></td>
                    </tr>
                    <tr>
                        <td class="text-muted">Team Size</td>
                        <td class="fw-bold text-dark text-end"><asp:Literal ID="litMetaTeamSize" runat="server" Text="2 Members" /></td>
                    </tr>
                    <tr>
                        <td class="text-muted">Location</td>
                        <td class="fw-bold text-dark text-end"><asp:Literal ID="litMetaLocation" runat="server" Text="Remote (India)" /></td>
                    </tr>
                    <tr>
                        <td class="text-muted">Commitment</td>
                        <td class="fw-bold text-dark text-end"><asp:Literal ID="litMetaCommitment" runat="server" Text="Part-time / Equity" /></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</asp:Content>
