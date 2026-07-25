# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Tenkai ("your second brain") is a personal life-tracking Flutter app: habit tracker, journal, gym tracker, knowledge base, and profile/stats, built with a bespoke "Tenkai" design system (dark, minimal, monochrome-with-glow aesthetic). All platforms are scaffolded (iOS/Android/macOS/Windows/Linux/Web) but the project is developed primarily for iOS/macOS (uses `cupertino_native_better` for native Cupertino widgets like the tab bar).

## Commands

```bash
flutter pub get                    # install dependencies
flutter run                        # run on connected device/simulator
flutter analyze                    # lint (flutter_lints via analysis_options.yaml)
flutter test                       # run all tests (no test/ dir exists yet — add tests under test/)
flutter test test/some_test.dart   # run a single test file
dart run build_runner build --delete-conflicting-outputs   # regenerate Drift code after editing lib/core/database.dart
dart run build_runner watch --delete-conflicting-outputs   # regenerate Drift code continuously
```

There is no CI config, no lint rules beyond the default `flutter_lints` set, and no test suite currently exists.

## Architecture

### Feature-first layout

Code lives under `lib/core` (shared infra) and `lib/features/<feature>` (habit_tracker, journal, gym_tracker, knowledge, profile, auth). Each feature typically has its own `models/`, `providers/`, `repositories/`, `screens/`, and `widgets/` subfolders, but not every feature has all of them yet — some (e.g. `habit_tracker`, `knowledge`) are still stubs with just a screen.

### State management: Riverpod

- All DI/state uses `hooks_riverpod`. Providers are declared at the bottom of the file they belong to (e.g. `authRepositoryProvider` in `auth_repository.dart`, `exerciseRepositoryProvider` in `exercise_repository.dart`) rather than centralized in one file.
- `lib/core/providers.dart` holds only the app-wide `appDataBaseProvider` (the Drift `AppDatabase` singleton).
- Two state patterns coexist depending on the data source:
  - **Local (Drift) data** — expose a `StreamProvider` that wraps a Drift `.watch()` query directly (see `journal_entries_provider.dart`). No manual refresh needed; Drift re-emits on writes.
  - **Remote (Dio) or mixed data** — use a `Notifier<SomeState>` with an explicit state class (`loading`/`error`/data fields) and a `copyWith`, calling into a repository (see `UserStatNotifier` in `features/profile/provider/user_stat_provider.dart`).

### Repository pattern + error handling

- Repositories wrap either `DioClient` (remote) or `AppDatabase` (local), constructed via their own `Provider` at the bottom of the repository file.
- Remote repository methods return `Either<Failure, T>` (via `package:dartz`), produced through `RepositoryHelper.execute<T>` (single object) or `RepositoryHelper.executeList<T>` (list) in `lib/core/helpers/repository_helper.dart`. These helpers centralize `DioException` → `Failure` mapping (`NetworkFailure`, `ServerFailure`, `UnauthorizedFailure`, `UnknownFailure`, etc. — see `lib/core/errors/failures.dart`) so individual repository methods stay thin: just call the helper with a request closure and a `fromJson` parser.
- Many repository/screen methods are still unimplemented stubs (`throw Exception()`) — check before assuming a feature is wired up end-to-end (this is very visible in `AuthRepository` and `AppRouter`, where several routes/branches are commented out).

### Networking

- `DioClient` (`lib/core/network/dio_client.dart`) configures a single `Dio` instance with `ErrorDecoderInterceptor` → `AuthInterceptor` → `LogInterceptor`, base URL from `lib/core/network/api_endpoints.dart`.
- `AuthInterceptor` attaches tokens from `StorageService` (`flutter_secure_storage`-backed).

### Local persistence: Drift

- Single database defined in `lib/core/database.dart` (`AppDatabase`, schemaVersion 1), generated code in `database.g.dart` via `build_runner`/`drift_dev`. Tables so far: `UserStat`, `UserStatLog`, `JournalEntries`.
- After changing any `Table` definition or DAO method in `database.dart`, you must rerun `build_runner` (see Commands) before the app will compile.

### Routing: go_router

- `lib/core/configs/app_router.dart` defines a single `goRouterProvider` using `StatefulShellRoute.indexedStack` for the four bottom-tab branches (`/`, `/profile`, `/knowledge`, `/journal`), wrapped by `MainShellWrapper`. `/login` and `/register` sit outside the shell. The `gym_tracker` branch and routes are currently commented out — re-enabling it means uncommenting both the branch here and the tab item in `MainShellWrapper`.
- `MainShellWrapper` (`lib/core/widgets/main_shell_wrapper.dart`) renders the native `CNTabBar` (from `cupertino_native_better`) only when the current location is one of the four main tab routes, and manually maps `navigationShell.currentIndex` to SF Symbol names (filled vs outline) per tab.

### Design system (`lib/core/design_system/`)

- Single entry point `design_system/tenkai.dart` re-exports tokens, sounds, atoms, molecules, and theme — import that instead of individual files where possible. Note: it is not exhaustive — newer atoms (`tenkai_app_bar.dart`, `liquid_glass.dart`, `native_glass.dart`, `tenkai_icon.dart`, `tenkai_node.dart`, `tenkai_form_error.dart`, `tenkai_record_button.dart`) exist under `atoms/` but aren't yet re-exported from `tenkai.dart`; import them directly when needed and consider adding the export.
- `tokens/` holds the raw design values (`TenkaiColors`, `TenkaiTypography`, `TenkaiRadius`, `TenkaiSpacing`, `TenkaiDuration`, `TenkaiCurves`, glow tokens) re-exported via `tokens/tenkai_tokens.dart`.
- Visual language: dark-only (`TenkaiTheme.dark`), `useMaterial3: false`, near-black grayscale (`gray950`…`white`) plus semantic success/warning/error colors and a white-glow ("LED") accent set (`ledDim`…`ledFull`) used for focus/glow effects. Sharp corners by default (`TenkaiRadius.sharp` on inputs).
- `sounds/tenkai_sound.dart` provides app-wide UI sound effects, initialized once in `main()` via `TenkaiSound.initialize()` before `runApp`.
- Custom shared page transition (`TenkaiPageTransitionBuilder`) is wired into `pageTransitionsTheme` for every platform, so all platforms share the same transition instead of platform defaults.

## Notes for future work

- Several routes/screens/repository methods are intentionally unfinished (commented-out routes, `throw Exception()` stubs) — treat these as "not yet implemented," not bugs to silently fix, unless the task is specifically to implement them.
- No test directory exists yet; when adding tests, standard Flutter convention (`test/` mirroring `lib/`) applies.
