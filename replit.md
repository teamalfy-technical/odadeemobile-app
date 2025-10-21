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
- **Port**: 5000 (mapped to external port 80)

### Production Optimization
**Web Configuration:**
- SEO-optimized meta tags for search engines
- Open Graph tags for social media sharing
- PWA manifest with dark theme colors (#0f172a)
- Proper viewport and theme-color meta tags
- Apple mobile web app capabilities enabled

**Build Optimization:**
- Production builds use `--release` flag for optimal performance
- DevicePreview automatically disabled in release mode
- Code minification and tree-shaking enabled
- Debug statements (debugPrint) automatically suppressed in release builds

**Performance Features:**
- Autoscale deployment for efficient resource usage
- Optimized asset loading
- Dark theme reduces battery usage on OLED screens
- Responsive design with proper viewport configuration

## Production Deployment

### How to Deploy
1. Click the **"Publish"** button in Replit to deploy to production
2. Replit will automatically:
   - Run `flutter build web --release` to create optimized production build
   - Deploy the app to an autoscale server
   - Assign a public URL for your app

### Production Checklist
- ✅ Dark theme matching website branding
- ✅ SEO meta tags configured
- ✅ PWA manifest with proper theme colors
- ✅ DevicePreview disabled in production
- ✅ Release mode optimizations enabled
- ✅ Responsive design for all devices
- ✅ Error handling for network failures
- ✅ Web platform detection for mobile-only features

### Monitoring Production
- Check the deployment logs in Replit for any build errors
- Test the published URL on multiple devices
- Verify all API endpoints are accessible from production
- Monitor user feedback for any issues

### Troubleshooting Deployment Issues

**If you encounter "Flutter dependency cache corrupted" error:**
1. Clear the Flutter pub cache:
   ```bash
   echo y | flutter pub cache clean
   ```

2. Reinstall dependencies:
   ```bash
   flutter pub get
   ```

3. Test the production build:
   ```bash
   flutter clean && flutter build web --release
   ```

4. If errors persist, ensure the `meta` package is explicitly listed in `pubspec.yaml` dependencies

**Note:** The `meta` package has been added as an explicit dependency to prevent annotation errors in production builds.

## Recent Changes
- **2025-10-21**: Production Deployment Fix
  - Fixed corrupted Flutter dependency cache issue
  - Added explicit `meta` package dependency to prevent annotation errors
  - Cleared and reinstalled all Flutter packages
  - Verified production build compiles successfully
  - App ready for deployment


- **2025-10-21**: Dark Theme Update to Match Website
  - Updated color scheme in `constants.dart` to match website design:
    - Dark navy background (#0f172a)
    - Blue primary accent (#2563eb) 
    - Yellow secondary accent (#f4d03f)
    - Card background (#1e293b)
    - White text for dark theme
  - Updated `theme.dart` with comprehensive dark theme:
    - Dark color scheme with proper contrast
    - Styled cards with rounded corners and elevation
    - Styled buttons with blue accent color
    - Styled input fields with dark background and blue focus
  - Updated splash screen with gradient background
  - Updated loading indicators to match dark theme
  - All UI components now consistent with website branding

- **2025-10-21**: Critical Bug Fixes
  - Fixed splash screen timer memory leak
  - Fixed dashboard null safety crash
  - Added navigation safety checks
  - Improved error handling for network failures
  - Added web platform detection for camera features
  
- **2025-10-21**: Initial Replit setup
  - Installed Flutter 3.32.0 and Dart 3.8.0 via Nix package manager
  - Fixed import case sensitivity issues (Components -> components)
  - Enabled web platform support
  - Updated SDK constraint from ">=2.18.6 <3.0.0" to ">=3.3.0 <4.0.0" for Dart 3.x compatibility
  - Updated intl package from 0.19.0 to 0.20.2 to resolve dependency conflicts with flutter_localizations
  - Configured workflow to serve on port 5000 with 0.0.0.0 hostname
  - Set up deployment configuration for production

## Development Notes

### Known Issues
- Firebase integration is currently commented out in main.dart
- The app requires an API key stored in SharedPreferences to access main features
- Some packages have newer versions available but are constrained by dependencies

### Important Files
- `lib/main.dart`: Main entry point with DevicePreview enabled for development
- `lib/constants.dart`: Contains API endpoints, color constants, and helper functions
- `lib/components/theme.dart`: Dark theme configuration matching website design
- `pubspec.yaml`: Flutter dependencies and configuration
- `web/index.html`: Web entry point (auto-generated)

### Design System
**Color Palette** (matching website):
- Background: #0f172a (dark navy)
- Card Background: #1e293b (slate)
- Primary (Blue): #2563eb
- Secondary (Yellow): #f4d03f
- Text: #ffffff (white)
- Secondary Text: #cbd5e1 (light gray)
- Border: #334155

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
