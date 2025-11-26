# Password Reset & Magic Link Authentication Guide

## Overview

The Odadee app now has a complete password reset and magic link authentication system. This document explains how these features work and how to use them.

## Features Implemented

### 1. **Password Reset via Email**
Users can request a password reset link via email if they've forgotten their password.

**Flow:**
1. User clicks "Forgot Password" on login screen
2. User enters their email address
3. Backend sends a reset link to their email
4. User clicks the link and resets their password

**API Endpoints:**
- `POST /api/auth/request-password-reset` - Request password reset link
- `POST /api/auth/reset-password` - Reset password with token

### 2. **Magic Link Authentication** 
Users can log in with just a magic link sent to their email (passwordless login).

**Flow:**
1. User enters email on login screen
2. Backend sends a magic link to their email
3. User clicks the link and is automatically logged in
4. If first time, user is prompted to set a password for future logins

**API Endpoints:**
- `POST /api/auth/magic-link/request` - Request magic link login
- `GET /api/auth/magic-link/validate/:token` - Validate magic link
- `POST /api/auth/magic-link/set-password` - Set password after magic link login

### 3. **Password Management in Settings**
Users can change their password in app settings with a dedicated screen.

**Features:**
- Change current password
- Set new password after magic link login
- Strong password validation (8+ chars, uppercase, lowercase, number, special char)
- Password confirmation matching

## Service Methods

All authentication methods are in `lib/services/auth_service.dart`:

### Request Password Reset
```dart
Future<Map<String, dynamic>> requestPasswordReset(String email) async
```
**Returns:**
- `success`: Boolean indicating success
- `message`: User-friendly message
- Example response: `{ success: true, message: "Password reset link sent..." }`

### Reset Password with Token
```dart
Future<Map<String, dynamic>> resetPasswordWithToken({
  required String token,
  required String newPassword,
}) async
```
**Returns:**
- `success`: Boolean indicating success
- `message`: User-friendly message

### Request Magic Link
```dart
Future<Map<String, dynamic>> requestMagicLinkLogin(String email) async
```
**Returns:**
- `success`: Boolean indicating success
- `message`: User-friendly message

### Set Password with Magic Link
```dart
Future<Map<String, dynamic>> setPasswordWithMagicLink({
  required String token,
  required String password,
}) async
```
**Returns:**
- `success`: Boolean indicating success
- `user`: User data if successful
- `message`: User-friendly message

## UI Components

### 1. **Forgot Password Screen**
- **Location:** `lib/Screens/Authentication/ForgetPassword/forgot_password.dart`
- **Features:**
  - Email input validation
  - Request password reset link
  - Success/error feedback dialogs
  - Returns to login on success

### 2. **Reset Password Screen**
- **Location:** `lib/Screens/Authentication/ForgetPassword/reset_password.dart`
- **Features:**
  - Password input with validation
  - Password confirmation
  - Strong password requirements display
  - Success handling

### 3. **Change Password Screen**
- **Location:** `lib/Screens/Settings/change_password_screen.dart`
- **Features:**
  - Change current password
  - Set new password for magic link users
  - Current password requirement toggle
  - Password strength validation
  - Clear instructions for users

### 4. **Magic Link Callback**
- **Location:** `lib/Screens/Authentication/magic_link_callback.dart`
- **Features:**
  - Validates magic link token
  - Auto-redirects on success
  - Displays error messages for invalid links
  - Allows retry or return to login

## Error Handling

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| Email not found | User account doesn't exist | Suggest signing up |
| Invalid or expired link | Token expired or invalid | Request new reset/magic link |
| Network error | Connection issue | Check connection and retry |
| Passwords don't match | Confirmation doesn't match | Re-enter password carefully |
| Weak password | Password doesn't meet requirements | Use 8+ chars with mixed case, numbers, symbols |

## Password Requirements

Passwords must meet these criteria:
- ✓ Minimum 8 characters
- ✓ At least one uppercase letter (A-Z)
- ✓ At least one lowercase letter (a-z)
- ✓ At least one number (0-9)
- ✓ At least one special character (!@#$%^&*)

## User Journeys

### Journey 1: Forgot Password
```
Login Screen
    ↓ (Click "Forgot Password")
Forgot Password Screen
    ↓ (Enter email, click "Reset Password")
[Wait for email]
    ↓ (Click link in email)
[Redirect to reset password page]
Reset Password Screen
    ↓ (Enter new password, confirm)
[Success message]
    ↓ (Return to login)
Login Screen [Now can login with new password]
```

### Journey 2: Magic Link Login
```
[Receive magic link email]
    ↓ (Click link in email)
Magic Link Callback Screen
    ↓ (Validating...)
[If first time]
    ↓
Change Password Screen [Set password]
    ↓
Dashboard
[If existing password]
    ↓
Dashboard [Already logged in]
```

### Journey 3: Change Password in Settings
```
Dashboard
    ↓ (Click Settings)
Settings Screen
    ↓ (Click "Change Password")
Change Password Screen
    ↓ (Enter current password & new password)
    [or check "No current password" if from magic link]
    ↓ (Click "Change Password")
[Success message]
    ↓
Back to Settings
```

## Testing Checklist

- [ ] Request password reset with valid email
- [ ] Request password reset with invalid email
- [ ] Click password reset link and reset password
- [ ] Try resetting with expired token
- [ ] Request magic link with valid email
- [ ] Click magic link and verify auto-login
- [ ] Set password after magic link login
- [ ] Change password in settings with current password
- [ ] Change password in settings as magic link user
- [ ] Test password validation requirements
- [ ] Test password mismatch handling
- [ ] Verify error messages display correctly
- [ ] Test network error handling

## Backend API Requirements

Ensure your backend implements these endpoints:

### 1. Request Password Reset
```
POST /api/auth/request-password-reset
Body: { email: "user@example.com" }
Response: { success: true, message: "Reset link sent" }
```

### 2. Reset Password
```
POST /api/auth/reset-password
Body: { token: "...", newPassword: "NewPass123!" }
Response: { success: true, message: "Password reset" }
```

### 3. Request Magic Link
```
POST /api/auth/magic-link/request
Body: { email: "user@example.com" }
Response: { success: true, message: "Magic link sent" }
```

### 4. Validate Magic Link
```
GET /api/auth/magic-link/validate/:token
Response: { success: true, user: {...}, accessToken: "...", refreshToken: "..." }
```

### 5. Set Password with Magic Link
```
POST /api/auth/magic-link/set-password
Body: { token: "...", password: "NewPass123!" }
Response: { success: true, user: {...}, accessToken: "...", refreshToken: "..." }
```

## Biometric Integration

These password reset and magic link flows work seamlessly with biometric login:
- After setting a password via magic link, users can enable biometric login
- Biometric credentials are stored securely for future passwordless access
- Users can still use password reset to change their biometric password

## Best Practices

1. **Email Verification:** Ensure all emails are verified before allowing password changes
2. **Token Expiration:** Keep reset/magic link tokens short-lived (15-30 minutes)
3. **Rate Limiting:** Limit password reset requests to prevent abuse
4. **Logging:** Log all password reset and magic link attempts for security
5. **Notification:** Consider notifying users of password changes via email
6. **Security:** Always use HTTPS for all authentication links
7. **User Education:** Help users understand password requirements upfront

## Troubleshooting

### Magic link not redirecting
- Check URL pattern detection in `main.dart` (_checkForMagicLink method)
- Ensure token is properly extracted from URL
- Verify backend is returning correct redirect URL

### Password change not saving
- Check network connectivity
- Verify current password is correct (if required)
- Ensure password meets validation requirements
- Check auth tokens are still valid

### Email not received
- Check spam/junk folder
- Verify email address is correct
- Contact backend team to check email service status

## Future Enhancements

- [ ] Two-factor authentication for password reset
- [ ] SMS magic links as alternative
- [ ] Password reset history
- [ ] Multi-device password reset confirmation
- [ ] Passwordless push notifications instead of links
- [ ] Social login options
