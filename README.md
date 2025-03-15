# Todo App ([Live](https://jannis15-todo.web.app/))

A Flutter-based Todo application.

### Key Technologies

This project utilizes the following technologies:

![icons8-flutter-96](https://github.com/user-attachments/assets/e578fa2e-0fbe-4840-8fc4-9f1d87467703)
![icons8-dart-96](https://github.com/user-attachments/assets/a33555eb-222e-41a0-afc8-2dce81e8bc23)
![icons8-supabase-96](https://github.com/user-attachments/assets/1d0614ea-bc9b-4645-9cfe-7c15a5824078)
![icons8-firebase-96](https://github.com/user-attachments/assets/221e0b2a-65e2-489d-9e46-7cc65130fb1a)
![icons8-postgresql-96](https://github.com/user-attachments/assets/0f1b05f3-88b4-44b7-b310-adc26936f573)
![icons8-sqlite-100](https://github.com/user-attachments/assets/7f246716-d503-49bb-b699-06fee81d3128)

- Flutter: The Dart framework used to build the front-end user interface for both web and Android platforms.
- Dart: Programming language for Flutter's cross-platform UI.
- Supabase: The back-end service employed for authentication and database management.
- Firebase: Used for hosting the live flutter web-version.
- PostgreSQL: The primary database for storage and API functions, implemented with PL/pgSQL.
- SQLite: Used for local, offline storage, primarily for mobile offline functionality.

Most notable Flutter packages used:
supabase_flutter,
flutter_bloc,
drift,
go_router,
json_annotation & freezed

### Key Features

* Create, read, update, and delete todo items.
* Categorize todos.
* User authentication & remote data storage via Supabase.
* Local data persistence with Drift.

### Building the project

The application can be built for different platforms:

**Flutter build web**

`fvm flutter build web --no-tree-shake-icons --release`

This can also be visited via: [https://jannis15-todo.web.app](https://jannis15-todo.web.app)

**Flutter build apk**

`fvm flutter build apk --no-tree-shake-icons --release`

**Note:** This project uses `fvm`.
