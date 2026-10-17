<%@ Page Title="Messages" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Messages.aspx.cs" Inherits="FoundrLink.Messages" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-chat-container {
            height: calc(100vh - 140px);
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: 16px;
            overflow: hidden;
            display: flex;
        }
        .fl-chat-list-pane {
            width: 340px;
            min-width: 340px;
            border-right: 1px solid var(--fl-border-color);
            display: flex;
            flex-direction: column;
            background: #FFFFFF;
        }
        .fl-chat-main-pane {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: #FAFAFA;
        }
        .fl-thread-item {
            padding: 16px;
            border-bottom: 1px solid #F1F5F9;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            display: flex;
            gap: 12px;
            transition: background 0.15s;
            position: relative;
        }
        .fl-thread-item:hover {
            background-color: #F8FAFC;
        }
        .fl-thread-item.active {
            background-color: #F8FAFC;
            border-left: 4px solid var(--fl-accent-teal);
        }
        .fl-chat-msg-area {
            flex: 1;
            overflow-y: auto;
            padding: 24px 32px;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .fl-bubble-in {
            align-self: flex-start;
            max-width: 65%;
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 14px 14px 14px 2px;
            padding: 14px 18px;
            font-size: 0.92rem;
            color: #0F172A;
            line-height: 1.5;
            box-shadow: 0 1px 2px rgba(0,0,0,0.03);
        }
        .fl-bubble-out {
            align-self: flex-end;
            max-width: 65%;
            background: #0F172A;
            color: #FFFFFF;
            border-radius: 14px 14px 2px 14px;
            padding: 14px 18px;
            font-size: 0.92rem;
            line-height: 1.5;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="fl-chat-container">
        <!-- Left Thread List Pane -->
        <div class="fl-chat-list-pane">
            <div class="p-3 border-bottom border-slate-100">
                <h4 class="fw-bold fs-4 mb-3 text-dark">Messages</h4>
                <div class="input-group input-group-sm">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                    <asp:TextBox ID="txtSearchThreads" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="Search conversations..." AutoPostBack="true" OnTextChanged="txtSearchThreads_TextChanged" />
                </div>
            </div>

            <div class="flex-grow-1 overflow-auto">
                <asp:Repeater ID="rptThreads" runat="server">
                    <ItemTemplate>
                        <a href='<%# "Messages.aspx?partnerId=" + Eval("PartnerUserId") %>' class='<%# "fl-thread-item " + (Convert.ToInt32(Eval("PartnerUserId")) == ActivePartnerId ? "active" : "") %>'>
                            <div class="position-relative">
                                <img src='<%# Eval("AvatarUrl") %>' class="rounded-circle" width="44" height="44" style="object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                                <%# Convert.ToInt32(Eval("UnreadCount")) > 0 ? "<span class='position-absolute top-0 start-100 translate-middle p-1 bg-teal border border-light rounded-circle'></span>" : "" %>
                            </div>
                            <div class="flex-grow-1 overflow-hidden">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <div class="fw-bold small text-dark text-truncate"><%# Eval("FullName") %></div>
                                    <span class="text-muted" style="font-size: 0.7rem;"><%# Eval("TimeText") %></span>
                                </div>
                                <div class="text-muted small text-truncate" style="font-size: 0.8rem;">
                                    <%# Eval("LastMessage") %>
                                </div>
                            </div>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- Right Active Chat Pane -->
        <div class="fl-chat-main-pane">
            <!-- Chat Partner Header -->
            <div class="p-3 bg-white border-bottom border-slate-200 d-flex justify-content-between align-items-center px-4">
                <div class="d-flex align-items-center gap-3">
                    <asp:Image ID="imgActivePartner" runat="server" CssClass="rounded-circle" Width="44" Height="44" style="object-fit:cover;" ImageUrl="https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100" />
                    <div>
                        <div class="fw-bold text-dark fs-6 lh-1 mb-1">
                            <asp:Literal ID="litActivePartnerName" runat="server" Text="Ananya Iyer" />
                        </div>
                        <div class="text-muted small" style="font-size: 0.75rem;">
                            <asp:Literal ID="litActivePartnerRole" runat="server" Text="Lead Investor @ Apex Ventures" />
                        </div>
                    </div>
                </div>

                <div class="d-flex align-items-center gap-2">
                    <a id="lnkViewProfile" runat="server" href="#" class="btn btn-sm btn-outline-secondary rounded-circle" style="width: 34px; height: 34px; padding: 0; display:flex; align-items:center; justify-content:center;" title="View Profile">
                        <i class="bi bi-person"></i>
                    </a>
                    <button type="button" class="btn btn-sm btn-outline-secondary rounded-circle" style="width: 34px; height: 34px; padding: 0; display:flex; align-items:center; justify-content:center;">
                        <i class="bi bi-three-dots-vertical"></i>
                    </button>
                </div>
            </div>

            <!-- Messages Stream Area -->
            <div class="fl-chat-msg-area" id="msgScrollArea">
                <div class="text-center my-2">
                    <span class="badge bg-light text-muted border px-3 py-1 rounded-pill small">Today</span>
                </div>

                <asp:Repeater ID="rptMessages" runat="server">
                    <ItemTemplate>
                        <div class='<%# Convert.ToInt32(Eval("SenderId")) == CurrentUserId ? "fl-bubble-out" : "fl-bubble-in" %>'>
                            <div><%# Eval("Content") %></div>
                            <div class='<%# "text-end mt-1 " + (Convert.ToInt32(Eval("SenderId")) == CurrentUserId ? "text-secondary" : "text-muted") %>' style="font-size: 0.68rem;">
                                <%# Eval("TimeText") %>
                                <%# Convert.ToInt32(Eval("SenderId")) == CurrentUserId ? "<i class='bi bi-check2-all text-teal ms-1'></i>" : "" %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- Input Bar -->
            <div class="p-3 bg-white border-top border-slate-200">
                <div class="d-flex align-items-center gap-2 mb-1">
                    <button type="button" class="btn text-secondary p-1" title="Attach file">
                        <i class="bi bi-paperclip fs-5"></i>
                    </button>
                    <asp:TextBox ID="txtMessageInput" runat="server" CssClass="form-control" placeholder="Type a message..." AutoCompleteType="None" />
                    <asp:LinkButton ID="btnSend" runat="server" CssClass="btn btn-fl-teal px-3" OnClick="btnSend_Click">
                        <i class="bi bi-send-fill"></i>
                    </asp:LinkButton>
                </div>
                <div class="text-center text-muted" style="font-size: 0.7rem;">
                    Press Enter to send, Shift+Enter for new line
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var scrollArea = document.getElementById('msgScrollArea');
            if (scrollArea) {
                scrollArea.scrollTop = scrollArea.scrollHeight;
            }
        });
    </script>
</asp:Content>
