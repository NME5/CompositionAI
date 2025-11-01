# CompositionAI UI

A Flutter application for smart body composition analysis using BIA (Bioelectrical Impedance Analysis) scales.

## Architecture

This project follows the **MVVM (Model-View-ViewModel)** architectural pattern for better separation of concerns and maintainability.

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── body_metrics.dart    # Body composition metrics
│   ├── device.dart          # BIA scale device model
│   ├── insight.dart         # AI insights and recommendations
│   └── user_profile.dart    # User profile and stats
├── viewmodels/              # ViewModels for state management
│   ├── analytics_view_model.dart
│   ├── home_view_model.dart
│   ├── insights_view_model.dart
│   └── profile_view_model.dart
├── views/ (pages/)          # UI Views/Pages
│   ├── analytics_page.dart
│   ├── home_page.dart
│   ├── insights_page.dart
│   └── profile_page.dart
├── widgets/                 # Reusable UI widgets
│   ├── dialogs.dart
│   └── shared_widgets.dart
└── services/                # Business logic services
    └── data_service.dart
```

### MVVM Components

#### Models (`lib/models/`)
Data structures that represent the application's business entities:
- **BodyMetrics**: Weight, muscle mass, body fat, water, bone mass, BMR
- **Device**: BIA scale device information
- **UserProfile**: User personal information and statistics
- **Insight**: AI-generated insights and health recommendations

#### ViewModels (`lib/viewmodels/`)
Manages the state and business logic for each view:
- Extends `ChangeNotifier` for reactive updates
- Handles user interactions and data transformations
- Notifies views when state changes

#### Views (`lib/pages/`)
UI components that display data and handle user input:
- Composed of Flutter widgets
- Observe ViewModels for state updates
- Dispatch user actions to ViewModels

#### Services (`lib/services/`)
Centralized business logic and data access:
- **DataService**: Mock data provider (replace with actual API calls)

#### Widgets (`lib/widgets/`)
Reusable UI components:
- **SharedWidgets**: StatCard, MetricCard, ChartPainter
- **Dialogs**: ConnectScaleDialog, MeasurementDialog

### Features

- 📊 **Home Dashboard**: Real-time connection status and body composition overview
- 📈 **Analytics**: Detailed body metrics with charts and trends
- 🧠 **AI Insights**: Personalized recommendations and health scoring
- 👤 **Profile**: User settings and preferences management
- ⚖️ **Scale Integration**: BIA scale device connection and measurement

### Getting Started

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

3. For Gradle issues (corrupted wrapper):
```bash
# Delete corrupted Gradle files
rm -rf ~/.gradle/wrapper/dists

# Or on Windows:
del /s /q %USERPROFILE%\.gradle\wrapper\dists

# Then rebuild
flutter clean
flutter pub get
flutter run
```

### Development Notes

- All ViewModels extend `ChangeNotifier` for reactive UI updates
- Views use `AnimatedBuilder` to rebuild when ViewModels change
- Service layer provides easy mock data replacement with real APIs
- Widgets are modular and reusable across different screens

### Future Enhancements

- Replace mock data in `DataService` with actual API integration
- Add real BIA scale connectivity via Bluetooth
- Implement data persistence (local database)
- Add user authentication and cloud sync
- Expand AI insights with machine learning models
