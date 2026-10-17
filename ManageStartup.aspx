<%@ Page Title="Manage Startup" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="ManageStartup.aspx.cs" Inherits="FoundrLink.ManageStartup" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-form-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: 14px;
            padding: 28px;
            margin-bottom: 24px;
        }
        .fl-section-title {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.15rem;
            font-weight: 700;
            color: #0F172A;
            margin-bottom: 20px;
        }
        .fl-logo-preview {
            width: 64px;
            height: 64px;
            border: 1px dashed #CBD5E1;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #94A3B8;
            font-size: 1.5rem;
            background: #F8FAFC;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mb-3">
        <a href="ExploreStartups.aspx" class="text-secondary small text-decoration-none fw-semibold">
            <i class="bi bi-arrow-left"></i> Back to Startups
        </a>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1 fs-3">Create Your Startup</h2>
            <p class="text-muted small mb-0">Detail your vision to connect with co-founders and investors.</p>
        </div>
        <span class="badge bg-light text-muted border px-3 py-2 fw-semibold">
            <i class="bi bi-file-earmark me-1"></i>
            <asp:Literal ID="litStatusBadge" runat="server" Text="Draft" />
        </span>
    </div>

    <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="alert alert-success py-2 small mb-4">
        <asp:Literal ID="litSuccess" runat="server" />
    </asp:Panel>

    <!-- 1. Basic Information -->
    <div class="fl-form-card">
        <div class="fl-section-title">
            <i class="bi bi-info-circle text-primary"></i>
            <span>Basic Information</span>
        </div>

        <div class="mb-3">
            <label class="form-label small fw-semibold text-dark">Startup Name <span class="text-danger">*</span></label>
            <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="e.g. Rita Sharma" />
            <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ErrorMessage="Startup Name is required" CssClass="text-danger small mt-1 d-block" Display="Dynamic" ValidationGroup="vgStartup" />
        </div>

        <div class="mb-3">
            <label class="form-label small fw-semibold text-dark">Tagline</label>
            <asp:TextBox ID="txtTagline" runat="server" CssClass="form-control" placeholder="One sentence describing what you do" />
        </div>

        <div class="row g-3 mb-3">
            <div class="col-md-6">
                <label class="form-label small fw-semibold text-dark">Industry</label>
                <asp:DropDownList ID="ddlIndustry" runat="server" CssClass="form-select">
                    <asp:ListItem Value="" Text="Select industry..." />
                    <asp:ListItem Value="AI/ML" Text="AI/ML" />
                    <asp:ListItem Value="FinTech" Text="FinTech" />
                    <asp:ListItem Value="HealthTech" Text="HealthTech" />
                    <asp:ListItem Value="Sustainability" Text="Sustainability" />
                    <asp:ListItem Value="PropTech" Text="PropTech" />
                    <asp:ListItem Value="Climate Tech" Text="Climate Tech" />
                    <asp:ListItem Value="B2B SaaS" Text="B2B SaaS" />
                </asp:DropDownList>
            </div>
            <div class="col-md-6">
                <label class="form-label small fw-semibold text-dark">Current Stage</label>
                <asp:DropDownList ID="ddlStage" runat="server" CssClass="form-select">
                    <asp:ListItem Value="" Text="Select stage..." />
                    <asp:ListItem Value="Pre-Seed" Text="Pre-Seed" />
                    <asp:ListItem Value="Seed Stage" Text="Seed Stage" />
                    <asp:ListItem Value="Series A" Text="Series A" />
                    <asp:ListItem Value="MVP" Text="MVP" />
                </asp:DropDownList>
            </div>
        </div>

        <div class="d-flex align-items-center gap-3">
            <div class="fl-logo-preview">
                <i class="bi bi-image"></i>
            </div>
            <div>
                <label class="form-label small fw-semibold text-dark mb-1">Startup Logo</label>
                <asp:FileUpload ID="fuLogo" runat="server" CssClass="form-control form-control-sm mb-1" />
                <div class="text-muted" style="font-size: 0.72rem;">Recommended: 256&times;256px square image.</div>
            </div>
        </div>
    </div>

    <!-- 2. Overview -->
    <div class="fl-form-card">
        <div class="fl-section-title">
            <i class="bi bi-file-text text-primary"></i>
            <span>Overview</span>
        </div>

        <div class="mb-3">
            <label class="form-label small fw-semibold text-dark">Short Description (Elevator Pitch)</label>
            <asp:TextBox ID="txtShortDesc" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Briefly describe your startup in 1-2 sentences..." />
        </div>

        <div class="mb-3">
            <label class="form-label small fw-semibold text-dark">Full Description</label>
            <asp:TextBox ID="txtFullDesc" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Elaborate on your vision, target market, and business model..." />
        </div>
    </div>

    <!-- 3. The Problem & Solution -->
    <div class="fl-form-card">
        <div class="row g-4">
            <div class="col-md-6">
                <div class="fl-section-title">
                    <i class="bi bi-pin-angle text-primary"></i>
                    <span>The Problem</span>
                </div>
                <asp:TextBox ID="txtProblem" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="What specific problem are you solving?" />
            </div>
            <div class="col-md-6">
                <div class="fl-section-title">
                    <i class="bi bi-lightbulb text-primary"></i>
                    <span>The Solution</span>
                </div>
                <asp:TextBox ID="txtSolution" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="How does your product solve this problem?" />
            </div>
        </div>
    </div>

    <!-- 4. Team & Hiring -->
    <div class="fl-form-card">
        <div class="fl-section-title">
            <i class="bi bi-people text-primary"></i>
            <span>Team &amp; Hiring</span>
        </div>

        <div class="row g-3 mb-3">
            <div class="col-md-4">
                <label class="form-label small fw-semibold text-dark">Current Team Size</label>
                <asp:TextBox ID="txtTeamSize" runat="server" CssClass="form-control" TextMode="Number" Text="1" />
            </div>
            <div class="col-md-8">
                <label class="form-label small fw-semibold text-dark">Required Skills (Comma separated)</label>
                <asp:TextBox ID="txtSkills" runat="server" CssClass="form-control" placeholder="React, Node.js, B2B Sales" />
            </div>
        </div>

        <div class="mb-3">
            <div class="d-flex justify-content-between align-items-center mb-1">
                <label class="form-label small fw-semibold text-dark mb-0">Open Positions</label>
            </div>
            <div class="input-group">
                <asp:TextBox ID="txtOpenRole" runat="server" CssClass="form-control" placeholder="e.g. Technical Co-Founder (CTO)" />
                <span class="input-group-text bg-white text-muted"><i class="bi bi-trash"></i></span>
            </div>
        </div>
    </div>

    <!-- 5. Additional Details -->
    <div class="fl-form-card">
        <div class="fl-section-title">
            <i class="bi bi-globe text-primary"></i>
            <span>Additional Details</span>
        </div>

        <div class="row g-3">
            <div class="col-md-6">
                <label class="form-label small fw-semibold text-dark">Location</label>
                <div class="input-group">
                    <span class="input-group-text bg-white text-muted"><i class="bi bi-geo-alt"></i></span>
                    <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="City, Country or Remote" />
                </div>
            </div>
            <div class="col-md-6">
                <label class="form-label small fw-semibold text-dark">Website URL</label>
                <div class="input-group">
                    <span class="input-group-text bg-white text-muted"><i class="bi bi-link-45deg"></i></span>
                    <asp:TextBox ID="txtWebsite" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="https://" />
                </div>
            </div>
        </div>
    </div>

    <!-- Footer Action Buttons -->
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 pt-3 mb-5">
        <asp:Button ID="btnDelete" runat="server" Text="Delete Startup" CssClass="btn btn-outline-danger" OnClick="btnDelete_Click" OnClientClick="return confirm('Are you sure you want to delete this startup?');" Visible="false" />
        <div class="ms-auto d-flex gap-2">
            <a href="ExploreStartups.aspx" class="btn btn-fl-outline">Cancel</a>
            <asp:Button ID="btnSaveDraft" runat="server" Text="Save Draft" CssClass="btn btn-fl-outline" OnClick="btnSaveDraft_Click" ValidationGroup="vgStartup" />
            <asp:Button ID="btnPublish" runat="server" Text="Publish Startup" CssClass="btn btn-fl-primary px-4" OnClick="btnPublish_Click" ValidationGroup="vgStartup" />
        </div>
    </div>
</asp:Content>
