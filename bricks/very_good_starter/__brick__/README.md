# {{project_name.titleCase()}}

{{description}}

## Features

- ✅ **Authentication**: Firebase Auth OR Supabase Auth with email/password
- ✅ **Anonymous Login**: Allow users to try your app without signing up
- ✅ **Form Validation**: Using formz for type-safe, reusable form validation
- ✅ **Onboarding**: Multi-step onboarding flow
- ✅ **State Management**: Bloc pattern for predictable state management
- ✅ **Repository Pattern**: Clean architecture with separation of concerns
- ✅ **Navigation**: Go Router for declarative routing
- 🚧 **Subscriptions**: Ready for payment integration (RevenueCat/IAP)
- 🚧 **Notifications**: Firebase Cloud Messaging setup

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.0
- **Choose one**: Firebase project OR Supabase project

### Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. **Option A: Configure Firebase**
   - Add `google-services.json` for Android in `android/app/`
   - Add `GoogleService-Info.plist` for iOS in `ios/Runner/`
   - In `lib/main.dart`, ensure `authBackend = AuthBackend.firebase`

3. **Option B: Configure Supabase**
   - Create a Supabase project at https://supabase.com
   - Get your project URL and anon key
   - In `lib/main.dart`, set `authBackend = AuthBackend.supabase`
   - Run with environment variables:
     ```bash
     flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
     ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── app/                    # App widget and routing
├── authentication/         # Authentication feature
│   ├── bloc/              # Authentication Bloc
│   ├── models/            # Formz validation models
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
- **Repository**: Abstraction layer for data sources (supports Firebase & Supabase)
- **Formz**: Type-safe form validation
- **View**: UI layer that reacts to state changes

## Authentication Backends

### Firebase Authentication
- Email/Password login
- Anonymous authentication
- Well-tested and production-ready

### Supabase Authentication
- Email/Password login
- Anonymous authentication
- Open-source alternative with PostgreSQL database
- Built-in Row Level Security (RLS)

Switch between backends by changing `authBackend` in `lib/main.dart`.

## Form Validation

Forms use the **formz** package for:
- Type-safe validation logic
- Reusable validators
- Automatic form status tracking
- Email validation with regex
- Password strength validation (8+ chars, letters + numbers)

## Testing

Run tests:
```bash
flutter test
```

## Contributing

Contributions are welcome! Please read the contributing guidelines first.

## License

This project is licensed under the MIT License.
