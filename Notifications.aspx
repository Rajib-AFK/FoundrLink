<%@ Page Title="Notifications" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="FoundrLink.Notifications" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-notif-item {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: 12px;
            padding: 18px 24px;
            margin-bottom: 12px;
            display: flex;
            align-items: flex-start;
            gap: 16px;
            transition: all 0.2s ease;
        }
        .fl-notif-item:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.04);
            border-color: #CBD5E1;
        }
        .fl-notif-item.unread {
            background: #F8FAFC;
            border-left: 4px solid var(--fl-accent-teal);
        }
        .fl-notif-icon {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            flex-shrink: 0;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row mb-4 align-items-center">
        <div class="col-md-8">
            <h2 class="fw-bold fs-3 text-dark mb-1">Notifications</h2>
            <p class="text-muted mb-0">Stay updated on your startup matches, team requests, and platform activity.</p>
        </div>
        <div class="col-md-4 text-md-end mt-3 mt-md-0">
            <asp:LinkButton ID="btnMarkAllRead" runat="server" CssClass="btn btn-outline-secondary btn-sm" OnClick="btnMarkAllRead_Click">
                <i class="bi bi-check2-all me-1"></i> Mark all as read
            </asp:LinkButton>
        </div>
    </div>

    <!-- Filter Pills -->
    <div class="d-flex flex-wrap gap-2 mb-4">
        <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="btn btn-sm btn-dark rounded-pill px-3" CommandArgument="All" OnClick="Filter_Click">All</asp:LinkButton>
        <asp:LinkButton ID="btnFilterUnread" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3" CommandArgument="Unread" OnClick="Filter_Click">Unread</asp:LinkButton>
        <asp:LinkButton ID="btnFilterRequests" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3" CommandArgument="Requests" OnClick="Filter_Click">Requests</asp:LinkButton>
        <asp:LinkButton ID="btnFilterMatches" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3" CommandArgument="Matches" OnClick="Filter_Click">Matches</asp:LinkButton>
        <asp:LinkButton ID="btnFilterActivity" runat="server" CssClass="btn btn-sm btn-outline-secondary rounded-pill px-3" CommandArgument="Activity" OnClick="Filter_Click">Activity</asp:LinkButton>
    </div>

    <asp:Panel ID="pnlSuccessAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show mb-4" role="alert">
        <asp:Literal ID="litSuccessMsg" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- Notification Feed -->
    <div class="fl-notif-container">
        <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
            <ItemTemplate>
                <div class='<%# "fl-notif-item " + (Convert.ToBoolean(Eval("IsRead")) ? "" : "unread") %>'>
                    <div class='<%# "fl-notif-icon " + GetIconClass(Eval("NotificationType").ToString()) %>'>
                        <i class='<%# GetIcon(Eval("NotificationType").ToString()) %>'></i>
                    </div>

                    <div class="flex-grow-1">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <h6 class="fw-bold text-dark mb-0"><%# Eval("Title") %></h6>
                            <span class="text-muted small" style="font-size: 0.75rem;"><%# FormatTime(Eval("CreatedAt")) %></span>
                        </div>
                        <p class="text-secondary small mb-2"><%# Eval("Message") %></p>

                        <%# Convert.ToBoolean(Eval("ActionRequired")) ? @"
                            <div class='d-flex gap-2 mt-2'>
                                <asp:LinkButton runat='server' CommandName='Accept' CommandArgument='" + Eval("NotificationId") + @"' CssClass='btn btn-fl-teal btn-sm px-3'>Accept</asp:LinkButton>
                                <asp:LinkButton runat='server' CommandName='Decline' CommandArgument='" + Eval("NotificationId") + @"' CssClass='btn btn-outline-secondary btn-sm px-3'>Decline</asp:LinkButton>
                            </div>
                        " : "" %>
                    </div>

                    <div>
                        <asp:LinkButton ID="btnDismiss" runat="server" CommandName="Dismiss" CommandArgument='<%# Eval("NotificationId") %>' CssClass="btn btn-link text-muted p-0" title="Delete notification">
                            <i class="bi bi-x-lg"></i>
                        </asp:LinkButton>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="text-center py-5 bg-white rounded-3 border">
            <i class="bi bi-bell-slash text-muted" style="font-size: 3rem;"></i>
            <h5 class="fw-bold text-dark mt-3">No Notifications</h5>
            <p class="text-muted small">You're all caught up! Check back later for new updates.</p>
        </asp:Panel>
    </div>
</asp:Content>
