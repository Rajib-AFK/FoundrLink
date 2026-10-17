<%@ Page Title="Support & Help" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Support.aspx.cs" Inherits="FoundrLink.Support" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-faq-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 16px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row mb-4">
        <div class="col-12">
            <h2 class="fw-bold fs-3 text-dark mb-1">Help & Support</h2>
            <p class="text-muted">Find answers to common questions or reach out directly to the FoundrLink founder operations team.</p>
        </div>
    </div>

    <asp:Panel ID="pnlAlertSuccess" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>
        <asp:Literal ID="litAlertSuccess" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <div class="row g-4">
        <div class="col-lg-7">
            <div class="card border-0 shadow-sm rounded-4 p-4 p-md-5">
                <h4 class="fw-bold text-dark mb-1">Submit a Support Ticket</h4>
                <p class="text-muted small mb-4">Our dedicated concierge responds to founders and investors within 4 business hours.</p>

                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">Subject Category <span class="text-danger">*</span></label>
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Startup Verification" Value="Verification" />
                            <asp:ListItem Text="Co-Founder Matching Issue" Value="Matching" />
                            <asp:ListItem Text="Technical Bug or Error" Value="Technical" />
                            <asp:ListItem Text="Report Suspicious Activity" Value="Moderation" />
                            <asp:ListItem Text="Billing or Premium Features" Value="Billing" />
                        </asp:DropDownList>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">Priority Level</label>
                        <asp:DropDownList ID="ddlPriority" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Normal" Value="Normal" />
                            <asp:ListItem Text="High" Value="High" />
                            <asp:ListItem Text="Urgent (Platform Outage)" Value="Urgent" />
                        </asp:DropDownList>
                    </div>

                    <div class="col-12">
                        <label class="form-label fw-semibold small">Subject Summary <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" placeholder="Brief description of the issue" />
                        <asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="txtSubject" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Subject is required." />
                    </div>

                    <div class="col-12">
                        <label class="form-label fw-semibold small">Detailed Description <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtDetails" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="5" placeholder="Please describe what happened, steps to reproduce, or any startup link..." />
                        <asp:RequiredFieldValidator ID="rfvDetails" runat="server" ControlToValidate="txtDetails" Display="Dynamic" CssClass="text-danger small" ErrorMessage="Description is required." />
                    </div>

                    <div class="col-12 pt-2">
                        <asp:Button ID="btnSubmitTicket" runat="server" Text="Submit Ticket" CssClass="btn btn-fl-teal px-4 py-2" OnClick="btnSubmitTicket_Click" />
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-5">
            <h5 class="fw-bold text-dark mb-3">Frequently Asked Questions</h5>

            <div class="fl-faq-card">
                <h6 class="fw-bold text-dark mb-2"><i class="bi bi-question-circle text-teal me-2"></i>How does startup verification work?</h6>
                <p class="text-muted small mb-0">Our curation team reviews incorporation records, founder LinkedIn profiles, and active traction metrics before granting the Verified badge within 48 hours.</p>
            </div>

            <div class="fl-faq-card">
                <h6 class="fw-bold text-dark mb-2"><i class="bi bi-shield-lock text-teal me-2"></i>Are my pitch decks confidential?</h6>
                <p class="text-muted small mb-0">Yes. Materials uploaded to your private startup vault are only shared with accredited investors who request access and whom you explicitly approve.</p>
            </div>

            <div class="fl-faq-card">
                <h6 class="fw-bold text-dark mb-2"><i class="bi bi-people text-teal me-2"></i>How do co-founder equity splits work?</h6>
                <p class="text-muted small mb-0">FoundrLink provides standard 4-year vesting with 1-year cliff agreement templates directly in your Team Details resources tab.</p>
            </div>
        </div>
    </div>
</asp:Content>
