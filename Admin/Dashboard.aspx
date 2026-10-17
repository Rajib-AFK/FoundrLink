<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FoundrLink.Admin.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-stat-card {
            background: #FFFFFF;
            border: 1px solid var(--fl-border-color);
            border-radius: 12px;
            padding: 24px;
            transition: all 0.2s ease;
        }
        .fl-stat-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            transform: translateY(-2px);
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row mb-4">
        <div class="col-12">
            <h2 class="fw-bold fs-3 text-dark mb-1">Platform Overview</h2>
            <p class="text-muted">Real-time metrics, system health, and pending platform moderation queues.</p>
        </div>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show" role="alert">
        <asp:Literal ID="litAlertMsg" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- Stat Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="fl-stat-card">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="text-muted small fw-semibold">Total Users</span>
                    <span class="badge bg-success-subtle text-success small">+12%</span>
                </div>
                <h3 class="fw-bold text-dark mb-0"><asp:Literal ID="litTotalUsers" runat="server" Text="0" /></h3>
                <span class="text-muted" style="font-size: 0.75rem;">Registered founders & investors</span>
            </div>
        </div>

        <div class="col-md-3">
            <div class="fl-stat-card">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="text-muted small fw-semibold">Active Startups</span>
                    <span class="badge bg-teal-subtle text-teal small" style="background:#E6FAF5; color:#10B981;">+8%</span>
                </div>
                <h3 class="fw-bold text-dark mb-0"><asp:Literal ID="litActiveStartups" runat="server" Text="0" /></h3>
                <span class="text-muted" style="font-size: 0.75rem;">Verified venture profiles</span>
            </div>
        </div>

        <div class="col-md-3">
            <div class="fl-stat-card">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="text-muted small fw-semibold">Pending Reports</span>
                    <span class="badge bg-warning-subtle text-warning small">Action Req.</span>
                </div>
                <h3 class="fw-bold text-dark mb-0"><asp:Literal ID="litPendingReports" runat="server" Text="0" /></h3>
                <span class="text-muted" style="font-size: 0.75rem;">Requires moderator review</span>
            </div>
        </div>

        <div class="col-md-3">
            <div class="fl-stat-card">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="text-muted small fw-semibold">Connections Made</span>
                    <span class="badge bg-primary-subtle text-primary small">+24%</span>
                </div>
                <h3 class="fw-bold text-dark mb-0"><asp:Literal ID="litTotalConnections" runat="server" Text="0" /></h3>
                <span class="text-muted" style="font-size: 0.75rem;">Successful introductions</span>
            </div>
        </div>
    </div>

    <!-- Platform Activity Graph -->
    <div class="card border-0 shadow-sm rounded-4 p-4 mb-4">
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
            <div>
                <h5 class="fw-bold text-dark mb-1">Platform Activity Trends</h5>
                <p class="text-muted small mb-0">Daily user registrations vs co-founder match requests over the last 30 days</p>
            </div>
            <div class="btn-group btn-group-sm">
                <button type="button" class="btn btn-outline-secondary active">30 Days</button>
                <button type="button" class="btn btn-outline-secondary">90 Days</button>
            </div>
        </div>
        <div style="height: 280px; width: 100%;">
            <canvas id="adminActivityChart"></canvas>
        </div>
    </div>

    <!-- Data Tables Grid -->
    <div class="row g-4">
        <!-- Pending Startup Submissions -->
        <div class="col-lg-7">
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold text-dark mb-0">Startup Submissions</h5>
                    <a href="ManageStartups.aspx" class="text-teal small fw-semibold text-decoration-none">View All <i class="bi bi-arrow-right"></i></a>
                </div>

                <div class="table-responsive">
                    <asp:Repeater ID="rptStartups" runat="server" OnItemCommand="rptStartups_ItemCommand">
                        <HeaderTemplate>
                            <table class="table align-middle table-hover mb-0">
                                <thead class="table-light">
                                    <tr style="font-size: 0.75rem;" class="text-muted text-uppercase">
                                        <th>Startup</th>
                                        <th>Industry</th>
                                        <th>Stage</th>
                                        <th>Status</th>
                                        <th class="text-end">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <img src='<%# Eval("LogoUrl") %>' class="rounded-3 border" width="34" height="34" style="object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100';" />
                                        <div>
                                            <div class="fw-bold text-dark small"><%# Eval("Name") %></div>
                                            <div class="text-muted" style="font-size: 0.7rem;"><%# Eval("Location") %></div>
                                        </div>
                                    </div>
                                </td>
                                <td class="small text-secondary"><%# Eval("Industry") %></td>
                                <td class="small text-secondary"><%# Eval("Stage") %></td>
                                <td>
                                    <span class='<%# Eval("Status").ToString() == "Published" ? "badge bg-success-subtle text-success small" : "badge bg-warning-subtle text-warning small" %>'>
                                        <%# Eval("Status") %>
                                    </span>
                                </td>
                                <td class="text-end">
                                    <asp:LinkButton ID="btnApprove" runat="server" CommandName="Approve" CommandArgument='<%# Eval("StartupId") %>' CssClass="btn btn-sm btn-outline-success py-0 px-2" title="Approve Startup">
                                        <i class="bi bi-check-lg"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("StartupId") %>' CssClass="btn btn-sm btn-outline-danger py-0 px-2 ms-1" title="Reject / Draft">
                                        <i class="bi bi-x-lg"></i>
                                    </asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>

        <!-- Recent User Registrations -->
        <div class="col-lg-5">
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold text-dark mb-0">Recent Users</h5>
                    <a href="ManageUsers.aspx" class="text-teal small fw-semibold text-decoration-none">Manage <i class="bi bi-arrow-right"></i></a>
                </div>

                <div class="table-responsive">
                    <asp:Repeater ID="rptUsers" runat="server">
                        <HeaderTemplate>
                            <table class="table align-middle table-hover mb-0">
                                <thead class="table-light">
                                    <tr style="font-size: 0.75rem;" class="text-muted text-uppercase">
                                        <th>User</th>
                                        <th>Role</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <img src='<%# Eval("AvatarUrl") %>' class="rounded-circle border" width="32" height="32" style="object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100';" />
                                        <div>
                                            <div class="fw-bold text-dark small"><%# Eval("FullName") %></div>
                                            <div class="text-muted" style="font-size: 0.7rem;"><%# Eval("Email") %></div>
                                        </div>
                                    </div>
                                </td>
                                <td class="small text-secondary"><%# Eval("Role") %></td>
                                <td>
                                    <span class='<%# Eval("Status").ToString() == "Active" ? "badge bg-success-subtle text-success small" : "badge bg-secondary-subtle text-secondary small" %>'>
                                        <%# Eval("Status") %>
                                    </span>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var ctx = document.getElementById('adminActivityChart');
            if (ctx) {
                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: ['Oct 1', 'Oct 5', 'Oct 10', 'Oct 15', 'Oct 20', 'Oct 25', 'Oct 30'],
                        datasets: [
                            {
                                label: 'Registrations',
                                data: [35, 59, 80, 81, 105, 120, 145],
                                borderColor: '#10B981',
                                backgroundColor: 'rgba(16, 185, 129, 0.1)',
                                fill: true,
                                tension: 0.4
                            },
                            {
                                label: 'Matches Requested',
                                data: [20, 42, 65, 70, 85, 98, 115],
                                borderColor: '#3B82F6',
                                backgroundColor: 'rgba(59, 130, 246, 0.05)',
                                fill: true,
                                tension: 0.4
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'top',
                                labels: { boxWidth: 12, usePointStyle: true }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                grid: { color: '#F1F5F9' }
                            },
                            x: {
                                grid: { display: false }
                            }
                        }
                    }
                });
            }
        });
    </script>
</asp:Content>
