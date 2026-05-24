package com.elms.model;

import java.time.LocalDate;

/**
 * Represents an employee in the system.
 */
public class Employee {

    private int empId;
    private int userId;
    private String firstName;
    private String lastName;
    private String phone;
    private int deptId;
    private String deptName;
    private Integer managerId;
    private String managerName;
    private String designation;
    private LocalDate joinDate;
    private int annualLeave;
    private int sickLeave;
    private int casualLeave;

    // From joined user table
    private String username;
    private String email;
    private boolean active;

    public Employee() {}

    // Convenience: full name
    public String getFullName() {
        return firstName + " " + lastName;
    }

    // ---------- Getters & Setters ----------

    public int getEmpId() { return empId; }
    public void setEmpId(int empId) { this.empId = empId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public int getDeptId() { return deptId; }
    public void setDeptId(int deptId) { this.deptId = deptId; }

    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }

    public Integer getManagerId() { return managerId; }
    public void setManagerId(Integer managerId) { this.managerId = managerId; }

    public String getManagerName() { return managerName; }
    public void setManagerName(String managerName) { this.managerName = managerName; }

    public String getDesignation() { return designation; }
    public void setDesignation(String designation) { this.designation = designation; }

    public LocalDate getJoinDate() { return joinDate; }
    public void setJoinDate(LocalDate joinDate) { this.joinDate = joinDate; }

    public int getAnnualLeave() { return annualLeave; }
    public void setAnnualLeave(int annualLeave) { this.annualLeave = annualLeave; }

    public int getSickLeave() { return sickLeave; }
    public void setSickLeave(int sickLeave) { this.sickLeave = sickLeave; }

    public int getCasualLeave() { return casualLeave; }
    public void setCasualLeave(int casualLeave) { this.casualLeave = casualLeave; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
