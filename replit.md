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

**Splash Screen:** Clean, simple splash screen on app launch:
- Displays PRESEC logo (`assets/images/presec_logo.webp`) on dark background
- Shows for 4 seconds before automatically navigating to login/registration
- Provides branding without video loading complexity
- Uses simple timer-based navigation for reliability

**Members Directory:** Clean, modern members list screen for browsing all alumni:
- Card grid layout displaying all registered members from `/api/search/members` endpoint
- **Full Pagination**: Fetches ALL pages from API (loops through all pages until complete) before displaying
- **Semantic Search**: Client-side fuzzy filtering across firstName, lastName, email, graduationYear, currentRole, company fields
- Search functionality with interactive search icon and clear button
- Each member card shows: profile image (with AuthenticatedImage), name, graduation year, current role
- Clickable cards navigate to individual member's full profile (MemberDetailPage)
- Responsive grid layout (2 columns on mobile, 3 on larger screens)
- Loading states, error handling, and empty state messages
- Integrated with dashboard "Total Members" card for seamless navigation
- **Navigation Architecture**: Two separate profile viewing contexts:
  - `MemberDetailPage` - For viewing other users' profiles (back button only, no bottom nav)
  - `UserProfileScreen` - For viewing own profile (full app navigation with bottom nav bar)
- **MemberDetailPage Design**: Clean, professional aesthetic matching dashboard:
  - White app bar with back button and member name
  - Dark backgrounds: #0f172a (main), #1e293b (cards)
  - Blue CTAs (#2563eb), yellow borders only (#f4d03f)
  - Zero gradients - completely flat design
  - Information/Status tabs with proper data mapping
- **Data Mapping**: Comprehensive field translation from search API to Data model:
  - Image URL normalization: handles protocol-relative (//), absolute (http/https), and relative paths
  - Field fallbacks: company→workPlace, currentRole→position, bio→about, graduationYear→yearGroup
  - Safe userStatus conversion: dynamic list to List<Map<String, dynamic>>
  - Null safety throughout with proper error handling
- **Known Limitation**: Status tab may show limited data due to API field name differences between `/api/search/members` (createdAt, updatedAt) and UserStatus model expectations (createdTime)

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

**Dashboard Navigation:** All dashboard stat cards now route to valid functional pages with consistent clean design:
- **Total Members** → MembersScreen (card grid view of all alumni with semantic search)
- **Events** → EventsScreen (upcoming events list with clean white app bar, back button navigation)
- **Products** → ProjectsScreen (community projects and shop items with clean white app bar, back button navigation)
- **Contributions** → PayDuesScreen (payment functionality for dues)
- **Year Group Members** → Individual cards navigate to MemberDetailPage (clean design, back button only)
- **"View All" Button** → MembersScreen (full member directory with search)

**Events & Projects Screens:** Redesigned to match MemberDetailPage clean aesthetic:
- **EventsScreen**: White app bar with back button, dark backgrounds (#0f172a main, #1e293b cards), blue CTAs (#2563eb), yellow accents (#f4d03f), zero gradients, no bottom nav
- **ProjectsScreen**: Same clean design pattern - white app bar, back button only, dark cards, flat colors, no bottom nav
- **Navigation**: Both screens use simple back navigation instead of full app navigation to maintain focus
- **Event Details**: Dashboard "Latest Events" section properly passes full event objects to EventDetailsScreen (no null errors)
- **Design Consistency**: All secondary screens (Members, Events, Projects) follow identical visual patterns for unified UX

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
- **Members Directory**: Searchable member list with card grid layout:
  - Browse all registered alumni from dashboard "Total Members" card
  - Search members by name with interactive UI
  - View individual member profiles by tapping cards
  - Responsive grid layout with profile images, graduation years, and roles
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
- `package_info_plus`: Retrieves app version and build number for settings display.

### Cloud Services
- **Replit**: Hosting and deployment platform for the web application.