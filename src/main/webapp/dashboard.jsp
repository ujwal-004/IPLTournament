<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
if (session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
}
Object flashMessage = session.getAttribute("flash");
if (flashMessage != null) {
    request.setAttribute("flashMessage", flashMessage);
    session.removeAttribute("flash");
}
%>
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>IPL Dashboard</title><link rel="stylesheet" href="css/style.css"></head>
<body>
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
<main class="container">
  <section class="hero"><h1>IPL Dashboard</h1><p>Welcome, <strong><c:out value="${sessionScope.username}"/></strong>. Manage tournament data from one place.</p></section>
  <c:if test="${not empty flashMessage}"><div class="message success"><c:out value="${flashMessage}"/></div></c:if>
  <c:if test="${not empty error}"><div class="message error"><c:out value="${error}"/></div></c:if>
  <div class="form-actions">
    <a class="button" href="team.jsp">Add Team</a>
    <a class="button" href="player.jsp">Add Player</a>
    <a class="button" href="match.jsp">Add Match</a>
  </div>
  <section class="panel"><h2>Teams</h2><div class="table-wrap"><table><thead><tr><th>Team</th><th>Coach</th><th>Owner</th></tr></thead><tbody>
    <c:forEach var="team" items="${teams}"><tr><td><c:out value="${team.team_name}"/></td><td><c:out value="${team.coach}"/></td><td><c:out value="${team.owner}"/></td></tr></c:forEach>
    <c:if test="${empty teams}"><tr><td class="empty" colspan="3">No teams have been added.</td></tr></c:if>
  </tbody></table></div></section>
  <section class="panel"><h2>Players</h2><div class="table-wrap"><table><thead><tr><th>Player</th><th>Role</th><th>Team</th></tr></thead><tbody>
    <c:forEach var="player" items="${players}"><tr><td><c:out value="${player.player_name}"/></td><td><c:out value="${player.role}"/></td><td><c:out value="${player.team_name}"/></td></tr></c:forEach>
    <c:if test="${empty players}"><tr><td class="empty" colspan="3">No players have been added.</td></tr></c:if>
  </tbody></table></div></section>
  <section class="panel"><h2>Matches</h2><div class="table-wrap"><table><thead><tr><th>Team 1</th><th>Team 2</th><th>Winner</th><th>Date</th><th>Venue</th></tr></thead><tbody>
    <c:forEach var="match" items="${matches}"><tr><td><c:out value="${match.team1}"/></td><td><c:out value="${match.team2}"/></td><td><c:out value="${match.winner}"/></td><td><c:out value="${match.match_date}"/></td><td><c:out value="${match.venue}"/></td></tr></c:forEach>
    <c:if test="${empty matches}"><tr><td class="empty" colspan="5">No matches have been recorded.</td></tr></c:if>
  </tbody></table></div></section>
</main>
</body></html>