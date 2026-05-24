package com.elms.servlet;

import com.elms.dao.LeaveDAO;
import com.elms.model.Employee;
import com.elms.model.LeaveApplication;
import com.elms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

/**
 * Handles leave application submission by employees.
 * GET  /employee/apply-leave  -> show apply form
 * POST /employee/apply-leave  -> submit application
 */
@WebServlet("/employee/apply-leave")
public class LeaveApplicationServlet extends HttpServlet {

    private final LeaveDAO leaveDAO = new LeaveDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Employee emp = getEmployeeOrRedirect(req, resp);
        if (emp == null) return;

        req.setAttribute("leaveTypes", leaveDAO.getAllLeaveTypes());
        req.getRequestDispatcher("/WEB-INF/jsp/apply-leave.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Employee emp = getEmployeeOrRedirect(req, resp);
        if (emp == null) return;

        String leaveTypeIdStr = req.getParameter("leaveTypeId");
        String startDateStr   = req.getParameter("startDate");
        String endDateStr     = req.getParameter("endDate");
        String reason         = req.getParameter("reason");

        // Basic server-side validation
        if (leaveTypeIdStr == null || startDateStr == null || endDateStr == null
                || startDateStr.isBlank() || endDateStr.isBlank()) {
            req.setAttribute("error", "All fields are required.");
            req.setAttribute("leaveTypes", leaveDAO.getAllLeaveTypes());
            req.getRequestDispatcher("/WEB-INF/jsp/apply-leave.jsp").forward(req, resp);
            return;
        }

        LocalDate startDate = LocalDate.parse(startDateStr);
        LocalDate endDate   = LocalDate.parse(endDateStr);

        if (endDate.isBefore(startDate)) {
            req.setAttribute("error", "End date cannot be before start date.");
            req.setAttribute("leaveTypes", leaveDAO.getAllLeaveTypes());
            req.getRequestDispatcher("/WEB-INF/jsp/apply-leave.jsp").forward(req, resp);
            return;
        }

        long totalDays = ChronoUnit.DAYS.between(startDate, endDate) + 1;

        LeaveApplication la = new LeaveApplication();
        la.setEmpId(emp.getEmpId());
        la.setLeaveTypeId(Integer.parseInt(leaveTypeIdStr));
        la.setStartDate(startDate);
        la.setEndDate(endDate);
        la.setTotalDays((int) totalDays);
        la.setReason(reason);

        int leaveId = leaveDAO.applyLeave(la);

        if (leaveId > 0) {
            resp.sendRedirect(req.getContextPath() + "/employee/dashboard?success=applied");
        } else {
            req.setAttribute("error", "Failed to submit leave application. Please try again.");
            req.setAttribute("leaveTypes", leaveDAO.getAllLeaveTypes());
            req.getRequestDispatcher("/WEB-INF/jsp/apply-leave.jsp").forward(req, resp);
        }
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
        return (Employee) session.getAttribute("employee");
    }
}
