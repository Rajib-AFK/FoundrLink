<%@ Page Title="Founder Dashboard" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FoundrLink.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-welcome-hero {
            background: linear-gradient(135deg, #FFFFFF 0%, #F8FAFC 100%);
            border: 1px solid var(--fl-border-color);
            border-radius: 16px;
            padding: 32px;
            margin-bottom: 24px;
            position: relative;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
        }
        .fl-avatar-edit-wrapper {
            position: relative;
            display: inline-block;
        }
        .fl-avatar-lg {
            width: 84px;
            height: 84px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #FFFFFF;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            background: #E2E8F0;
        }
        .fl-avatar-edit-badge {
            position: absolute;
            bottom: 2px;
            right: 2px;
            width: 26px;
            height: 26px;
            border-radius: 50%;
            background: #FFFFFF;
            border: 1px solid #CBD5E1;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            color: #334155;
            cursor: pointer;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .fl-date-badge {
            width: 52px;
            height: 52px;
            border-radius: 10px;
            background: #FFF1F2;
            color: #E11D48;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            line-height: 1.1;
        }
        .fl-date-badge-alt {
            background: #F1F5F9;
            color: #475569;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Welcome Hero Card -->
    <div class="fl-welcome-hero d-flex flex-wrap align-items-center justify-content-between gap-4">
        <div class="d-flex align-items-center gap-4">
            <div class="fl-avatar-edit-wrapper">
                <asp:Image ID="imgHeroAvatar" runat="server" CssClass="fl-avatar-lg" ImageUrl="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150" />
                <a href="Profile.aspx" class="fl-avatar-edit-badge" title="Edit Profile">
                    <i class="bi bi-pencil-fill"></i>
                </a>
            </div>
            <div>
                <h2 class="fw-bold fs-3 mb-1">
                    Welcome back, <asp:Literal ID="litUserName" runat="server" Text="Rachit" />
                </h2>
                <p class="text-muted mb-0 fs-6">
                    <asp:Literal ID="litUserHeadline" runat="server" Text="Technical Co-founder searching for seed funding." />
                </p>
            </div>
        </div>

        <!-- Profile Completion Widget -->
        <div class="p-3 bg-white rounded-3 border border-slate-200 shadow-sm" style="min-width: 280px;">
            <div class="d-flex justify-content-between align-items-center mb-1">
                <span class="small fw-semibold text-dark">Profile Completion</span>
                <span class="small fw-bold text-teal"><asp:Literal ID="litCompletionPct" runat="server" Text="85%" /></span>
            </div>
            <div class="progress mb-2" style="height: 6px;">
                <div class="progress-bar bg-teal" role="progressbar" style='<%= "width: " + CompletionPercentage + "%;" %>'></div>
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
                <div class="fl-stat-icon-wrapper bg-teal-subtle text-teal">
                    <i class="bi bi-eye-fill"></i>
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
                <div class="fl-stat-icon-wrapper bg-dark text-white">
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
                <div class="fl-stat-icon-wrapper bg-light text-muted border">
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
                    <h5 class="fw-bold mb-0">Connection Growth</h5>
                    <span class="badge bg-light text-muted border px-3 py-2 fw-semibold">Last 30 Days</span>
                </div>
                <div style="height: 280px; position: relative;">
                    <canvas id="connectionGrowthChart"></canvas>
                </div>
            </div>

            <!-- Recent Activity Card -->
            <div class="fl-card">
                <div class="fl-card-header">
                    <h5 class="fw-bold mb-0">Recent Activity</h5>
                </div>

                <div class="d-flex flex-column gap-3 mb-3">
                    <asp:Repeater ID="rptActivities" runat="server">
                        <ItemTemplate>
                            <div class="d-flex align-items-start gap-3 p-2 rounded-2 hover-bg-light">
                                <div class='<%# GetActivityIconClass(Eval("ActivityType")) %>'>
                                    <i class='<%# GetActivityIcon(Eval("ActivityType")) %>'></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="fw-semibold small text-dark"><%# Eval("ActivityText") %></div>
                                    <div class="text-muted" style="font-size: 0.75rem;"><%# Eval("TimeAgo") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="pt-3 border-top text-center">
                    <a href="#" class="text-teal fw-bold small text-decoration-none">View All Activity</a>
                </div>
            </div>
        </div>

        <!-- Right Column: Deadlines & Suggested Connections -->
        <div class="col-lg-4">
            <!-- Upcoming Deadlines -->
            <div class="fl-card mb-4">
                <div class="fl-card-header">
                    <h5 class="fw-bold mb-0">Upcoming Deadlines</h5>
                    <button type="button" class="btn btn-sm btn-outline-secondary rounded-circle" style="width: 28px; height: 28px; padding: 0;">
                        <i class="bi bi-plus"></i>
                    </button>
                </div>

                <div class="d-flex flex-column gap-3">
                    <asp:Repeater ID="rptDeadlines" runat="server">
                        <ItemTemplate>
                            <div class="d-flex align-items-center gap-3">
                                <div class='<%# "fl-date-badge " + (Container.ItemIndex % 2 == 1 ? "fl-date-badge-alt" : "") %>'>
                                    <span style="font-size: 0.65rem; text-transform: uppercase;"><%# Eval("MonthText") %></span>
                                    <span class="fs-5"><%# Eval("DayText") %></span>
                                </div>
                                <div>
                                    <div class="fw-bold small text-dark"><%# Eval("Title") %></div>
                                    <div class="text-muted" style="font-size: 0.75rem;"><%# Eval("Description") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Suggested Connections -->
            <div class="fl-card">
                <div class="fl-card-header">
                    <h5 class="fw-bold mb-0">Suggested Connections</h5>
                </div>

                <div class="d-flex flex-column gap-3">
                    <asp:Repeater ID="rptSuggested" runat="server" OnItemCommand="rptSuggested_ItemCommand">
                        <ItemTemplate>
                            <div class="d-flex align-items-center justify-content-between p-2 rounded-2">
                                <div class="d-flex align-items-center gap-3">
                                    <img src='<%# Eval("AvatarUrl") %>' class="rounded-circle" width="40" height="40" style="object-fit:cover;" />
                                    <div>
                                        <div class="fw-bold small text-dark"><%# Eval("FullName") %></div>
                                        <div class="text-muted" style="font-size: 0.75rem;"><%# Eval("Role") %></div>
                                    </div>
                                </div>
                                <asp:LinkButton ID="btnConnect" runat="server" CommandName="Connect" CommandArgument='<%# Eval("UserId") %>' CssClass="btn btn-sm btn-outline-secondary rounded-circle p-0" style="width: 32px; height: 32px; display:flex; align-items:center; justify-content:center;" ToolTip="Connect">
                                    <i class="bi bi-person-plus"></i>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden field holding serialized chart data for Chart.js -->
    <asp:HiddenField ID="hfChartLabels" runat="server" Value="['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct']" />
    <asp:HiddenField ID="hfChartData" runat="server" Value="[14, 28, 24, 46, 42, 68]" />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var ctx = document.getElementById('connectionGrowthChart');
            if (ctx) {
                var labels = JSON.parse(document.getElementById('<%= hfChartLabels.ClientID %>').value.replace(/'/g, '"'));
                var dataVals = JSON.parse(document.getElementById('<%= hfChartData.ClientID %>').value);

                var gradient = ctx.getContext('2d').createLinearGradient(0, 0, 0, 260);
                gradient.addColorStop(0, 'rgba(45, 212, 191, 0.35)');
                gradient.addColorStop(1, 'rgba(45, 212, 191, 0.0)');

                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Connections',
                            data: dataVals,
                            borderColor: '#10B981',
                            borderWidth: 2.5,
                            backgroundColor: gradient,
                            fill: true,
                            tension: 0.4,
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
