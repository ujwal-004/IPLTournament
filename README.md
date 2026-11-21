# IPL Tournament Manager

A Java Servlet/JSP tournament management application for Apache Tomcat 9. Authenticated users can add teams, assign players to teams, schedule matches and view the tournament dashboard.

## Features

- Session-based login with BCrypt password verification
- First admin account bootstrapped from environment variables (no hard-coded default password)
- Team management: name, coach and owner
- Player management: name, role and team relationship
- Match scheduling: two teams, optional winner, date and venue
- Dashboard lists teams, players and matches
- Parameterized JDBC statements and database foreign keys

## Tech stack

Java 17, Maven, Java Servlet 4.0 (`javax.servlet`), JSP/JSTL, Apache Tomcat 9, MySQL, BCrypt.

## Requirements

- JDK 17+
- Maven 3.9+
- MySQL 8 or compatible server
- Apache Tomcat 9.0.x (Tomcat 10/11 is not supported by this javax.servlet build)

## 1. Create the database

From the repository root:

```bash
mysql -u root -p < schema.sql
```

This creates `ipl_tournament` and the `users`, `teams`, `players` and `matches` tables. The schema does not install a default password.

## 2. Configure the database and initial admin

Set these environment variables in the Tomcat process before first deployment:

| Variable | Purpose | Default |
|---|---|---|
| `IPL_DB_URL` | JDBC URL | `jdbc:mysql://localhost:3306/ipl_tournament?useSSL=false&serverTimezone=UTC` |
| `IPL_DB_USER` | Database username | `root` |
| `IPL_DB_PASSWORD` | Database password | empty |
| `IPL_ADMIN_USERNAME` | First admin username | not configured |
| `IPL_ADMIN_PASSWORD` | First admin password (12–72 UTF-8 bytes) | not configured |

The first admin is inserted once at servlet startup if the configured username does not exist. Its password is stored as a BCrypt hash. Keep these environment values private and never commit them.

For local development you can copy `.env.example` as a reference, but Tomcat does not automatically load `.env`; export the variables in the shell or configure them in the service environment.

## 3. Build the WAR

```bash
mvn clean package
```

The deployable artifact is `target/ipl-tournament.war`.

## 4. Deploy to Tomcat 9

Copy `target/ipl-tournament.war` to Tomcat's `webapps/` directory, start Tomcat, then open:

- Login: `http://localhost:8080/ipl-tournament/login.jsp`
- Dashboard: `http://localhost:8080/ipl-tournament/DashboardServlet`

On Windows you may use `build-app.ps1` to run Maven and `run-server.ps1` to copy the WAR and start a configured Tomcat 9 installation. Set `CATALINA_HOME` and `JAVA_HOME` first.

## Forms and routes

| Form | Servlet route | Required input fields |
|---|---|---|
| Login | POST `/LoginServlet` | `username`, `password` |
| Team | POST `/TeamServlet` | `name`, optional `coach`, `owner` |
| Player | POST `/PlayerServlet` | `name`, optional `role`, `teamId` |
| Match | POST `/MatchServlet` | `team1`, `team2`, optional `winner`, `match_date`, `venue` |
| Logout | GET `/LogoutServlet` | — |
| Dashboard | GET `/DashboardServlet` | — |

Team names entered in match forms must exactly match existing team names. Player entries require an existing team ID.

## Security and limitations

- Passwords are BCrypt-hashed and never stored as plaintext.
- Servlet sessions are invalidated on logout and use a 30-minute inactivity timeout.
- SQL inputs are parameterized; team/player/match relationships are enforced by foreign keys.
- This is an educational application, not a production-ready tournament platform. Before public deployment, add CSRF protection, HTTPS, security headers, login rate limiting, administrative roles and audit logging. Use a least-privilege database account.
