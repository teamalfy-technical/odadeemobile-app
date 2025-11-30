# Odadee - Flutter Mobile App

## Overview
Odadee is a Flutter mobile application, configured for web deployment, serving as a community platform for alumni. Its primary purpose is to foster community engagement and streamline administrative tasks by integrating user authentication, community discussions, event management, live radio streaming, project funding, and dues payment functionalities. The project aims to provide a seamless, modern, and engaging experience for alumni, mirroring the clean aesthetic of the odadee.net web application.

## User Preferences
None documented yet.

## System Architecture

### UI/UX Decisions
The application utilizes a dark theme aligned with the website's branding, featuring a color palette of dark navy, slate, blue as a primary accent, and yellow as a secondary accent. Text is primarily white with light gray for secondary text. The design incorporates styled cards with rounded corners and elevation, blue-accented buttons, and input fields that match the dark theme. The dashboard features a minimalist webapp-style aesthetic with personalized greetings and vertically stacked cards for information display. A persistent footer navigation uses modern rounded icons and active tab indicators. The overall design emphasizes flat colors, subtle borders, and minimal shadows for a professional, business-focused look. Consistent design patterns are applied across secondary screens (Members, Events, Projects) for a unified user experience.

### Technical Implementations
Built with Flutter 3.32.0 and Dart 3.8.0, the project targets the web platform with a modular structure comprising `components`, feature-specific `Screens`, and utility files. Authentication is managed via `flutter_secure_storage` and `AuthService`, ensuring secure token management and API communication.

**Key Features Implemented:**
-   **Payment Integration:** Utilizes PayAngel, adapting implementation for web (via `url_launcher` and manual confirmation) and mobile (via `webview_flutter` with automatic callback detection).
-   **Profile Management:** A full-featured user profile system with `UserService` for API calls, image handling (CORS-workaround via `AuthenticatedImage`), data normalization, and comprehensive form validation for profile updates. All profile image fallbacks use `oda_logo.png`.
-   **Splash Screen:** Displays `presec_logo.webp` for 4 seconds before navigation, providing branding without video complexity.
-   **Members Directory:** A clean, modern, paginated member list with Google-style semantic search using `SemanticSearchHelper`. Features include fuzzy matching (Levenshtein distance), relevance scoring (name matches weighted higher), word tokenization for multi-term queries, and real-time search as user types. Member profile pictures display via `AuthenticatedImage` with proper URL normalization. The responsive card grid layout navigates to individual `MemberDetailPage` or the user's `UserProfileScreen`.
-   **Settings & App Store Compliance:** A comprehensive settings page including account deletion, GDPR-compliant data export, privacy/legal links (via WebView), cache management (preserving auth tokens), notification settings, support features, and app info display.
-   **Change Password:** Users can change their password or set a new one after logging in via magic link. Includes password validation (8+ characters, uppercase, lowercase, numbers), confirmation matching, and toggle for users without an existing password.
-   **Dashboard Navigation:** All dashboard stat cards route to functional pages (Members, Events, Projects, PayDues) with consistent design and navigation.
-   **Events & Projects Screens:** Redesigned to match the clean aesthetic of `MemberDetailPage`, featuring white app bars, dark backgrounds, blue CTAs, yellow accents, and flat designs with simple back navigation.
-   **Centralized Image URL Handling:** All image URLs (events, projects, user avatars, articles) are normalized through `ImageUrlHelper` utility, ensuring consistent access via the correct API endpoint: `https://odadee.net/api/images/uploads/`. Both `EventImageWidget` and `AuthenticatedImage` components use this centralized helper.
Error handling, null safety, and data transformation are implemented throughout.

### Feature Specifications
-   **User Authentication:** Secure sign-in/sign-up, password reset, and token refresh fully integrated with website credentials.
-   **Content Management:** Displays community discussions, events, member profiles, and projects.
-   **Financial Features:** Project funding and community dues payment with dedicated payment flows.
-   **Multimedia:** Live radio streaming functionality.
-   **User Management:** Comprehensive user profile management with real-time API data, including profile viewing, editing with image upload, and handling of various personal and professional fields.
-   **Members Directory:** Searchable member list with interactive UI for browsing alumni and viewing individual profiles.
-   **Settings & Compliance:** Full settings page for App Store/Play Store compliance, including account deletion, data export, privacy policy, terms of service, push notification preferences, cache clearing, and support features.
-   **Deployment:** Automated build process (`build.sh`) for optimized production web builds.

### System Design Choices
The application uses a responsive design approach with `device_preview` for development. Deployment is on Replit as a **static web app**, using a custom build script (`build.sh`) to generate production-ready static files. The architecture prioritizes secure API communication with comprehensive error handling and debug logging, routing all API calls through an `AuthService`.

## External Dependencies

### APIs
-   **Production Backend API**: `https://odadee.net`
-   **Key Endpoints**: Authentication, User Management, Content (Events, Projects, Discussions, Year Groups), Payments, and Statistics.
-   **Full API Documentation**: `https://odadee.net/api-docs`

### Core Libraries
-   `http`: API communications, authenticated image fetching.
-   `flutter_secure_storage`: Secure token and sensitive data storage.
-   `shared_preferences`: Local user preferences storage.
-   `radio_player`: Audio streaming.
-   `url_launcher`: External URL and link handling.
-   `webview_flutter`: Embedded web views.
-   `image_picker` & `image_cropper`: Image selection and manipulation.
-   `intl`: Internationalization and date formatting.
-   `device_info_plus`: Device information for authentication tracking.
-   `uuid`: Unique identifier generation.
-   `vector_math`: Geometry types and vector operations.
-   `package_info_plus`: App version and build number retrieval.

### Cloud Services
-   **Replit**: Hosting and deployment platform.

## Production Deployment

### Current Version
- **Version**: 1.1.0+2
- **Release Date**: November 23, 2025
- **API Integration**: Live production API at odadee.net

### Deployment Configuration
The app is configured for **static web deployment** on Replit:
- **Deployment Type**: Static (serves pre-built files)
- **Build Command**: `bash build.sh`
- **Public Directory**: `build/web`
- **Workflow**: `python3 -m http.server 5000 --directory build/web` (serves pre-built static files for local preview)

### Development vs Production
- **Local Preview Workflow**: Serves pre-built static files from `build/web` using `python3 -m http.server 5000`
  - Run `bash build.sh` first to generate the build files
  - This workflow is for previewing the built app locally, not for production deployment
- **Interactive Development**: For live reload during development, manually run `flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0` in the shell
- **Production Deployment**: Static hosting using pre-built files from `build/web` directory served directly by Replit

### Build Process
The production build script (`build.sh`) performs:
1. Clean Flutter pub cache to prevent dependency issues
2. Clean previous build artifacts
3. Install fresh dependencies
4. Build for web in release mode: `flutter build web --release`
5. Verify build output before completion

**Note:** Flutter automatically selects the optimal web renderer based on the browser. Deprecated flags have been removed for compatibility with modern Flutter versions.

### Production Features (v1.1.0)
- ✅ Live API integration with odadee.net
- ✅ Event detail pages with banner images
- ✅ Project detail pages with funding progress visualization
- ✅ Null-safe data handling throughout
- ✅ Centralized image URL normalization via ImageUrlHelper (all images use /api/images/uploads/ endpoint)
- ✅ Clean navigation architecture
- ✅ Production-ready error handling

### Deployment Steps
1. Ensure all code changes are committed
2. Click the **Deploy** button in Replit
3. Verify deployment configuration:
   - Deployment type: Static
   - Build command: `bash build.sh`
   - Publish directory: `build/web`
4. Click **Deploy** - Replit will build and publish automatically
5. Test the deployed app at the production URL

### Post-Deployment Verification
After deployment, verify:
1. App loads correctly on production URL
2. Authentication flow works with live API
3. Dashboard displays live events and projects
4. Event detail pages show banner images
5. Project detail pages show funding progress
6. Navigation between screens works smoothly
7. Image loading from odadee.net works correctly
8. Responsive design works on mobile and desktop