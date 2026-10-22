<%@ Page Title="Privacy Policy" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PrivacyPolicy.aspx.cs" Inherits="FoundrLink.PrivacyPolicy" %>

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
            <span class="fl-badge-draft">FoundrLink Platform Documentation</span>
            <h1 class="fw-bold display-6 mb-2">Privacy Policy</h1>
            <p class="text-secondary small mb-0" style="color: #94A3B8 !important;">
                Last updated: October 2024 &bull; Effective for all registered members and visitors.
            </p>
        </div>
    </div>

    <!-- Body Content -->
    <div class="fl-legal-container">
        <div class="fl-legal-section">
            <h3>1. Introduction and Scope</h3>
            <p>
                FoundrLink operates an online co-founder discovery and startup networking platform. This Privacy Policy details our actual data handling practices regarding information collected through our website, user registration, founder profiles, startup listings, messaging, and customer support.
            </p>
            <p>
                We believe in transparency and data minimization. We only collect information necessary to facilitate authentic networking, matching, and platform moderation between startup founders, technical contributors, and angel backers.
            </p>
        </div>

        <div class="fl-legal-section">
            <h3>2. Information We Collect</h3>
            <p>We collect and store information you directly provide to us, including:</p>
            <ul>
                <li><strong>Account Credentials:</strong> Full name, verified email address (<code class="small text-dark">you@ripaldesign.studio</code> in our demonstration sandbox), and salted, cryptographically hashed passwords (PBKDF2). Plaintext passwords are never stored or accessible by system operators.</li>
                <li><strong>Founder &amp; Contributor Profiles:</strong> Professional headline, bio, location/city, industry specialization, skill tags (e.g., React, Python, Distributed Systems), availability (full-time vs. part-time), and what you can offer or seek in a co-founder.</li>
                <li><strong>Startup Listings:</strong> Startup name, pitch tagline, stage (Pre-seed, Seed, MVP), short and full descriptions, team size, open roles, website URLs, and self-reported funding metrics.</li>
                <li><strong>Platform Messaging &amp; Requests:</strong> Direct messages exchanged between connected members and connection/collaboration requests with custom pitch notes.</li>
                <li><strong>Moderation &amp; Support Reports:</strong> Reports submitted regarding suspicious activities, spam, or terms violations, including reporter identity and submitted evidence.</li>
            </ul>
        </div>

        <div class="fl-legal-section">
            <h3>3. How We Use Stored Information</h3>
            <p>Your information is utilized solely for legitimate operational purposes:</p>
            <ul>
                <li>To maintain your secure session and authenticate access to authenticated platform features.</li>
                <li>To index and display founder profiles in the Find Co-Founders directory based on matching filter criteria.</li>
                <li>To enable direct messaging and collaboration workflows between founders.</li>
                <li>To compute personalized dashboard metrics (e.g., active conversation counts, team memberships).</li>
                <li>To investigate reported policy violations, resolve platform disputes, and prevent abusive or malicious behavior.</li>
            </ul>
        </div>

        <div class="fl-legal-section">
            <h3>4. Sharing and Disclosure</h3>
            <p>
                FoundrLink does not sell, rent, or trade your personal data with third-party advertising brokers. Your public profile data (name, headline, bio, and skills) is visible to authenticated users on the platform to facilitate matching. Private messaging content is accessible only to the conversation participants and authorized platform moderators during formal investigations.
            </p>
        </div>

        <div class="fl-legal-section">
            <h3>5. Data Security &amp; Retention</h3>
            <p>
                We employ standard enterprise security practices, including parameterized SQL data operations to prevent injection attacks, salted password hashing, and server-side authorization controls. Data is retained for as long as your account remains active. Users may request account deactivation or update their stored information at any time via Account Settings.
            </p>
        </div>

        <div class="fl-legal-section">
            <h3>6. Contact and Privacy Inquiries</h3>
            <p>
                If you have questions, corrections, or requests concerning your stored personal information, please submit a ticket through our <a href="Support.aspx" class="fw-semibold text-decoration-none" style="color: #0284C7;">Support Center</a> or contact our platform administration team.
            </p>
        </div>
    </div>
</asp:Content>
