# Flutter Development Guidelines — MVVM / MVC (Simplified) (CLAUDE.md)

This file defines the architecture, structure, and conventions Claude Code
must follow when creating or modifying Flutter code in this project.
Use this file for data-thin features that don't need a full domain layer
(no usecases, no separate datasource abstraction). For features with real
business rules, use `CLAUDE-clean-arch.md` instead.

Do not deviate from these patterns unless explicitly told to.

---

## 1. pubspec.yaml Conventions

Group dependencies by purpose with comment headers, in this order:

```yaml
name: your_app_name
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.4 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Style And Widgets
  cupertino_icons: ^1.0.6
  toastification: ^2.0.0
  flutter_svg: ^2.0.10+1
  skeletonizer: ^1.4.2
  cached_network_image: ^3.3.1

  # App Controller And Helpers
  flutter_bloc: ^8.1.3
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  intl: ^0.18.1
  dartz: ^0.10.1
  get_it: ^7.6.4
  easy_localization: ^3.0.7
  go_router: ^13.0.0

  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  hive: ^2.2.3          # or sqflite — pick ONE per project, not both
  hive_flutter: ^1.1.0

  # Remote Network
  dio: ^5.3.3
  pretty_dio_logger: ^1.3.1
  connectivity_plus: ^6.0.2

  # Firebase (optional — only if project uses Firebase)
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  firebase_crashlytics: ^3.4.9
  firebase_analytics: ^10.7.4

  # Device & Permissions
  permission_handler: ^11.1.0
  device_info_plus: ^9.1.1
  url_launcher: ^6.2.2
  image_picker: ^1.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter

  # App Analyzer
  flutter_lints: ^3.0.0
  custom_lint: ^0.5.7
  dart_code_metrics: ^5.7.6

  # Code Generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/svg/
    - assets/translations/
  fonts:
    - family: InterFont
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
```

---

## 2. Package Reference (by purpose)

| Category | Package(s) |
|---|---|
| Code generation | `freezed`, `freezed_annotation`, `build_runner`, `json_serializable` |
| Routing | `go_router` |
| Image caching | `cached_network_image` |
| Form validation | custom `AppValidators` extension on `String?` (no external package) |
| Firebase | `firebase_core`, `firebase_messaging`, `firebase_crashlytics`, `firebase_analytics` |
| Permissions | `permission_handler` |
| Device info | `device_info_plus` |
| Dependency Injection | `get_it` |
| Networking | `dio` + `pretty_dio_logger` |
| Cache | `shared_preferences` (general), `flutter_secure_storage` (tokens/credentials) |
| Local DB | `hive` **or** `sqflite` — chosen per project, never both together |
| Lint | `flutter_lints` + `custom_lint` + `dart_code_metrics` |
| State management | `flutter_bloc` (Cubit only — no Bloc/Events) |
| Functional returns | `dartz` (`Either<Failure, T>`) |
| UI/UX | `toastification`, `flutter_svg`, `skeletonizer` |
| Utilities | `url_launcher`, `image_picker` |

**Storage rule:** tokens/credentials → `flutter_secure_storage`. Everything else (settings, flags, cached simple values) → `shared_preferences`.

---

## 3. lib/ Top-Level Structure

```
lib/
  core/
  features/
  shared/
  main.dart          # only the main() function — no setup logic here
  app.dart            # root MaterialApp / MaterialApp.router
  firebase_options.dart   # optional, only if Firebase is used
```

## 4. assets/ Structure

```
assets/
  images/
  icons/
  svg/
  translations/
  fonts/
```

---

## 5. core/ Structure

```
core/
├── api/
│   ├── base_api_service.dart
│   ├── dio_api_service.dart
│   ├── end_points.dart
│   └── interceptors/
│       └── custom_interceptors.dart
├── cache/
│   └── shared_preferences_service.dart
├── config/
│   ├── router/
│   │   ├── app_router.dart
│   │   ├── route_pages.dart
│   │   └── routes.dart
│   └── themes/
│       ├── app_colors.dart      # single source of truth for colors
│       └── app_theme.dart
├── connection/
│   └── network_info.dart
├── di/
│   ├── service_locator.dart
│   └── service_locator_imports.dart
├── error/
│   ├── error_handler.dart       # canonical ApiErrorHandler (see §8)
│   └── failure.dart
├── helpers/
│   ├── app_helper.dart
│   ├── debouncer.dart
│   ├── permission_service.dart
│   └── throttler.dart
├── localization/
│   ├── codegen_loader.g.dart
│   ├── locale_keys.g.dart
│   └── locale_manager.dart
└── utils/
    ├── asset_paths.dart
    ├── constants.dart
    ├── screen_size.dart
    └── validators.dart
```

**Important:** `app_colors.dart` lives ONLY in `config/themes/`. Never
duplicate it in `utils/` — colors are part of the design system, not a
generic utility.

---

## 6. features/ Structure (Simplified — MVVM/MVC, 2-Layer)

No `domain/` layer, no usecases, no separate datasource abstraction.
Repositories are called directly from the Cubit (ViewModel).

```
lib/features/notifications/
├── data/
│   ├── models/
│   │   └── notifications_model.dart
│   ├── params/
│   │   └── device_data_params.dart
│   ├── repositories/
│   │   └── notifications_repo.dart              # interface
│   └── repositories_implementation/
│       ├── salon_notifications_repo_implementation.dart
│       └── team_member_notifications_repo_implementation.dart
└── presentation/
    ├── controller/
    │   ├── notifications_cubit.dart
    │   ├── notifications_cubit.freezed.dart      # generated
    │   └── notifications_state.dart
    └── view/
        ├── screens/
        │   ├── notifications/
        │   │   ├── notification_screen.dart
        │   │   └── widgets/
        │   └── notifications_settings/
        │       ├── notification_settings_screen.dart
        │       └── widgets/
        └── shared_widgets/
            ├── filter_button.dart
            └── notification_widget.dart
```

### Rules
- `data/repositories/` defines the interface; `data/repositories_implementation/`
  holds the implementation(s) — multiple implementations are allowed when a
  feature serves different user roles (e.g. `salon_...`, `team_member_...`).
- The Cubit (`presentation/controller/`) calls the repository directly —
  no usecase layer in between.
- Cubit state is a `freezed` union — see §9 for the base shape.
- Views only read Cubit state and call Cubit methods — no business logic in views.

### When to use this tier
Use this simplified structure when the feature is mostly data
display/passthrough with minimal business rules — fetching, showing, maybe
light client-side filtering — and doesn't need independently-testable
business logic or multiple data source abstractions.

---

## 7. shared/ Structure

```
lib/shared/
├── custom_widgets/    # e.g. custom TextEditingController, app buttons
├── controllers/       # APP-LEVEL cubits only (ThemeCubit, LocaleCubit, ConnectivityCubit)
├── models/             # models used by 2+ features
├── params/             # params used by 2+ features
└── components/         # full reusable states/screens (error state, no-internet screen, etc.)
```

**Note:** `shared/controllers/` is only for cubits that represent app-wide
state, not tied to one feature. Feature-specific cubits always live in
`features/<name>/presentation/controller/`.

---

## 8. Networking & Error Handling

### `BaseApiService` (contract)

```dart
abstract class BaseApiService {
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters, Options? options});
  Future<Response> post(String endpoint, {Map<String, dynamic>? queryParameters, dynamic body, bool enableFormData = false, Options? options});
  Future<Response> put(String endpoint, {Map<String, dynamic>? queryParameters, dynamic body, bool enableFormData = false});
  Future<Response> delete(String endpoint, {Map<String, dynamic>? queryParameters});
}
```

### `DioApiService` (implementation)
- Configure `BaseOptions` with: `baseUrl`, 30s `connectTimeout`/`receiveTimeout`,
  `followRedirects: false`, `receiveDataWhenStatusError: true`, and a custom
  `validateStatus` that accepts status codes up to 999 (so error bodies reach
  `ApiErrorHandler` instead of throwing before you can parse them).
- Interceptors: always add `CustomInterceptor`; add `PrettyDioLogger` only
  `if (kDebugMode)`.

### `EndPoints`
- Private constructor (`EndPoints._()`).
- All static routes as `static const String NAME = '/path'` (SCREAMING_CASE).
- Parameterized routes as static methods returning `String`.

### `CustomInterceptor`
- `onRequest`: attach `Authorization: Bearer <token>` (read via `sl<SharedPreferencesService>()`) and `Content-Type: application/json` to every request.
- `onError`: on `401`, clear the stored token and navigate to the login route via `GoRouter` (`context.go(Routes.login)`), using a global navigator key.

### `Failure` hierarchy

```dart
abstract class Failure extends Equatable implements Exception {
  const Failure(this.message);
  final String message; // localization key, e.g. 'failure.bad_request'
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure { const ServerFailure(super.message); }
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, this.errors);
  final Map<String, List<String>> errors;
  @override
  List<Object?> get props => [message, errors];
}
class UnauthorizedFailure extends Failure { const UnauthorizedFailure(super.message); }
class NotFoundFailure extends Failure { const NotFoundFailure(super.message); }
class UnknownFailure extends Failure { const UnknownFailure(super.message); }
class RateLimitFailure extends Failure { const RateLimitFailure(super.message); }
class NoInternetFailure extends Failure { const NoInternetFailure() : super('failure.no_internet'); }
class UnexpectedFailure extends Failure { const UnexpectedFailure() : super('failure.unexpected'); }
// Feature-specific failures are allowed
```

All `Failure.message` values are **localization keys** (`easy_localization`),
never raw English strings.

### `ApiErrorHandler` (canonical — the "advanced" version)
- Uses the `logging` package to log every error (endpoint, DioExceptionType,
  status code, response data) before mapping it.
- Switches on `DioExceptionType` first (timeout types → `NoInternetFailure`,
  `badCertificate` → `ServerFailure`, `badResponse` → delegate to status-code
  handling, `cancel`, `connectionError`, `unknown`).
- Maintains a `_statusCodeMessages` map covering 400/401/403/404/405/409/422/429/5xx.
- Parses validation errors (422) supporting multiple API shapes: `errors` as
  a `Map<String, List<String>>`, `errors` as a `List` of `{message}` objects,
  or a single `{field, message}` object.
- Extracts a human-readable message from the response body when available,
  falling back to the status-code map.

---

## 9. Dependency Injection (`service_locator.dart`)

Registration order — always in this sequence:

```dart
part of 'service_locator_imports.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  sl
    //! Features (repository, then implementation, per feature)
    ..registerLazySingleton<NotificationsRepo>(
      () => SalonNotificationsRepoImplementation(apiHelper: sl()),
    )
    //! Core
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))
    ..registerLazySingleton<BaseApiService>(() => DioApiService(dioClient: sl<Dio>()))
    //! External
    ..registerLazySingleton<SharedPreferencesService>(SharedPreferencesService.new)
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<Dio>(Dio.new);
}
```

Always `registerLazySingleton` unless a fresh instance is explicitly required
per use (then use `registerFactory`).

---

## 10. Base Cubit / State Convention

Every Cubit's `freezed` state must include at minimum these four cases:

```dart
@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial() = _Initial;
  const factory NotificationsState.loading() = _Loading;
  const factory NotificationsState.success(List<NotificationModel> items) = _Success;
  const factory NotificationsState.error(String message) = _Error;
}
```

Additional states (e.g. `refreshing`, `paginating`) may be added per feature
on top of this baseline — never remove the baseline four.

---

## 11. Helpers & Validators

- `AppHelper` — static utility class (scroll physics, `closeKeyboard()`, `hasNotch(context)`).
- `AppDebouncer` — instantiable, `AppDebouncer(milliseconds: n)`, call `.run(action)` to reset/schedule a `Timer`.
- `AppThrottler` — instantiable, `AppThrottler(durationSeconds: n)`, call `.run(action)` → returns `bool` (whether it executed).
- `AppPermissionService` — static methods per permission type, always check `status` before calling `.request()`.
- `AppValidators` — extension on `String?`. Every validator returns either
  `null` (valid) or a **localization key** (e.g. `'validation.required_email'`).
  Methods: `.email()`, `.password()`, `.required()`, `.numbersExactLength(n)`,
  `.minLength(n)`, `.phoneNumber()`, `.identical(other)`.

---

## 12. Linting

- Base: `flutter_lints` + `custom_lint` plugin + `dart_code_metrics`.
- Metrics thresholds: cyclomatic-complexity ≤ 20, lines-of-code ≤ 100/file,
  number-of-arguments ≤ 4, number-of-methods ≤ 10, maximum-nesting ≤ 5,
  maintainability-index ≥ 80.
- Notable enforced rules: `require_trailing_commas`, `sort_constructors_first`,
  `prefer_single_quotes`, `lines_longer_than_80_chars`, `directives_ordering`,
  `avoid_print`, `unawaited_futures`, `always_declare_return_types`.
- Excludes generated files: `**/*.g.dart`, `**/*.freezed.dart`, `lib/generated/**`.

---

## 13. Naming Conventions Recap

- Files: `snake_case.dart`
- Screens: `xxx_screen.dart`
- Cubits: `xxx_cubit.dart` + `xxx_state.dart` (+ generated `xxx_cubit.freezed.dart`)
- Repositories: interface `xxx_repo.dart`, impl `xxx_repo_implementation.dart` in `repositories_implementation/`
- Models: `xxx_model.dart`
