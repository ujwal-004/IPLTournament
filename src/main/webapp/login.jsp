<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>IPL Tournament Login</title><link rel="stylesheet" href="css/style.css"></head>
<body>
<main class="panel login-card">
  <div class="hero"><h1>IPL Tournament Manager</h1><p>Sign in to manage teams, players and fixtures.</p></div>
  <% if (request.getAttribute("error") != null) { %><div class="message error"><%= org.apache.commons.text.StringEscapeUtils.escapeHtml4(String.valueOf(request.getAttribute("error"))) %></div><% } %>
  <form action="LoginServlet" method="post">
    <div class="form-field"><label for="username">Username</label><input id="username" name="username" autocomplete="username" required maxlength="80"></div>
    <div class="form-field"><label for="password">Password</label><input id="password" name="password" type="password" autocomplete="current-password" required></div>
    <button type="submit">Login</button>
  </form>
  <p class="hint">The first administrator is created from IPL_ADMIN_USERNAME and IPL_ADMIN_PASSWORD environment variables. No default password is built into the application.</p>
</main>
</body></html>