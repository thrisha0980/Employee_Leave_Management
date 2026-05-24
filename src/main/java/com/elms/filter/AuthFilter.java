package com.elms.filter;

import com.elms.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Protects all URLs under /admin/*, /manager/*, /employee/*.
 * Redirects unauthenticated users to the login page.
 */
@WebFilter(urlPatterns = {"/admin/*", "/manager/*", "/employee/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Prevent browser caching of protected pages
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        // Role-based path protection
        User user = (User) session.getAttribute("user");
        String path = req.getServletPath();

        if (path.startsWith("/admin") && !"ADMIN".equals(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (path.startsWith("/manager") && !"MANAGER".equals(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (path.startsWith("/employee") && !"EMPLOYEE".equals(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        chain.doFilter(request, response);
    }
}
