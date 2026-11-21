# Contributing

1. Create a feature branch from `main`.
2. Keep servlet endpoints consistent with `WEB-INF/web.xml` and existing JSP form field names.
3. Use prepared statements for all user-controlled SQL values.
4. Never commit database credentials, session secrets, generated WAR/JAR files or IDE workspace files.
5. Run `mvn clean package` before opening a pull request.
6. Update `schema.sql` and the README when changing database fields or setup steps.
