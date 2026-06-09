<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>IPL Login</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<h2 style="text-align:center">IPL Tournament Login</h2>
<form action="LoginServlet" method="post">
    <input name="username" placeholder="Username"><br><br>
    <input name="password" type="password" placeholder="Password"><br><br>
    <button>Login</button>
</form>
</body>
</html>