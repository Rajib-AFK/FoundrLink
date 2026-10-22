<%@ Page Title="Collaboration Requests" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="CollaborationRequests.aspx.cs" Inherits="FoundrLink.CollaborationRequests" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-req-card {
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 16px;
            transition: all 0.2s ease;
        }
        .fl-req-card:hover {
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.04);
            border-color: #CBD5E1;
        }
        .fl-status-badge {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 12px;
            border-radius: 20px;
            display: inline-block;
        }
        .fl-status-pending { background-color: #FEF3C7; color: #B45309; }
        .fl-status-accepted { background-color: #DCFCE7; color: #15803D; }
        .fl-status-declined { background-color: #FEE2E2; color: #B91C1C; }
        .fl-status-withdrawn { background-color: #F1F5F9; color: #64748B; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
        <div>
            <h2 class="fw-bold text-dark mb-1" style="font-size: 1.85rem; letter-spacing: -0.02em;">Collaboration Requests</h2>
            <p class="text-muted small mb-0">Manage incoming team collaboration requests and track applications you've sent.</p>
        </div>
        <div class="d-flex gap-2">
            <a href="ExploreStartups.aspx" class="btn btn-sm btn-outline-dark px-3 py-2 fw-semibold" style="font-size: 0.82rem;">Explore Startups</a>
            <a href="FindCoFounders.aspx" class="btn btn-sm btn-dark px-3 py-2 fw-semibold" style="font-size: 0.82rem;">Find Co-Founders</a>
        </div>
    </div>

    <!-- Alert Panel -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show mb-4" role="alert">
        <asp:Literal ID="litAlertMessage" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- Navigation Tabs: Received vs Sent -->
    <div class="d-flex border-bottom mb-4" style="border-color: #E2E8F0 !important;">
        <asp:LinkButton ID="btnTabReceived" runat="server" CssClass="pb-3 px-4 fw-bold text-decoration-none border-bottom border-2 border-dark text-dark" OnClick="Tab_Click" CommandArgument="Received" style="font-size: 0.95rem;">
            Received Requests
            <span class="badge bg-light text-dark border ms-1 rounded-pill"><asp:Literal ID="litReceivedCount" runat="server" Text="0" /></span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnTabSent" runat="server" CssClass="pb-3 px-4 fw-medium text-decoration-none text-muted" OnClick="Tab_Click" CommandArgument="Sent" style="font-size: 0.95rem;">
            Sent Requests
            <span class="badge bg-light text-dark border ms-1 rounded-pill"><asp:Literal ID="litSentCount" runat="server" Text="0" /></span>
        </asp:LinkButton>
    </div>

    <!-- Filter Pills -->
    <div class="d-flex flex-wrap gap-2 mb-4">
        <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="btn btn-sm btn-dark rounded-pill px-3 py-1 fw-medium" CommandArgument="All" OnClick="Filter_Click" style="font-size: 0.8rem;">All</asp:LinkButton>
        <asp:LinkButton ID="btnFilterPending" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3 py-1 fw-medium" CommandArgument="Pending" OnClick="Filter_Click" style="font-size: 0.8rem;">Pending</asp:LinkButton>
        <asp:LinkButton ID="btnFilterAccepted" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3 py-1 fw-medium" CommandArgument="Accepted" OnClick="Filter_Click" style="font-size: 0.8rem;">Accepted</asp:LinkButton>
        <asp:LinkButton ID="btnFilterDeclined" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3 py-1 fw-medium" CommandArgument="Declined" OnClick="Filter_Click" style="font-size: 0.8rem;">Declined</asp:LinkButton>
        <asp:LinkButton ID="btnFilterWithdrawn" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3 py-1 fw-medium" CommandArgument="Withdrawn" OnClick="Filter_Click" style="font-size: 0.8rem;">Withdrawn</asp:LinkButton>
    </div>

    <!-- Empty State -->
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="fl-card text-center py-5">
        <div style="font-size: 2.5rem; color: #94A3B8;"><i class="bi bi-inbox"></i></div>
        <h5 class="fw-bold text-dark mt-3 mb-1">No requests found</h5>
        <p class="text-muted small mb-0">There are no collaboration requests matching this filter.</p>
    </asp:Panel>

    <!-- Requests Repeater -->
    <asp:Repeater ID="rptRequests" runat="server" OnItemCommand="rptRequests_ItemCommand">
        <ItemTemplate>
            <div class="fl-req-card">
                <div class="d-flex flex-wrap justify-content-between align-items-start gap-3">
                    <div class="d-flex align-items-start gap-3">
                        <img src='<%# Eval("PartnerAvatar") %>' class="rounded-circle" width="48" height="48" style="object-fit:cover; background:#E2E8F0;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                        <div>
                            <div class="d-flex align-items-center gap-2 mb-1">
                                <a href='<%# "Profile.aspx?id=" + Eval("PartnerUserId") %>' class="fw-bold text-dark text-decoration-none fs-6">
                                    <%# Eval("PartnerName") %>
                                </a>
                                <span class='<%# "fl-status-badge fl-status-" + Eval("Status").ToString().ToLowerInvariant() %>'>
                                    <%# Eval("Status") %>
                                </span>
                            </div>
                            <div class="text-muted small mb-2" style="font-size: 0.8rem;">
                                <%# Eval("PartnerTitle") %> &bull; Startup: <strong><a href='<%# "StartupDetails.aspx?id=" + Eval("StartupId") %>' class="text-dark text-decoration-none"><%# Eval("StartupName") %></a></strong>
                            </div>
                            <div class="p-3 bg-light rounded-3 text-secondary small" style="max-width: 650px; line-height: 1.55; border: 1px solid #F1F5F9;">
                                <%# Eval("Message") %>
                            </div>
                            <div class="text-muted mt-2" style="font-size: 0.72rem;">
                                Requested on <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy h:mm tt") %>
                            </div>
                        </div>
                    </div>

                    <!-- Action Controls -->
                    <div class="d-flex gap-2 align-items-center">
                        <%# (ActiveTab == "Received" && Eval("Status").ToString() == "Pending") ? @"
                            <asp:LinkButton runat='server' CommandName='Accept' CommandArgument='" + Eval("RequestId") + @"' CssClass='btn btn-sm btn-dark px-3 fw-semibold' style='font-size:0.8rem;'>Accept</asp:LinkButton>
                            <asp:LinkButton runat='server' CommandName='Decline' CommandArgument='" + Eval("RequestId") + @"' CssClass='btn btn-sm btn-outline-secondary px-3 fw-semibold' style='font-size:0.8rem;'>Decline</asp:LinkButton>
                        " : "" %>

                        <%# (ActiveTab == "Sent" && Eval("Status").ToString() == "Pending") ? @"
                            <asp:LinkButton runat='server' CommandName='Withdraw' CommandArgument='" + Eval("RequestId") + @"' CssClass='btn btn-sm btn-outline-danger px-3 fw-semibold' style='font-size:0.8rem;'>Withdraw</asp:LinkButton>
                        " : "" %>

                        <a href='<%# "Messages.aspx?partnerId=" + Eval("PartnerUserId") %>' class="btn btn-sm btn-outline-secondary px-3" style="font-size: 0.8rem;" title="Send Message">
                            <i class="bi bi-chat-dots"></i>
                        </a>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Content>
