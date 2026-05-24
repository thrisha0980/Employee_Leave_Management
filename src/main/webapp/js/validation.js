/**
 * Employee Leave Management System - Client-side Validation & Utilities
 */

// ---- Login Form Validation ----
function validateLoginForm() {
    const username = document.getElementById('username');
    const password = document.getElementById('password');
    let valid = true;
    clearErrors();

    if (!username.value.trim()) {
        showFieldError(username, 'Username is required');
        valid = false;
    }
    if (!password.value.trim()) {
        showFieldError(password, 'Password is required');
        valid = false;
    }
    return valid;
}

// ---- Leave Application Validation ----
function validateLeaveForm() {
    const leaveType = document.getElementById('leaveTypeId');
    const startDate = document.getElementById('startDate');
    const endDate   = document.getElementById('endDate');
    const reason    = document.getElementById('reason');
    let valid = true;
    clearErrors();

    if (!leaveType || !leaveType.value) {
        showFieldError(leaveType, 'Please select a leave type');
        valid = false;
    }
    if (!startDate.value) {
        showFieldError(startDate, 'Start date is required');
        valid = false;
    }
    if (!endDate.value) {
        showFieldError(endDate, 'End date is required');
        valid = false;
    }
    if (startDate.value && endDate.value) {
        const s = new Date(startDate.value);
        const e = new Date(endDate.value);
        if (e < s) {
            showFieldError(endDate, 'End date cannot be before start date');
            valid = false;
        }
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        if (s < today) {
            showFieldError(startDate, 'Start date cannot be in the past');
            valid = false;
        }
    }
    if (!reason || !reason.value.trim()) {
        showFieldError(reason, 'Please provide a reason');
        valid = false;
    }
    return valid;
}

// ---- Employee Form Validation ----
function validateEmployeeForm() {
    let valid = true;
    clearErrors();

    const fields = [
        { id: 'firstName',   msg: 'First name is required' },
        { id: 'lastName',    msg: 'Last name is required' },
        { id: 'email',       msg: 'Email is required' },
        { id: 'deptId',      msg: 'Department is required' },
        { id: 'designation', msg: 'Designation is required' }
    ];

    fields.forEach(f => {
        const el = document.getElementById(f.id);
        if (el && !el.value.trim()) {
            showFieldError(el, f.msg);
            valid = false;
        }
    });

    const email = document.getElementById('email');
    if (email && email.value && !isValidEmail(email.value)) {
        showFieldError(email, 'Enter a valid email address');
        valid = false;
    }

    const phone = document.getElementById('phone');
    if (phone && phone.value && !/^\d{10,15}$/.test(phone.value.replace(/[- ]/g, ''))) {
        showFieldError(phone, 'Enter a valid phone number');
        valid = false;
    }

    // If creating new employee, validate username & password
    const username = document.getElementById('username');
    const password = document.getElementById('password');
    if (username && !username.disabled && !username.value.trim()) {
        showFieldError(username, 'Username is required');
        valid = false;
    }
    if (password && !password.disabled && !password.value.trim()) {
        showFieldError(password, 'Password is required');
        valid = false;
    }

    return valid;
}

// ---- Helper: Show error message below a field ----
function showFieldError(el, message) {
    if (!el) return;
    el.style.borderColor = '#ef4444';
    const errDiv = document.createElement('div');
    errDiv.className = 'field-error';
    errDiv.style.color = '#fca5a5';
    errDiv.style.fontSize = '0.75rem';
    errDiv.style.marginTop = '4px';
    errDiv.textContent = message;
    el.parentNode.appendChild(errDiv);
}

function clearErrors() {
    document.querySelectorAll('.field-error').forEach(e => e.remove());
    document.querySelectorAll('[style*="border-color"]').forEach(e => {
        e.style.borderColor = '';
    });
}

function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// ---- Auto-calculate total days ----
function calculateDays() {
    const startDate = document.getElementById('startDate');
    const endDate   = document.getElementById('endDate');
    const totalDays = document.getElementById('totalDays');
    if (startDate && endDate && startDate.value && endDate.value) {
        const s = new Date(startDate.value);
        const e = new Date(endDate.value);
        const diff = Math.ceil((e - s) / (1000 * 60 * 60 * 24)) + 1;
        if (totalDays) totalDays.textContent = diff > 0 ? diff + ' day(s)' : '--';
    }
}

// ---- Sidebar toggle for mobile ----
function toggleSidebar() {
    const sidebar = document.querySelector('.sidebar');
    if (sidebar) sidebar.classList.toggle('open');
}

// ---- Modal helpers ----
function openModal(id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.add('active');
}

function closeModal(id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.remove('active');
}

// Close modal on backdrop click
document.addEventListener('click', function (e) {
    if (e.target.classList.contains('modal-backdrop')) {
        e.target.classList.remove('active');
    }
});

// ---- Confirm Delete ----
function confirmDelete(empId) {
    if (confirm('Are you sure you want to delete this employee? This action cannot be undone.')) {
        const form = document.getElementById('deleteForm');
        if (form) {
            document.getElementById('deleteEmpId').value = empId;
            form.submit();
        }
    }
}

// ---- Auto-dismiss alerts after 5 seconds ----
document.addEventListener('DOMContentLoaded', function () {
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(function (alert) {
        setTimeout(function () {
            alert.style.transition = 'opacity 0.5s';
            alert.style.opacity = '0';
            setTimeout(function () { alert.remove(); }, 500);
        }, 5000);
    });
});
