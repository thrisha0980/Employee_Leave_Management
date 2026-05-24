<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.elms.model.User, com.elms.model.Employee" %>
<%@ page import="com.elms.model.LeaveApplication, com.elms.model.LeaveType" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    Employee emp = (Employee) session.getAttribute("employee");
    int pendingCount  = (Integer) request.getAttribute("pendingCount");
    int approvedCount = (Integer) request.getAttribute("approvedCount");
    int rejectedCount = (Integer) request.getAttribute("rejectedCount");
    List<LeaveApplication> leaveHistory = (List<LeaveApplication>) request.getAttribute("leaveHistory");
    List<LeaveType> leaveTypes = (List<LeaveType>) request.getAttribute("leaveTypes");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Dashboard - ELMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">

    <!-- SIDEBAR -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <div class="brand-icon">&#128188;</div>
            <div><h2>ELMS</h2><small>Employee Portal</small></div>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section-title">Main</div>
            <a href="${pageContext.request.contextPath}/employee/dashboard" class="nav-link active">
                <span class="nav-icon">&#127968;</span> Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/employee/apply-leave" class="nav-link">
                <span class="nav-icon">&#128221;</span> Apply for Leave
            </a>
            <div class="nav-section-title">Account</div>
            <a href="${pageContext.request.contextPath}/logout" class="nav-link">
                <span class="nav-icon">&#128682;</span> Logout
            </a>
        </nav>
        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar"><%= emp.getFirstName().substring(0,1) %></div>
                <div>
                    <div class="user-name"><%= emp.getFullName() %></div>
                    <div class="user-role"><%= emp.getDesignation() %></div>
                </div>
            </div>
        </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <button class="mobile-menu-btn" onclick="toggleSidebar()">&#9776;</button>

        <div class="page-header">
            <h1>Hello, <%= emp.getFirstName() %> &#128075;</h1>
            <p><%= emp.getDesignation() %> &bull; <%= emp.getDeptName() %></p>
        </div>

        <%
            String success = request.getParameter("success");
            if ("applied".equals(success)) {
        %>
            <div class="alert alert-success">&#9989; Leave application submitted successfully!</div>
        <% } %>

        <!-- STATS -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon orange">&#9203;</div>
                <div class="stat-info"><h3>Pending</h3><div class="stat-value"><%= pendingCount %></div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">&#9989;</div>
                <div class="stat-info"><h3>Approved</h3><div class="stat-value"><%= approvedCount %></div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red">&#10060;</div>
                <div class="stat-info"><h3>Rejected</h3><div class="stat-value"><%= rejectedCount %></div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple">&#127796;</div>
                <div class="stat-info"><h3>Annual Balance</h3><div class="stat-value"><%= emp.getAnnualLeave() %></div></div>
            </div>
        </div>

        <!-- LEAVE BALANCE -->
        <div class="card mb-3">
            <div class="card-header">
                <h2>&#127796; Leave Balance</h2>
                <a href="${pageContext.request.contextPath}/employee/apply-leave" class="btn btn-sm btn-primary">+ Apply Leave</a>
            </div>
            <div class="card-body">
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon blue">&#128197;</div>
                        <div class="stat-info"><h3>Annual Leave</h3><div class="stat-value"><%= emp.getAnnualLeave() %></div></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon red">&#129658;</div>
                        <div class="stat-info"><h3>Sick Leave</h3><div class="stat-value"><%= emp.getSickLeave() %></div></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon green">&#127947;</div>
                        <div class="stat-info"><h3>Casual Leave</h3><div class="stat-value"><%= emp.getCasualLeave() %></div></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- LEAVE HISTORY -->
        <div class="card">
            <div class="card-header"><h2>&#128203; Leave History</h2></div>
            <div class="card-body table-responsive">
                <% if (leaveHistory != null && !leaveHistory.isEmpty()) { %>
                <table class="data-table">
                    <thead><tr><th>Type</th><th>From</th><th>To</th><th>Days</th><th>Reason</th><th>Status</th><th>Remarks</th></tr></thead>
                    <tbody>
                    <% for (LeaveApplication la : leaveHistory) { %>
                        <tr>
                            <td><%= la.getLeaveTypeName() %></td>
                            <td><%= la.getStartDate() %></td>
                            <td><%= la.getEndDate() %></td>
                            <td><%= la.getTotalDays() %></td>
                            <td><%= la.getReason() != null ? la.getReason() : "-" %></td>
                            <td><span class="badge badge-<%= la.getStatus().toLowerCase() %>"><%= la.getStatus() %></span></td>
                            <td><%= la.getManagerRemarks() != null ? la.getManagerRemarks() : "-" %></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="no-data"><div class="empty-icon">&#128196;</div><p>No leave history found</p></div>
                <% } %>
            </div>
        </div>

    </main>
</div>
<script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
