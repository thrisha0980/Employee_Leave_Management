package com.elms.servlet;

import com.elms.dao.EmployeeDAO;
import com.elms.dao.UserDAO;
import com.elms.model.Employee;
import com.elms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;

/**
 * Handles Employee CRUD (Admin only).
 * GET  /admin/employees          -> list all employees
 * GET  /admin/employees?action=edit&empId=X -> show edit form
 * POST /admin/employees?action=add    -> create new employee
 * POST /admin/employees?action=update -> update existing employee
 * POST /admin/employees?action=delete -> delete employee
 */
@WebServlet("/admin/employees")
public class EmployeeCRUDServlet extends HttpServlet {

    private final EmployeeDAO employeeDAO = new EmployeeDAO();
    private final UserDAO     userDAO     = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req, resp)) return;

        String action = req.getParameter("action");

        if ("edit".equals(action)) {
            int empId = Integer.parseInt(req.getParameter("empId"));
            req.setAttribute("editEmployee", employeeDAO.getEmployeeById(empId));
        }

        req.setAttribute("employees",    employeeDAO.getAllEmployees());
        req.setAttribute("managers",     getManagerList());
        req.setAttribute("departments",  getDepartmentList(req));
        req.getRequestDispatcher("/WEB-INF/jsp/manage-employees.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req, resp)) return;

        String action = req.getParameter("action");

        switch (action == null ? "" : action) {
            case "add"    -> addEmployee(req, resp);
            case "update" -> updateEmployee(req, resp);
            case "delete" -> deleteEmployee(req, resp);
            default       -> resp.sendRedirect(req.getContextPath() + "/admin/employees");
        }
    }

    // ------------------------------------------------------------------ //

    private void addEmployee(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username    = req.getParameter("username");
        String password    = req.getParameter("password");
        String email       = req.getParameter("email");
        String firstName   = req.getParameter("firstName");
        String lastName    = req.getParameter("lastName");
        String phone       = req.getParameter("phone");
        int    deptId      = Integer.parseInt(req.getParameter("deptId"));
        String mgrIdStr    = req.getParameter("managerId");
        String designation = req.getParameter("designation");
        String joinDateStr = req.getParameter("joinDate");

        // Create user account first
        int userId = userDAO.createUser(username, password, email, 3); // role 3 = EMPLOYEE
        if (userId == -1) {
            resp.sendRedirect(req.getContextPath() + "/admin/employees?error=userExists");
            return;
        }

        Employee emp = new Employee();
        emp.setUserId(userId);
        emp.setFirstName(firstName);
        emp.setLastName(lastName);
        emp.setPhone(phone);
        emp.setDeptId(deptId);
        emp.setManagerId(mgrIdStr != null && !mgrIdStr.isBlank() ? Integer.parseInt(mgrIdStr) : null);
        emp.setDesignation(designation);
        emp.setJoinDate(joinDateStr != null && !joinDateStr.isBlank() ? LocalDate.parse(joinDateStr) : LocalDate.now());
        emp.setAnnualLeave(20);
        emp.setSickLeave(10);
        emp.setCasualLeave(5);

        employeeDAO.addEmployee(emp);
        resp.sendRedirect(req.getContextPath() + "/admin/employees?success=added");
    }

    private void updateEmployee(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int    empId       = Integer.parseInt(req.getParameter("empId"));
        String firstName   = req.getParameter("firstName");
        String lastName    = req.getParameter("lastName");
        String phone       = req.getParameter("phone");
        int    deptId      = Integer.parseInt(req.getParameter("deptId"));
        String mgrIdStr    = req.getParameter("managerId");
        String designation = req.getParameter("designation");
        String joinDateStr = req.getParameter("joinDate");
        int    annual      = Integer.parseInt(req.getParameter("annualLeave"));
        int    sick        = Integer.parseInt(req.getParameter("sickLeave"));
        int    casual      = Integer.parseInt(req.getParameter("casualLeave"));

        Employee emp = new Employee();
        emp.setEmpId(empId);
        emp.setFirstName(firstName);
        emp.setLastName(lastName);
        emp.setPhone(phone);
        emp.setDeptId(deptId);
        emp.setManagerId(mgrIdStr != null && !mgrIdStr.isBlank() ? Integer.parseInt(mgrIdStr) : null);
        emp.setDesignation(designation);
        emp.setJoinDate(joinDateStr != null && !joinDateStr.isBlank() ? LocalDate.parse(joinDateStr) : null);
        emp.setAnnualLeave(annual);
        emp.setSickLeave(sick);
        emp.setCasualLeave(casual);

        employeeDAO.updateEmployee(emp);
        resp.sendRedirect(req.getContextPath() + "/admin/employees?success=updated");
    }

    private void deleteEmployee(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int empId = Integer.parseInt(req.getParameter("empId"));
        employeeDAO.deleteEmployee(empId);
        resp.sendRedirect(req.getContextPath() + "/admin/employees?success=deleted");
    }

    // ------------------------------------------------------------------ //

    /** Returns all employees who are managers (role_id=2). */
    private java.util.List<Employee> getManagerList() {
        // Re-use EmployeeDAO; filter by role in query is not in DAO,
        // so we return all and let the JSP filter, or fetch directly.
        // For simplicity, we return all employees as potential managers.
        return employeeDAO.getAllEmployees();
    }

    /** Fetch departments using a quick inline query via DBConnection. */
    private java.util.List<java.util.Map<String, Object>> getDepartmentList(HttpServletRequest req) {
        java.util.List<java.util.Map<String, Object>> depts = new java.util.ArrayList<>();
        String sql = "SELECT dept_id, dept_name FROM departments ORDER BY dept_name";
        try (java.sql.Connection conn = com.elms.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                m.put("deptId",   rs.getInt("dept_id"));
                m.put("deptName", rs.getString("dept_name"));
                depts.add(m);
            }
        } catch (java.sql.SQLException e) { e.printStackTrace(); }
        return depts;
    }

    private boolean isAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
