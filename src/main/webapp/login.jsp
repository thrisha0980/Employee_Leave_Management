<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Employee Leave Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="login-wrapper">
    <div class="login-card">
        <div class="login-logo">
            <div class="logo-icon">&#128188;</div>
            <h1>ELMS</h1>
            <p>Employee Leave Management System</p>
        </div>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
            <div class="alert alert-error">&#9888; <%= error %></div>
        <% } %>

        <form action="${pageContext.request.contextPath}/login" method="post"
              onsubmit="return validateLoginForm()">

            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username"
                       placeholder="Enter your username" autocomplete="username">
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password"
                       placeholder="Enter your password" autocomplete="current-password">
            </div>

            <button type="submit" class="btn btn-primary btn-full">
                Sign In &#10132;
            </button>
        </form>

        <p class="text-center mt-2" style="color:var(--text-muted);font-size:.8125rem;">
            Default password for all users: <strong>Password@123</strong>
        </p>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
