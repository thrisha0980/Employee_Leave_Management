<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.elms.model.User, com.elms.model.Employee" %>
<%@ page import="com.elms.model.LeaveApplication" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    User user = (User) session.getAttribute("user");
    Employee emp = (Employee) session.getAttribute("employee");
    int totalEmployees = (Integer) request.getAttribute("totalEmployees");
    int pendingLeaves  = (Integer) request.getAttribute("pendingLeaves");
    List<LeaveApplication> allLeaves = (List<LeaveApplication>) request.getAttribute("allLeaves");
    List<Employee> allEmployees = (List<Employee>) request.getAttribute("allEmployees");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - ELMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">

    <!-- SIDEBAR -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <div class="brand-icon">&#128188;</div>
            <div>
                <h2>ELMS</h2>
                <small>Admin Panel</small>
            </div>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section-title">Main</div>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link active">
                <span class="nav-icon">&#127968;</span> Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/admin/employees" class="nav-link">
                <span class="nav-icon">&#128101;</span> Manage Employees
            </a>
            <a href="${pageContext.request.contextPath}/admin/leave-approval" class="nav-link">
                <span class="nav-icon">&#9989;</span> Leave Approvals
            </a>
            <div class="nav-section-title">Account</div>
            <a href="${pageContext.request.contextPath}/logout" class="nav-link">
                <span class="nav-icon">&#128682;</span> Logout
            </a>
        </nav>
        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar"><%= user.getUsername().substring(0,1).toUpperCase() %></div>
                <div>
                    <div class="user-name"><%= emp != null ? emp.getFullName() : user.getUsername() %></div>
                    <div class="user-role">Administrator</div>
                </div>
            </div>
        </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <button class="mobile-menu-btn" onclick="toggleSidebar()">&#9776;</button>

        <div class="page-header">
            <h1>Welcome back, <%= emp != null ? emp.getFirstName() : user.getUsername() %> &#128075;</h1>
            <p>Here's an overview of your organization</p>
        </div>

        <!-- STATS GRID -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon purple">&#128101;</div>
                <div class="stat-info">
                    <h3>Total Employees</h3>
                    <div class="stat-value"><%= totalEmployees %></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange">&#9203;</div>
                <div class="stat-info">
                    <h3>Pending Leaves</h3>
                    <div class="stat-value"><%= pendingLeaves %></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">&#9989;</div>
                <div class="stat-info">
                    <h3>Total Applications</h3>
                    <div class="stat-value"><%= allLeaves != null ? allLeaves.size() : 0 %></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blue">&#127970;</div>
                <div class="stat-info">
                    <h3>Departments</h3>
                    <div class="stat-value">5</div>
                </div>
            </div>
        </div>

        <!-- RECENT LEAVE APPLICATIONS -->
        <div class="card">
            <div class="card-header">
                <h2>&#128203; Recent Leave Applications</h2>
                <a href="${pageContext.request.contextPath}/admin/leave-approval" class="btn btn-sm btn-secondary">View All</a>
            </div>
            <div class="card-body table-responsive">
                <% if (allLeaves != null && !allLeaves.isEmpty()) { %>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Employee</th>
                            <th>Department</th>
                            <th>Type</th>
                            <th>From</th>
                            <th>To</th>
                            <th>Days</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% int count = 0;
                       for (LeaveApplication la : allLeaves) {
                           if (count++ >= 10) break; %>
                        <tr>
                            <td><%= la.getEmpName() %></td>
                            <td><%= la.getDeptName() %></td>
                            <td><%= la.getLeaveTypeName() %></td>
                            <td><%= la.getStartDate() %></td>
                            <td><%= la.getEndDate() %></td>
                            <td><%= la.getTotalDays() %></td>
                            <td>
                                <span class="badge badge-<%= la.getStatus().toLowerCase() %>">
                                    <%= la.getStatus() %>
                                </span>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="no-data">
                    <div class="empty-icon">&#128196;</div>
                    <p>No leave applications yet</p>
                </div>
                <% } %>
            </div>
        </div>

    </main>
</div>
<script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
