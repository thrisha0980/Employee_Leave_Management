package com.elms.dao;

import com.elms.model.LeaveApplication;
import com.elms.model.LeaveType;
import com.elms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Leave Applications and Leave Types.
 */
public class LeaveDAO {

    // ------------------------------------------------------------------ //
    //  LEAVE TYPES
    // ------------------------------------------------------------------ //

    public List<LeaveType> getAllLeaveTypes() {
        List<LeaveType> list = new ArrayList<>();
        String sql = "SELECT leave_type_id, leave_type_name, description FROM leave_types ORDER BY leave_type_id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new LeaveType(
                        rs.getInt("leave_type_id"),
                        rs.getString("leave_type_name"),
                        rs.getString("description")));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ------------------------------------------------------------------ //
    //  APPLY FOR LEAVE
    // ------------------------------------------------------------------ //

    /**
     * Submits a new leave application. Returns generated leave_id or -1.
     */
    public int applyLeave(LeaveApplication la) {
        String sql = "INSERT INTO leave_applications " +
                     "(emp_id, leave_type_id, start_date, end_date, total_days, reason) " +
                     "VALUES (?,?,?,?,?,?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, la.getEmpId());
            ps.setInt(2, la.getLeaveTypeId());
            ps.setDate(3, Date.valueOf(la.getStartDate()));
            ps.setDate(4, Date.valueOf(la.getEndDate()));
            ps.setInt(5, la.getTotalDays());
            ps.setString(6, la.getReason());
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    // ------------------------------------------------------------------ //
    //  FETCH: employee's own history
    // ------------------------------------------------------------------ //

    public List<LeaveApplication> getLeavesByEmployee(int empId) {
        String sql = buildSelectBase() +
                     "WHERE la.emp_id = ? ORDER BY la.applied_on DESC";
        return fetchList(sql, empId);
    }

    // ------------------------------------------------------------------ //
    //  FETCH: pending leaves for manager's team
    // ------------------------------------------------------------------ //

    public List<LeaveApplication> getPendingLeavesByManager(int managerEmpId) {
        String sql = buildSelectBase() +
                     "WHERE e.manager_id = ? AND la.status = 'PENDING' " +
                     "ORDER BY la.applied_on ASC";
        return fetchList(sql, managerEmpId);
    }

    public List<LeaveApplication> getAllLeavesByManager(int managerEmpId) {
        String sql = buildSelectBase() +
                     "WHERE e.manager_id = ? ORDER BY la.applied_on DESC";
        return fetchList(sql, managerEmpId);
    }

    // ------------------------------------------------------------------ //
    //  FETCH: all leaves (admin)
    // ------------------------------------------------------------------ //

    public List<LeaveApplication> getAllLeaves() {
        String sql = buildSelectBase() + "ORDER BY la.applied_on DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<LeaveApplication> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        } catch (SQLException e) { e.printStackTrace(); }
        return new ArrayList<>();
    }

    public List<LeaveApplication> getPendingLeaves() {
        String sql = buildSelectBase() +
                     "WHERE la.status = 'PENDING' ORDER BY la.applied_on ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<LeaveApplication> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        } catch (SQLException e) { e.printStackTrace(); }
        return new ArrayList<>();
    }

    // ------------------------------------------------------------------ //
    //  APPROVE / REJECT
    // ------------------------------------------------------------------ //

    public boolean reviewLeave(int leaveId, int reviewerEmpId, String status, String remarks) {
        String sql = "UPDATE leave_applications " +
                     "SET status=?, reviewed_by=?, reviewed_on=NOW(), manager_remarks=? " +
                     "WHERE leave_id=? AND status='PENDING'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, reviewerEmpId);
            ps.setString(3, remarks);
            ps.setInt(4, leaveId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ------------------------------------------------------------------ //
    //  COUNTS for dashboard
    // ------------------------------------------------------------------ //

    public int countByStatusForEmployee(int empId, String status) {
        String sql = "SELECT COUNT(*) FROM leave_applications WHERE emp_id=? AND status=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, empId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int countPendingForManager(int managerEmpId) {
        String sql = "SELECT COUNT(*) FROM leave_applications la " +
                     "JOIN employees e ON la.emp_id=e.emp_id " +
                     "WHERE e.manager_id=? AND la.status='PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerEmpId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int countTotalPending() {
        String sql = "SELECT COUNT(*) FROM leave_applications WHERE status='PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ------------------------------------------------------------------ //
    //  PRIVATE HELPERS
    // ------------------------------------------------------------------ //

    private String buildSelectBase() {
        return "SELECT la.leave_id, la.emp_id, " +
               "CONCAT(e.first_name,' ',e.last_name) AS emp_name, d.dept_name, " +
               "la.leave_type_id, lt.leave_type_name, " +
               "la.start_date, la.end_date, la.total_days, la.reason, " +
               "la.status, la.applied_on, la.reviewed_by, " +
               "CONCAT(rv.first_name,' ',rv.last_name) AS reviewer_name, " +
               "la.reviewed_on, la.manager_remarks " +
               "FROM leave_applications la " +
               "JOIN employees e   ON la.emp_id      = e.emp_id " +
               "JOIN departments d ON e.dept_id       = d.dept_id " +
               "JOIN leave_types lt ON la.leave_type_id = lt.leave_type_id " +
               "LEFT JOIN employees rv ON la.reviewed_by = rv.emp_id ";
    }

    private List<LeaveApplication> fetchList(String sql, int param) {
        List<LeaveApplication> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    private LeaveApplication mapRow(ResultSet rs) throws SQLException {
        LeaveApplication la = new LeaveApplication();
        la.setLeaveId(rs.getInt("leave_id"));
        la.setEmpId(rs.getInt("emp_id"));
        la.setEmpName(rs.getString("emp_name"));
        la.setDeptName(rs.getString("dept_name"));
        la.setLeaveTypeId(rs.getInt("leave_type_id"));
        la.setLeaveTypeName(rs.getString("leave_type_name"));
        la.setStartDate(rs.getDate("start_date").toLocalDate());
        la.setEndDate(rs.getDate("end_date").toLocalDate());
        la.setTotalDays(rs.getInt("total_days"));
        la.setReason(rs.getString("reason"));
        la.setStatus(rs.getString("status"));
        Timestamp appliedOn = rs.getTimestamp("applied_on");
        if (appliedOn != null) la.setAppliedOn(appliedOn.toLocalDateTime());
        int reviewedBy = rs.getInt("reviewed_by");
        la.setReviewedBy(rs.wasNull() ? null : reviewedBy);
        la.setReviewerName(rs.getString("reviewer_name"));
        Timestamp reviewedOn = rs.getTimestamp("reviewed_on");
        if (reviewedOn != null) la.setReviewedOn(reviewedOn.toLocalDateTime());
        la.setManagerRemarks(rs.getString("manager_remarks"));
        return la;
    }
}
