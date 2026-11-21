<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% if (session.getAttribute("userId") == null) { response.sendRedirect("login.jsp"); return; } %>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Add Player</title><link rel="stylesheet" href="css/style.css"></head><body>
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
<main class="container"><h1>Add Player</h1><p class="subtitle">Add a player to a team using the team ID shown on the database record.</p>
<c:if test="${not empty error}"><div class="message error"><c:out value="${error}"/></div></c:if>
<section class="panel"><form action="PlayerServlet" method="post"><div class="form-grid">
<div><label for="name">Player Name</label><input id="name" name="name" required maxlength="100"></div>
<div><label for="role">Role</label><input id="role" name="role" maxlength="60" placeholder="Batter, Bowler, All-rounder, Wicketkeeper"></div>
<div><label for="teamId">Team ID</label><input id="teamId" name="teamId" type="number" min="1" required></div>
</div><div class="form-actions"><button type="submit">Add Player</button><a class="button secondary" href="DashboardServlet">Cancel</a></div></form></section></main></body></html>