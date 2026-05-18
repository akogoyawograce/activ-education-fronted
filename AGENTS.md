# Repository Guidelines

## Project Structure & Module Organization
- `lib/` – Contains all Dart source code. Organize by feature or layer (e.g., `lib/screens/`, `lib/components/`, `lib/services/`).
- `assets/` – Static assets such as images, fonts, and JSON files. Reference in `pubspec.yaml`.
- `test/` – Unit and widget tests. Mirror lib structure under `test/`.
- Platform folders (`android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`) – Host platform-specific code; rarely need modification.
- `build/` – Generated build artifacts (ignored by Git).

## Build, Test, and Development Commands
- `flutter pub get` – Install dependencies.
- `flutter run` – Launch the app on a connected device or emulator.
- `flutter build apk` – Build Android release APK.
- `flutter build ios` – Build iOS release archive.
- `flutter test` – Run all unit and widget tests.
- `flutter test --coverage` – Generate test coverage report (see `coverage/`).
- `flutter analyze` – Run static analysis via `analysis_options.yaml`.

## Coding Style & Naming Conventions
- Format code with `dart format` (configured via `analysis_options.yaml`).
- Follow Effective Dart guidelines.
- Naming:
  - Variables, functions: `lowerCamelCase`.
  - Classes, enums, typedefs: `UpperCamelCase`.
  - Constants (compile-time): `CONSTANT_CASE`.
  - Files: `snake_case.dart`.
- Avoid magic numbers; use `const` for compile-time constants.

## Testing Guidelines
- Use `test` package for unit tests; `flutter_test` for widget tests.
- Name test files: `[feature]_test.dart`.
- Group tests with `group()`; use `setUp()` and `tearDown()` for fixtures.
- Aim for meaningful assertions; mock dependencies with `mockito` or `mocktail`.
- Run tests before committing; ensure no new failures.

## Commit & Pull Request Guidelines
- Commit messages: Use Conventional Commits (e.g., `feat: add login screen`, `fix: resolve null pointer`).
- Keep commits atomic and focused.
- Pull Requests:
  - Provide a clear summary of changes.
  - Link to related issue(s) (if any).
  - Include screenshots or GIFs for UI changes.
  - Ensure all tests pass and analysis warnings are resolved.
  - Request at least one review before merging.

