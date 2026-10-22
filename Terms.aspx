<%@ Page Title="Terms of Service" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Terms.aspx.cs" Inherits="FoundrLink.Terms" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-legal-hero {
            background-color: #0F172A;
            color: #FFFFFF;
            padding: 60px 0 50px 0;
            border-bottom: 1px solid #1E293B;
        }
        .fl-legal-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 50px 20px 80px 20px;
        }
        .fl-legal-section {
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 32px 36px;
            margin-bottom: 24px;
        }
        .fl-legal-section h3 {
            font-size: 1.25rem;
            font-weight: 700;
            color: #0F172A;
            margin-bottom: 16px;
        }
        .fl-legal-section p, .fl-legal-section li {
            font-size: 0.94rem;
            line-height: 1.7;
            color: #475569;
        }
        .fl-badge-draft {
            background-color: #EFF6FF;
            color: #1D4ED8;
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 12px;
            border-radius: 20px;
            display: inline-block;
            margin-bottom: 12px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header Banner -->
    <div class="fl-legal-hero">
        <div class="container" style="max-width: 900px;">
            <span class="fl-badge-draft">Draft Terms of Service &bull; Standard Operating Guidelines</span>
            <h1 class="fw-bold display-6 mb-2">Terms of Service</h1>
            <p class="text-secondary small mb-0" style="color: #94A3B8 !important;">
                Please read these terms carefully before accessing or using FoundrLink.
            </p>
        </div>
    </div>

    <!-- Body Content -->
    <div class="fl-legal-container">
        <div class="fl-legal-section">
            <h3>1. Acceptance of Terms</h3>
            <p>
                By creating an account, browsing profiles, listing a startup, or using FoundrLink services, you agree to comply with and be bound by these Terms of Service. If you do not agree to these terms, you must not access or use the platform.
            </p>
            <p class="small text-muted mb-0">
                <em>Note: These terms represent operational draft terms and are subject to periodic platform review and updates.</em>
            </p>
        </div>

        <div class="fl-legal-section">
            <h3>2. Account Responsibilities &amp; Eligibility</h3>
            <ul>
                <li>You must provide accurate, current, and verifiable information during registration.</li>
                <li>You are solely responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your session.</li>
                <li>You must immediately notify platform administrators via <a href="Support.aspx" class="text-decoration-none">Support</a> if you suspect any unauthorized use or security compromise of your account.</li>
            </ul>
        </div>

        <div class="fl-legal-section">
            <h3>3. Acceptable Use and Founder Conduct</h3>
            <p>
                FoundrLink is dedicated to facilitating genuine co-founder relationships, technical collaborations, and early-stage startup building. Users agree to:
            </p>
            <ul>
                <li>Communicate professionally and respectfully with other entrepreneurs and investors.</li>
                <li>Accurately represent their professional skills, employment status, equity expectations, and background.</li>
                <li>Accurately describe startup metrics, stage, problem statements, and funding history without fabrication.</li>
            </ul>
        </div>

        <div class="fl-legal-section">
            <h3>4. Prohibited Misuse</h3>
            <p>The following activities are strictly prohibited on FoundrLink:</p>
            <ul>
                <li>Spamming members with unsolicited commercial promotions, multi-level marketing, or unrelated sales pitches.</li>
                <li>Impersonating another person, brand, or registered business entity.</li>
                <li>Harassment, abusive conduct, hate speech, or discriminatory behavior in public listings or private messages.</li>
                <li>Scraping, crawling, or automated data extraction from the platform directory.</li>
                <li>Attempting to bypass server-side authorization controls, manipulate record IDs, or execute injection attacks.</li>
            </ul>
        </div>

        <div class="fl-legal-section">
            <h3>5. User-Generated Content &amp; Intellectual Property</h3>
            <p>
                Founders retain full ownership of the pitch descriptions, logos, trade secrets, and intellectual property they submit. By posting startup profiles, you grant FoundrLink a non-exclusive license to host and display the material to registered users according to your configured privacy settings.
            </p>
            <p class="mb-0">
                FoundrLink does not provide legal guarantees regarding non-disclosure. We recommend executing standard bilateral Non-Disclosure Agreements (NDAs) directly with prospective co-founders prior to disclosing proprietary technical source code or patentable designs.
            </p>
        </div>

        <div class="fl-legal-section">
            <h3>6. Moderation, Reporting, and Account Suspension</h3>
            <p>
                FoundrLink maintains an active moderation system. Users may submit reports on suspect profiles, malicious listings, or spam. Platform administrators reserve the right to review reported content, issue warnings, deactivate listings, or suspend accounts that violate these terms.
            </p>
        </div>

        <div class="fl-legal-section">
            <h3>7. Contact Information</h3>
            <p class="mb-0">
                For questions regarding these Terms of Service or to report violations, please open a support ticket on <a href="Support.aspx" class="fw-semibold text-decoration-none" style="color: #0284C7;">Support.aspx</a> or reach out to our platform moderation desk.
            </p>
        </div>
    </div>
</asp:Content>
