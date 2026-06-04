# Apex CRM

Apex CRM is a premium offline-first Flutter CRM mobile app. It uses Clean Architecture, Riverpod, GoRouter, Hive local persistence, secure session storage, Material 3, responsive layouts, and a polished enterprise UI.

## Features

- Authentication: login, registration, forgot password, OTP, remember-me, biometric entry point, secure session restore, and profile management.
- Dashboard: revenue summary, lead/customer counts, pipeline value, task and meeting summaries, conversion rate, charts, and activity feed.
- Offline CRM: persisted leads, customers, deals, tasks, meetings, activities, notifications, communication records, and export records using Hive.
- Lead management: create, edit, delete, search, filter, update status/priority, add notes, and schedule follow-up data.
- Customer management: create, edit, delete, search, toggle favorites, segment customers, and add timeline notes.
- Pipeline: Kanban board with persisted drag-and-drop stages, create/edit/delete deals, and mark won/lost actions.
- Productivity: task completion/deletion, meeting scheduling/deletion, manual activity logs, reminders, and notification read/delete actions.
- Communication and reports: locally queued email/SMS/WhatsApp/bulk records, generated export records, and export history.
- Settings and admin: theme settings, security preferences, notification preferences, CRM preferences, admin analytics, user/team/role/config actions, and audit exports.
- UI system: Material 3, light/dark mode, glass panels, subtle gradients, responsive phone/tablet layouts, premium action buttons, card-grid module navigation, charts, skeleton loading, empty states, and reusable widgets.

## Structure

```text
lib/
  core/            constants, theme, errors, responsive helpers, validators
  data/            Hive data sources, repositories, sample data, mock API
  domain/          entities, repository contracts, use cases
  presentation/    screens, shell, controllers/providers
  routes/          GoRouter configuration
  services/        integrations, session, biometric services
  widgets/         reusable CRM UI components
test/              unit, repository, controller, and widget tests
android/           current Flutter Android runner
```

## Architecture

```text
Presentation screens
  -> Riverpod controllers
  -> Domain use cases
  -> Repository interfaces
  -> Hive-backed local data source
```

The app is currently designed as an offline-first CRM. External services such as email, SMS, WhatsApp, PDF/Excel export, calendar, and push notifications are represented as local records/confirmations so they can later be wired to real providers.

## Local Setup

Install Flutter and Android SDK, then run:

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run -d android
```

If Flutter cannot find the Android SDK:

```sh
flutter config --android-sdk <path-to-android-sdk>
flutter doctor -v
```

## Notes

- The Android runner has been generated with the current Flutter v2 embedding.
- The iOS runner can be generated when needed with `flutter create --platforms=ios .`.
- Data is seeded locally on first launch and persists on-device through Hive.