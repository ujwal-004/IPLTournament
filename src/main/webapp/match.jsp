<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<% if (session.getAttribute("userId") == null) { response.sendRedirect("login.jsp"); return; } %>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Add Match</title><link rel="stylesheet" href="css/style.css"></head><body>
<header class="topbar">
  <div class="brand">IPL Tournament Manager</div>
  <nav class="nav">
    <a href="DashboardServlet">Dashboard</a>
    <a href="team.jsp">Teams</a>
    <a href="player.jsp">Players</a>
    <a href="match.jsp">Matches</a>
    <a href="LogoutServlet">Logout</a>
  </nav>
</header>
<main class="container"><h1>Add Match</h1><p class="subtitle">Create a fixture by entering the exact team names used in the Teams list.</p>
<% if (request.getAttribute("error") != null) { %><div class="message error"><%= org.apache.commons.text.StringEscapeUtils.escapeHtml4(String.valueOf(request.getAttribute("error"))) %></div><% } %>
<section class="panel"><form action="MatchServlet" method="post"><div class="form-grid">
<div><label for="team1">Team 1</label><input id="team1" name="team1" required maxlength="100"></div>
<div><label for="team2">Team 2</label><input id="team2" name="team2" required maxlength="100"></div>
<div><label for="winner">Winner (optional)</label><input id="winner" name="winner" maxlength="100"></div>
<div><label for="match_date">Match Date</label><input id="match_date" name="match_date" type="date" required></div>
<div><label for="venue">Venue</label><input id="venue" name="venue" maxlength="150"></div>
</div><div class="form-actions"><button type="submit">Add Match</button><a class="button secondary" href="DashboardServlet">Cancel</a></div></form></section></main></body></html>