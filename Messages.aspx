<%@ Page Title="Messages" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Messages.aspx.cs" Inherits="FoundrLink.Messages" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-chat-layout {
            height: calc(100vh - 130px);
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: var(--fl-radius-card);
            overflow: hidden;
            display: flex;
        }
        .fl-chat-sidebar-pane {
            width: 340px;
            min-width: 340px;
            border-right: 1px solid var(--fl-border-color);
            display: flex;
            flex-direction: column;
            background: #FFFFFF;
        }
        .fl-chat-content-pane {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: #FAFCFE;
        }
        .fl-conversation-item {
            padding: 16px 20px;
            border-bottom: 1px solid #F1F5F9;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            display: flex;
            gap: 12px;
            transition: all 0.15s ease;
            position: relative;
        }
        .fl-conversation-item:hover {
            background-color: #F8FAFC;
            color: inherit;
        }
        .fl-conversation-item.active {
            background-color: #F8FAFC;
            border-left: 4px solid #10B981;
            color: inherit;
        }
        .fl-chat-messages-container {
            flex: 1;
            overflow-y: auto;
            padding: 24px 40px;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .fl-msg-received {
            align-self: flex-start;
            max-width: 60%;
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 14px;
            padding: 14px 18px;
            font-size: 0.9rem;
            color: #0F172A;
            line-height: 1.5;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
        }
        .fl-msg-sent {
            align-self: flex-end;
            max-width: 60%;
            background: #0F172A;
            color: #FFFFFF;
            border-radius: 14px;
            padding: 14px 18px;
            font-size: 0.9rem;
            line-height: 1.5;
        }
        .fl-chat-input-container {
            padding: 16px 24px;
            background: #FFFFFF;
            border-top: 1px solid var(--fl-border-color);
        }
        .fl-chat-input-box {
            display: flex;
            align-items: center;
            gap: 12px;
            background: #F8FAFC;
            border: 1px solid #E2E8F0;
            border-radius: 10px;
            padding: 6px 12px;
        }
        .fl-chat-input-box input {
            background: transparent;
            border: none;
            outline: none;
            font-size: 0.9rem;
            flex: 1;
        }
        .fl-send-btn {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            background-color: #008477;
            color: #FFFFFF;
            display: flex;
            align-items: center;
            justify-content: center;
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: background-color 0.15s ease;
        }
        .fl-send-btn:hover {
            background-color: #006591;
            color: #FFFFFF;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="fl-chat-layout">
        <!-- Left Conversations List -->
        <div class="fl-chat-sidebar-pane">
            <div class="p-4 border-bottom" style="border-color: #F1F5F9 !important;">
                <h4 class="fw-bold mb-3 text-dark" style="font-size: 1.4rem; letter-spacing: -0.02em;">Messages</h4>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted" style="border-color: #E2E8F0;"><i class="bi bi-search"></i></span>
                    <asp:TextBox ID="txtSearchThreads" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="Search conversations..." AutoPostBack="true" OnTextChanged="txtSearchThreads_TextChanged" style="border-color: #E2E8F0; height: 40px; font-size: 0.85rem;" />
                </div>
            </div>

            <div class="flex-grow-1 overflow-auto">
                <asp:Repeater ID="rptThreads" runat="server">
                    <ItemTemplate>
                        <a href='<%# "Messages.aspx?partnerId=" + Eval("PartnerUserId") %>' class='<%# "fl-conversation-item " + (Convert.ToInt32(Eval("PartnerUserId")) == ActivePartnerId ? "active" : "") %>'>
                            <div class="position-relative">
                                <img src='<%# Eval("AvatarUrl") %>' class="rounded-circle" width="44" height="44" style="object-fit:cover; flex-shrink: 0;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                            </div>
                            <div class="flex-grow-1 overflow-hidden">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <div class="fw-bold text-dark text-truncate small" style="font-size: 0.88rem;"><%# Eval("FullName") %></div>
                                    <div class="d-flex align-items-center gap-1">
                                        <span class="text-muted" style="font-size: 0.72rem;"><%# Eval("TimeText") %></span>
                                        <%# Convert.ToInt32(Eval("UnreadCount")) > 0 ? "<span class='rounded-circle d-inline-block' style='width:7px; height:7px; background:#10B981;'></span>" : "" %>
                                    </div>
                                </div>
                                <div class="text-muted text-truncate" style="font-size: 0.8rem; line-height: 1.3;">
                                    <%# Eval("LastMessage") %>
                                </div>
                            </div>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- Right Active Chat Window -->
        <div class="fl-chat-content-pane">
            <!-- Header Bar -->
            <div class="p-3 bg-white border-bottom d-flex justify-content-between align-items-center px-4" style="border-color: #E2E8F0 !important;">
                <div class="d-flex align-items-center gap-3">
                    <asp:Image ID="imgActivePartner" runat="server" CssClass="rounded-circle" Width="44" height="44" style="object-fit:cover;" ImageUrl="https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100" />
                    <div>
                        <div class="fw-bold text-dark mb-0 lh-1" style="font-size: 0.95rem;">
                            <asp:Literal ID="litActivePartnerName" runat="server" Text="Ananya Iyer" />
                        </div>
                        <div class="text-muted small mt-1" style="font-size: 0.75rem;">
                            <asp:Literal ID="litActivePartnerRole" runat="server" Text="Lead Investor @ Apex Ventures" />
                        </div>
                    </div>
                </div>

                <div class="d-flex align-items-center gap-2">
                    <a id="lnkViewProfile" runat="server" href="#" class="btn btn-sm btn-outline-secondary rounded-circle" style="width: 34px; height: 34px; padding: 0; display:flex; align-items:center; justify-content:center; border-color: #E2E8F0;" title="View Profile">
                        <i class="bi bi-person"></i>
                    </a>
                    <button type="button" class="btn btn-sm btn-outline-secondary rounded-circle" style="width: 34px; height: 34px; padding: 0; display:flex; align-items:center; justify-content:center; border-color: #E2E8F0;">
                        <i class="bi bi-three-dots-vertical"></i>
                    </button>
                </div>
            </div>

            <!-- Messages Stream Area -->
            <div class="fl-chat-messages-container" id="msgScrollArea">
                <div class="text-center my-2">
                    <span class="badge bg-light text-muted border px-3 py-1 rounded-pill fw-semibold" style="font-size: 0.72rem;">Today</span>
                </div>

                <asp:Repeater ID="rptMessages" runat="server">
                    <ItemTemplate>
                        <div class='<%# Convert.ToInt32(Eval("SenderId")) == CurrentUserId ? "fl-msg-sent" : "fl-msg-received" %>'>
                            <div><%# Eval("Content") %></div>
                            <div class='<%# "text-end mt-1 " + (Convert.ToInt32(Eval("SenderId")) == CurrentUserId ? "text-light text-opacity-75" : "text-muted") %>' style="font-size: 0.68rem;">
                                <%# Eval("TimeText") %>
                                <%# Convert.ToInt32(Eval("SenderId")) == CurrentUserId ? "<i class='bi bi-check2-all ms-1' style='color:#10B981;'></i>" : "" %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- Input Bar -->
            <div class="fl-chat-input-container">
                <div class="fl-chat-input-box mb-2">
                    <button type="button" class="btn text-secondary p-0" title="Attach file" style="border:none; background:transparent;">
                        <i class="bi bi-paperclip fs-5" style="color: #64748B;"></i>
                    </button>
                    <asp:TextBox ID="txtMessageInput" runat="server" placeholder="Type a message..." AutoCompleteType="None" />
                    <asp:LinkButton ID="btnSend" runat="server" CssClass="fl-send-btn" OnClick="btnSend_Click">
                        <i class="bi bi-send-fill" style="font-size: 0.85rem;"></i>
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
