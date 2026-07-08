# Repository Guidelines

## Project Structure & Module Organization

Cya! is a Flutter/Dart app. App code lives in `lib/`, organized by responsibility: `core/` for theme, routing, and shared utilities; `domain/` for pure Dart models/enums; `data/` for mock or future persistence implementations; and `presentation/` for screens, providers, shells, and widgets. Assets currently live under `lib/assets/images/`, `lib/assets/fonts/`, and `lib/assets/videos/`; only declared Flutter assets in `pubspec.yaml` are bundled by Flutter. Platform code is in `android/`, `ios/`, `web/`, `linux/`, `macos/`, and `windows/`. Tests live in `test/`. Product requirements, plans, and build notes live in `docs/` and `plans/`.

## Build, Test, and Development Commands

- `flutter pub get`: install dependencies after changing `pubspec.yaml`.
- `flutter run`: run the app on a connected device or emulator.
- `flutter analyze`: run static analysis; keep output clean before merging.
- `dart format .`: format Dart sources with the standard formatter.
- `flutter test`: run all tests.
- `flutter test test/widget_test.dart`: run one test file.
- `flutter build apk`: produce an Android release artifact.

## Coding Style & Naming Conventions

Use Dart defaults: 2-space indentation, formatted by `dart format`, and `flutter_lints` from `analysis_options.yaml`. Prefer small widgets and focused files. Use `PascalCase` for classes/widgets, `camelCase` for members/providers, and `lower_snake_case.dart` for file names. Keep `domain/` free of Flutter imports. In product/UI copy, say "promise"; in data/domain architecture, use the planned `Intention` vocabulary where applicable.

## Testing Guidelines

Use `flutter_test` for widget and unit tests. Name test files `*_test.dart` and keep expectations user-visible where possible, as in `test/widget_test.dart`. Add or update tests with each behavior change, especially navigation, Riverpod state, theming, and promise completion flows. There is no numeric coverage threshold yet, but new work should ship with relevant regression coverage.

## Commit & Pull Request Guidelines

Recent history is minimal, with `feat:` used once; prefer concise Conventional Commit-style subjects such as `feat: add home shell tests` or `fix: correct splash asset path`. Pull requests should summarize the change, link the relevant plan or issue, note test results, and include screenshots or screen recordings for UI changes.

## Agent-Specific Instructions

Before non-trivial work, read `docs/Cya_Master_PRD_and_Development_Bible.md` and check `plans/`. Follow the written loop: requirement analysis, planning, execution, testing, and feedback. Append outcomes to `plans/BUILD_LOG.md` when completing a unit of work. Preserve the local-first, native-thin capture path: do not add network calls, model inference, or Flutter engine startup to critical capture surfaces.
