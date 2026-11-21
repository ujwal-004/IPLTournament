<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<% if (session.getAttribute("userId") == null) { response.sendRedirect("login.jsp"); return; } %>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Add Team</title><link rel="stylesheet" href="css/style.css"></head><body>
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
<main class="container"><h1>Add Team</h1><p class="subtitle">Register a tournament team.</p>
<% if (request.getAttribute("error") != null) { %><div class="message error"><%= org.apache.commons.text.StringEscapeUtils.escapeHtml4(String.valueOf(request.getAttribute("error"))) %></div><% } %>
<section class="panel"><form action="TeamServlet" method="post"><div class="form-grid">
<div><label for="name">Team Name</label><input id="name" name="name" required maxlength="100"></div>
<div><label for="coach">Coach</label><input id="coach" name="coach" maxlength="100"></div>
<div><label for="owner">Owner</label><input id="owner" name="owner" maxlength="100"></div>
</div><div class="form-actions"><button type="submit">Add Team</button><a class="button secondary" href="DashboardServlet">Cancel</a></div></form></section></main></body></html>