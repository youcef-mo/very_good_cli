# {{project_name.titleCase()}}

{{description}}

## Features

- ✅ **Authentication**: Firebase Auth integration with email/password
- ✅ **Onboarding**: Multi-step onboarding flow
- ✅ **State Management**: Bloc pattern for predictable state management
- ✅ **Repository Pattern**: Clean architecture with separation of concerns
- ✅ **Navigation**: Go Router for declarative routing
- 🚧 **Subscriptions**: Ready for payment integration (RevenueCat/IAP)
- 🚧 **Notifications**: Firebase Cloud Messaging setup

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.0
- Firebase project configured

### Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Configure Firebase:
   - Add `google-services.json` for Android in `android/app/`
   - Add `GoogleService-Info.plist` for iOS in `ios/Runner/`

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── app/                    # App widget and routing
├── authentication/         # Authentication feature
│   ├── bloc/              # Authentication Bloc
│   ├── repository/        # Authentication Repository
│   └── view/              # Login/Signup UI
├── onboarding/            # Onboarding feature
│   ├── bloc/              # Onboarding Bloc
│   └── view/              # Onboarding UI
└── home/                  # Home feature
    └── view/              # Home UI
```

## Architecture

This project follows the **Bloc pattern** with **Repository pattern** for data management:

- **Bloc**: Business Logic Component for state management
- **Repository**: Abstraction layer for data sources
- **View**: UI layer that reacts to state changes

## Testing

Run tests:
```bash
flutter test
```

## Contributing

Contributions are welcome! Please read the contributing guidelines first.

## License

This project is licensed under the MIT License.
