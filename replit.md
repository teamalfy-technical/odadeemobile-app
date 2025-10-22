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
**Current State**: Dashboard fully functional - fixed API format mismatch, all data sections load correctly
**Last Updated**: October 22, 2025

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
- `flutter_secure_storage`: Secure token storage (NEW)
- `device_info_plus`: Device information for authentication (NEW)
- `uuid`: Unique device ID generation (NEW)
- `image_picker` & `image_cropper`: Image handling
- `radio_player`: Audio streaming
- `shared_preferences`: Local data storage (user preferences only)
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
- **Build Command**: `bash build.sh` (automated build script)
- **Run Command**: `flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0 --release`
- **Port**: 5000 (mapped to external port 80)

**Automated Build Process (`build.sh`):**
The deployment uses a custom build script that ensures clean, reliable builds:
1. Cleans Flutter pub cache to prevent corrupted dependencies
2. Cleans previous build artifacts
3. Installs fresh dependencies with `flutter pub get`
4. Builds optimized web release with `flutter build web --release`

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
   - Run `bash build.sh` to create a clean, optimized production build
   - The build script cleans cache, reinstalls dependencies, and builds the release
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
- **2025-10-22**: Fixed API Data Format Mismatch ✅ ARCHITECT REVIEWED
  - **Issue**: Backend returns direct arrays `{"users": [...]}` but models expected paginated responses `{"users": {"current_page": 1, "data": [...]}}`
  - **Solution**: Updated all 4 data models to handle both formats gracefully
  - **Files Updated**: all_users_model.dart, events_model.dart, all_projects_model.dart, all_articles_model.dart
  - **Backward Compatible**: Still supports paginated responses if backend changes format
  - **Result**: Dashboard now loads successfully with all data sections (Users, Events, Projects, Articles)
  
  **Important Note on Browser Caching:**
  - After code changes, you MUST force refresh your browser (Ctrl+Shift+R on Windows/Linux, Cmd+Shift+R on Mac)
  - Or use "Empty Cache and Hard Reload" in Chrome DevTools (F12 → right-click refresh button)
  - Flutter web apps use service workers that cache aggressively

- **2025-10-22**: Complete API Migration to AuthService ✅ ARCHITECT REVIEWED
  - **Security**: Migrated ALL API calls from insecure SharedPreferences to encrypted flutter_secure_storage
  - **Consistency**: Every screen now uses AuthService.authenticatedRequest for API calls
  - **Debug Logging**: Comprehensive logging across ALL screens showing endpoint, status, and response
  - **Error Handling**: User-friendly error messages with retry functionality via SnackBars
  - **Production Ready**: Configured production API at https://odadee-connect.replit.app
  - **Auto Refresh**: All screens support automatic token refresh (15-minute access token expiry)
  
  **Files Updated:**
  - List Screens: events_list.dart, projects_screen.dart, all_news_screen.dart
  - Detail Screens: project_details.dart, news_details.dart, radio_screen.dart, playing_screen.dart
  - Dashboard: dashboard_screen.dart
  - Auth Check: main.dart
  - Config: api_config.dart
  
  **Testing Instructions:**
  1. If you see a blank white screen, force refresh your browser (Ctrl+Shift+R or Cmd+Shift+R)
  2. The service worker may cache old versions - use "Empty Cache and Hard Reload" in DevTools
  3. Test credentials: superadmin@presec.edu.gh / Admin@123
  4. Check browser console for comprehensive debug logs showing all API calls
  5. Test scenarios: Login → Dashboard → Events/Projects/Articles → Detail pages → Logout
  
  **Before Production Deployment:**
  - Review and sanitize verbose response-body logging if sensitive data is present
  - Consider toggling `isDevelopment` to `false` in api_config.dart for production URL
  - Monitor debug logs for any API response format mismatches

- **2025-10-21**: Authentication System Overhaul
  - Implemented new secure authentication using `flutter_secure_storage`
  - Created `AuthService` with login, registration, token refresh, and logout
  - Created `ApiConfig` for easy development/production URL switching
  - Updated SignIn and SignUp screens to use new authentication API
  - Added automatic token refresh mechanism (15-minute access token expiry)
  - Implemented device tracking for better security
  - Created migration helper to transition from old to new storage system
  - Updated main.dart to use new authentication checks
  - Test credentials: superadmin@presec.edu.gh / Admin@123

- **2025-10-21**: Production Deployment Configuration Update
  - Created automated `build.sh` script for reliable deployments
  - Updated deployment configuration to use build script
  - Build script automatically cleans Flutter pub cache before each deployment
  - Ensures fresh dependencies installation to prevent cache corruption
  - Resolves deployment failures from corrupted package files
  
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

### New Authentication System (Updated October 21, 2025)

**API Configuration:**
The app now uses a flexible API configuration system that supports both development and production environments:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const bool isDevelopment = true; // Toggle for testing vs production
  
  static String get baseUrl {
    return isDevelopment
        ? 'https://a784362b-4352-4c94-81a8-8c3994588922-00-1img99c8h7fps.worf.replit.dev'  // Development
        : 'https://odadee-connect.replit.app';  // Production (stable URL)
  }
}
```

**Production Deployment:**
- Development URL: `https://a784362b-4352-4c94-81a8-8c3994588922-00-1img99c8h7fps.worf.replit.dev` (temporary, for testing)
- Production URL: `https://odadee-connect.replit.app` (stable, permanent)
- Toggle `isDevelopment` to `false` before publishing to production

**Authentication Features:**
- ✅ Secure token storage using `flutter_secure_storage`
- ✅ Automatic token refresh (access tokens expire every 15 minutes)
- ✅ Device tracking for better security
- ✅ Login, registration, and logout functionality
- ✅ Support for logout from all devices
- ✅ Authenticated API requests with automatic retry on token expiry

**API Endpoints:**
- Login: `/api/auth/mobile/login`
- Register: `/api/auth/mobile/register`
- Refresh Token: `/api/auth/mobile/refresh`
- Logout: `/api/auth/mobile/logout`
- Logout All: `/api/auth/mobile/logout-all`
- Get Current User: `/api/auth/me`

**Security Improvements:**
- Moved from `SharedPreferences` (insecure) to `flutter_secure_storage` (encrypted)
- All tokens stored in device's secure storage
- Device information included in authentication requests
- Automatic migration from old to new storage system

**Test Credentials:**
- Email: `superadmin@presec.edu.gh`
- Password: `Admin@123`
- Role: `super_admin`
