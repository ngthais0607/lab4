<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String studentCode = request.getParameter("student_code");
    String fullName    = request.getParameter("full_name");
    String email       = request.getParameter("email");
    String major       = request.getParameter("major");

    if (studentCode == null) studentCode = "";
    if (fullName == null)    fullName    = "";
    if (email == null)       email       = "";
    if (major == null)       major       = "";

    studentCode = studentCode.trim();
    fullName    = fullName.trim();
    email       = email.trim();
    major       = major.trim();

    // 1. Required fields
    if (studentCode.isEmpty() || fullName.isEmpty()) {
        response.sendRedirect("add_student.jsp?error=Student code and full name are required");
        return;
    }

    // 2. Exercise 6.2 - Student Code Pattern Validation
    // Pattern: 2 uppercase letters + >= 3 digits (e.g., SV001, IT123, CS9999)
    if (!studentCode.matches("[A-Z]{2}[0-9]{3,}")) {
        response.sendRedirect("add_student.jsp?error=Invalid student code format (e.g. SV001)");
        return;
    }

    // 3. Exercise 6.1 - Email Validation (optional field)
    if (!email.isEmpty()) {
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        if (!email.matches(emailRegex)) {
            response.sendRedirect("add_student.jsp?error=Invalid email format");
            return;
        }
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/student_management",
                "root",
                "quangthai123"
        );

        String sql = "INSERT INTO students (student_code, full_name, email, major) VALUES (?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, studentCode);
        pstmt.setString(2, fullName);
        pstmt.setString(3, email.isEmpty() ? null : email);
        pstmt.setString(4, major.isEmpty() ? null : major);

        int rowsAffected = pstmt.executeUpdate();

        if (rowsAffected > 0) {
            response.sendRedirect("list_students.jsp?message=Student added successfully");
        } else {
            response.sendRedirect("add_student.jsp?error=Failed to add student");
        }

    } catch (ClassNotFoundException e) {
        response.sendRedirect("add_student.jsp?error=Driver not found");
        e.printStackTrace();
    } catch (SQLException e) {
        String errorMsg = e.getMessage();
        if (errorMsg != null && errorMsg.contains("Duplicate entry")) {
            response.sendRedirect("add_student.jsp?error=Student code already exists");
        } else {
            response.sendRedirect("add_student.jsp?error=Database error");
        }
        e.printStackTrace();
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
