package com.elms.model;

/**
 * Represents a leave type (Annual, Sick, Casual, etc.).
 */
public class LeaveType {

    private int leaveTypeId;
    private String leaveTypeName;
    private String description;

    public LeaveType() {}

    public LeaveType(int leaveTypeId, String leaveTypeName, String description) {
        this.leaveTypeId = leaveTypeId;
        this.leaveTypeName = leaveTypeName;
        this.description = description;
    }

    // ---------- Getters & Setters ----------

    public int getLeaveTypeId() { return leaveTypeId; }
    public void setLeaveTypeId(int leaveTypeId) { this.leaveTypeId = leaveTypeId; }

    public String getLeaveTypeName() { return leaveTypeName; }
    public void setLeaveTypeName(String leaveTypeName) { this.leaveTypeName = leaveTypeName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
