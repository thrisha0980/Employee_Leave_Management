package com.elms.servlet;

import com.elms.dao.LeaveDAO;
import com.elms.model.Employee;
import com.elms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Handles leave approval/rejection by managers.
 * GET  /manager/leave-approval  -> show pending leaves for manager's team
 * POST /manager/leave-approval  -> approve or reject a leave
 *
 * Also handles admin leave approval:
 * GET  /admin/leave-approval
 * POST /admin/leave-approval
 */
@WebServlet({"/manager/leave-approval", "/admin/leave-approval"})
public class LeaveApprovalServlet extends HttpServlet {

    private final LeaveDAO leaveDAO = new LeaveDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role = getRole(req, resp);
        if (role == null) return;

        Employee reviewer = (Employee) req.getSession(false).getAttribute("employee");

        if ("ADMIN".equals(role)) {
            req.setAttribute("pendingLeaves", leaveDAO.getPendingLeaves());
            req.setAttribute("allLeaves",     leaveDAO.getAllLeaves());
        } else {
            req.setAttribute("pendingLeaves", leaveDAO.getPendingLeavesByManager(reviewer.getEmpId()));
            req.setAttribute("allLeaves",     leaveDAO.getAllLeavesByManager(reviewer.getEmpId()));
        }

        req.getRequestDispatcher("/WEB-INF/jsp/leave-approval.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role = getRole(req, resp);
        if (role == null) return;

        int    leaveId  = Integer.parseInt(req.getParameter("leaveId"));
        String action   = req.getParameter("action"); // "approve" or "reject"
        String remarks  = req.getParameter("remarks");

        Employee reviewer = (Employee) req.getSession(false).getAttribute("employee");
        String   status   = "approve".equalsIgnoreCase(action) ? "APPROVED" : "REJECTED";

        leaveDAO.reviewLeave(leaveId, reviewer.getEmpId(), status, remarks);

        String redirectBase = "ADMIN".equals(role)
                ? req.getContextPath() + "/admin/leave-approval"
                : req.getContextPath() + "/manager/leave-approval";

        resp.sendRedirect(redirectBase + "?success=" + status.toLowerCase());
    }

    // ------------------------------------------------------------------ //

    private String getRole(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        User user = (User) session.getAttribute("user");
        String role = user.getRoleName();
        if (!"ADMIN".equals(role) && !"MANAGER".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return role;
    }
}
