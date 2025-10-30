# Odadee - Flutter Mobile App

## Overview
Odadee is a Flutter mobile application, configured for web deployment, serving as a community platform. It integrates features such as user authentication, community discussions, event management, live radio streaming, and functionalities for project funding and dues payment. The platform also supports user profiles and settings, aiming to foster community engagement and streamline administrative tasks.

## Recent Changes
**October 30, 2025 - Dashboard API Endpoint Fixes**
- Fixed critical bug: Changed dashboard to call `/api/discussions` instead of non-existent `/api/articles` endpoint
- Implemented safe data transformation from discussions format to articles model
- Added null-safe handling for discussions data - section now gracefully hides when unavailable
- Changed "Latest News" label to "Latest Discussions" to reflect actual data source
- Added placeholder icons for discussions without images
- Fixed potential runtime crashes with defensive substring operations

**Cross-Platform Authentication**
- Confirmed: Users can login to the mobile app using credentials created on the main website (e.g., superadmin@presec.edu.gh)
- Authentication system fully integrated between web and mobile platforms

## User Preferences
None documented yet.

## Important Testing Notes
**⚠️ Flutter Web Cache Issue**
After code updates, the browser may serve a cached version of the app due to Flutter's aggressive service worker caching. To see updates:

1. **Hard Refresh (Required after updates):**
   - Windows/Linux: `Ctrl + Shift + R` or `Ctrl + F5`
   - Mac: `Cmd + Shift + R`

2. **Alternative: Clear Service Worker Cache:**
   - Open browser DevTools (F12)
   - Application tab → Service Workers → "Unregister"
   - Application tab → Clear Storage → "Clear site data"
   - Then refresh the page

3. **For Developers:**
   - Browser console logs showing "Loading from existing service worker" indicate cached version
   - Consider implementing version.json auto-update system for production deployment

## System Architecture

### UI/UX Decisions
The application features a dark theme designed to match the website branding, utilizing a color palette of dark navy (#0f172a) for backgrounds, slate (#1e293b) for card backgrounds, blue (#2563eb) as a primary accent, and yellow (#f4d03f) as a secondary accent. Text is primarily white (#ffffff) with light gray (#cbd5e1) for secondary text. The design incorporates styled cards with rounded corners and elevation, blue-accented buttons, and input fields that align with the dark theme. The application is designed to be responsive across devices and includes PWA manifest and SEO-optimized meta tags for web deployment.

### Technical Implementations
The project is built with Flutter 3.32.0 and Dart 3.8.0, targeting the web platform. It follows a modular project structure, organizing code into reusable `components`, feature-specific `Screens` (e.g., `Authentication`, `Dashboard`, `Events`, `Radio`), and utility files like `constants.dart` and `main.dart`. A key technical implementation is the robust authentication system, which uses `flutter_secure_storage` for secure token management, `AuthService` for authentication flows (login, registration, token refresh, logout), and `ApiConfig` for managing development and production API endpoints. Device tracking is also integrated for enhanced security.

### Feature Specifications
- **User Authentication**: Secure sign-in/sign-up, password reset, and token refresh. Fully integrated with website credentials.
- **Content Management**: Display of community discussions, events, and member profiles.
- **Discussions**: Community discussion board with categories (networking, mentorship, career, opportunities, general)
- **Events**: Browse and register for alumni events (homecoming, reunions, networking)
- **Projects**: View and contribute to school projects and scholarship funds
- **Multimedia**: Live radio streaming.
- **Financial Features**: Project funding and payment of community dues.
- **User Management**: User profiles and settings.
- **Deployment**: Automated build process (`build.sh`) for clean, optimized production builds, including cache cleaning, dependency installation, and web release building. Production builds are optimized for performance with the `--release` flag, code minification, and tree-shaking.

### System Design Choices
The application leverages a responsive design approach with `device_preview` for development. Deployment is managed via an autoscale stateless web app model on Replit, utilizing a custom build script for reliability. The architecture emphasizes secure API communication with comprehensive error handling and debug logging. All API calls are routed through an `AuthService` to ensure consistency and security.

## External Dependencies

### APIs
- **Backend API**: `http://api.odadee.net` (legacy, being migrated from)
- **Production API**: `https://odadee-connect.replit.app`
- **Development API**: `https://a784362b-4352-4c94-81a8-8c3994588922-00-1img99c8h7fps.worf.replit.dev`

**Active Endpoints (as of Oct 30, 2025):**
- `/api/auth/mobile/login` - Mobile authentication
- `/api/auth/mobile/refresh` - Token refresh
- `/api/auth/me` - Current user profile
- `/api/users` - List all users (super_admin only)
- `/api/events` - List events
- `/api/projects` - List projects
- `/api/discussions` - Community discussions (replaces legacy /api/articles)
- `/api/year-groups` - Year group information
- `/api/stats` - Dashboard statistics

Full API documentation: `https://odadee-connect.replit.app/api-docs` (80+ endpoints)

### Core Libraries
- `http`: For all API communications.
- `flutter_secure_storage`: Securely stores authentication tokens and sensitive user data.
- `shared_preferences`: Used for local storage of user preferences (non-sensitive data).
- `radio_player`: Enables audio streaming for the radio feature.
- `image_picker` & `image_cropper`: For handling image selection and manipulation.
- `intl`: Provides internationalization and date formatting utilities.
- `device_info_plus`: Gathers device information for authentication and security.
- `uuid`: Generates unique device identifiers.
- `vector_math`: Essential for handling geometry types and vector operations within Flutter.

### Cloud Services
- **Replit**: Hosting and deployment platform for the web application.