<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.elms.model.User, com.elms.model.Employee" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    User user   = (User) session.getAttribute("user");
    Employee me = (Employee) session.getAttribute("employee");
    List<Employee> employees   = (List<Employee>) request.getAttribute("employees");
    List<Employee> managers    = (List<Employee>) request.getAttribute("managers");
    List<Map<String,Object>> departments = (List<Map<String,Object>>) request.getAttribute("departments");
    Employee editEmp = (Employee) request.getAttribute("editEmployee");
    String success   = request.getParameter("success");
    String errorMsg  = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Employees - ELMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <div class="brand-icon">&#128188;</div>
            <div><h2>ELMS</h2><small>Admin Panel</small></div>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section-title">Main</div>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link">
                <span class="nav-icon">&#127968;</span> Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/admin/employees" class="nav-link active">
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
                    <div class="user-name"><%= me != null ? me.getFullName() : user.getUsername() %></div>
                    <div class="user-role">Administrator</div>
                </div>
            </div>
        </div>
    </aside>

    <main class="main-content">
        <button class="mobile-menu-btn" onclick="toggleSidebar()">&#9776;</button>
        <div class="page-header">
            <h1>&#128101; Manage Employees</h1>
            <p>Add, edit, or remove employee records</p>
        </div>

        <% if (success != null) { %>
        <div class="alert alert-success">&#9989;
            <% if ("added".equals(success))   out.print("Employee added successfully!"); %>
            <% if ("updated".equals(success)) out.print("Employee updated successfully!"); %>
            <% if ("deleted".equals(success)) out.print("Employee deleted successfully!"); %>
        </div>
        <% } %>
        <% if ("userExists".equals(errorMsg)) { %>
        <div class="alert alert-error">&#9888; Username or email already exists.</div>
        <% } %>

        <!-- ADD / EDIT FORM -->
        <div class="card">
            <div class="card-header">
                <h2><%= editEmp != null ? "&#9998; Edit Employee" : "&#43; Add New Employee" %></h2>
                <% if (editEmp != null) { %>
                <a href="${pageContext.request.contextPath}/admin/employees" class="btn btn-sm btn-secondary">Cancel</a>
                <% } %>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/employees" method="post"
                      onsubmit="return validateEmployeeForm()">
                    <input type="hidden" name="action" value="<%= editEmp != null ? "update" : "add" %>">
                    <% if (editEmp != null) { %>
                    <input type="hidden" name="empId" value="<%= editEmp.getEmpId() %>">
                    <% } %>
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="firstName">First Name *</label>
                            <input type="text" id="firstName" name="firstName"
                                   value="<%= editEmp != null ? editEmp.getFirstName() : "" %>" placeholder="First name">
                        </div>
                        <div class="form-group">
                            <label for="lastName">Last Name *</label>
                            <input type="text" id="lastName" name="lastName"
                                   value="<%= editEmp != null ? editEmp.getLastName() : "" %>" placeholder="Last name">
                        </div>
                        <% if (editEmp == null) { %>
                        <div class="form-group">
                            <label for="username">Username *</label>
                            <input type="text" id="username" name="username" placeholder="Login username">
                        </div>
                        <div class="form-group">
                            <label for="password">Password *</label>
                            <input type="password" id="password" name="password" placeholder="Initial password">
                        </div>
                        <div class="form-group">
                            <label for="email">Email *</label>
                            <input type="email" id="email" name="email" placeholder="Email address">
                        </div>
                        <% } %>
                        <div class="form-group">
                            <label for="phone">Phone</label>
                            <input type="text" id="phone" name="phone"
                                   value="<%= editEmp != null && editEmp.getPhone() != null ? editEmp.getPhone() : "" %>"
                                   placeholder="Phone number">
                        </div>
                        <div class="form-group">
                            <label for="designation">Designation *</label>
                            <input type="text" id="designation" name="designation"
                                   value="<%= editEmp != null && editEmp.getDesignation() != null ? editEmp.getDesignation() : "" %>"
                                   placeholder="Job title">
                        </div>
                        <div class="form-group">
                            <label for="deptId">Department *</label>
                            <select id="deptId" name="deptId">
                                <option value="">-- Select --</option>
                                <% if (departments != null) {
                                    for (Map<String,Object> d : departments) {
                                        int did = (int) d.get("deptId");
                                        String dname = (String) d.get("deptName");
                                        boolean sel = editEmp != null && editEmp.getDeptId() == did; %>
                                <option value="<%= did %>" <%= sel ? "selected" : "" %>><%= dname %></option>
                                <%  } } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="managerId">Manager</label>
                            <select id="managerId" name="managerId">
                                <option value="">-- None --</option>
                                <% if (managers != null) {
                                    for (Employee m : managers) {
                                        if (editEmp != null && m.getEmpId() == editEmp.getEmpId()) continue;
                                        boolean sel = editEmp != null && editEmp.getManagerId() != null
                                                      && editEmp.getManagerId() == m.getEmpId(); %>
                                <option value="<%= m.getEmpId() %>" <%= sel ? "selected" : "" %>><%= m.getFullName() %></option>
                                <%  } } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="joinDate">Join Date</label>
                            <input type="date" id="joinDate" name="joinDate"
                                   value="<%= editEmp != null && editEmp.getJoinDate() != null ? editEmp.getJoinDate().toString() : "" %>">
                        </div>
                        <% if (editEmp != null) { %>
                        <div class="form-group">
                            <label for="annualLeave">Annual Leave</label>
                            <input type="number" id="annualLeave" name="annualLeave" min="0" value="<%= editEmp.getAnnualLeave() %>">
                        </div>
                        <div class="form-group">
                            <label for="sickLeave">Sick Leave</label>
                            <input type="number" id="sickLeave" name="sickLeave" min="0" value="<%= editEmp.getSickLeave() %>">
                        </div>
                        <div class="form-group">
                            <label for="casualLeave">Casual Leave</label>
                            <input type="number" id="casualLeave" name="casualLeave" min="0" value="<%= editEmp.getCasualLeave() %>">
                        </div>
                        <% } %>
                    </div>
                    <div style="margin-top:16px;">
                        <button type="submit" class="btn btn-primary">
                            <%= editEmp != null ? "&#128190; Update Employee" : "&#43; Add Employee" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- EMPLOYEE TABLE -->
        <div class="card">
            <div class="card-header">
                <h2>&#128203; All Employees (<%= employees != null ? employees.size() : 0 %>)</h2>
            </div>
            <div class="card-body table-responsive">
                <form id="deleteForm" action="${pageContext.request.contextPath}/admin/employees"
                      method="post" style="display:none;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="empId" id="deleteEmpId">
                </form>
                <% if (employees != null && !employees.isEmpty()) { %>
                <table class="data-table">
                    <thead><tr>
                        <th>#</th><th>Name</th><th>Username</th><th>Designation</th>
                        <th>Department</th><th>Manager</th><th>Email</th><th>Status</th><th>Actions</th>
                    </tr></thead>
                    <tbody>
                    <% int sn = 1; for (Employee e : employees) { %>
                    <tr>
                        <td><%= sn++ %></td>
                        <td><strong><%= e.getFullName() %></strong></td>
                        <td><%= e.getUsername() %></td>
                        <td><%= e.getDesignation() != null ? e.getDesignation() : "-" %></td>
                        <td><%= e.getDeptName() %></td>
                        <td><%= e.getManagerName() != null ? e.getManagerName() : "-" %></td>
                        <td><%= e.getEmail() %></td>
                        <td><span class="badge <%= e.isActive() ? "badge-active" : "badge-inactive" %>">
                            <%= e.isActive() ? "Active" : "Inactive" %></span></td>
                        <td class="actions">
                            <a href="${pageContext.request.contextPath}/admin/employees?action=edit&empId=<%= e.getEmpId() %>"
                               class="btn btn-sm btn-warning">Edit</a>
                            <button class="btn btn-sm btn-danger"
                                    onclick="confirmDelete(<%= e.getEmpId() %>)">Delete</button>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="no-data"><div class="empty-icon">&#128101;</div><p>No employees found</p></div>
                <% } %>
            </div>
        </div>
    </main>
</div>
<script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
