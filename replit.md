# Odadee - Flutter Mobile App

## Overview
Odadee is a Flutter mobile application, configured for web deployment, serving as a community platform. It integrates features such as user authentication, community discussions, event management, live radio streaming, and functionalities for project funding and dues payment. The platform also supports user profiles and settings, aiming to foster community engagement and streamline administrative tasks.

## Recent Changes
**November 23, 2025 - PayAngel Payment Integration**
- Implemented complete PayAngel payment integration for year group dues payment
- Added PaymentService class (lib/services/payment_service.dart) with createPayment method connecting to /payments/create endpoint
- Created PaymentScreen widget with WebView for PayAngel checkout, properly detects callbacks via /payments/callback?transactionStatus
- Built PayDuesModal component with interactive year group dropdown and dues selector
- Modal automatically fetches available dues when year group changes, auto-selects first item
- Updated pay_dues.dart to show modal on load with clean informational screen design
- Footer navigation background color updated from #1a1a1a to #0f172a for consistency with app theme
- Added required packages: url_launcher ^6.2.0, webview_flutter ^4.4.0, dio ^5.4.0
- Payment flow: User selects year group → selects dues item → proceeds to PayAngel WebView → receives success/failure confirmation
- PaymentService maps 'dues' to 'YEAR_GROUP_DUES' product code as expected by backend
- PaymentScreen detects transactionStatus=SUCCESS|FAILED|CANCELLED in callback URLs with comprehensive fallback checks
- **Fixed dues amount parsing:** Updated PayDuesModal to handle string amounts (e.g., "50.00") from backend API using double.parse(), resolving TypeError that prevented dues from loading for year groups like Class of 1995
- **Fixed network/CORS error:** Replaced Dio library with AuthService.authenticatedRequest (http package) for better Flutter Web compatibility, eliminating XMLHttpRequest CORS errors
- **Fixed endpoint URL:** Corrected payment endpoint from `/payments/create` to `/api/payments/create` to match backend CORS configuration (all endpoints require `/api/` prefix)
- **Fixed 400 validation error:** Updated PaymentService to include firstName, lastName, and email from current user in payment request (required fields for public payments)
- Added comprehensive error handling for non-JSON responses (HTML/text gateway errors) with fallback to raw response body
- Production-ready implementation verified by architect review

**November 23, 2025 - Bug Fixes and Logo Addition**
- Added PRESEC logo to dashboard header (50x50px with rounded corners, replaces placeholder "P")
- Fixed event date parsing to handle ISO 8601 format (2024-12-20T18:00:00.000Z) and legacy formats
- Enhanced getCurrentUser() with comprehensive debug logging and null safety checks
- Fixed discussions transformation to properly handle field types (string/int conversions)
- Improved error handling throughout dashboard data loading

**November 23, 2025 - Footer Navigation Enhancement**
- Added 2px yellow border (odaSecondary #f4d03f) around footer navigation container for enhanced visual definition
- Created reusable FooterNav component (components/footer_nav.dart) that now persists across all app pages
- Footer appears on Dashboard, Settings, Profile, and Pay Dues screens with correct active tab indicators
- Uses pushReplacement navigation to prevent stack buildup when switching between tabs
- Fixed Profile screen structure with proper Stack + Positioned.fill wrapper for content (80px bottom padding to avoid footer overlap)
- Removed all Radio tab references from navigation and cleaned up unused imports
- Footer design: Dark rounded container (#1a1a1a) with yellow border, 30px border radius, positioned 20px from edges

**November 23, 2025 - Webapp-Style Dashboard Redesign**
- Implemented comprehensive dashboard redesign matching clean odadee.net webapp aesthetic
- Added personalized welcome header: "Welcome back, [FirstName]!" with user's first name only, email and graduation class from API
- Redesigned footer navigation: Removed Radio tab, kept only Home, Pay Dues, Settings, and Profile
- Active tab indicator: White background with dark icon, inactive tabs show white icons on transparent background
- Modern rounded icons (home_rounded, payment_rounded, settings_rounded, person_rounded) for cleaner look
- Changed stat cards from 2x2 grid to full-width vertical stack (one card per row) for better mobile readability
- Replaced all yellow section headers with white for cleaner, professional look (blue reserved for interactive links)
- Converted all horizontal scrolling carousels to vertical stacked cards for "less is more" minimalism
- Year Group section: Displays up to 6 members vertically stacked
- Events section: Shows 3 upcoming events vertically with clean date boxes
- Projects section: Displays 3 active projects vertically with contribution progress
- Latest Discussions: Shows 3 recent discussions vertically with category badges
- Increased spacing throughout: 30px between sections, 20px horizontal padding, generous breathing room
- Fixed critical bugs: TypeError in articlesData (proper null-safe casting), removed invalid event.location references
- All sections now gracefully hide when no data available with proper empty states
- Design philosophy: Clean flat colors, white headers, minimal shadows, vertical flows for modern simplicity

**October 30, 2025 - Flat Design Implementation**
- Completely redesigned dashboard UI to match clean, minimal, professional aesthetic
- Removed all gradients from StatCard component - now uses flat dark backgrounds (#1e293b) with simple borders (#334155)
- Updated dashboard stats cards with flat design: Total Members, Events, Products, Contributions
- Redesigned Year Group avatars with flat color (#334155) and simple borders instead of gradients
- Simplified Events section with flat dark backgrounds and borders on date boxes
- Cleaned up Projects section - removed gradients from image placeholders and buttons, using flat odaPrimary color
- Replaced all GradientText components with simple Text in odaPrimary color
- Removed unused simple_gradient_text dependency
- Overall design now features consistent flat colors, subtle borders, and minimal shadows for a professional, business-focused look

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