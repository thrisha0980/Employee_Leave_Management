package com.elms.servlet;

import com.elms.dao.EmployeeDAO;
import com.elms.dao.UserDAO;
import com.elms.model.Employee;
import com.elms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Handles user login. Maps to /login
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final EmployeeDAO employeeDAO = new EmployeeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // If already logged in, redirect to appropriate dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            redirectToDashboard((User) session.getAttribute("user"), req.getContextPath(), resp);
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Username and password are required.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.authenticate(username.trim(), password);

        if (user == null) {
            req.setAttribute("error", "Invalid credentials or account disabled.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // Fetch employee profile linked to user
        Employee employee = employeeDAO.getEmployeeByUserId(user.getUserId());

        // Create new session
        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("employee", employee);
        session.setMaxInactiveInterval(30 * 60); // 30 minutes

        redirectToDashboard(user, req.getContextPath(), resp);
    }

    private void redirectToDashboard(User user, String ctx, HttpServletResponse resp) throws IOException {
        switch (user.getRoleName()) {
            case "ADMIN"    -> resp.sendRedirect(ctx + "/admin/dashboard");
            case "MANAGER"  -> resp.sendRedirect(ctx + "/manager/dashboard");
            default         -> resp.sendRedirect(ctx + "/employee/dashboard");
        }
    }
}
