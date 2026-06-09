<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head><title>Add Team</title></head>
<body>
<h2>Add Team</h2>
<form action="TeamServlet" method="post">
    <input name="name" placeholder="Team Name"><br><br>
    <input name="coach" placeholder="Coach"><br><br>
    <input name="owner" placeholder="Owner"><br><br>
<button>Add Team</button>
</form>
</body>
</html>