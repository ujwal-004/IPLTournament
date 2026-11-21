package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Servlet controller for login, teams, players, matches and dashboard.
 * Mapped to the existing form actions through WEB-INF/web.xml.
 */
public class TournamentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private String config(String key, String fallback) {
        String value = System.getenv(key);
        if (value == null || value.isBlank()) value = System.getProperty(key);
        return value == null || value.isBlank() ? fallback : value;
    }

    private Connection openConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(
            config("IPL_DB_URL", "jdbc:mysql://localhost:3306/ipl_tournament?useSSL=false&serverTimezone=UTC"),
            config("IPL_DB_USER", "root"),
            config("IPL_DB_PASSWORD", "")
        );
    }

    @Override
    public void init() throws ServletException {
        String username = config("IPL_ADMIN_USERNAME", "");
        String password = config("IPL_ADMIN_PASSWORD", "");
        if (username.isBlank() || password.isBlank()) {
            getServletContext().log("IPL admin is not seeded. Set IPL_ADMIN_USERNAME and IPL_ADMIN_PASSWORD before first use.");
            return;
        }
        if (password.length() < 12 || password.getBytes(java.nio.charset.StandardCharsets.UTF_8).length > 72) {
            throw new ServletException("IPL_ADMIN_PASSWORD must be 12–72 UTF-8 bytes.");
        }
        try (Connection connection = openConnection();
             PreparedStatement find = connection.prepareStatement("SELECT user_id FROM users WHERE username = ?")) {
            find.setString(1, username);
            try (ResultSet result = find.executeQuery()) {
                if (result.next()) return;
            }
            try (PreparedStatement insert = connection.prepareStatement(
                    "INSERT INTO users (username, password_hash) VALUES (?, ?)")) {
                insert.setString(1, username);
                insert.setString(2, BCrypt.hashpw(password, BCrypt.gensalt(12)));
                insert.executeUpdate();
                getServletContext().log("Initial IPL admin account created from environment settings.");
            }
        } catch (Exception exception) {
            throw new ServletException("Unable to initialise the IPL database/admin. Import schema.sql and check IPL_DB_* settings.", exception);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        if ("/LogoutServlet".equals(path)) {
            HttpSession session = request.getSession(false);
            if (session != null) session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        if ("/DashboardServlet".equals(path)) {
            if (!requireLogin(request, response)) return;
            showDashboard(request, response);
            return;
        }
        if ("/LoginServlet".equals(path)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        try {
            switch (path) {
                case "/LoginServlet" -> login(request, response);
                case "/TeamServlet" -> {
                    if (requireLogin(request, response)) addTeam(request, response);
                }
                case "/PlayerServlet" -> {
                    if (requireLogin(request, response)) addPlayer(request, response);
                }
                case "/MatchServlet" -> {
                    if (requireLogin(request, response)) addMatch(request, response);
                }
                default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (IllegalArgumentException exception) {
            forwardError(request, response, path, exception.getMessage());
        } catch (SQLException exception) {
            getServletContext().log("IPL database operation failed.", exception);
            forwardError(request, response, path, "The request could not be saved. Check the record values and database constraints.");
        } catch (Exception exception) {
            getServletContext().log("Unexpected IPL application error.", exception);
            forwardError(request, response, path, "The request could not be completed. Check the application configuration.");
        }
    }

    private void login(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String username = value(request, "username");
        String password = request.getParameter("password");
        if (username.isBlank() || password == null || password.isBlank()) {
            forwardError(request, response, "/LoginServlet", "Enter both username and password.");
            return;
        }

        try (Connection connection = openConnection();
             PreparedStatement statement = connection.prepareStatement(
                 "SELECT user_id, username, password_hash FROM users WHERE username = ? LIMIT 1")) {
            statement.setString(1, username);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next() || !BCrypt.checkpw(password, result.getString("password_hash"))) {
                    forwardError(request, response, "/LoginServlet", "Invalid username or password.");
                    return;
                }
                HttpSession session = request.getSession(true);
                request.changeSessionId();
                session.setAttribute("userId", result.getLong("user_id"));
                session.setAttribute("username", result.getString("username"));
                session.setMaxInactiveInterval(30 * 60);
            }
        }
        response.sendRedirect(request.getContextPath() + "/DashboardServlet");
    }

    private boolean requireLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }

    private void addTeam(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String name = value(request, "name");
        String coach = value(request, "coach");
        String owner = value(request, "owner");
        if (name.isBlank() || name.length() > 100) throw new IllegalArgumentException("Enter a team name (maximum 100 characters).");
        try (Connection connection = openConnection();
             PreparedStatement statement = connection.prepareStatement(
                 "INSERT INTO teams (team_name, coach, owner) VALUES (?, ?, ?)")) {
            statement.setString(1, name);
            statement.setString(2, coach);
            statement.setString(3, owner);
            statement.executeUpdate();
        }
        successRedirect(request, response, "Team added successfully.");
    }

    private void addPlayer(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String name = value(request, "name");
        String role = value(request, "role");
        int teamId = positiveInt(value(request, "teamId"), "Select a valid team ID.");
        if (name.isBlank() || name.length() > 100) throw new IllegalArgumentException("Enter a player name (maximum 100 characters).");
        try (Connection connection = openConnection();
             PreparedStatement statement = connection.prepareStatement(
                 "INSERT INTO players (player_name, role, team_id) VALUES (?, ?, ?)")) {
            statement.setString(1, name);
            statement.setString(2, role);
            statement.setInt(3, teamId);
            statement.executeUpdate();
        }
        successRedirect(request, response, "Player added successfully.");
    }

    private void addMatch(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String team1 = value(request, "team1");
        String team2 = value(request, "team2");
        String winner = value(request, "winner");
        String dateText = value(request, "match_date");
        String venue = value(request, "venue");

        if (team1.isBlank() || team2.isBlank() || team1.equalsIgnoreCase(team2)) {
            throw new IllegalArgumentException("Enter two different team names.");
        }
        LocalDate date;
        try {
            date = LocalDate.parse(dateText);
        } catch (Exception exception) {
            throw new IllegalArgumentException("Match date must use YYYY-MM-DD.");
        }

        try (Connection connection = openConnection()) {
            int team1Id = findTeamId(connection, team1);
            int team2Id = findTeamId(connection, team2);
            Integer winnerId = winner.isBlank() ? null : findTeamId(connection, winner);

            try (PreparedStatement statement = connection.prepareStatement(
                "INSERT INTO matches (team1_id, team2_id, winner_team_id, match_date, venue) VALUES (?, ?, ?, ?, ?)")) {
                statement.setInt(1, team1Id);
                statement.setInt(2, team2Id);
                if (winnerId == null) statement.setNull(3, java.sql.Types.INTEGER);
                else statement.setInt(3, winnerId);
                statement.setDate(4, Date.valueOf(date));
                statement.setString(5, venue);
                statement.executeUpdate();
            }
        }
        successRedirect(request, response, "Match added successfully.");
    }

    private int findTeamId(Connection connection, String name) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
            "SELECT team_id FROM teams WHERE team_name = ? LIMIT 1")) {
            statement.setString(1, name);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) throw new IllegalArgumentException("Team not found: " + name);
                return result.getInt("team_id");
            }
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try (Connection connection = openConnection()) {
            request.setAttribute("teams", queryRows(connection,
                "SELECT team_id, team_name, coach, owner FROM teams ORDER BY team_name"));
            request.setAttribute("players", queryRows(connection,
                "SELECT p.player_id, p.player_name, p.role, t.team_name FROM players p JOIN teams t ON t.team_id=p.team_id ORDER BY p.player_name"));
            request.setAttribute("matches", queryRows(connection,
                "SELECT m.match_id, t1.team_name AS team1, t2.team_name AS team2, tw.team_name AS winner, m.match_date, m.venue " +
                "FROM matches m JOIN teams t1 ON t1.team_id=m.team1_id JOIN teams t2 ON t2.team_id=m.team2_id " +
                "LEFT JOIN teams tw ON tw.team_id=m.winner_team_id ORDER BY m.match_date DESC"));
        } catch (Exception exception) {
            getServletContext().log("Unable to load IPL dashboard.", exception);
            request.setAttribute("error", "Dashboard data could not be loaded. Check the database connection.");
        }
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }

    private List<Map<String, Object>> queryRows(Connection connection, String sql) throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            int count = result.getMetaData().getColumnCount();
            while (result.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                for (int index = 1; index <= count; index++) {
                    row.put(result.getMetaData().getColumnLabel(index), result.getObject(index));
                }
                rows.add(row);
            }
        }
        return rows;
    }

    private void successRedirect(HttpServletRequest request, HttpServletResponse response, String message) throws IOException {
        request.getSession(false).setAttribute("flash", message);
        response.sendRedirect(request.getContextPath() + "/DashboardServlet");
    }

    private void forwardError(HttpServletRequest request, HttpServletResponse response, String path, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message == null ? "The request could not be completed." : message);
        String target = "/LoginServlet".equals(path) ? "/login.jsp"
            : "/TeamServlet".equals(path) ? "/team.jsp"
            : "/PlayerServlet".equals(path) ? "/player.jsp"
            : "/MatchServlet".equals(path) ? "/match.jsp"
            : "/login.jsp";
        request.getRequestDispatcher(target).forward(request, response);
    }

    private static String value(HttpServletRequest request, String key) {
        String value = request.getParameter(key);
        return value == null ? "" : value.trim();
    }

    private static int positiveInt(String value, String message) {
        try {
            int number = Integer.parseInt(value);
            if (number <= 0) throw new NumberFormatException();
            return number;
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(message);
        }
    }
}
