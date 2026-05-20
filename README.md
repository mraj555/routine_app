# Routine App

A Flutter mobile application for managing daily routines with local database storage and external API integration.

## Features

- **Routine Management** - Create, read, update, and delete routines
- **Category System** - Organize routines by categories with custom categories
- **Time Scheduling** - Set start times for routines using time picker
- **Day Selection** - Assign routines to specific days of the week
- **Search Functionality** - Search routines by title
- **Product Integration** - Fetch products from FakeStoreAPI and store locally
- **API Export** - Upload local products to a custom server
- **Real-time Updates** - Automatic UI refresh when data changes
- **Dark Theme** - Modern dark-themed UI with gradient accents

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x |
| Language | Dart ^3.11.5 |
| Local Database | Isar ^3.1.0+1 |
| HTTP Client | Dio ^5.9.2 |
| Logging | Logger ^2.7.0 |
| State Management | Built-in StatefulWidget |

## Architecture

The app follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── collections/          # Data models and Isar schemas
│   ├── category/        # Category model
│   ├── product/         # Product model (embedded rating)
│   └── routine/         # Routine model with links
├── pages/               # UI screens
│   ├── main_page.dart       # Home with routine list & products
│   ├── create_routine_page.dart
│   └── update_routine_page.dart
├── service/             # Business logic layer
│   └── api_service.dart     # HTTP client wrapper
├── config.dart          # Configuration constants
└── main.dart            # App entry point
```

### Data Layer (Collections)

- **Routine** - Contains title, startTime, day, and category link
- **Category** - Unique category names with indexing
- **Product** - External product data with embedded Rating

### Service Layer

- **APIService** - HTTP client supporting GET, POST, DELETE, PATCH methods

### UI Layer

- **MainPage** - Dashboard with routine list, search, products grid
- **CreateRoutinePage** - Form to add new routines
- **UpdateRoutinePage** - Edit existing routines with delete option

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / Xcode for platform-specific setup

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```

2. Navigate to project directory:
   ```bash
   cd routine_app
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Generate Isar schemas:
   ```bash
   flutter pub run build_runner build
   ```

5. Run the app:
   ```bash
   flutter run
   ```

### Configuration

The app uses the following configuration in `lib/config.dart`:

```dart
const String baseUrl = 'https://fakestoreapi.com/';
const String serverUrl = 'http://192.168.1.8:5000';
```

Modify these URLs to point to your desired API endpoints.

## Usage

### Creating a Routine
1. Tap the **+** icon in the app bar
2. Select or create a category
3. Enter routine title
4. Select start time using the time picker
5. Choose the day of the week
6. Tap "Add Routine"

### Managing Products
- **Download**: Tap the download icon to fetch products from FakeStoreAPI
- **Upload**: Tap the upload icon to send local products to your server

### Searching
Use the search bar on the main page to filter routines by title.

### Deleting
Navigate to a routine and tap the delete icon in the app bar.

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  isar: ^3.1.0+1
  isar_generator: ^3.1.0+1
  build_runner: ^2.4.13
  path_provider: ^2.1.5
  isar_flutter_libs: ^3.1.0+1
  dio: ^5.9.2
  logger: ^2.7.0
```

## Build

### Android
```bash
flutter build apk
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

## Color Scheme

| Color | Hex Code | Usage |
|-------|----------|-------|
| Background | #0D0D0D | Main background |
| Surface | #1A1A2E | Cards, inputs |
| Primary | #6C63FF | Buttons, accents |
| Secondary | #00D4AA | Gradients, highlights |
| Error | #FF4757 | Delete actions |
| Text Secondary | #B0B0C3 | Hints, labels |

## License

This project is open source and available under the MIT License.