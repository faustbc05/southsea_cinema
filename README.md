# Southsea Cinema

Southsea Cinema is a Flutter coursework application for browsing cinema
screenings and creating ticket bookings. Movie data is loaded from the
application assets, and the app provides a simple flow from movie details to a
basket, checkout, and booking history.

## Features

- Browse the available movies and view their descriptions, age ratings,
  screening details, locations, runtimes, and ticket prices.
- Select ticket quantities from a movie listing and add tickets to a shared
  basket. The basket displays item quantities, line totals, and the order total.
- Remove individual items or clear the basket.
- Check out a basket to create a booking with a generated booking number using
  transaction-protected SQLite checkout.
- Store itemised booking records and display previous bookings in descending
  booking-number order using SQLite version 2.
- Manage profile settings including full name, address, email address, and
  newsletter preference.
- Switch between light and dark themes. The selected theme and profile
  settings are persisted between app launches.

## Technologies and dependencies

- [Flutter](https://flutter.dev/) and Dart
- `material_ui` for the Material-based user interface
- `shared_preferences` for profile settings and theme persistence
- `sqflite` for the local SQLite booking database
- `path` for constructing the database file path
- `sqflite_common_ffi` for database support in tests
- `flutter_test` and `flutter_lints` for automated testing and static analysis

Movie data and poster images are bundled under `assets/data/` and
`assets/images/`.

## Getting started

### Prerequisites

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and
ensure that `flutter` is available on your command line. A connected device,
emulator, or supported desktop/web target is also required to run the app.

### Install dependencies

From the project directory, fetch the Dart and Flutter packages:

```bash
flutter pub get
```

### Run the app

List available targets if needed:

```bash
flutter devices
```

Run the app on a selected target:

```bash
flutter run -d <device-id>
```

For example, when Chrome is available as a Flutter target:

```bash
flutter run -d chrome
```

## Tests and static analysis

Run the complete automated test suite with:

```bash
flutter test
```

The tests cover models, repositories, database operations, widgets, and key
view interactions.

Run Dart and Flutter static analysis with:

```bash
flutter analyze
```

The analysis configuration is in `analysis_options.yaml` and is based on
`flutter_lints`.

## Project structure

```text
southsea_cinema/
|-- assets/
|   |-- data/movies.json          # Movie catalogue data
|   `-- images/                   # Movie artwork
|-- lib/
|   |-- constants.dart            # Shared app constants and theme values
|   |-- main.dart                 # Application entry point and routes
|   |-- database/
|   |   `-- cinema_db.dart        # SQLite booking persistence
|   |-- models/                   # Movie, basket, booking, and settings models
|   |-- repositories/             # Movie and basket data access
|   |-- views/                    # Home, listing, basket, and settings screens
|   `-- widgets/                  # Reusable cards, buttons, and navigation
|-- test/
|   |-- database/                 # Database tests
|   |-- models/                   # Model tests
|   |-- repositories/             # Repository tests
|   |-- views/                    # Screen/widget interaction tests
|   |-- widgets/                  # Reusable widget tests
|   `-- widget_test.dart          # Application-level widget tests
|-- analysis_options.yaml         # Static analysis and lint configuration
|-- pubspec.yaml                  # Package metadata and dependencies
`-- README.md                     # Project documentation
```
