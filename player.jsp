<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Add Player</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<h2>Add Player</h2>
<form action="PlayerServlet" method="post">
    <input name="name" placeholder="Player Name"><br><br>
    <input name="role" placeholder="Role"><br><br>
    <input name="teamId" type="number" placeholder="Team ID"><br><br>
    <button>Add Player</button>
</form>
<p><a href="dashboard.jsp">Back to Dashboard</a></p>
</body>
</html>
