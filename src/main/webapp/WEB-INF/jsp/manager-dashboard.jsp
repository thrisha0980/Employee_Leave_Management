<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.elms.model.User, com.elms.model.Employee" %>
<%@ page import="com.elms.model.LeaveApplication" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    Employee emp = (Employee) session.getAttribute("employee");
    int teamSize     = (Integer) request.getAttribute("teamSize");
    int pendingCount = (Integer) request.getAttribute("pendingCount");
    List<LeaveApplication> pendingLeaves = (List<LeaveApplication>) request.getAttribute("pendingLeaves");
    List<LeaveApplication> allTeamLeaves = (List<LeaveApplication>) request.getAttribute("allTeamLeaves");
    List<Employee> teamEmployees = (List<Employee>) request.getAttribute("teamEmployees");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Dashboard - ELMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">

    <!-- SIDEBAR -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <div class="brand-icon">&#128188;</div>
            <div><h2>ELMS</h2><small>Manager Panel</small></div>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section-title">Main</div>
            <a href="${pageContext.request.contextPath}/manager/dashboard" class="nav-link active">
                <span class="nav-icon">&#127968;</span> Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/manager/leave-approval" class="nav-link">
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
                    <div class="user-name"><%= emp.getFullName() %></div>
                    <div class="user-role">Manager &bull; <%= emp.getDeptName() %></div>
                </div>
            </div>
        </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <button class="mobile-menu-btn" onclick="toggleSidebar()">&#9776;</button>

        <div class="page-header">
            <h1>Welcome, <%= emp.getFirstName() %> &#128075;</h1>
            <p>Manage your team's leave requests</p>
        </div>

        <%
            String success = request.getParameter("success");
            if (success != null) {
        %>
            <div class="alert alert-success">&#9989; Leave has been <%= success %> successfully.</div>
        <% } %>

        <!-- STATS -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue">&#128101;</div>
                <div class="stat-info"><h3>Team Members</h3><div class="stat-value"><%= teamSize %></div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange">&#9203;</div>
                <div class="stat-info"><h3>Pending Requests</h3><div class="stat-value"><%= pendingCount %></div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">&#128203;</div>
                <div class="stat-info"><h3>Total Requests</h3><div class="stat-value"><%= allTeamLeaves != null ? allTeamLeaves.size() : 0 %></div></div>
            </div>
        </div>

        <!-- PENDING LEAVES -->
        <div class="card">
            <div class="card-header">
                <h2>&#9203; Pending Leave Requests</h2>
                <a href="${pageContext.request.contextPath}/manager/leave-approval" class="btn btn-sm btn-primary">Review All</a>
            </div>
            <div class="card-body table-responsive">
                <% if (pendingLeaves != null && !pendingLeaves.isEmpty()) { %>
                <table class="data-table">
                    <thead><tr>
                        <th>Employee</th><th>Type</th><th>From</th><th>To</th><th>Days</th><th>Reason</th><th>Actions</th>
                    </tr></thead>
                    <tbody>
                    <% for (LeaveApplication la : pendingLeaves) { %>
                        <tr>
                            <td><%= la.getEmpName() %></td>
                            <td><%= la.getLeaveTypeName() %></td>
                            <td><%= la.getStartDate() %></td>
                            <td><%= la.getEndDate() %></td>
                            <td><%= la.getTotalDays() %></td>
                            <td><%= la.getReason() != null ? la.getReason() : "-" %></td>
                            <td class="actions">
                                <form action="${pageContext.request.contextPath}/manager/leave-approval" method="post" style="display:inline">
                                    <input type="hidden" name="leaveId" value="<%= la.getLeaveId() %>">
                                    <input type="hidden" name="action" value="approve">
                                    <input type="hidden" name="remarks" value="Approved">
                                    <button class="btn btn-sm btn-success" type="submit">Approve</button>
                                </form>
                                <form action="${pageContext.request.contextPath}/manager/leave-approval" method="post" style="display:inline">
                                    <input type="hidden" name="leaveId" value="<%= la.getLeaveId() %>">
                                    <input type="hidden" name="action" value="reject">
                                    <input type="hidden" name="remarks" value="Rejected">
                                    <button class="btn btn-sm btn-danger" type="submit">Reject</button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="no-data"><div class="empty-icon">&#127881;</div><p>No pending requests. All caught up!</p></div>
                <% } %>
            </div>
        </div>

        <!-- TEAM LIST -->
        <div class="card">
            <div class="card-header"><h2>&#128101; Your Team</h2></div>
            <div class="card-body table-responsive">
                <% if (teamEmployees != null && !teamEmployees.isEmpty()) { %>
                <table class="data-table">
                    <thead><tr><th>Name</th><th>Designation</th><th>Department</th><th>Email</th><th>Phone</th></tr></thead>
                    <tbody>
                    <% for (Employee te : teamEmployees) { %>
                        <tr>
                            <td><%= te.getFullName() %></td>
                            <td><%= te.getDesignation() %></td>
                            <td><%= te.getDeptName() %></td>
                            <td><%= te.getEmail() %></td>
                            <td><%= te.getPhone() %></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="no-data"><div class="empty-icon">&#128101;</div><p>No team members found</p></div>
                <% } %>
            </div>
        </div>

    </main>
</div>
<script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
