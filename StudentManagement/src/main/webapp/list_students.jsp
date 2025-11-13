<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 { color: #333; }
        .message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin-bottom: 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
        }
        th {
            background-color: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover { background-color: #f8f9fa; }
        .action-link {
            color: #007bff;
            text-decoration: none;
            margin-right: 10px;
        }
        .delete-link { color: #dc3545; }

        /* Pagination styles */
        .pagination {
            margin-top: 20px;
        }
        .pagination a,
        .pagination strong {
            display: inline-block;
            padding: 6px 10px;
            margin: 0 3px;
            border-radius: 4px;
            text-decoration: none;
            border: 1px solid #007bff;
        }
        .pagination a {
            color: #007bff;
            background-color: #fff;
        }
        .pagination strong {
            background-color: #007bff;
            color: #fff;
        }
    </style>
</head>
<body>
<h1>📚 Student Management System</h1>

<% if (request.getParameter("message") != null) { %>
<div class="message success">
    <%= request.getParameter("message") %>
</div>
<% } %>

<% if (request.getParameter("error") != null) { %>
<div class="message error">
    <%= request.getParameter("error") %>
</div>
<% } %>

<!-- Search form (Exercise 5) -->
<form action="list_students.jsp" method="GET">
    <input
            type="text"
            name="keyword"
            placeholder="Search by name or code..."
            value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>"
    >
    <button type="submit">Search</button>
    <a href="list_students.jsp">Clear</a>
</form>

<a href="add_student.jsp" class="btn">➕ Add New Student</a>

<table>
    <thead>
    <tr>
        <th>ID</th>
        <th>Student Code</th>
        <th>Full Name</th>
        <th>Email</th>
        <th>Major</th>
        <th>Created At</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        PreparedStatement countPstmt = null;
        Statement stmt = null;
        ResultSet rs = null;
        ResultSet rsCount = null;

      
        int currentPage = 1;
        int recordsPerPage = 10; // mỗi trang 10 dòng
        int totalRecords = 0;
        int totalPages = 1;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/student_management",
                    "root",
                    "quangthai123"
            );

            String keyword = request.getParameter("keyword");
            String keywordTrimmed = (keyword != null) ? keyword.trim() : null;

            // Lấy page từ URL
            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                try {
                    currentPage = Integer.parseInt(pageParam);
                } catch (NumberFormatException ex) {
                    currentPage = 1;
                }
            }
            if (currentPage < 1) currentPage = 1;

            int offset = (currentPage - 1) * recordsPerPage;

           
            if (keywordTrimmed != null && !keywordTrimmed.isEmpty()) {
                String like = "%" + keywordTrimmed + "%";

                String countSql = "SELECT COUNT(*) FROM students " +
                        "WHERE full_name LIKE ? OR student_code LIKE ?";
                countPstmt = conn.prepareStatement(countSql);
                countPstmt.setString(1, like);
                countPstmt.setString(2, like);
                rsCount = countPstmt.executeQuery();
                if (rsCount.next()) {
                    totalRecords = rsCount.getInt(1);
                }

                String sql = "SELECT * FROM students " +
                        "WHERE full_name LIKE ? OR student_code LIKE ? " +
                        "ORDER BY id DESC " +
                        "LIMIT ? OFFSET ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, like);
                pstmt.setString(2, like);
                pstmt.setInt(3, recordsPerPage);
                pstmt.setInt(4, offset);
                rs = pstmt.executeQuery();
            } else {
                String countSql = "SELECT COUNT(*) FROM students";
                stmt = conn.createStatement();
                rsCount = stmt.executeQuery(countSql);
                if (rsCount.next()) {
                    totalRecords = rsCount.getInt(1);
                }

                String sql = "SELECT * FROM students " +
                        "ORDER BY id DESC " +
                        "LIMIT ? OFFSET ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, recordsPerPage);
                pstmt.setInt(2, offset);
                rs = pstmt.executeQuery();
            }

           
            if (totalRecords > 0) {
                totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
            } else {
                totalPages = 1;
            }

            while (rs.next()) {
                int id = rs.getInt("id");
                String studentCode = rs.getString("student_code");
                String fullName = rs.getString("full_name");
                String email = rs.getString("email");
                String major = rs.getString("major");
                Timestamp createdAt = rs.getTimestamp("created_at");
    %>
    <tr>
        <td><%= id %></td>
        <td><%= studentCode %></td>
        <td><%= fullName %></td>
        <td><%= email != null ? email : "N/A" %></td>
        <td><%= major != null ? major : "N/A" %></td>
        <td><%= createdAt %></td>
        <td>
            <a href="edit_student.jsp?id=<%= id %>" class="action-link">✏️ Edit</a>
            <a href="delete_student.jsp?id=<%= id %>"
               class="action-link delete-link"
               onclick="return confirm('Are you sure?')">🗑️ Delete</a>
        </td>
    </tr>
    <%
        } // end while
    %>
    </tbody>
</table>


<div class="pagination">
    <%
        
        String keywordParam = "";
        if (keywordTrimmed != null && !keywordTrimmed.isEmpty()) {
            keywordParam = "&keyword=" + keywordTrimmed;
        }

        if (totalPages > 1) {
            // Previous
            if (currentPage > 1) {
    %>
    <a href="list_students.jsp?page=<%= currentPage - 1 %><%= keywordParam %>">Previous</a>
    <%
        }

       
        for (int i = 1; i <= totalPages; i++) {
            if (i == currentPage) {
    %>
    <strong><%= i %></strong>
    <%
    } else {
    %>
    <a href="list_students.jsp?page=<%= i %><%= keywordParam %>"><%= i %></a>
    <%
            }
        }

    
        if (currentPage < totalPages) {
    %>
    <a href="list_students.jsp?page=<%= currentPage + 1 %><%= keywordParam %>">Next</a>
    <%
                }
            } // end if totalPages>1
        } catch (ClassNotFoundException e) {
            out.println("<tr><td colspan='7'>Error: JDBC Driver not found!</td></tr>");
            e.printStackTrace();
        } catch (SQLException e) {
            out.println("<tr><td colspan='7'>Database Error: " + e.getMessage() + "</td></tr>");
            e.printStackTrace();
        } finally {
            try {
                if (rsCount != null) rsCount.close();
                if (countPstmt != null) countPstmt.close();
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
</div>
</body>
</html>
