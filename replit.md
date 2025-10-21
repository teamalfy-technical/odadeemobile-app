# Odadee - Flutter Mobile App

## Overview
Odadee is a Flutter mobile application that has been configured to run as a web application in the Replit environment. The app is a community platform that includes features like:
- User authentication (Sign In/Sign Up)
- News and articles
- Events management
- Radio streaming
- Project funding and dues payment
- User profiles and settings

## Project Status
**Current State**: Fully functional Flutter web application running on Replit
**Last Updated**: October 21, 2025

## Architecture

### Technology Stack
- **Framework**: Flutter 3.32.0
- **Language**: Dart 3.8.0
- **Platform**: Web (originally a mobile app)
- **Backend API**: http://api.odadee.net

### Project Structure
```
lib/
├── components/        # Reusable components (theme, buttons, etc.)
├── Screens/          # App screens organized by feature
│   ├── AllUsers/     # User listing and profiles
│   ├── Articles/     # News and articles
│   ├── Authentication/  # Sign in/up, password reset
│   ├── Dashboard/    # Main dashboard
│   ├── Events/       # Events listing and details
│   ├── Onboarding/   # App onboarding
│   ├── Profile/      # User profile
│   ├── Projects/     # Project funding and dues
│   ├── Radio/        # Radio streaming
│   ├── Settings/     # App settings
│   └── SplashScreen/ # Initial splash screen
├── constants.dart    # App constants and utilities
└── main.dart        # App entry point
```

### Key Dependencies
- `device_preview`: For responsive design preview
- `firebase_core` & `firebase_messaging`: Push notifications (currently disabled)
- `http`: API communication
- `image_picker` & `image_cropper`: Image handling
- `radio_player`: Audio streaming
- `shared_preferences`: Local data storage
- `intl`: Internationalization and date formatting

## Configuration

### Environment Setup
- **Flutter**: Installed via Nix package manager
- **Web Support**: Enabled for browser-based deployment
- **Dev Server**: Running on port 5000 with host 0.0.0.0

### Workflow
The app runs using the command:
```bash
flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0
```

### Deployment
- **Type**: Autoscale (stateless web app)
- **Build Command**: `flutter build web --release`
- **Run Command**: `flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0 --release`

## Recent Changes
- **2025-10-21**: Initial Replit setup
  - Installed Flutter and Dart dependencies
  - Fixed import case sensitivity issues (Components -> components)
  - Enabled web platform support
  - Updated intl package from 0.19.0 to 0.20.2 to resolve dependency conflicts
  - Configured workflow to serve on port 5000
  - Set up deployment configuration for production

## Development Notes

### Known Issues
- Firebase integration is currently commented out in main.dart
- The app requires an API key stored in SharedPreferences to access main features
- Some packages have newer versions available but are constrained by dependencies

### Important Files
- `lib/main.dart`: Main entry point with DevicePreview enabled for development
- `lib/constants.dart`: Contains API endpoints and helper functions
- `pubspec.yaml`: Flutter dependencies and configuration
- `web/index.html`: Web entry point (auto-generated)

## User Preferences
None documented yet.

## API Integration
The app connects to a backend API at `http://api.odadee.net` for:
- User authentication and management
- News and articles
- Events data
- Projects and funding
- Radio streams

Authentication is handled via Bearer tokens stored in SharedPreferences.
