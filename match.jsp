<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Add Match</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<h2>Add Match</h2>
<form action="MatchServlet" method="post">
    <input name="team1" placeholder="Team 1"><br><br>
    <input name="team2" placeholder="Team 2"><br><br>
    <input name="winner" placeholder="Winner"><br><br>
    <input name="match_date" placeholder="Match Date"><br><br>
    <input name="venue" placeholder="Venue"><br><br>
    <button>Add Match</button>
</form>
<p><a href="dashboard.jsp">Back to Dashboard</a></p>
</body>
</html>
