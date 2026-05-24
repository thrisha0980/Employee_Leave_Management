package com.elms.dao;

import com.elms.model.Employee;
import com.elms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Employee CRUD operations.
 */
public class EmployeeDAO {

    // ------------------------------------------------------------------ //
    //  READ
    // ------------------------------------------------------------------ //

    /** Returns all employees with joined department and manager info. */
    public List<Employee> getAllEmployees() {
        List<Employee> list = new ArrayList<>();
        String sql = "SELECT e.emp_id, e.user_id, e.first_name, e.last_name, e.phone, " +
                     "e.dept_id, d.dept_name, e.manager_id, " +
                     "CONCAT(m.first_name,' ',m.last_name) AS manager_name, " +
                     "e.designation, e.join_date, e.annual_leave, e.sick_leave, e.casual_leave, " +
                     "u.username, u.email, u.is_active " +
                     "FROM employees e " +
                     "JOIN departments d  ON e.dept_id  = d.dept_id " +
                     "JOIN users u        ON e.user_id  = u.user_id " +
                     "LEFT JOIN employees m ON e.manager_id = m.emp_id " +
                     "ORDER BY e.emp_id";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(mapRow(rs));

        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** Returns employees under a specific manager (by emp_id). */
    public List<Employee> getEmployeesByManager(int managerEmpId) {
        List<Employee> list = new ArrayList<>();
        String sql = "SELECT e.emp_id, e.user_id, e.first_name, e.last_name, e.phone, " +
                     "e.dept_id, d.dept_name, e.manager_id, " +
                     "CONCAT(m.first_name,' ',m.last_name) AS manager_name, " +
                     "e.designation, e.join_date, e.annual_leave, e.sick_leave, e.casual_leave, " +
                     "u.username, u.email, u.is_active " +
                     "FROM employees e " +
                     "JOIN departments d  ON e.dept_id  = d.dept_id " +
                     "JOIN users u        ON e.user_id  = u.user_id " +
                     "LEFT JOIN employees m ON e.manager_id = m.emp_id " +
                     "WHERE e.manager_id = ? " +
                     "ORDER BY e.first_name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, managerEmpId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** Returns a single employee by emp_id. */
    public Employee getEmployeeById(int empId) {
        String sql = "SELECT e.emp_id, e.user_id, e.first_name, e.last_name, e.phone, " +
                     "e.dept_id, d.dept_name, e.manager_id, " +
                     "CONCAT(m.first_name,' ',m.last_name) AS manager_name, " +
                     "e.designation, e.join_date, e.annual_leave, e.sick_leave, e.casual_leave, " +
                     "u.username, u.email, u.is_active " +
                     "FROM employees e " +
                     "JOIN departments d  ON e.dept_id  = d.dept_id " +
                     "JOIN users u        ON e.user_id  = u.user_id " +
                     "LEFT JOIN employees m ON e.manager_id = m.emp_id " +
                     "WHERE e.emp_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, empId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    /** Returns the Employee record linked to a user_id. */
    public Employee getEmployeeByUserId(int userId) {
        String sql = "SELECT e.emp_id, e.user_id, e.first_name, e.last_name, e.phone, " +
                     "e.dept_id, d.dept_name, e.manager_id, " +
                     "CONCAT(m.first_name,' ',m.last_name) AS manager_name, " +
                     "e.designation, e.join_date, e.annual_leave, e.sick_leave, e.casual_leave, " +
                     "u.username, u.email, u.is_active " +
                     "FROM employees e " +
                     "JOIN departments d  ON e.dept_id  = d.dept_id " +
                     "JOIN users u        ON e.user_id  = u.user_id " +
                     "LEFT JOIN employees m ON e.manager_id = m.emp_id " +
                     "WHERE e.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    /** Returns count of total employees (excluding admin). */
    public int getTotalEmployeeCount() {
        String sql = "SELECT COUNT(*) FROM employees e JOIN users u ON e.user_id=u.user_id " +
                     "JOIN roles r ON u.role_id=r.role_id WHERE r.role_name='EMPLOYEE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ------------------------------------------------------------------ //
    //  CREATE
    // ------------------------------------------------------------------ //

    /**
     * Inserts a new employee record. Returns the generated emp_id, or -1.
     */
    public int addEmployee(Employee emp) {
        String sql = "INSERT INTO employees " +
                     "(user_id, first_name, last_name, phone, dept_id, manager_id, " +
                     " designation, join_date, annual_leave, sick_leave, casual_leave) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, emp.getUserId());
            ps.setString(2, emp.getFirstName());
            ps.setString(3, emp.getLastName());
            ps.setString(4, emp.getPhone());
            ps.setInt(5, emp.getDeptId());
            if (emp.getManagerId() != null) ps.setInt(6, emp.getManagerId());
            else                             ps.setNull(6, Types.INTEGER);
            ps.setString(7, emp.getDesignation());
            ps.setDate(8, emp.getJoinDate() != null ? Date.valueOf(emp.getJoinDate()) : null);
            ps.setInt(9, emp.getAnnualLeave());
            ps.setInt(10, emp.getSickLeave());
            ps.setInt(11, emp.getCasualLeave());
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    // ------------------------------------------------------------------ //
    //  UPDATE
    // ------------------------------------------------------------------ //

    public boolean updateEmployee(Employee emp) {
        String sql = "UPDATE employees SET first_name=?, last_name=?, phone=?, dept_id=?, " +
                     "manager_id=?, designation=?, join_date=?, annual_leave=?, sick_leave=?, " +
                     "casual_leave=? WHERE emp_id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, emp.getFirstName());
            ps.setString(2, emp.getLastName());
            ps.setString(3, emp.getPhone());
            ps.setInt(4, emp.getDeptId());
            if (emp.getManagerId() != null) ps.setInt(5, emp.getManagerId());
            else                             ps.setNull(5, Types.INTEGER);
            ps.setString(6, emp.getDesignation());
            ps.setDate(7, emp.getJoinDate() != null ? Date.valueOf(emp.getJoinDate()) : null);
            ps.setInt(8, emp.getAnnualLeave());
            ps.setInt(9, emp.getSickLeave());
            ps.setInt(10, emp.getCasualLeave());
            ps.setInt(11, emp.getEmpId());
            return ps.executeUpdate() > 0;

        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ------------------------------------------------------------------ //
    //  DELETE
    // ------------------------------------------------------------------ //

    public boolean deleteEmployee(int empId) {
        String getUserSql     = "SELECT user_id FROM employees WHERE emp_id = ?";
        String delLeavesSql   = "DELETE FROM leave_applications WHERE emp_id = ?";
        String clearMgrSql    = "UPDATE employees SET manager_id = NULL WHERE manager_id = ?";
        String clearReviewSql = "UPDATE leave_applications SET reviewed_by = NULL WHERE reviewed_by = ?";
        String delEmpSql      = "DELETE FROM employees WHERE emp_id = ?";
        String delUserSql     = "DELETE FROM users WHERE user_id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            int userId = -1;

            try (PreparedStatement ps = conn.prepareStatement(getUserSql)) {
                ps.setInt(1, empId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) userId = rs.getInt("user_id");
                }
            }

            // Remove leave applications for this employee
            try (PreparedStatement ps = conn.prepareStatement(delLeavesSql)) {
                ps.setInt(1, empId);
                ps.executeUpdate();
            }

            // Clear this employee as reviewer on other leave records
            try (PreparedStatement ps = conn.prepareStatement(clearReviewSql)) {
                ps.setInt(1, empId);
                ps.executeUpdate();
            }

            // Clear this employee as manager for other employees
            try (PreparedStatement ps = conn.prepareStatement(clearMgrSql)) {
                ps.setInt(1, empId);
                ps.executeUpdate();
            }

            // Delete employee record
            try (PreparedStatement ps = conn.prepareStatement(delEmpSql)) {
                ps.setInt(1, empId);
                ps.executeUpdate();
            }

            // Delete user account
            if (userId != -1) {
                try (PreparedStatement ps = conn.prepareStatement(delUserSql)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        return false;
    }

    // ------------------------------------------------------------------ //
    //  HELPER: map ResultSet row to Employee
    // ------------------------------------------------------------------ //

    private Employee mapRow(ResultSet rs) throws SQLException {
        Employee e = new Employee();
        e.setEmpId(rs.getInt("emp_id"));
        e.setUserId(rs.getInt("user_id"));
        e.setFirstName(rs.getString("first_name"));
        e.setLastName(rs.getString("last_name"));
        e.setPhone(rs.getString("phone"));
        e.setDeptId(rs.getInt("dept_id"));
        e.setDeptName(rs.getString("dept_name"));
        int mgr = rs.getInt("manager_id");
        e.setManagerId(rs.wasNull() ? null : mgr);
        e.setManagerName(rs.getString("manager_name"));
        e.setDesignation(rs.getString("designation"));
        Date jd = rs.getDate("join_date");
        e.setJoinDate(jd != null ? jd.toLocalDate() : null);
        e.setAnnualLeave(rs.getInt("annual_leave"));
        e.setSickLeave(rs.getInt("sick_leave"));
        e.setCasualLeave(rs.getInt("casual_leave"));
        e.setUsername(rs.getString("username"));
        e.setEmail(rs.getString("email"));
        e.setActive(rs.getBoolean("is_active"));
        return e;
    }
}
