package com.elms.servlet;

import com.elms.dao.LeaveDAO;
import com.elms.model.Employee;
import com.elms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Employee dashboard – shows own leave summary and history.
 */
@WebServlet("/employee/dashboard")
public class EmployeeDashboardServlet extends HttpServlet {

    private final LeaveDAO leaveDAO = new LeaveDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Employee emp = getEmployeeOrRedirect(req, resp);
        if (emp == null) return;

        req.setAttribute("pendingCount",  leaveDAO.countByStatusForEmployee(emp.getEmpId(), "PENDING"));
        req.setAttribute("approvedCount", leaveDAO.countByStatusForEmployee(emp.getEmpId(), "APPROVED"));
        req.setAttribute("rejectedCount", leaveDAO.countByStatusForEmployee(emp.getEmpId(), "REJECTED"));
        req.setAttribute("leaveHistory",  leaveDAO.getLeavesByEmployee(emp.getEmpId()));
        req.setAttribute("leaveTypes",    leaveDAO.getAllLeaveTypes());

        req.getRequestDispatcher("/WEB-INF/jsp/employee-dashboard.jsp").forward(req, resp);
    }

    // ------------------------------------------------------------------ //

    private Employee getEmployeeOrRedirect(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        User user = (User) session.getAttribute("user");
        if (!"EMPLOYEE".equals(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        Employee emp = (Employee) session.getAttribute("employee");
        if (emp == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return emp;
    }
}
