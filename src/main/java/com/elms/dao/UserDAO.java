package com.elms.dao;

import com.elms.model.User;
import com.elms.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;

/**
 * Data Access Object for User authentication and management.
 */
public class UserDAO {

    /**
     * Authenticates a user by username and plain-text password.
     * Returns the User object on success, null on failure.
     */
    public User authenticate(String username, String plainPassword) {
        String sql = "SELECT u.user_id, u.username, u.password_hash, u.email, " +
                     "u.role_id, r.role_name, u.is_active " +
                     "FROM users u JOIN roles r ON u.role_id = r.role_id " +
                     "WHERE u.username = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password_hash");
                    if (BCrypt.checkpw(plainPassword, storedHash)) {
                        if (!rs.getBoolean("is_active")) {
                            return null; // account disabled
                        }
                        User user = new User();
                        user.setUserId(rs.getInt("user_id"));
                        user.setUsername(rs.getString("username"));
                        user.setPasswordHash(storedHash);
                        user.setEmail(rs.getString("email"));
                        user.setRoleId(rs.getInt("role_id"));
                        user.setRoleName(rs.getString("role_name"));
                        user.setActive(true);
                        return user;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Finds a user by their user_id.
     */
    public User findById(int userId) {
        String sql = "SELECT u.user_id, u.username, u.email, u.role_id, " +
                     "r.role_name, u.is_active " +
                     "FROM users u JOIN roles r ON u.role_id = r.role_id " +
                     "WHERE u.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setRoleId(rs.getInt("role_id"));
                    user.setRoleName(rs.getString("role_name"));
                    user.setActive(rs.getBoolean("is_active"));
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Creates a new user account. Returns the generated user_id or -1 on failure.
     */
    public int createUser(String username, String plainPassword, String email, int roleId) {
        String sql = "INSERT INTO users (username, password_hash, email, role_id) VALUES (?, ?, ?, ?)";
        String hash = BCrypt.hashpw(plainPassword, BCrypt.gensalt(10));

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, username);
            ps.setString(2, hash);
            ps.setString(3, email);
            ps.setInt(4, roleId);
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Updates user active status.
     */
    public boolean setActiveStatus(int userId, boolean active) {
        String sql = "UPDATE users SET is_active = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Updates a user's password.
     */
    public boolean updatePassword(int userId, String newPlainPassword) {
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        String hash = BCrypt.hashpw(newPlainPassword, BCrypt.gensalt(10));
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Checks if a username already exists.
     */
    public boolean usernameExists(String username) {
        String sql = "SELECT 1 FROM users WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Checks if an email already exists.
     */
    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
