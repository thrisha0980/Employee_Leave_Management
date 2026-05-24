package com.elms.servlet;

import com.elms.dao.EmployeeDAO;
import com.elms.dao.LeaveDAO;
import com.elms.model.Employee;
import com.elms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Manager dashboard – shows team stats and pending leave requests.
 */
@WebServlet("/manager/dashboard")
public class ManagerDashboardServlet extends HttpServlet {

    private final EmployeeDAO employeeDAO = new EmployeeDAO();
    private final LeaveDAO    leaveDAO    = new LeaveDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Employee manager = getManagerOrRedirect(req, resp);
        if (manager == null) return;

        req.setAttribute("teamSize",        employeeDAO.getEmployeesByManager(manager.getEmpId()).size());
        req.setAttribute("pendingCount",    leaveDAO.countPendingForManager(manager.getEmpId()));
        req.setAttribute("pendingLeaves",   leaveDAO.getPendingLeavesByManager(manager.getEmpId()));
        req.setAttribute("allTeamLeaves",   leaveDAO.getAllLeavesByManager(manager.getEmpId()));
        req.setAttribute("teamEmployees",   employeeDAO.getEmployeesByManager(manager.getEmpId()));

        req.getRequestDispatcher("/WEB-INF/jsp/manager-dashboard.jsp").forward(req, resp);
    }

    // ------------------------------------------------------------------ //

    private Employee getManagerOrRedirect(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        User user = (User) session.getAttribute("user");
        if (!"MANAGER".equals(user.getRoleName())) {
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
