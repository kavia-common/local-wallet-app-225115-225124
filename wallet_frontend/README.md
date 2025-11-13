# Local Wallet - Flutter (Frontend only)

This is a local-only wallet app built with Flutter. All data is stored on the device using SQLite via `sqflite`. State management is provided by `provider`. No backend or external services are used.

## Features

- Three tabs with bottom navigation:
  - Home: balance and this month's income/expense
  - Transactions: list with basic type filter
  - Categories: manage categories (add/edit/delete)
- Floating action button to add new transactions via a bottom sheet
- Validation for required fields and positive amounts
- Material 3 theming with light/dark mode
- Local currency formatting using `intl`

## Setup

1. Ensure Flutter SDK is installed.
2. From the project root, run:
   ```
   cd wallet_frontend
   flutter pub get
   flutter run
   ```

## Data Model

- Table `categories`
  - id INTEGER PRIMARY KEY AUTOINCREMENT
  - name TEXT NOT NULL UNIQUE
  - color INTEGER NOT NULL
  - icon TEXT NOT NULL

- Table `transactions`
  - id INTEGER PRIMARY KEY AUTOINCREMENT
  - amount INTEGER NOT NULL            (stored in cents)
  - type TEXT NOT NULL CHECK(type IN ('income','expense'))
  - category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE RESTRICT
  - note TEXT
  - date INTEGER NOT NULL              (epoch millis)

Indices:
- idx_transactions_date on `transactions(date)`
- idx_transactions_category on `transactions(category_id)`

## Architecture

- Database helper (singleton) sets up schema and indices.
- DAO layer encapsulates SQLite operations.
- Repository layer performs validation and domain operations.
- Provider (`ChangeNotifier`) exposes computed values and lists to UI.
- UI is split into screens and reusable widgets.

## Testing

The repo includes basic unit and widget tests:
- `test/unit/transaction_repository_test.dart`
- `test/unit/category_repository_test.dart`
- `test/widget/navigation_and_fab_test.dart`

Note: Tests use in-memory fakes for repositories to avoid platform (SQLite) constraints. If you want to test SQLite queries directly in pure Dart, consider `sqflite_common_ffi` in your test environment.

Run tests:
```
flutter test
```

## ADR: SQLite choice

We selected `sqflite` for:
- Mature, widely-used plugin for local persistence
- Simple schema evolution
- Good performance for local datasets
- Supports indices and constraints we rely on

The app is intentionally offline-first and local-only.

## Security & Privacy

- No network calls
- No sensitive data leaves the device
- SQL queries are parameterized to mitigate injection risks

## Notes

- Currency formatting uses locale defaults. You can change the locale via device settings.
- Amounts are stored in cents to avoid floating point rounding issues.
