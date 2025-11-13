# LAB 4 — Exercises 5 → 7  
## Search · Validation · Pagination  


---

# 📘 Exercise 5 — Search Feature  
**File:** `list_students.jsp`  
**Purpose:** Allow users to filter student records based on a keyword matched against `student_code` or `full_name`.

---

## 🔎 Feature Description  
The Search Feature enables keyword-based filtering for the student list. When the user enters a search term, the system checks whether the keyword appears within the student’s code or full name. A SQL query with the LIKE operator is used to perform partial matching. If the search field is empty, the system simply loads the full list of students.

---

## 🧠 Workflow (Paragraph Form)  
When the user types a keyword into the search box and submits the form, the browser issues a GET request containing the keyword as part of the URL query string. The JSP page retrieves this keyword and checks whether it contains a non-empty value. If a keyword is provided, the server executes a SQL query using the LIKE operator to filter for records where either the student code or full name contains the keyword. If the keyword field is empty, the system loads and displays all student records without applying any filters. Regardless of the case, the resulting set of records is then dynamically rendered within the table on the page.

---

## 🧩 Core Search Logic  
```jsp
String keyword = request.getParameter("keyword");

if (keyword != null && !keyword.trim().isEmpty()) {
    String like = "%" + keyword.trim() + "%";
    sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? ORDER BY id DESC";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, like);
    pstmt.setString(2, like);
    rs = pstmt.executeQuery();
} else {
    sql = "SELECT * FROM students ORDER BY id DESC";
    stmt = conn.createStatement();
    rs = stmt.executeQuery(sql);
}
```

---

# 📘 Exercise 6 — Input Validation  
**Files:** `process_add.jsp`, `process_edit.jsp`  
**Purpose:** Ensure all submitted form data follows rules before being stored or updated in the database.

---

## ✔️ Required Validations  
1. **Full Name** → must not be empty  
2. **Student Code** → must follow strict format:  
   - **Two uppercase letters + at least three digits**  
   - Regex: `[A-Z]{2}[0-9]{3,}`  
3. **Email** (optional) → if provided, must match valid email pattern:  
   - Regex: `^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$`  

---

## 🧠 Workflow (Paragraph Form)  
When the user submits a form to add or update a student record, the server retrieves every input value and trims possible extra whitespace. It then validates mandatory fields to ensure that the full name and student code are not empty. The student code is checked using a regular expression to ensure it matches the required pattern of two uppercase letters followed by at least three digits. If the user provides an email address, the system verifies that it follows a valid email format using another regular expression; if the email field is empty, it is considered acceptable. If any validation rule fails, the server immediately redirects the user back to the form page along with an error message describing the issue. Only after all input data is confirmed to be valid does the server proceed to insert or update the record in the database.

---

## 🧩 Email Validation Code  
```jsp
String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$";

if (!email.isEmpty() && !email.matches(emailRegex)) {
    response.sendRedirect("add_student.jsp?error=Invalid email format");
    return;
}
```

---

## 🧩 Student Code Validation Code  
```jsp
if (!studentCode.matches("[A-Z]{2}[0-9]{3,}")) {
    response.sendRedirect("add_student.jsp?error=Invalid student code format (e.g. SV001)");
    return;
}
```

---

# 📘 Exercise 7 — Pagination Feature  
**File:** `list_students.jsp`  
**Purpose:** Divide the student list into multiple pages for improved readability. Default: **10 records per page**.

---

## 🔎 Feature Description  
Pagination allows the student table to display a limited number of records per page, improving readability and performance. It also ensures that search and pagination can work together seamlessly.

---

## 🧠 Workflow (Paragraph Form)  
When the student list page is accessed, the system reads the `page` parameter from the URL to determine which page number the user is requesting. If the parameter is missing, the current page defaults to page one. Based on this page number, the system calculates an offset value that determines how many records should be skipped before retrieving the next set from the database. A SQL query with LIMIT and OFFSET is then executed to extract only the records belonging to the current page. In parallel, a COUNT(*) query calculates the total number of records in the database, allowing the system to compute the total number of pages. Using this information, the page generates a pagination interface that includes numeric page links as well as previous and next buttons. If the user is currently performing a keyword search, the pagination links are automatically formed in a way that preserves the keyword, ensuring consistent filtering when moving between pages.

---

## 🧮 Pagination Code Example  
### Determine Current Page  
```jsp
int currentPage = 1;
String pageParam = request.getParameter("page");
if (pageParam != null) currentPage = Integer.parseInt(pageParam);
```

### Calculate Offset  
```jsp
int recordsPerPage = 10;
int offset = (currentPage - 1) * recordsPerPage;
```

### SQL Query with Pagination  
```jsp
String sql = "SELECT * FROM students ORDER BY id DESC LIMIT ? OFFSET ?";
pstmt.setInt(1, recordsPerPage);
pstmt.setInt(2, offset);
rs = pstmt.executeQuery();
```

---
