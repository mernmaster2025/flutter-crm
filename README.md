# Apex CRM

A premium Flutter CRM mobile application scaffold with Clean Architecture, Riverpod state management, GoRouter navigation, Dio-backed mock APIs, Hive caching, secure session storage, and Material 3 theming.

## Features

- Authentication flows: login, registration, forgot password, OTP, remember-me, biometric entry point, profile/session management.
- Dashboard: revenue summary, leads, customers, pipeline, tasks, meetings, conversion rate, charts, and activity feed.
- CRM modules: leads, customers, sales pipeline Kanban, tasks, meetings, activities, communication, reports, notifications, settings, and admin.
- UI system: dark/light themes, glass panels, subtle gradients, responsive tablet layouts, charts, skeleton loading, empty states, and reusable components.
- Architecture: domain entities/use cases, repository contracts, data repositories, mock Dio services, Hive cache service, secure storage service, and Riverpod dependency injection.

## Structure

```text
lib/
  core/            constants, theme, errors, responsive helpers, validators
  data/            mock API, repositories, sample data, local cache
  domain/          entities, repository contracts, use cases
  presentation/    screens, shell, controllers/providers
  routes/          GoRouter configuration
  services/        integrations, session, biometric services
  widgets/         reusable CRM UI components
```

## Local Setup

Flutter is required to generate native runners and execute the app:

```sh
flutter create --platforms=android,ios .
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

The current repository includes placeholders for `android/` and `ios/` because the Flutter SDK was not available in the generation environment.