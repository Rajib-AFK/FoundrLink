<%@ Page Title="Founder Dashboard" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FoundrLink.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-welcome-hero {
            background-color: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: var(--fl-radius-card);
            padding: 32px;
            margin-bottom: 24px;
            position: relative;
            background-image: radial-gradient(circle at 90% 10%, rgba(109, 245, 225, 0.15), transparent 40%);
        }
        .fl-avatar-edit-wrapper {
            position: relative;
            display: inline-block;
        }
        .fl-avatar-lg {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #FFFFFF;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            background: #E0E7FF;
        }
        .fl-avatar-edit-badge {
            position: absolute;
            bottom: 0;
            right: 0;
            width: 26px;
            height: 26px;
            border-radius: 50%;
            background: #FFFFFF;
            border: 1px solid #CBD5E1;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.72rem;
            color: #334155;
            cursor: pointer;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
            text-decoration: none;
        }
        .fl-avatar-edit-badge:hover {
            background-color: #F8FAFC;
            color: #0F172A;
        }
        .fl-profile-completion-box {
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 10px;
            padding: 16px 20px;
            min-width: 280px;
        }
        .fl-date-badge-red {
            width: 48px;
            height: 48px;
            border-radius: 8px;
            background: #FEE2E2;
            color: #DC2626;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            line-height: 1.05;
            flex-shrink: 0;
        }
        .fl-date-badge-gray {
            width: 48px;
            height: 48px;
            border-radius: 8px;
            background: #F1F5F9;
            color: #475569;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            line-height: 1.05;
            flex-shrink: 0;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Welcome Hero Card -->
    <div class="fl-welcome-hero d-flex flex-wrap align-items-center justify-content-between gap-4">
        <div class="d-flex align-items-center gap-4">
            <div class="fl-avatar-edit-wrapper">
                <asp:Image ID="imgHeroAvatar" runat="server" CssClass="fl-avatar-lg" ImageUrl="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150" />
                <a href="Profile.aspx" class="fl-avatar-edit-badge" title="Edit Profile">
                    <i class="bi bi-pencil-fill"></i>
                </a>
            </div>
            <div>
                <h2 class="fw-bold mb-1 text-dark" style="font-size: 1.75rem; letter-spacing: -0.02em;">
                    Welcome back, <asp:Literal ID="litUserName" runat="server" Text="Rachit" />
                </h2>
                <p class="text-muted mb-0 small" style="font-size: 0.92rem;">
                    <asp:Literal ID="litUserHeadline" runat="server" Text="Technical Co-founder searching for seed funding." />
                </p>
            </div>
        </div>

        <!-- Profile Completion Widget -->
        <div class="fl-profile-completion-box">
            <div class="d-flex justify-content-between align-items-center mb-2">
                <span class="small fw-semibold text-dark">Profile Completion</span>
                <span class="small fw-bold" style="color: #10B981;"><asp:Literal ID="litCompletionPct" runat="server" Text="85%" /></span>
            </div>
            <div class="progress mb-2" style="height: 6px; background-color: #E2E8F0; border-radius: 4px;">
                <div class="progress-bar" style='<%= "width: " + CompletionPercentage + "%; background-color: #10B981; border-radius: 4px;" %>'></div>
            </div>
            <div class="text-muted" style="font-size: 0.72rem;">
                Add your pitch deck to reach 100%
            </div>
        </div>
    </div>

    <!-- Stat Cards Row -->
    <div class="row g-4 mb-4">
        <div class="col-md-4">
            <div class="fl-stat-card">
                <div>
                    <div class="fl-stat-title">Profile Views</div>
                    <div class="fl-stat-value">
                        <asp:Literal ID="litProfileViews" runat="server" Text="894" />
                    </div>
                </div>
                <div class="fl-stat-icon-wrapper" style="background-color: #6DF5E1; color: #0F172A;">
                    <i class="bi bi-eye"></i>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="fl-stat-card">
                <div>
                    <div class="fl-stat-title">Active Messages</div>
                    <div class="fl-stat-value">
                        <asp:Literal ID="litActiveMessages" runat="server" Text="12" />
                    </div>
                </div>
                <div class="fl-stat-icon-wrapper" style="background-color: #0F172A; color: #FFFFFF;">
                    <i class="bi bi-chat-dots-fill"></i>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="fl-stat-card">
                <div>
                    <div class="fl-stat-title">Teams Joined</div>
                    <div class="fl-stat-value">
                        <asp:Literal ID="litTeamsJoined" runat="server" Text="2" />
                    </div>
                </div>
                <div class="fl-stat-icon-wrapper" style="background-color: #F1F5F9; color: #475569;">
                    <i class="bi bi-people-fill"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Grid Section -->
    <div class="row g-4">
        <!-- Left Column: Chart & Recent Activity -->
        <div class="col-lg-8">
            <!-- Connection Growth Chart Card -->
            <div class="fl-card mb-4">
                <div class="fl-card-header">
                    <h5 class="fw-bold mb-0 text-dark">Connection Growth</h5>
                    <span class="badge bg-light text-muted border px-3 py-1 fw-semibold" style="font-size: 0.75rem;">Last 30 Days</span>
                </div>
                <div style="height: 260px; position: relative;">
                    <canvas id="connectionGrowthChart"></canvas>
                </div>
            </div>

            <!-- Recent Activity Card -->
            <div class="fl-card">
                <div class="fl-card-header mb-3">
                    <h5 class="fw-bold mb-0 text-dark">Recent Activity</h5>
                </div>

                <div class="d-flex flex-column gap-3 mb-3">
                    <asp:Repeater ID="rptActivities" runat="server">
                        <ItemTemplate>
                            <div class="d-flex align-items-center gap-3 p-2 rounded-2">
                                <div class='<%# GetActivityIconClass(Eval("ActivityType")) %>' style="width: 38px; height: 38px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                    <i class='<%# GetActivityIcon(Eval("ActivityType")) %>'></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="fw-semibold small text-dark"><%# Eval("ActivityText") %></div>
                                    <div class="text-muted" style="font-size: 0.74rem;"><%# Eval("TimeAgo") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="pt-3 border-top text-center" style="border-color: #F1F5F9 !important;">
                    <a href="#" class="fw-bold small text-decoration-none" style="color: #006591;">View All Activity</a>
                </div>
            </div>
        </div>

        <!-- Right Column: Deadlines & Suggested Connections -->
        <div class="col-lg-4">
            <!-- Upcoming Deadlines -->
            <div class="fl-card mb-4">
                <div class="fl-card-header">
                    <h5 class="fw-bold mb-0 text-dark">Upcoming Deadlines</h5>
                    <button type="button" class="btn btn-sm btn-outline-secondary rounded-circle" style="width: 26px; height: 26px; padding: 0; display:flex; align-items:center; justify-content:center;">
                        <i class="bi bi-plus"></i>
                    </button>
                </div>

                <div class="d-flex flex-column gap-3">
                    <asp:Repeater ID="rptDeadlines" runat="server">
                        <ItemTemplate>
                            <div class="d-flex align-items-center gap-3">
                                <div class='<%# Container.ItemIndex == 0 ? "fl-date-badge-red" : "fl-date-badge-gray" %>'>
                                    <span style="font-size: 0.62rem; text-transform: uppercase;"><%# Eval("MonthText") %></span>
                                    <span class="fs-5" style="line-height: 1;"><%# Eval("DayText") %></span>
                                </div>
                                <div>
                                    <div class="fw-bold small text-dark"><%# Eval("Title") %></div>
                                    <div class="text-muted" style="font-size: 0.74rem;"><%# Eval("Description") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Suggested Connections -->
            <div class="fl-card">
                <div class="fl-card-header mb-3">
                    <h5 class="fw-bold mb-0 text-dark">Suggested Connections</h5>
                </div>

                <div class="d-flex flex-column gap-3">
                    <asp:Repeater ID="rptSuggested" runat="server" OnItemCommand="rptSuggested_ItemCommand">
                        <ItemTemplate>
                            <div class="d-flex align-items-center justify-content-between p-1">
                                <div class="d-flex align-items-center gap-3">
                                    <img src='<%# Eval("AvatarUrl") %>' class="rounded-circle" width="38" height="38" style="object-fit:cover; background:#E2E8F0;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                                    <div>
                                        <div class="fw-bold small text-dark"><%# Eval("FullName") %></div>
                                        <div class="text-muted" style="font-size: 0.74rem;"><%# Eval("Role") %></div>
                                    </div>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <span class="badge rounded-pill px-2 py-1 fw-bold" style="background-color: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; font-size: 0.68rem;">
                                        <i class="bi bi-stars"></i> <%# GetMatchPercent(Container.ItemIndex) %>% Match
                                    </span>
                                    <asp:LinkButton ID="btnConnect" runat="server" CommandName="Connect" CommandArgument='<%# Eval("UserId") %>' CssClass="btn btn-sm btn-outline-secondary rounded-circle" style="width: 32px; height: 32px; display:flex; align-items:center; justify-content:center; padding:0;" ToolTip="Connect">
                                        <i class="bi bi-person-plus"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden field holding serialized chart data for Chart.js -->
    <asp:HiddenField ID="hfChartLabels" runat="server" Value="['May', 'Jun', 'Jul', 'Aug', 'Sep']" />
    <asp:HiddenField ID="hfChartData" runat="server" Value="[14, 28, 24, 46, 68]" />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var ctx = document.getElementById('connectionGrowthChart');
            if (ctx) {
                var labels = JSON.parse(document.getElementById('<%= hfChartLabels.ClientID %>').value.replace(/'/g, '"'));
                var dataVals = JSON.parse(document.getElementById('<%= hfChartData.ClientID %>').value);

                var gradient = ctx.getContext('2d').createLinearGradient(0, 0, 0, 240);
                gradient.addColorStop(0, 'rgba(109, 245, 225, 0.4)');
                gradient.addColorStop(1, 'rgba(109, 245, 225, 0.0)');

                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Connections',
                            data: dataVals,
                            borderColor: '#10B981',
                            borderWidth: 2,
                            backgroundColor: gradient,
                            fill: true,
                            tension: 0.35,
                            pointBackgroundColor: '#FFFFFF',
                            pointBorderColor: '#10B981',
                            pointBorderWidth: 2,
                            pointRadius: 4,
                            pointHoverRadius: 6
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false }
                        },
                        scales: {
                            x: {
                                grid: { display: false },
                                ticks: { color: '#94A3B8', font: { family: 'Plus Jakarta Sans', size: 12 } }
                            },
                            y: {
                                display: false,
                                beginAtZero: true
                            }
                        }
                    }
                });
            }
        });
    </script>
</asp:Content>
