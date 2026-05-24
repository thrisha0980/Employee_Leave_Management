<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.elms.model.User, com.elms.model.Employee, com.elms.model.LeaveType" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%
    User user = (User) session.getAttribute("user");
    Employee emp = (Employee) session.getAttribute("employee");
    List<LeaveType> leaveTypes = (List<LeaveType>) request.getAttribute("leaveTypes");
    String error = (String) request.getAttribute("error");
    String today = LocalDate.now().toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply for Leave - ELMS</title>
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
            <a href="${pageContext.request.contextPath}/employee/dashboard" class="nav-link">
                <span class="nav-icon">&#127968;</span> Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/employee/apply-leave" class="nav-link active">
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
            <h1>&#128221; Apply for Leave</h1>
            <p>Submit a new leave application</p>
        </div>

        <% if (error != null) { %>
            <div class="alert alert-error">&#9888; <%= error %></div>
        <% } %>

        <div class="card" style="max-width:640px;">
            <div class="card-header">
                <h2>Leave Application Form</h2>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/employee/apply-leave"
                      method="post" onsubmit="return validateLeaveForm()">

                    <div class="form-group">
                        <label for="leaveTypeId">Leave Type *</label>
                        <select id="leaveTypeId" name="leaveTypeId">
                            <option value="">-- Select Leave Type --</option>
                            <% if (leaveTypes != null) {
                                for (LeaveType lt : leaveTypes) { %>
                            <option value="<%= lt.getLeaveTypeId() %>"><%= lt.getLeaveTypeName() %></option>
                            <%   }
                               } %>
                        </select>
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label for="startDate">Start Date *</label>
                            <input type="date" id="startDate" name="startDate"
                                   min="<%= today %>" onchange="calculateDays()">
                        </div>
                        <div class="form-group">
                            <label for="endDate">End Date *</label>
                            <input type="date" id="endDate" name="endDate"
                                   min="<%= today %>" onchange="calculateDays()">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Total Days</label>
                        <div id="totalDays" style="padding:12px 16px;background:rgba(99,102,241,.08);
                             border:1px solid var(--border-color);border-radius:var(--radius-sm);
                             color:var(--primary-light);font-weight:600;">
                            -- select dates --
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="reason">Reason *</label>
                        <textarea id="reason" name="reason"
                                  placeholder="Please describe the reason for your leave..."></textarea>
                    </div>

                    <div style="display:flex;gap:12px;margin-top:8px;">
                        <button type="submit" class="btn btn-primary">
                            &#128228; Submit Application
                        </button>
                        <a href="${pageContext.request.contextPath}/employee/dashboard"
                           class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Leave Balance Reminder -->
        <div class="card" style="max-width:640px;">
            <div class="card-header"><h2>&#127796; Your Leave Balance</h2></div>
            <div class="card-body">
                <div class="stats-grid" style="grid-template-columns:repeat(3,1fr);">
                    <div class="stat-card">
                        <div class="stat-icon blue">&#128197;</div>
                        <div class="stat-info"><h3>Annual</h3><div class="stat-value"><%= emp.getAnnualLeave() %></div></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon red">&#129658;</div>
                        <div class="stat-info"><h3>Sick</h3><div class="stat-value"><%= emp.getSickLeave() %></div></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon green">&#127947;</div>
                        <div class="stat-info"><h3>Casual</h3><div class="stat-value"><%= emp.getCasualLeave() %></div></div>
                    </div>
                </div>
            </div>
        </div>

    </main>
</div>
<script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
