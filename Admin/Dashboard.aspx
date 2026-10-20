<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FoundrLink.Admin.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .fl-admin-stat-card {
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 14px;
            padding: 22px 24px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 148px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            transition: all 0.2s ease;
        }
        .fl-admin-stat-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            transform: translateY(-2px);
        }
        .fl-icon-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.15rem;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header Row -->
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <div>
            <h1 class="fw-bold fs-2 text-dark mb-1" style="letter-spacing: -0.02em;">Overview Dashboard</h1>
            <p class="text-muted mb-0 small">Welcome back. Here's what's happening on FoundrLink today.</p>
        </div>
        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-success-subtle text-success border border-success border-opacity-25 rounded-pill px-3 py-2 fw-semibold small">
                <i class="bi bi-circle-fill me-1" style="font-size: 0.45rem;"></i> System Status: Optimal
            </span>
        </div>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show rounded-3 shadow-sm border-0" role="alert">
        <div class="d-flex align-items-center gap-2">
            <i class="bi bi-check-circle-fill fs-5 text-success"></i>
            <div><asp:Literal ID="litAlertMsg" runat="server" /></div>
        </div>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <!-- Stat Cards Row (3 Cards from Figma) -->
    <div class="row g-4 mb-4">
        <!-- Card 1: Total Users -->
        <div class="col-md-4">
            <div class="fl-admin-stat-card">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="text-uppercase fw-bold text-muted" style="font-size: 0.75rem; letter-spacing: 0.05em;">Total Users</span>
                    <div class="fl-icon-circle bg-light text-dark">
                        <i class="bi bi-people-fill"></i>
                    </div>
                </div>
                <div>
                    <h2 class="fw-bold text-dark mb-2" style="font-size: 2.25rem; line-height: 1; letter-spacing: -0.03em;">
                        <asp:Literal ID="litTotalUsers" runat="server" Text="2,486" />
                    </h2>
                    <div class="d-flex align-items-center gap-1 text-success small fw-semibold" style="font-size: 0.8rem;">
                        <i class="bi bi-arrow-up-right"></i>
                        <span>+12.5% from last month</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Card 2: Active Startups -->
        <div class="col-md-4">
            <div class="fl-admin-stat-card">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="text-uppercase fw-bold text-muted" style="font-size: 0.75rem; letter-spacing: 0.05em;">Active Startups</span>
                    <div class="fl-icon-circle bg-light text-dark">
                        <i class="bi bi-rocket-takeoff"></i>
                    </div>
                </div>
                <div>
                    <h2 class="fw-bold text-dark mb-2" style="font-size: 2.25rem; line-height: 1; letter-spacing: -0.03em;">
                        <asp:Literal ID="litActiveStartups" runat="server" Text="184" />
                    </h2>
                    <div class="d-flex align-items-center gap-1 text-success small fw-semibold" style="font-size: 0.8rem;">
                        <i class="bi bi-arrow-up-right"></i>
                        <span>+8 new this week</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Card 3: Pending Reports -->
        <div class="col-md-4">
            <div class="fl-admin-stat-card">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="text-uppercase fw-bold text-muted" style="font-size: 0.75rem; letter-spacing: 0.05em;">Pending Reports</span>
                    <div class="fl-icon-circle bg-danger-subtle text-danger">
                        <i class="bi bi-flag-fill"></i>
                    </div>
                </div>
                <div>
                    <h2 class="fw-bold text-dark mb-2" style="font-size: 2.25rem; line-height: 1; letter-spacing: -0.03em;">
                        <asp:Literal ID="litPendingReports" runat="server" Text="12" />
                    </h2>
                    <div class="d-flex align-items-center gap-1 text-secondary small fw-semibold" style="font-size: 0.8rem;">
                        <i class="bi bi-clock"></i>
                        <span>Requires attention</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden compatibility literal for designer -->
    <asp:Literal ID="litTotalConnections" runat="server" Visible="false" Text="0" />

    <!-- Platform Activity Graph Card -->
    <div class="card border-0 shadow-sm rounded-4 p-4 mb-4" style="border: 1px solid #E2E8F0 !important;">
        <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
            <h5 class="fw-bold text-dark mb-0 fs-5">Platform Activity</h5>
            <div class="d-flex align-items-center gap-2">
                <button type="button" class="btn btn-sm text-white px-3 py-1 rounded-pill fw-semibold shadow-none border-0" style="background:#0F172A; font-size: 0.75rem;">7 Days</button>
                <button type="button" class="btn btn-sm text-secondary px-3 py-1 rounded-pill fw-semibold shadow-none border" style="background:#F1F5F9; font-size: 0.75rem;">30 Days</button>
            </div>
        </div>
        <div style="height: 270px; width: 100%;">
            <canvas id="adminActivityChart"></canvas>
        </div>
        <!-- Legend -->
        <div class="d-flex justify-content-center align-items-center gap-4 mt-3 pt-2 text-muted small fw-medium" style="font-size: 0.8rem;">
            <div class="d-flex align-items-center gap-2">
                <span style="width: 10px; height: 10px; border-radius: 50%; background-color: #10B981; display: inline-block;"></span>
                <span>New Users</span>
            </div>
            <div class="d-flex align-items-center gap-2">
                <span style="width: 10px; height: 10px; border-radius: 50%; background-color: #0F172A; display: inline-block;"></span>
                <span>New Startups</span>
            </div>
            <div class="d-flex align-items-center gap-2">
                <span style="width: 10px; height: 10px; border-radius: 50%; background-color: #64748B; display: inline-block;"></span>
                <span>Collab Requests</span>
            </div>
        </div>
    </div>

    <!-- 50/50 Data Tables Row -->
    <div class="row g-4">
        <!-- Left: Recent Registrations -->
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm rounded-4 p-4 h-100" style="border: 1px solid #E2E8F0 !important;">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold text-dark mb-0 fs-5">Recent Registrations</h5>
                    <a href="ManageUsers.aspx" class="text-teal small fw-semibold text-decoration-none" style="color: #008C75;">View All</a>
                </div>

                <div class="table-responsive">
                    <asp:Repeater ID="rptUsers" runat="server">
                        <HeaderTemplate>
                            <table class="table align-middle mb-0">
                                <thead style="background: #F8FAFC;">
                                    <tr style="font-size: 0.78rem;" class="text-muted fw-semibold">
                                        <th class="py-2 px-3 border-0">User</th>
                                        <th class="py-2 px-3 border-0">Role</th>
                                        <th class="py-2 px-3 border-0 text-end">Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr class="border-bottom">
                                <td class="py-3 px-3">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="fl-avatar-sm rounded-circle d-flex align-items-center justify-content-center fw-bold small flex-shrink-0" style="width:36px; height:36px; background:#EEF2FF; color:#4F46E5;">
                                            <%# Eval("FullName").ToString().Length > 1 ? Eval("FullName").ToString().Substring(0, 2).ToUpper() : "U" %>
                                        </div>
                                        <div class="overflow-hidden">
                                            <div class="fw-bold text-dark text-truncate small"><%# Eval("FullName") %></div>
                                            <div class="text-muted small text-truncate" style="font-size: 0.72rem;"><%# Eval("Email") %></div>
                                        </div>
                                    </div>
                                </td>
                                <td class="py-3 px-3">
                                    <span class="badge bg-light text-secondary border border-secondary-subtle rounded-pill px-3 py-1 small fw-medium" style="font-size: 0.75rem;">
                                        <%# Eval("Role") %>
                                    </span>
                                </td>
                                <td class="py-3 px-3 text-end text-muted small" style="font-size: 0.78rem;">
                                    <%# Eval("Status").ToString() == "Active" ? "Active" : "2h ago" %>
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

        <!-- Right: Startup Submissions -->
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm rounded-4 p-4 h-100" style="border: 1px solid #E2E8F0 !important;">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold text-dark mb-0 fs-5">Startup Submissions</h5>
                    <a href="ManageStartups.aspx" class="text-teal small fw-semibold text-decoration-none" style="color: #008C75;">View All</a>
                </div>

                <div class="table-responsive">
                    <asp:Repeater ID="rptStartups" runat="server" OnItemCommand="rptStartups_ItemCommand">
                        <HeaderTemplate>
                            <table class="table align-middle mb-0">
                                <thead style="background: #F8FAFC;">
                                    <tr style="font-size: 0.78rem;" class="text-muted fw-semibold">
                                        <th class="py-2 px-3 border-0">Startup Name</th>
                                        <th class="py-2 px-3 border-0">Status</th>
                                        <th class="py-2 px-3 border-0 text-end">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr class="border-bottom">
                                <td class="py-3 px-3">
                                    <div class="fw-bold text-dark small"><%# Eval("Name") %></div>
                                    <div class="text-muted" style="font-size: 0.72rem;"><%# Eval("Industry") %></div>
                                </td>
                                <td class="py-3 px-3">
                                    <span class='<%# Eval("Status").ToString() == "Published" ? "badge bg-success-subtle text-success border border-success border-opacity-25 rounded-pill px-3 py-1 fw-medium" : "badge bg-light text-secondary border border-secondary-subtle rounded-pill px-3 py-1 fw-medium" %>' style="font-size: 0.75rem;">
                                        <i class='<%# Eval("Status").ToString() == "Published" ? "bi bi-circle-fill me-1 text-success" : "bi bi-circle-fill me-1 text-secondary" %>' style="font-size: 0.45rem;"></i>
                                        <%# Eval("Status").ToString() == "Published" ? "Approved" : "Under Review" %>
                                    </span>
                                </td>
                                <td class="py-3 px-3 text-end">
                                    <div class="dropdown">
                                        <button class="btn btn-sm btn-link text-muted p-0 shadow-none border-0" type="button" data-bs-toggle="dropdown" aria-expanded="false" title="Actions">
                                            <i class="bi bi-three-dots-vertical fs-5"></i>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end shadow-sm border small rounded-3">
                                            <li>
                                                <asp:LinkButton ID="btnApprove" runat="server" CommandName="Approve" CommandArgument='<%# Eval("StartupId") %>' CssClass="dropdown-item py-2 text-success">
                                                    <i class="bi bi-check-circle me-2"></i> Approve
                                                </asp:LinkButton>
                                            </li>
                                            <li>
                                                <asp:LinkButton ID="btnReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("StartupId") %>' CssClass="dropdown-item py-2 text-danger">
                                                    <i class="bi bi-x-circle me-2"></i> Reject (Draft)
                                                </asp:LinkButton>
                                            </li>
                                        </ul>
                                    </div>
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
                var gradient = ctx.getContext('2d').createLinearGradient(0, 0, 0, 260);
                gradient.addColorStop(0, 'rgba(16, 185, 129, 0.25)');
                gradient.addColorStop(1, 'rgba(16, 185, 129, 0.0)');

                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                        datasets: [
                            {
                                label: 'New Users',
                                data: [12, 19, 28, 45, 62, 78, 95],
                                borderColor: '#10B981',
                                backgroundColor: gradient,
                                fill: true,
                                tension: 0.45,
                                borderWidth: 3,
                                pointRadius: 5,
                                pointBackgroundColor: '#FFFFFF',
                                pointBorderColor: '#10B981',
                                pointBorderWidth: 2
                            },
                            {
                                label: 'New Startups',
                                data: [5, 8, 12, 18, 24, 30, 42],
                                borderColor: '#0F172A',
                                borderDash: [5, 5],
                                fill: false,
                                tension: 0.45,
                                borderWidth: 2,
                                pointRadius: 0
                            },
                            {
                                label: 'Collab Requests',
                                data: [2, 4, 7, 10, 14, 20, 26],
                                borderColor: '#64748B',
                                fill: false,
                                tension: 0.45,
                                borderWidth: 2,
                                pointRadius: 0
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                backgroundColor: '#0F172A',
                                titleFont: { size: 12, weight: 'bold' },
                                bodyFont: { size: 12 },
                                padding: 10,
                                cornerRadius: 8
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                grid: { color: '#F1F5F9' },
                                ticks: { color: '#94A3B8', font: { size: 11 } }
                            },
                            x: {
                                grid: { display: false },
                                ticks: { color: '#94A3B8', font: { size: 11 } }
                            }
                        }
                    }
                });
            }
        });
    </script>
</asp:Content>
