# Odadee - Flutter Mobile App

## Overview
Odadee is a Flutter mobile application, configured for web deployment, serving as a community platform for alumni. It integrates user authentication, community discussions, event management, live radio streaming, and functionalities for project funding and dues payment. The platform also supports user profiles and settings, aiming to foster community engagement and streamline administrative tasks. The project's ambition is to provide a seamless, modern, and engaging experience for alumni, mirroring the clean aesthetic of the odadee.net web application.

## User Preferences
None documented yet.

## System Architecture

### UI/UX Decisions
The application features a dark theme designed to match the website branding, utilizing a color palette of dark navy (#0f172a) for backgrounds, slate (#1e293b) for card backgrounds, blue (#2563eb) as a primary accent, and yellow (#f4d03f) as a secondary accent. Text is primarily white (#ffffff) with light gray (#cbd5e1) for secondary text. The design incorporates styled cards with rounded corners and elevation, blue-accented buttons, and input fields that align with the dark theme. The dashboard features a clean, minimalist webapp-style aesthetic with personalized greetings, vertically stacked cards for information display (e.g., year group members, events, projects, discussions), and a persistent footer navigation with modern rounded icons and active tab indicators. The overall design emphasizes flat colors, subtle borders, and minimal shadows for a professional, business-focused look.

### Technical Implementations
The project is built with Flutter 3.32.0 and Dart 3.8.0, targeting the web platform. It follows a modular project structure, organizing code into reusable `components`, feature-specific `Screens`, and utility files. A robust authentication system uses `flutter_secure_storage` for secure token management, `AuthService` for authentication flows (login, registration, token refresh, logout), and `ApiConfig` for managing API endpoints. Device tracking is integrated for enhanced security. 

**Payment Integration:** PayAngel payment gateway with platform-specific handling:
- **Web:** Uses `url_launcher` to open PayAngel in external browser tab with manual user confirmation ("Yes, Payment Complete" button) to prevent false-positive payment records.
- **Mobile:** Uses `webview_flutter` with embedded WebView that auto-detects payment callback URLs for automatic success/failure handling.
- **Implementation:** Platform detection via `kIsWeb` runtime guards, with separated build methods for web confirmation screen and mobile WebView screen. All payment data (user info, amount, year group) is properly validated and extracted from nested API responses.

**Profile Management:** Full-featured user profile system:
- `UserService` for centralized profile API calls (`getCurrentUser()`, `updateUserProfile()`)
- Live data fetching from `/api/auth/me` with proper handling of nested `{user: {...}}` response structure
- Image handling: CORS workaround via `AuthenticatedImage` component that fetches images through authenticated HTTP requests instead of direct URLs
- Data normalization: Empty strings treated as null for optional fields (location, bio, role, company, profession)
- Profile updates via PATCH `/api/users/:id/profile` with multipart form data for image uploads
- Edit profile screen with comprehensive form validation and user feedback
- All profile image fallbacks use Odadee logo (oda_logo.png) for consistent branding

**Video Splash Screen:** Hero video splash screen on app launch:
- Auto-plays PRESEC hero video (`assets/images/splash_video.mp4`) using `video_player` package
- Automatically navigates to onboarding when video completes
- Provides branding immersion for first-time and returning users

**Settings & App Store Compliance:** Comprehensive settings page meeting all App Store/Play Store requirements:
- **Account Deletion**: Double confirmation with DELETE `/api/auth/delete-account` integration
- **Data Export**: GDPR-compliant POST `/api/users/export-data` with email delivery confirmation
- **Privacy & Legal**: WebView links to Privacy Policy (`odadee.net/privacy-policy`) and Terms of Service (`odadee.net/terms-service`)
- **Cache Management**: Clear cached data while preserving auth tokens (access_token, refresh_token, user data)
- **Notification Settings**: Toggle push notifications with API synchronization via PATCH `/api/users/:id/preferences`
- **Support Features**: Contact support via email, Rate App links (Play Store/App Store), Open Source Licenses
- **App Info**: Version and build number display using `package_info_plus`
- **Navigation**: Logout, view/edit profile shortcuts
- All features include proper error handling, confirmation dialogs, loading states, and user feedback

Error handling, null safety, and proper data transformation are implemented throughout the application.

### Feature Specifications
- **User Authentication**: Secure sign-in/sign-up, password reset, and token refresh, fully integrated with website credentials.
- **Content Management**: Display of community discussions, events, member profiles, and projects.
- **Financial Features**: Project funding and payment of community dues, including a dedicated payment flow with external gateway integration.
- **Multimedia**: Live radio streaming.
- **User Management**: Comprehensive user profile management with live API data:
  - Profile viewing with real-time data from `/api/auth/me` endpoint
  - Profile editing with image upload (profile picture and cover image)
  - Fields: bio, phone, location, graduation year, professional info (current role, company, profession), skills, mentorship status
  - Automatic image URL normalization (relative paths converted to absolute URLs)
  - Empty string handling (treated as null for cleaner UI display)
  - Form validation and error handling
  - CORS-proof image loading via authenticated HTTP requests
- **Settings & Compliance**: Full settings page for App Store/Play Store compliance:
  - Account deletion with double confirmation
  - GDPR-compliant data export via email
  - Privacy Policy and Terms of Service via WebView
  - Push notification preferences with API sync
  - Cache clearing (preserves auth tokens)
  - Support features: Contact, Rate App, Open Source Licenses
  - App version display and About section
- **Deployment**: Automated build process (`build.sh`) for optimized production web builds, including cache cleaning, dependency installation, and web release building.

### System Design Choices
The application leverages a responsive design approach with `device_preview` for development. Deployment is managed via an autoscale stateless web app model on Replit, utilizing a custom build script for reliability. The architecture emphasizes secure API communication with comprehensive error handling and debug logging. All API calls are routed through an `AuthService` to ensure consistency and security.

## External Dependencies

### APIs
- **Production Backend API**: `https://odadee-connect.replit.app`
- **Development Backend API**: `https://a784362b-4352-4c94-81a8-8c3994588922-00-1img99c8h7fps.worf.replit.dev`
- **Key Endpoints**: Authentication (`/api/auth/mobile/login`, `/api/auth/mobile/refresh`, `/api/auth/me`), User Management (`/api/users`), Content (`/api/events`, `/api/projects`, `/api/discussions`, `/api/year-groups`), Payments (`/api/payments/create`), and Statistics (`/api/stats`).
- **Full API Documentation**: `https://odadee-connect.replit.app/api-docs` (80+ endpoints).

### Core Libraries
- `http`: For all API communications and authenticated image fetching.
- `flutter_secure_storage`: Securely stores authentication tokens and sensitive user data.
- `shared_preferences`: Used for local storage of user preferences.
- `radio_player`: Enables audio streaming.
- `url_launcher`: For launching URLs and external links (payment flows, support email, rate app).
- `webview_flutter`: For embedding web views (payment flows, Privacy Policy, Terms of Service).
- `image_picker` & `image_cropper`: For handling image selection and manipulation in profile editing.
- `intl`: Provides internationalization and date formatting utilities.
- `device_info_plus`: Gathers device information for authentication tracking.
- `uuid`: Generates unique identifiers.
- `vector_math`: For geometry types and vector operations.
- `video_player`: Plays hero video on splash screen.
- `package_info_plus`: Retrieves app version and build number for settings display.

### Cloud Services
- **Replit**: Hosting and deployment platform for the web application.