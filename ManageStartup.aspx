<%@ Page Title="Manage Startup" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="ManageStartup.aspx.cs" Inherits="FoundrLink.ManageStartup" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-form-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: var(--fl-radius-card);
            padding: 28px;
            margin-bottom: 24px;
        }
        .fl-section-title {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.1rem;
            font-weight: 700;
            color: #0F172A;
            margin-bottom: 20px;
        }
        .fl-section-title i {
            color: #0284C7;
            font-size: 1.15rem;
        }
        .fl-logo-preview-box {
            width: 56px;
            height: 56px;
            border: 1px solid #E2E8F0;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #64748B;
            font-size: 1.5rem;
            background: #F8FAFC;
            flex-shrink: 0;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mb-3">
        <a href="ExploreStartups.aspx" class="text-secondary small text-decoration-none fw-semibold d-inline-flex align-items-center gap-1">
            <i class="bi bi-arrow-left"></i> Back to Startups
        </a>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1 text-dark" style="font-size: 1.85rem; letter-spacing: -0.02em;">Create Your Startup</h2>
            <p class="text-muted small mb-0">Detail your vision to connect with co-founders and investors.</p>
        </div>
        <span class="badge bg-light text-muted border px-3 py-1 fw-semibold" style="font-size: 0.75rem; border-radius: 6px;">
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
            <i class="bi bi-info-circle"></i>
            <span>Basic Information</span>
        </div>

        <div class="mb-3">
            <label class="form-label small fw-semibold text-dark mb-1">Startup Name <span class="text-danger">*</span></label>
            <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="e.g. Rita Sharma" style="height: 44px;" />
            <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ErrorMessage="Startup Name is required" CssClass="text-danger small mt-1 d-block" Display="Dynamic" ValidationGroup="vgStartup" />
        </div>

        <div class="mb-3">
            <label class="form-label small fw-semibold text-dark mb-1">Tagline</label>
            <asp:TextBox ID="txtTagline" runat="server" CssClass="form-control" placeholder="One sentence describing what you do" style="height: 44px;" />
        </div>

        <div class="row g-3 mb-3">
            <div class="col-md-6">
                <label class="form-label small fw-semibold text-dark mb-1">Industry</label>
                <asp:DropDownList ID="ddlIndustry" runat="server" CssClass="form-select" style="height: 44px;">
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
                <label class="form-label small fw-semibold text-dark mb-1">Current Stage</label>
                <asp:DropDownList ID="ddlStage" runat="server" CssClass="form-select" style="height: 44px;">
                    <asp:ListItem Value="" Text="Select stage..." />
                    <asp:ListItem Value="Pre-Seed" Text="Pre-Seed" />
                    <asp:ListItem Value="Seed Stage" Text="Seed Stage" />
                    <asp:ListItem Value="Series A" Text="Series A" />
                    <asp:ListItem Value="MVP" Text="MVP" />
                </asp:DropDownList>
            </div>
        </div>

        <div class="d-flex align-items-center gap-3 pt-2">
            <div class="fl-logo-preview-box">
                <i class="bi bi-image"></i>
            </div>
            <div class="flex-grow-1">
                <label class="form-label small fw-semibold text-dark mb-1">Startup Logo</label>
                <asp:FileUpload ID="fuLogo" runat="server" CssClass="form-control form-control-sm mb-1" style="max-width: 380px;" />
                <div class="text-muted" style="font-size: 0.72rem;">Recommended: 256&times;256px square image.</div>
            </div>
        </div>
    </div>

    <!-- 2. Overview -->
    <div class="fl-form-card">
        <div class="fl-section-title">
            <i class="bi bi-file-earmark-text"></i>
            <span>Overview</span>
        </div>

        <div class="mb-3">
            <label class="form-label small fw-semibold text-dark mb-1">Short Description (Elevator Pitch)</label>
            <asp:TextBox ID="txtShortDesc" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Briefly describe your startup in 1-2 sentences..." />
        </div>

        <div class="mb-2">
            <label class="form-label small fw-semibold text-dark mb-1">Full Description</label>
            <asp:TextBox ID="txtFullDesc" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Elaborate on your vision, target market, and business model..." />
        </div>
    </div>

    <!-- 3. The Problem & Solution -->
    <div class="fl-form-card">
        <div class="row g-4">
            <div class="col-md-6">
                <div class="fl-section-title">
                    <i class="bi bi-pin-angle"></i>
                    <span>The Problem</span>
                </div>
                <asp:TextBox ID="txtProblem" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="What specific problem are you solving?" />
            </div>
            <div class="col-md-6">
                <div class="fl-section-title">
                    <i class="bi bi-lightbulb"></i>
                    <span>The Solution</span>
                </div>
                <asp:TextBox ID="txtSolution" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="How does your product solve this problem?" />
            </div>
        </div>
    </div>

    <!-- 4. Team & Hiring -->
    <div class="fl-form-card">
        <div class="fl-section-title">
            <i class="bi bi-people"></i>
            <span>Team &amp; Hiring</span>
        </div>

        <div class="row g-3 mb-3">
            <div class="col-md-4">
                <label class="form-label small fw-semibold text-dark mb-1">Current Team Size</label>
                <asp:TextBox ID="txtTeamSize" runat="server" CssClass="form-control" TextMode="Number" Text="1" style="height: 44px;" />
            </div>
            <div class="col-md-8">
                <label class="form-label small fw-semibold text-dark mb-1">Required Skills (Comma separated)</label>
                <asp:TextBox ID="txtSkills" runat="server" CssClass="form-control" placeholder="React, Node.js, B2B Sales" style="height: 44px;" />
            </div>
        </div>

        <div class="p-3 border rounded-3" style="background-color: #FAFAFA; border-color: #E2E8F0 !important;">
            <div class="d-flex justify-content-between align-items-center mb-2">
                <label class="form-label small fw-semibold text-dark mb-0">Open Positions</label>
                <span class="small text-muted" style="font-size: 0.75rem;">Add roles (separated by commas or newlines)</span>
            </div>
            <asp:TextBox ID="txtOpenRole" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="e.g. Technical Co-Founder (CTO), Lead Full-Stack Engineer" />
        </div>
    </div>

    <!-- 5. Additional Details -->
    <div class="fl-form-card">
        <div class="fl-section-title">
            <i class="bi bi-globe"></i>
            <span>Additional Details</span>
        </div>

        <div class="row g-3">
            <div class="col-md-6">
                <label class="form-label small fw-semibold text-dark mb-1">Location</label>
                <div class="input-group">
                    <span class="input-group-text bg-white text-muted" style="border-color: #E2E8F0;"><i class="bi bi-geo-alt"></i></span>
                    <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="City, Country or Remote" style="height: 44px;" />
                </div>
            </div>
            <div class="col-md-6">
                <label class="form-label small fw-semibold text-dark mb-1">Website URL</label>
                <div class="input-group">
                    <span class="input-group-text bg-white text-muted" style="border-color: #E2E8F0;"><i class="bi bi-link-45deg"></i></span>
                    <asp:TextBox ID="txtWebsite" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="https://" style="height: 44px;" />
                </div>
            </div>
        </div>
    </div>

    <!-- Footer Action Buttons -->
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 pt-3 mb-5">
        <asp:Button ID="btnDelete" runat="server" Text="Delete Startup" CssClass="btn btn-outline-danger" OnClick="btnDelete_Click" OnClientClick="return confirm('Are you sure you want to delete this startup?');" Visible="false" />
        <div class="ms-auto d-flex gap-2">
            <a href="ExploreStartups.aspx" class="btn-fl-outline">Cancel</a>
            <asp:Button ID="btnSaveDraft" runat="server" Text="Save Draft" CssClass="btn-fl-outline" OnClick="btnSaveDraft_Click" ValidationGroup="vgStartup" />
            <asp:Button ID="btnPublish" runat="server" Text="Publish Startup" CssClass="btn-fl-primary px-4" OnClick="btnPublish_Click" ValidationGroup="vgStartup" />
        </div>
    </div>
</asp:Content>
