-- ============================================================
-- Employee Leave Management System - Database Schema
-- Database: employee_leave_management
-- ============================================================

CREATE DATABASE IF NOT EXISTS employee_leave_management
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE employee_leave_management;

-- ============================================================
-- Table: roles
-- ============================================================
CREATE TABLE IF NOT EXISTS roles (
    role_id   INT          NOT NULL AUTO_INCREMENT,
    role_name VARCHAR(50)  NOT NULL UNIQUE,
    PRIMARY KEY (role_id)
) ENGINE=InnoDB;

INSERT INTO roles (role_name) VALUES ('ADMIN'), ('MANAGER'), ('EMPLOYEE');

-- ============================================================
-- Table: departments
-- ============================================================
CREATE TABLE IF NOT EXISTS departments (
    dept_id   INT          NOT NULL AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (dept_id)
) ENGINE=InnoDB;

INSERT INTO departments (dept_name) VALUES
    ('Engineering'),
    ('Human Resources'),
    ('Finance'),
    ('Marketing'),
    ('Operations');

-- ============================================================
-- Table: users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    user_id       INT          NOT NULL AUTO_INCREMENT,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    role_id       INT          NOT NULL,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
) ENGINE=InnoDB;

-- ============================================================
-- Table: employees
-- ============================================================
CREATE TABLE IF NOT EXISTS employees (
    emp_id        INT          NOT NULL AUTO_INCREMENT,
    user_id       INT          NOT NULL UNIQUE,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    phone         VARCHAR(20),
    dept_id       INT          NOT NULL,
    manager_id    INT,                         -- references employees.emp_id
    designation   VARCHAR(100),
    join_date     DATE,
    annual_leave  INT          NOT NULL DEFAULT 20,
    sick_leave    INT          NOT NULL DEFAULT 10,
    casual_leave  INT          NOT NULL DEFAULT 5,
    PRIMARY KEY (emp_id),
    FOREIGN KEY (user_id)    REFERENCES users(user_id),
    FOREIGN KEY (dept_id)    REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
) ENGINE=InnoDB;

-- ============================================================
-- Table: leave_types
-- ============================================================
CREATE TABLE IF NOT EXISTS leave_types (
    leave_type_id   INT         NOT NULL AUTO_INCREMENT,
    leave_type_name VARCHAR(50) NOT NULL UNIQUE,
    description     VARCHAR(255),
    PRIMARY KEY (leave_type_id)
) ENGINE=InnoDB;

INSERT INTO leave_types (leave_type_name, description) VALUES
    ('Annual Leave',  'Yearly paid leave entitlement'),
    ('Sick Leave',    'Leave due to illness or medical reasons'),
    ('Casual Leave',  'Short-notice leave for personal matters'),
    ('Maternity Leave','Leave for maternity purposes'),
    ('Paternity Leave','Leave for paternity purposes'),
    ('Unpaid Leave',  'Leave without pay');

-- ============================================================
-- Table: leave_applications
-- ============================================================
CREATE TABLE IF NOT EXISTS leave_applications (
    leave_id        INT          NOT NULL AUTO_INCREMENT,
    emp_id          INT          NOT NULL,
    leave_type_id   INT          NOT NULL,
    start_date      DATE         NOT NULL,
    end_date        DATE         NOT NULL,
    total_days      INT          NOT NULL,
    reason          TEXT,
    status          ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
    applied_on      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_by     INT,                         -- references employees.emp_id (manager)
    reviewed_on     DATETIME,
    manager_remarks TEXT,
    PRIMARY KEY (leave_id),
    FOREIGN KEY (emp_id)        REFERENCES employees(emp_id),
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(leave_type_id),
    FOREIGN KEY (reviewed_by)   REFERENCES employees(emp_id)
) ENGINE=InnoDB;

-- ============================================================
-- SAMPLE DATA
-- Passwords: All users have password "Password@123"
-- BCrypt hash of "Password@123":
-- $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
-- ============================================================

-- Admin user
INSERT INTO users (username, password_hash, email, role_id) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin@elms.com', 1);

-- Manager users
INSERT INTO users (username, password_hash, email, role_id) VALUES
('mgr_eng',  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'mgr.eng@elms.com',  2),
('mgr_hr',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'mgr.hr@elms.com',   2),
('mgr_fin',  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'mgr.fin@elms.com',  2);

-- Employee users (16 employees)
INSERT INTO users (username, password_hash, email, role_id) VALUES
('emp_alice',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'alice@elms.com',   3),
('emp_bob',     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'bob@elms.com',     3),
('emp_carol',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'carol@elms.com',   3),
('emp_david',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'david@elms.com',   3),
('emp_eve',     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'eve@elms.com',     3),
('emp_frank',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'frank@elms.com',   3),
('emp_grace',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'grace@elms.com',   3),
('emp_hank',    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'hank@elms.com',    3),
('emp_iris',    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'iris@elms.com',    3),
('emp_jack',    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'jack@elms.com',    3),
('emp_karen',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'karen@elms.com',   3),
('emp_leo',     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'leo@elms.com',     3),
('emp_mia',     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'mia@elms.com',     3),
('emp_noah',    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'noah@elms.com',    3),
('emp_olivia',  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'olivia@elms.com',  3),
('emp_peter',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'peter@elms.com',   3);

-- Admin employee record (user_id=1)
INSERT INTO employees (user_id, first_name, last_name, phone, dept_id, manager_id, designation, join_date) VALUES
(1, 'System', 'Admin', '9000000000', 2, NULL, 'System Administrator', '2020-01-01');

-- Manager employee records (user_id 2,3,4)
INSERT INTO employees (user_id, first_name, last_name, phone, dept_id, manager_id, designation, join_date) VALUES
(2, 'Robert',  'Wilson',  '9111111111', 1, NULL, 'Engineering Manager',  '2019-03-15'),
(3, 'Sandra',  'Lee',     '9222222222', 2, NULL, 'HR Manager',           '2018-07-01'),
(4, 'Thomas',  'Brown',   '9333333333', 3, NULL, 'Finance Manager',      '2017-11-20');

-- Employee records (user_id 5-20, manager_id references emp_id of managers: eng=2, hr=3, fin=4)
INSERT INTO employees (user_id, first_name, last_name, phone, dept_id, manager_id, designation, join_date) VALUES
(5,  'Alice',   'Johnson',  '9401010101', 1, 2, 'Senior Developer',    '2021-06-01'),
(6,  'Bob',     'Smith',    '9402020202', 1, 2, 'Backend Developer',   '2022-01-10'),
(7,  'Carol',   'Davis',    '9403030303', 1, 2, 'Frontend Developer',  '2022-03-15'),
(8,  'David',   'Martinez', '9404040404', 1, 2, 'DevOps Engineer',     '2021-09-01'),
(9,  'Eve',     'Garcia',   '9405050505', 1, 2, 'QA Engineer',         '2023-02-01'),
(10, 'Frank',   'Taylor',   '9406060606', 2, 3, 'HR Executive',        '2020-08-01'),
(11, 'Grace',   'Anderson', '9407070707', 2, 3, 'Recruiter',           '2021-04-10'),
(12, 'Hank',    'Thomas',   '9408080808', 3, 4, 'Senior Accountant',   '2019-12-01'),
(13, 'Iris',    'Jackson',  '9409090909', 3, 4, 'Financial Analyst',   '2022-07-15'),
(14, 'Jack',    'White',    '9410101010', 4, 3, 'Marketing Executive', '2023-01-05'),
(15, 'Karen',   'Harris',   '9411111111', 4, 3, 'Content Writer',      '2022-11-20'),
(16, 'Leo',     'Clark',    '9412121212', 5, 3, 'Operations Analyst',  '2021-03-01'),
(17, 'Mia',     'Lewis',    '9413131313', 5, 3, 'Logistics Coordinator','2022-06-01'),
(18, 'Noah',    'Robinson', '9414141414', 1, 2, 'Junior Developer',    '2024-01-15'),
(19, 'Olivia',  'Walker',   '9415151515', 2, 3, 'HR Coordinator',      '2023-08-01'),
(20, 'Peter',   'Hall',     '9416161616', 3, 4, 'Accounts Executive',  '2023-05-10');

-- Sample leave applications
INSERT INTO leave_applications (emp_id, leave_type_id, start_date, end_date, total_days, reason, status, reviewed_by, reviewed_on, manager_remarks) VALUES
(5,  1, '2025-01-06', '2025-01-10', 5,  'Annual vacation',                'APPROVED', 2, '2025-01-04 10:00:00', 'Approved. Enjoy your vacation.'),
(6,  2, '2025-02-03', '2025-02-05', 3,  'Fever and cold',                 'APPROVED', 2, '2025-02-03 09:00:00', 'Get well soon.'),
(7,  3, '2025-03-17', '2025-03-17', 1,  'Personal work',                  'APPROVED', 2, '2025-03-16 14:00:00', 'Noted.'),
(8,  1, '2025-04-14', '2025-04-18', 5,  'Family trip',                    'REJECTED', 2, '2025-04-12 11:00:00', 'Critical release week, cannot approve.'),
(9,  2, '2025-05-05', '2025-05-06', 2,  'Medical appointment',            'APPROVED', 2, '2025-05-04 16:00:00', 'Approved.'),
(10, 1, '2025-06-02', '2025-06-06', 5,  'Wedding anniversary trip',       'APPROVED', 3, '2025-05-30 10:00:00', 'Approved. Congratulations!'),
(11, 3, '2025-07-21', '2025-07-21', 1,  'Personal errand',                'APPROVED', 3, '2025-07-20 09:00:00', 'OK.'),
(12, 2, '2025-08-11', '2025-08-13', 3,  'Back pain treatment',            'APPROVED', 4, '2025-08-10 10:00:00', 'Please submit medical certificate on return.'),
(13, 1, '2025-09-01', '2025-09-05', 5,  'Vacation',                       'PENDING',  NULL, NULL, NULL),
(14, 3, '2025-10-06', '2025-10-06', 1,  'Bank work',                      'PENDING',  NULL, NULL, NULL),
(15, 1, '2025-11-17', '2025-11-21', 5,  'Travel plans',                   'PENDING',  NULL, NULL, NULL),
(16, 2, '2025-12-08', '2025-12-09', 2,  'Flu symptoms',                   'PENDING',  NULL, NULL, NULL);
