<%@ Page Title="Notifications" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="FoundrLink.Notifications" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-notif-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: var(--fl-radius-card);
            padding: 20px 24px;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: all 0.15s ease;
        }
        .fl-notif-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            border-color: #CBD5E1;
        }
        .fl-notif-card.unread {
            background: #FFFFFF;
            border-left: 4px solid #006591;
        }
        .fl-notif-icon-circle {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.15rem;
            flex-shrink: 0;
        }
        .fl-notif-icon-blue {
            background-color: #E0F2FE;
            color: #0284C7;
        }
        .fl-notif-icon-gray {
            background-color: #F1F5F9;
            color: #475569;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold fs-3 text-dark mb-0" style="font-size: 2rem; letter-spacing: -0.02em;">Notifications</h2>
        </div>
        <div class="d-flex align-items-center gap-2">
            <a href="CollaborationRequests.aspx" class="btn btn-sm btn-outline-dark fw-semibold" style="font-size: 0.82rem; padding: 7px 16px;">
                <i class="bi bi-people me-1"></i> Collaboration Requests
            </a>
            <asp:LinkButton ID="btnMarkAllRead" runat="server" CssClass="btn-fl-outline" OnClick="btnMarkAllRead_Click" style="font-size: 0.82rem; padding: 7px 16px;">
                Mark all as read
            </asp:LinkButton>
        </div>
    </div>

    <!-- Filter Pills -->
    <div class="d-flex flex-wrap gap-2 mb-4">
        <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="btn btn-sm btn-dark rounded-pill px-3 py-1 fw-medium" CommandArgument="All" OnClick="Filter_Click" style="font-size: 0.8rem;">All</asp:LinkButton>
        <asp:LinkButton ID="btnFilterUnread" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3 py-1 fw-medium" CommandArgument="Unread" OnClick="Filter_Click" style="font-size: 0.8rem; border-color: #E2E8F0; color: #475569;">Unread</asp:LinkButton>
        <asp:LinkButton ID="btnFilterRequests" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3 py-1 fw-medium" CommandArgument="Requests" OnClick="Filter_Click" style="font-size: 0.8rem; border-color: #E2E8F0; color: #475569;">Requests</asp:LinkButton>
        <asp:LinkButton ID="btnFilterMatches" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3 py-1 fw-medium" CommandArgument="Matches" OnClick="Filter_Click" style="font-size: 0.8rem; border-color: #E2E8F0; color: #475569;">Matches</asp:LinkButton>
        <asp:LinkButton ID="btnFilterActivity" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3 py-1 fw-medium" CommandArgument="Activity" OnClick="Filter_Click" style="font-size: 0.8rem; border-color: #E2E8F0; color: #475569;">Activity</asp:LinkButton>
    </div>

    <asp:Panel ID="pnlSuccessAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show mb-4" role="alert">
        <asp:Literal ID="litSuccessMsg" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- Notification Feed -->
    <div class="fl-notif-container">
        <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
            <ItemTemplate>
                <div class='<%# "fl-notif-card " + (Convert.ToBoolean(Eval("IsRead")) ? "" : "unread") %>'>
                    <div class="d-flex align-items-center gap-3 flex-grow-1">
                        <div class='<%# "fl-notif-icon-circle " + (Convert.ToBoolean(Eval("ActionRequired")) ? "fl-notif-icon-blue" : "fl-notif-icon-gray") %>'>
                            <i class='<%# GetIcon(Eval("NotificationType").ToString()) %>'></i>
                        </div>

                        <div>
                            <div class="fw-bold text-dark mb-1" style="font-size: 0.95rem;"><%# Eval("Title") %></div>
                            <%# Convert.ToBoolean(Eval("ActionRequired")) ? @"
                                <div class='d-flex gap-2 mt-2'>
                                    <asp:LinkButton runat='server' CommandName='Accept' CommandArgument='" + Eval("NotificationId") + @"' CssClass='btn btn-sm text-white px-3 fw-semibold' style='background:#006591; border-radius:6px; font-size:0.8rem;'>Accept</asp:LinkButton>
                                    <asp:LinkButton runat='server' CommandName='Decline' CommandArgument='" + Eval("NotificationId") + @"' CssClass='btn btn-sm btn-outline-secondary px-3 fw-semibold' style='border-radius:6px; font-size:0.8rem; border-color:#CBD5E1; color:#0F172A;'>Decline</asp:LinkButton>
                                </div>
                            " : "" %>
                        </div>
                    </div>

                    <div class="d-flex align-items-center gap-3">
                        <span class="text-muted small" style="font-size: 0.8rem;"><%# FormatTime(Eval("CreatedAt")) %></span>
                        <asp:LinkButton ID="btnDismiss" runat="server" CommandName="Dismiss" CommandArgument='<%# Eval("NotificationId") %>' CssClass="btn btn-link text-muted p-0" title="Delete notification" style="color: #CBD5E1 !important;">
                            <i class="bi bi-x-lg" style="font-size: 0.75rem;"></i>
                        </asp:LinkButton>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="text-center py-5 bg-white rounded-3 border">
            <i class="bi bi-bell-slash text-muted" style="font-size: 2.5rem;"></i>
            <h5 class="fw-bold text-dark mt-3">No Notifications</h5>
            <p class="text-muted small">You're all caught up! Check back later for new updates.</p>
        </asp:Panel>
    </div>
</asp:Content>
