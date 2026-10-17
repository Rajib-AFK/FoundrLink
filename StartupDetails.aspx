<%@ Page Title="Startup Details" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="StartupDetails.aspx.cs" Inherits="FoundrLink.StartupDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-detail-meta-table td {
            padding: 12px 0;
            border-bottom: 1px solid #F1F5F9;
            font-size: 0.9rem;
        }
        .fl-detail-meta-table tr:last-child td {
            border-bottom: none;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row g-4">
        <!-- Left Column -->
        <div class="col-lg-8">
            <!-- Header Card -->
            <div class="fl-card mb-4">
                <div class="d-flex align-items-start gap-4 mb-3">
                    <div class="fl-startup-logo-box" style="width: 72px; height: 72px;">
                        <asp:Image ID="imgLogo" runat="server" CssClass="rounded-2" Width="64" Height="64" style="object-fit:cover;" ImageUrl="https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=150" />
                    </div>
                    <div>
                        <div class="d-flex align-items-center gap-2 mb-1">
                            <h2 class="fw-bold mb-0 text-dark">
                                <asp:Literal ID="litStartupName" runat="server" Text="EcoTrack" />
                            </h2>
                            <span class="badge bg-light text-muted border text-uppercase fw-bold">
                                <asp:Literal ID="litStageBadge" runat="server" Text="MVP" />
                            </span>
                        </div>
                        <p class="text-muted mb-2 fs-6">
                            <asp:Literal ID="litTagline" runat="server" Text="Helping small businesses reduce environmental impact" />
                        </p>
                        <div class="d-flex align-items-center gap-3 text-muted small">
                            <span><i class="bi bi-shield-shaded me-1"></i><asp:Literal ID="litIndustry" runat="server" Text="Sustainability" /></span>
                            <span><i class="bi bi-person me-1"></i><asp:Literal ID="litFounder" runat="server" Text="Rajibul Sheikh (Founder)" /></span>
                        </div>
                    </div>
                </div>

                <div class="pt-3 border-top border-slate-100 d-flex gap-3">
                    <asp:Button ID="btnRequestJoin" runat="server" Text="Request to Join" CssClass="btn btn-fl-primary px-4" OnClick="btnRequestJoin_Click" />
                    <asp:Button ID="btnContactFounder" runat="server" Text="Contact Founder" CssClass="btn btn-fl-outline px-4" OnClick="btnContactFounder_Click" />
                    <a id="lnkTeamDetails" runat="server" href="#" class="btn btn-fl-outline ms-auto">
                        <i class="bi bi-people me-1"></i> View Team &amp; Careers
                    </a>
                </div>

                <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success mt-3 py-2 small">
                    <asp:Literal ID="litAlertMessage" runat="server" />
                </asp:Panel>
            </div>

            <!-- About Card -->
            <div class="fl-card mb-4">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <i class="bi bi-info-circle text-dark fs-5"></i>
                    <h5 class="fw-bold mb-0">About</h5>
                </div>
                <div class="text-muted lh-base" style="font-size: 0.95rem;">
                    <asp:Literal ID="litAbout" runat="server" Text="EcoTrack is an integrated platform designed to help small to medium-sized businesses seamlessly track, analyze, and offset their carbon footprint. We are building a comprehensive dashboard that integrates with existing supply chain management tools to provide real-time sustainability metrics." />
                </div>
            </div>

            <!-- The Problem & The Solution -->
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="fl-card h-100">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <i class="bi bi-exclamation-triangle text-dark fs-5"></i>
                            <h5 class="fw-bold mb-0">The Problem</h5>
                        </div>
                        <p class="text-muted small mb-0 lh-base">
                            <asp:Literal ID="litProblem" runat="server" Text="SMBs face increasing pressure to report on environmental impact, but lack affordable, easy-to-use tools. Current solutions are enterprise-focused, expensive, and require specialized sustainability officers." />
                        </p>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="fl-card h-100">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <i class="bi bi-lightbulb text-dark fs-5"></i>
                            <h5 class="fw-bold mb-0">The Solution</h5>
                        </div>
                        <p class="text-muted small mb-0 lh-base">
                            <asp:Literal ID="litSolution" runat="server" Text="A streamlined, AI-driven web application that automatically calculates emissions based on basic input data and utility bills, providing actionable reduction strategies and certified offset options." />
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column: Metadata Sidebar -->
        <div class="col-lg-4">
            <div class="fl-card">
                <div class="text-uppercase tracking-wider fw-bold small text-muted mb-3">
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
