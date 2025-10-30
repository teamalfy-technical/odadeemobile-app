# Odadee - Flutter Mobile App

## Overview
Odadee is a Flutter mobile application, configured for web deployment, serving as a community platform. It integrates features such as user authentication, news and article delivery, event management, live radio streaming, and functionalities for project funding and dues payment. The platform also supports user profiles and settings, aiming to foster community engagement and streamline administrative tasks.

## User Preferences
None documented yet.

## System Architecture

### UI/UX Decisions
The application features a dark theme designed to match the website branding, utilizing a color palette of dark navy (#0f172a) for backgrounds, slate (#1e293b) for card backgrounds, blue (#2563eb) as a primary accent, and yellow (#f4d03f) as a secondary accent. Text is primarily white (#ffffff) with light gray (#cbd5e1) for secondary text. The design incorporates styled cards with rounded corners and elevation, blue-accented buttons, and input fields that align with the dark theme. The application is designed to be responsive across devices and includes PWA manifest and SEO-optimized meta tags for web deployment.

### Technical Implementations
The project is built with Flutter 3.32.0 and Dart 3.8.0, targeting the web platform. It follows a modular project structure, organizing code into reusable `components`, feature-specific `Screens` (e.g., `Authentication`, `Dashboard`, `Events`, `Radio`), and utility files like `constants.dart` and `main.dart`. A key technical implementation is the robust authentication system, which uses `flutter_secure_storage` for secure token management, `AuthService` for authentication flows (login, registration, token refresh, logout), and `ApiConfig` for managing development and production API endpoints. Device tracking is also integrated for enhanced security.

### Feature Specifications
- **User Authentication**: Secure sign-in/sign-up, password reset, and token refresh.
- **Content Management**: Display of news, articles, and events.
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