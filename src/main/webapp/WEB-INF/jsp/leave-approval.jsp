<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.elms.model.User, com.elms.model.Employee" %>
<%@ page import="com.elms.model.LeaveApplication" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    Employee emp = (Employee) session.getAttribute("employee");
    String role = user.getRoleName();
    boolean isAdmin = "ADMIN".equals(role);
    List<LeaveApplication> pendingLeaves = (List<LeaveApplication>) request.getAttribute("pendingLeaves");
    List<LeaveApplication> allLeaves = (List<LeaveApplication>) request.getAttribute("allLeaves");
    String success = request.getParameter("success");
    String basePath = isAdmin ? "/admin/leave-approval" : "/manager/leave-approval";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave Approvals - ELMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <div class="brand-icon">&#128188;</div>
            <div><h2>ELMS</h2><small><%= isAdmin ? "Admin" : "Manager" %> Panel</small></div>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section-title">Main</div>
            <a href="${pageContext.request.contextPath}/<%= isAdmin ? "admin" : "manager" %>/dashboard" class="nav-link">
                <span class="nav-icon">&#127968;</span> Dashboard
            </a>
            <% if (isAdmin) { %>
            <a href="${pageContext.request.contextPath}/admin/employees" class="nav-link">
                <span class="nav-icon">&#128101;</span> Manage Employees
            </a>
            <% } %>
            <a href="${pageContext.request.contextPath}<%= basePath %>" class="nav-link active">
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
                    <div class="user-role"><%= isAdmin ? "Administrator" : "Manager" %></div>
                </div>
            </div>
        </div>
    </aside>

    <main class="main-content">
        <button class="mobile-menu-btn" onclick="toggleSidebar()">&#9776;</button>
        <div class="page-header">
            <h1>&#9989; Leave Approvals</h1>
            <p>Review and manage leave requests</p>
        </div>

        <% if (success != null) { %>
        <div class="alert alert-success">&#9989; Leave has been <%= success %> successfully.</div>
        <% } %>

        <!-- PENDING LEAVES -->
        <div class="card">
            <div class="card-header">
                <h2>&#9203; Pending Requests (<%= pendingLeaves != null ? pendingLeaves.size() : 0 %>)</h2>
            </div>
            <div class="card-body table-responsive">
                <% if (pendingLeaves != null && !pendingLeaves.isEmpty()) { %>
                <table class="data-table">
                    <thead><tr>
                        <th>Employee</th><th>Dept</th><th>Type</th><th>From</th>
                        <th>To</th><th>Days</th><th>Reason</th><th>Applied On</th><th>Actions</th>
                    </tr></thead>
                    <tbody>
                    <% for (LeaveApplication la : pendingLeaves) { %>
                    <tr>
                        <td><strong><%= la.getEmpName() %></strong></td>
                        <td><%= la.getDeptName() %></td>
                        <td><%= la.getLeaveTypeName() %></td>
                        <td><%= la.getStartDate() %></td>
                        <td><%= la.getEndDate() %></td>
                        <td><%= la.getTotalDays() %></td>
                        <td><%= la.getReason() != null ? la.getReason() : "-" %></td>
                        <td><%= la.getAppliedOn() != null ? la.getAppliedOn().toLocalDate() : "-" %></td>
                        <td>
                            <div class="actions">
                                <button class="btn btn-sm btn-success"
                                        onclick="openReviewModal(<%= la.getLeaveId() %>,'approve')">Approve</button>
                                <button class="btn btn-sm btn-danger"
                                        onclick="openReviewModal(<%= la.getLeaveId() %>,'reject')">Reject</button>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="no-data"><div class="empty-icon">&#127881;</div><p>No pending requests!</p></div>
                <% } %>
            </div>
        </div>

        <!-- ALL LEAVES HISTORY -->
        <div class="card">
            <div class="card-header">
                <h2>&#128203; All Leave History</h2>
            </div>
            <div class="card-body table-responsive">
                <% if (allLeaves != null && !allLeaves.isEmpty()) { %>
                <table class="data-table">
                    <thead><tr>
                        <th>Employee</th><th>Dept</th><th>Type</th><th>From</th>
                        <th>To</th><th>Days</th><th>Status</th><th>Reviewer</th><th>Remarks</th>
                    </tr></thead>
                    <tbody>
                    <% for (LeaveApplication la : allLeaves) { %>
                    <tr>
                        <td><%= la.getEmpName() %></td>
                        <td><%= la.getDeptName() %></td>
                        <td><%= la.getLeaveTypeName() %></td>
                        <td><%= la.getStartDate() %></td>
                        <td><%= la.getEndDate() %></td>
                        <td><%= la.getTotalDays() %></td>
                        <td><span class="badge badge-<%= la.getStatus().toLowerCase() %>"><%= la.getStatus() %></span></td>
                        <td><%= la.getReviewerName() != null ? la.getReviewerName() : "-" %></td>
                        <td><%= la.getManagerRemarks() != null ? la.getManagerRemarks() : "-" %></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="no-data"><div class="empty-icon">&#128196;</div><p>No leave records found</p></div>
                <% } %>
            </div>
        </div>
    </main>
</div>

<!-- REVIEW MODAL -->
<div class="modal-backdrop" id="reviewModal">
    <div class="modal">
        <div class="modal-header">
            <h3 id="reviewTitle">Review Leave</h3>
            <button class="modal-close" onclick="closeModal('reviewModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}<%= basePath %>" method="post">
            <div class="modal-body">
                <input type="hidden" name="leaveId" id="reviewLeaveId">
                <input type="hidden" name="action" id="reviewAction">
                <div class="form-group">
                    <label for="remarks">Remarks / Comments</label>
                    <textarea id="remarks" name="remarks" placeholder="Add your remarks..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('reviewModal')">Cancel</button>
                <button type="submit" class="btn" id="reviewSubmitBtn">Submit</button>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/validation.js"></script>
<script>
function openReviewModal(leaveId, action) {
    document.getElementById('reviewLeaveId').value = leaveId;
    document.getElementById('reviewAction').value = action;
    const btn = document.getElementById('reviewSubmitBtn');
    const title = document.getElementById('reviewTitle');
    if (action === 'approve') {
        title.textContent = '\\u2705 Approve Leave';
        btn.className = 'btn btn-success';
        btn.textContent = 'Approve';
    } else {
        title.textContent = '\\u274C Reject Leave';
        btn.className = 'btn btn-danger';
        btn.textContent = 'Reject';
    }
    openModal('reviewModal');
}
</script>
</body>
</html>
