package com.elms.servlet;

import com.elms.dao.EmployeeDAO;
import com.elms.dao.LeaveDAO;
import com.elms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Admin dashboard – shows system-wide stats and all leave applications.
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final EmployeeDAO employeeDAO = new EmployeeDAO();
    private final LeaveDAO    leaveDAO    = new LeaveDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req, resp)) return;

        req.setAttribute("totalEmployees",  employeeDAO.getTotalEmployeeCount());
        req.setAttribute("pendingLeaves",   leaveDAO.countTotalPending());
        req.setAttribute("allLeaves",       leaveDAO.getAllLeaves());
        req.setAttribute("allEmployees",    employeeDAO.getAllEmployees());

        req.getRequestDispatcher("/WEB-INF/jsp/admin-dashboard.jsp").forward(req, resp);
    }

    // ------------------------------------------------------------------ //

    private boolean isAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        User user = (User) session.getAttribute("user");
        if (!"ADMIN".equals(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        return true;
    }
}
