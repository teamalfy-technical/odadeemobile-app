# Flutter Integration Guide - Authentication API

## Quick Start

This guide covers everything you need to implement authentication in your Flutter app for the PRESEC Ɔdadeɛ Global Alumni Network.

## API Base URLs

### Development URL (Testing Only)
```
https://a784362b-4352-4c94-81a8-8c3994588922-00-1img99c8h7fps.worf.replit.dev
```
⚠️ **This is temporary** - Use only for initial testing. This URL changes and is not suitable for production.

### Production URL (After Publishing)
```
https://odadee-connect.replit.app
```
✅ **Use this for your production app** - This is the stable, permanent URL that will work after the backend is published.

### How to Configure in Your Flutter App

Create a configuration file to easily switch between environments:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const bool isDevelopment = false; // Set to false for production
  
  static String get baseUrl {
    if (isDevelopment) {
      // Development URL (temporary)
      return 'https://a784362b-4352-4c94-81a8-8c3994588922-00-1img99c8h7fps.worf.replit.dev';
    } else {
      // Production URL (stable)
      return 'https://odadee-connect.replit.app';
    }
  }
}
```

Then use it in your AuthService:
```dart
class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;
  // ... rest of your code
}
```

## Test Credentials

Use these credentials for testing:
- **Email**: `superadmin@presec.edu.gh`
- **Password**: `Admin@123`
- **Role**: `super_admin`

---

## 1. Login (Get Tokens)

### Endpoint
```
POST /api/auth/mobile/login
```

### Request Headers
```
Content-Type: application/json
```

### Request Body
```json
{
  "email": "superadmin@presec.edu.gh",
  "password": "Admin@123",
  "deviceInfo": {
    "deviceId": "unique-device-id-here",
    "deviceName": "John's iPhone",
    "deviceType": "iOS",
    "deviceModel": "iPhone 14 Pro",
    "osName": "iOS",
    "osVersion": "17.2",
    "appVersion": "1.0.0",
    "pushNotificationToken": "optional-fcm-token-here"
  }
}
```

### Response (200 OK)
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "email": "superadmin@presec.edu.gh",
    "firstName": "Super",
    "lastName": "Admin",
    "role": "super_admin",
    "isActive": true,
    "profilePicture": null,
    "yearGroupId": null
  }
}
```

### Error Response (401 Unauthorized)
```json
{
  "message": "Invalid email or password"
}
```

### Flutter Example
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  static const String baseUrl = 'https://your-api-url.replit.dev';
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Generate or retrieve unique device ID
    final deviceId = await _getDeviceId();
    final deviceInfo = await _getDeviceInfo();
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/mobile/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'deviceInfo': {
          'deviceId': deviceId,
          'deviceName': deviceInfo['deviceName'],
          'deviceType': deviceInfo['deviceType'],
          'deviceModel': deviceInfo['deviceModel'],
          'osName': deviceInfo['osName'],
          'osVersion': deviceInfo['osVersion'],
          'appVersion': '1.0.0',
        },
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Store tokens securely
      await _storeTokens(data['accessToken'], data['refreshToken']);
      
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Login failed');
    }
  }
  
  Future<String> _getDeviceId() async {
    // Get or generate device ID (store in secure storage)
    // Use flutter_secure_storage package
    final storage = FlutterSecureStorage();
    String? deviceId = await storage.read(key: 'device_id');
    
    if (deviceId == null) {
      deviceId = Uuid().v4();
      await storage.write(key: 'device_id', value: deviceId);
    }
    
    return deviceId;
  }
  
  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'deviceName': androidInfo.model,
        'deviceType': 'Android',
        'deviceModel': androidInfo.model,
        'osName': 'Android',
        'osVersion': androidInfo.version.release,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'deviceName': iosInfo.name,
        'deviceType': 'iOS',
        'deviceModel': iosInfo.model,
        'osName': 'iOS',
        'osVersion': iosInfo.systemVersion,
      };
    }
    
    return {
      'deviceName': 'Unknown',
      'deviceType': 'Unknown',
      'deviceModel': 'Unknown',
      'osName': 'Unknown',
      'osVersion': 'Unknown',
    };
  }
  
  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: 'access_token', value: accessToken);
    await storage.write(key: 'refresh_token', value: refreshToken);
  }
}
```

---

## 2. Using Access Tokens

### How to Make Authenticated Requests

Add the `Authorization` header with your access token to all API requests:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Flutter Example
```dart
Future<Map<String, dynamic>> getProfile() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'access_token');
  
  final response = await http.get(
    Uri.parse('$baseUrl/api/auth/me'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else if (response.statusCode == 401) {
    // Token expired, refresh it
    await refreshAccessToken();
    return getProfile(); // Retry
  } else {
    throw Exception('Failed to get profile');
  }
}
```

### Token Lifespan
- **Access Token**: Expires in **15 minutes**
- **Refresh Token**: Expires in **30 days**

---

## 3. Refresh Access Token

When your access token expires (after 15 minutes), use the refresh token to get a new one.

### Endpoint
```
POST /api/auth/mobile/refresh
```

### Request Headers
```
Content-Type: application/json
```

### Request Body
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Response (200 OK)
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Error Response (401 Unauthorized)
```json
{
  "message": "Refresh token not found or has been revoked"
}
```

### Flutter Example
```dart
Future<String> refreshAccessToken() async {
  final storage = FlutterSecureStorage();
  final refreshToken = await storage.read(key: 'refresh_token');
  
  if (refreshToken == null) {
    throw Exception('No refresh token available');
  }
  
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/mobile/refresh'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'refreshToken': refreshToken,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final newAccessToken = data['accessToken'];
    
    // Store new access token
    await storage.write(key: 'access_token', value: newAccessToken);
    
    return newAccessToken;
  } else {
    // Refresh token expired or revoked, user must login again
    await _clearTokens();
    throw Exception('Session expired, please login again');
  }
}

Future<void> _clearTokens() async {
  final storage = FlutterSecureStorage();
  await storage.delete(key: 'access_token');
  await storage.delete(key: 'refresh_token');
}
```

---

## 4. Logout

Revoke the refresh token to logout from the current device.

### Endpoint
```
POST /api/auth/mobile/logout
```

### Request Headers
```
Content-Type: application/json
```

### Request Body
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Response (200 OK)
```json
{
  "message": "Logged out successfully"
}
```

### Flutter Example
```dart
Future<void> logout() async {
  final storage = FlutterSecureStorage();
  final refreshToken = await storage.read(key: 'refresh_token');
  
  if (refreshToken != null) {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/auth/mobile/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );
    } catch (e) {
      // Logout failed, but clear local tokens anyway
      print('Logout error: $e');
    }
  }
  
  // Clear stored tokens
  await storage.delete(key: 'access_token');
  await storage.delete(key: 'refresh_token');
  await storage.delete(key: 'user_data');
}
```

---

## 5. Logout from All Devices

Revoke all refresh tokens to logout from all devices.

### Endpoint
```
POST /api/auth/mobile/logout-all
```

### Request Headers
```
Authorization: Bearer <access_token>
```

### Response (200 OK)
```json
{
  "message": "Logged out from all devices successfully"
}
```

### Flutter Example
```dart
Future<void> logoutAllDevices() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'access_token');
  
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/mobile/logout-all'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );
  
  if (response.statusCode == 200) {
    // Clear local tokens
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }
}
```

---

## 6. Get Current User

Get information about the currently authenticated user.

### Endpoint
```
GET /api/auth/me
```

### Request Headers
```
Authorization: Bearer <access_token>
```

### Response (200 OK)
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "superadmin@presec.edu.gh",
  "firstName": "Super",
  "lastName": "Admin",
  "role": "super_admin",
  "isActive": true,
  "profilePicture": null,
  "yearGroupId": null,
  "graduationYear": null,
  "phone": null,
  "bio": null,
  "lastLoginAt": "2024-01-15T10:30:00.000Z"
}
```

---

## Complete Authentication Flow Example

Here's a complete example showing how to structure your authentication in Flutter:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

class ApiConfig {
  static const bool isDevelopment = false; // Change to false for production
  
  static String get baseUrl {
    return isDevelopment 
      ? 'https://a784362b-4352-4c94-81a8-8c3994588922-00-1img99c8h7fps.worf.replit.dev'  // Dev
      : 'https://odadee-connect.replit.app';  // Production
  }
}

class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;
  final storage = const FlutterSecureStorage();
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final deviceId = await _getOrCreateDeviceId();
    final deviceInfo = await _getDeviceInfo();
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/mobile/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'deviceInfo': {
          'deviceId': deviceId,
          ...deviceInfo,
        },
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storeTokens(data['accessToken'], data['refreshToken']);
      await _storeUser(data['user']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Login failed');
    }
  }
  
  // Refresh token
  Future<String> refreshToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    
    if (refreshToken == null) {
      throw Exception('No refresh token');
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/mobile/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['accessToken']);
      return data['accessToken'];
    } else {
      await _clearStorage();
      throw Exception('Session expired');
    }
  }
  
  // Logout
  Future<void> logout() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    
    if (refreshToken != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/api/auth/mobile/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      } catch (e) {
        print('Logout error: $e');
      }
    }
    
    await _clearStorage();
  }
  
  // Make authenticated request
  Future<http.Response> authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    String? accessToken = await storage.read(key: 'access_token');
    
    final response = await _makeRequest(method, endpoint, accessToken, body);
    
    if (response.statusCode == 401) {
      // Token expired, refresh and retry
      accessToken = await refreshToken();
      return await _makeRequest(method, endpoint, accessToken, body);
    }
    
    return response;
  }
  
  Future<http.Response> _makeRequest(
    String method,
    String endpoint,
    String? token,
    Map<String, dynamic>? body,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(uri, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return await http.put(uri, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      default:
        throw Exception('Unsupported HTTP method');
    }
  }
  
  // Helper methods
  Future<String> _getOrCreateDeviceId() async {
    String? deviceId = await storage.read(key: 'device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await storage.write(key: 'device_id', value: deviceId);
    }
    return deviceId;
  }
  
  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return {
        'deviceName': info.model,
        'deviceType': 'Android',
        'deviceModel': info.model,
        'osName': 'Android',
        'osVersion': info.version.release,
        'appVersion': '1.0.0',
      };
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return {
        'deviceName': info.name,
        'deviceType': 'iOS',
        'deviceModel': info.model,
        'osName': 'iOS',
        'osVersion': info.systemVersion,
        'appVersion': '1.0.0',
      };
    }
    
    return {
      'deviceName': 'Unknown',
      'deviceType': 'Unknown',
      'deviceModel': 'Unknown',
      'osName': 'Unknown',
      'osVersion': 'Unknown',
      'appVersion': '1.0.0',
    };
  }
  
  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    await storage.write(key: 'access_token', value: accessToken);
    await storage.write(key: 'refresh_token', value: refreshToken);
  }
  
  Future<void> _storeUser(Map<String, dynamic> user) async {
    await storage.write(key: 'user_data', value: jsonEncode(user));
  }
  
  Future<void> _clearStorage() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_data');
  }
  
  Future<bool> isLoggedIn() async {
    final accessToken = await storage.read(key: 'access_token');
    return accessToken != null;
  }
  
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userData = await storage.read(key: 'user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }
}
```

---

## Required Flutter Packages

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  device_info_plus: ^10.0.0
  uuid: ^4.0.0
```

---

## Error Handling

Common HTTP status codes you'll encounter:

- **200**: Success
- **400**: Bad request (missing fields, invalid data)
- **401**: Unauthorized (invalid credentials or expired token)
- **403**: Forbidden (insufficient permissions)
- **404**: Not found
- **429**: Too many requests (rate limit exceeded)
- **500**: Server error

---

## Security Best Practices

1. **Always use HTTPS** in production
2. **Store tokens securely** using `flutter_secure_storage`
3. **Never log tokens** in production
4. **Implement automatic token refresh** before expiry
5. **Clear tokens on logout**
6. **Handle token expiration** gracefully
7. **Use device-specific IDs** for better security

---

## Important: URL Configuration

### Before Publishing (Development)
1. Keep `isDevelopment = true` in `ApiConfig`
2. Use the dev URL for testing
3. The dev URL may change - check with backend team if connection fails

### After Publishing (Production)
1. Set `isDevelopment = false` in `ApiConfig`
2. The production URL (`https://odadee-connect.replit.app`) is stable and permanent
3. This URL will work for all users once the backend is published

### Environment Variables (Advanced)
For better configuration management, use environment variables:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static String get baseUrl {
    const env = String.fromEnvironment('ENV', defaultValue: 'production');
    
    if (env == 'development') {
      return 'https://a784362b-4352-4c94-81a8-8c3994588922-00-1img99c8h7fps.worf.replit.dev';
    }
    return 'https://odadee-connect.replit.app';
  }
}
```

Then run your app with:
```bash
# Development
flutter run --dart-define=ENV=development

# Production
flutter run --dart-define=ENV=production
```

---

# Part 2: Feature APIs

Now that authentication is working, here are all the features available in your Flutter app. All these endpoints require the `Authorization: Bearer <accessToken>` header unless marked as Public.

---

## 7. Events API

### Get All Events
```
GET /api/events
```

**Response (200 OK)**:
```json
{
  "events": [
    {
      "id": "event-uuid",
      "title": "2024 Homecoming",
      "description": "Annual alumni gathering...",
      "location": "PRESEC Campus",
      "startDate": "2024-12-15T10:00:00.000Z",
      "endDate": "2024-12-15T18:00:00.000Z",
      "imageUrl": "https://...",
      "isVirtual": false,
      "meetingLink": null,
      "price": 50.00,
      "currency": "GHS",
      "maxAttendees": 500,
      "registrationDeadline": "2024-12-10T23:59:59.000Z"
    }
  ]
}
```

### Get Single Event
```
GET /api/events/:id
```

### Register for Event
```
POST /api/events/:id/register
```

**Request Body**:
```json
{
  "numberOfTickets": 2,
  "paymentMethod": "mobile_money",
  "paymentReference": "MM123456789"
}
```

**Response (200 OK)**:
```json
{
  "registration": {
    "id": "registration-uuid",
    "eventId": "event-uuid",
    "userId": "user-uuid",
    "numberOfTickets": 2,
    "totalAmount": 100.00,
    "paymentStatus": "pending",
    "paymentMethod": "mobile_money",
    "paymentReference": "MM123456789"
  }
}
```

### Get My Event Registrations
```
GET /api/events/my-registrations
```

### Flutter Example - Events
```dart
// Fetch all events
Future<List<Map<String, dynamic>>> getEvents() async {
  final response = await authService.authenticatedRequest('GET', '/api/events');
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['events']);
  }
  throw Exception('Failed to load events');
}

// Register for event
Future<void> registerForEvent(String eventId, int tickets) async {
  final response = await authService.authenticatedRequest(
    'POST',
    '/api/events/$eventId/register',
    body: {
      'numberOfTickets': tickets,
      'paymentMethod': 'mobile_money',
      'paymentReference': 'MM${DateTime.now().millisecondsSinceEpoch}',
    },
  );
  
  if (response.statusCode == 200) {
    print('Successfully registered for event');
  }
}
```

---

## 8. Projects API

### Get All Projects
```
GET /api/projects
```

**Response (200 OK)**:
```json
{
  "projects": [
    {
      "id": "project-uuid",
      "title": "New Science Lab",
      "description": "Building a state-of-the-art science laboratory...",
      "goalAmount": 100000.00,
      "raisedAmount": 45000.00,
      "currency": "GHS",
      "status": "active",
      "startDate": "2024-01-01T00:00:00.000Z",
      "targetDate": "2024-12-31T23:59:59.000Z",
      "imageUrl": "https://...",
      "category": "infrastructure"
    }
  ]
}
```

### Get Single Project (with updates)
```
GET /api/projects/:id
```

**Response includes project updates**:
```json
{
  "project": { ...project details... },
  "updates": [
    {
      "id": "update-uuid",
      "title": "Foundation Complete",
      "content": "We've completed the foundation work...",
      "imageUrl": "https://...",
      "createdAt": "2024-10-15T10:00:00.000Z"
    }
  ]
}
```

### Record a Donation/Payment
```
POST /api/projects/:projectId/payments
```

**Request Body**:
```json
{
  "amount": 500.00,
  "paymentMethod": "mobile_money",
  "paymentReference": "MM123456789",
  "donorName": "John Doe",
  "isAnonymous": false
}
```

**Note**: This endpoint is typically restricted to super_admin. For mobile apps, you might want to create a separate donation flow that users can initiate, then admins verify.

### Flutter Example - Projects
```dart
// Fetch all projects
Future<List<Map<String, dynamic>>> getProjects() async {
  final response = await authService.authenticatedRequest('GET', '/api/projects');
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['projects']);
  }
  throw Exception('Failed to load projects');
}

// Get project details with updates
Future<Map<String, dynamic>> getProjectDetails(String projectId) async {
  final response = await authService.authenticatedRequest('GET', '/api/projects/$projectId');
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception('Failed to load project details');
}
```

---

## 9. Community Discussions API

### Get All Discussion Posts
```
GET /api/discussions
```

**Optional Query Parameters**:
- `?category=networking` - Filter by category
- `?limit=20` - Limit results

**Response (200 OK)**:
```json
{
  "discussions": [
    {
      "id": "discussion-uuid",
      "title": "Networking Event Ideas",
      "content": "What are your thoughts on...",
      "category": "networking",
      "authorId": "user-uuid",
      "authorName": "John Doe",
      "createdAt": "2024-10-20T15:30:00.000Z",
      "commentCount": 5
    }
  ]
}
```

### Create Discussion Post
```
POST /api/discussions
```

**Request Body**:
```json
{
  "title": "Looking for Mentors in Tech",
  "content": "Hi everyone, I'm looking for mentors...",
  "category": "mentorship"
}
```

**Categories**: `general`, `networking`, `mentorship`, `career`, `opportunities`

### Get Discussion with Comments
```
GET /api/discussions/:id
```

**Response includes comments**:
```json
{
  "discussion": { ...discussion details... },
  "comments": [
    {
      "id": "comment-uuid",
      "content": "Great idea!",
      "userId": "user-uuid",
      "userName": "Jane Smith",
      "createdAt": "2024-10-20T16:00:00.000Z"
    }
  ]
}
```

### Add Comment to Discussion
```
POST /api/discussions/:id/comments
```

**Request Body**:
```json
{
  "content": "This is my comment on the discussion..."
}
```

### Delete Discussion Post
```
DELETE /api/discussions/:id
```
(Only the author can delete their own post)

### Delete Comment
```
DELETE /api/discussions/:discussionId/comments/:commentId
```

### Flutter Example - Discussions
```dart
// Fetch all discussions
Future<List<Map<String, dynamic>>> getDiscussions() async {
  final response = await authService.authenticatedRequest('GET', '/api/discussions');
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['discussions']);
  }
  throw Exception('Failed to load discussions');
}

// Create new discussion
Future<void> createDiscussion(String title, String content, String category) async {
  final response = await authService.authenticatedRequest(
    'POST',
    '/api/discussions',
    body: {
      'title': title,
      'content': content,
      'category': category,
    },
  );
  
  if (response.statusCode == 200) {
    print('Discussion created successfully');
  }
}

// Add comment
Future<void> addComment(String discussionId, String content) async {
  final response = await authService.authenticatedRequest(
    'POST',
    '/api/discussions/$discussionId/comments',
    body: {'content': content},
  );
  
  if (response.statusCode == 200) {
    print('Comment added successfully');
  }
}
```

---

## 10. Year Groups API

### Get All Year Groups
```
GET /api/year-groups
```

**Response (200 OK)**:
```json
{
  "yearGroups": [
    {
      "id": "year-group-uuid",
      "name": "Class of 2015",
      "year": 2015,
      "description": "The amazing class of 2015",
      "memberCount": 150
    }
  ]
}
```

### Get Year Group Members
```
GET /api/year-groups/:yearGroupId/members
```

### Get Year Group Announcements
```
GET /api/year-groups/:yearGroupId/announcements
```

**Response (200 OK)**:
```json
{
  "announcements": [
    {
      "id": "announcement-uuid",
      "title": "Reunion Planning",
      "content": "We're planning our 10-year reunion...",
      "yearGroupId": "year-group-uuid",
      "createdBy": "user-uuid",
      "createdAt": "2024-10-15T10:00:00.000Z",
      "comments": [
        {
          "id": "comment-uuid",
          "content": "Count me in!",
          "userId": "user-uuid",
          "userName": "John Doe"
        }
      ]
    }
  ]
}
```

### Create Announcement (Year Group Admin Only)
```
POST /api/year-groups/:yearGroupId/announcements
```

**Request Body**:
```json
{
  "title": "Important Update",
  "content": "Dear classmates, here's an important update..."
}
```

### Add Comment to Announcement
```
POST /api/announcements/:announcementId/comments
```

**Request Body**:
```json
{
  "content": "Thanks for the update!"
}
```

### Get Year Group Dues
```
GET /api/year-groups/:yearGroupId/dues
```

**Response (200 OK)**:
```json
{
  "dues": [
    {
      "id": "dues-uuid",
      "title": "Annual Dues 2024",
      "description": "Yearly contribution for class activities",
      "amount": 100.00,
      "currency": "GHS",
      "dueDate": "2024-12-31T23:59:59.000Z",
      "status": "active"
    }
  ]
}
```

### Flutter Example - Year Groups
```dart
// Fetch year groups
Future<List<Map<String, dynamic>>> getYearGroups() async {
  final response = await authService.authenticatedRequest('GET', '/api/year-groups');
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['yearGroups']);
  }
  throw Exception('Failed to load year groups');
}

// Get announcements for a year group
Future<List<Map<String, dynamic>>> getAnnouncements(String yearGroupId) async {
  final response = await authService.authenticatedRequest(
    'GET',
    '/api/year-groups/$yearGroupId/announcements',
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['announcements']);
  }
  throw Exception('Failed to load announcements');
}
```

---

## 11. User Profile API

### Get Current User Profile
```
GET /api/auth/me
```

**Response (200 OK)**:
```json
{
  "id": "user-uuid",
  "email": "john@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": "member",
  "profileImage": "https://...",
  "coverImage": "https://...",
  "bio": "PRESEC alumnus, software engineer...",
  "graduationYear": 2015,
  "phoneNumber": "+233...",
  "location": "Accra, Ghana",
  "currentRole": "Software Engineer",
  "company": "Tech Company",
  "profession": "Engineering",
  "skills": ["JavaScript", "Flutter", "React"],
  "openToMentor": true,
  "isActive": true,
  "lastLoginAt": "2024-10-21T10:00:00.000Z"
}
```

### Get Another User's Profile (with privacy filtering)
```
GET /api/users/:id/profile
```

**Note**: Response is filtered based on that user's privacy settings. Some fields may be hidden.

### Update Own Profile
```
PATCH /api/users/:id/profile
```

**Request Body** (all fields optional):
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "bio": "Updated bio text",
  "phoneNumber": "+233...",
  "location": "Accra, Ghana",
  "currentRole": "Senior Engineer",
  "company": "New Company",
  "profession": "Technology",
  "skills": ["Flutter", "Dart", "Firebase"],
  "openToMentor": true
}
```

### Add Work Experience
```
POST /api/users/:id/work-experience
```

**Request Body**:
```json
{
  "company": "Tech Corp",
  "position": "Software Engineer",
  "startDate": "2020-01-01",
  "endDate": "2023-12-31",
  "description": "Developed mobile applications...",
  "isCurrent": false
}
```

### Add Education
```
POST /api/users/:id/education
```

**Request Body**:
```json
{
  "institution": "University of Ghana",
  "degree": "BSc Computer Science",
  "fieldOfStudy": "Computer Science",
  "startDate": "2015-09-01",
  "endDate": "2019-06-30",
  "description": "Studied computer science fundamentals..."
}
```

### Update Privacy Settings
```
PATCH /api/users/:id/privacy-settings
```

**Request Body**:
```json
{
  "profileVisibility": "alumni_only",
  "emailVisibility": "private",
  "phoneVisibility": "year_group_only",
  "locationVisibility": "alumni_only",
  "workVisibility": "alumni_only",
  "educationVisibility": "public"
}
```

**Visibility Options**: `public`, `alumni_only`, `year_group_only`, `private`

### Search Members
```
GET /api/search/members?query=john&graduationYear=2015&profession=engineering
```

**Query Parameters** (all optional):
- `query` - Name search
- `graduationYear` - Filter by year
- `profession` - Filter by profession
- `location` - Filter by location
- `openToMentor` - Filter mentors (true/false)

### Flutter Example - Profile
```dart
// Get current user profile
Future<Map<String, dynamic>> getMyProfile() async {
  final response = await authService.authenticatedRequest('GET', '/api/auth/me');
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception('Failed to load profile');
}

// Update profile
Future<void> updateProfile(Map<String, dynamic> updates) async {
  final user = await authService.getCurrentUser();
  if (user == null) return;
  
  final response = await authService.authenticatedRequest(
    'PATCH',
    '/api/users/${user['id']}/profile',
    body: updates,
  );
  
  if (response.statusCode == 200) {
    print('Profile updated successfully');
  }
}

// Search members
Future<List<Map<String, dynamic>>> searchMembers(String query) async {
  final response = await authService.authenticatedRequest(
    'GET',
    '/api/search/members?query=$query',
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['users'] ?? []);
  }
  throw Exception('Failed to search members');
}
```

---

## 12. Notifications API

### Get My Notifications
```
GET /api/notifications?limit=50
```

**Response (200 OK)**:
```json
[
  {
    "id": "notification-uuid",
    "userId": "user-uuid",
    "type": "event_registration",
    "title": "Event Registration Confirmed",
    "message": "You're registered for 2024 Homecoming",
    "data": {
      "eventId": "event-uuid",
      "eventTitle": "2024 Homecoming"
    },
    "isRead": false,
    "createdAt": "2024-10-21T10:00:00.000Z"
  }
]
```

**Notification Types**:
- `welcome` - Welcome message
- `event_registration` - Event registration
- `project_update` - Project update
- `year_group_announcement` - Year group announcement
- `dues_reminder` - Dues payment reminder
- `payment_received` - Payment confirmation
- `new_member` - New year group member

### Get Unread Count
```
GET /api/notifications/unread-count
```

**Response (200 OK)**:
```json
{
  "count": 5
}
```

### Mark Notification as Read
```
PATCH /api/notifications/:id/read
```

### Mark All as Read
```
PATCH /api/notifications/read-all
```

### Delete Notification
```
DELETE /api/notifications/:id
```

### Real-Time Notifications (WebSocket)

For real-time notifications, you can connect to the WebSocket endpoint:

```
wss://odadee-connect.replit.app/ws
```

**Important**: Send the access token as a query parameter or use session cookies for WebSocket authentication.

### Flutter Example - Notifications
```dart
// Fetch notifications
Future<List<Map<String, dynamic>>> getNotifications() async {
  final response = await authService.authenticatedRequest(
    'GET',
    '/api/notifications?limit=50',
  );
  
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }
  throw Exception('Failed to load notifications');
}

// Get unread count
Future<int> getUnreadCount() async {
  final response = await authService.authenticatedRequest(
    'GET',
    '/api/notifications/unread-count',
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['count'] as int;
  }
  return 0;
}

// Mark as read
Future<void> markAsRead(String notificationId) async {
  await authService.authenticatedRequest(
    'PATCH',
    '/api/notifications/$notificationId/read',
  );
}

// Mark all as read
Future<void> markAllAsRead() async {
  await authService.authenticatedRequest(
    'PATCH',
    '/api/notifications/read-all',
  );
}

// WebSocket connection (optional for real-time)
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationService {
  WebSocketChannel? _channel;
  
  void connectWebSocket(String accessToken) {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://odadee-connect.replit.app/ws?token=$accessToken'),
    );
    
    _channel!.stream.listen((message) {
      print('New notification: $message');
      // Handle real-time notification
    });
  }
  
  void disconnect() {
    _channel?.sink.close();
  }
}
```

**WebSocket Package**:
```yaml
dependencies:
  web_socket_channel: ^2.4.0
```

---

## 13. Executives API

### Get All Executives
```
GET /api/executives
```

**Response (200 OK)**:
```json
{
  "executives": [
    {
      "id": "executive-uuid",
      "name": "Dr. John Mensah",
      "position": "President",
      "bio": "Dr. Mensah is a renowned educator...",
      "imageUrl": "https://...",
      "email": "president@presec.edu.gh",
      "phoneNumber": "+233...",
      "linkedinUrl": "https://linkedin.com/in/...",
      "order": 1,
      "isActive": true
    }
  ]
}
```

**Note**: This endpoint is typically public or requires authentication depending on your setup. Check with the backend team.

### Flutter Example - Executives
```dart
// Fetch executives
Future<List<Map<String, dynamic>>> getExecutives() async {
  final response = await authService.authenticatedRequest('GET', '/api/executives');
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['executives']);
  }
  throw Exception('Failed to load executives');
}
```

---

## 14. Dashboard Stats

### Get Dashboard Statistics
```
GET /api/stats
```

**Response varies by user role**:

**For Regular Members**:
```json
{
  "totalMembers": 5000,
  "totalYearGroups": 50,
  "totalExecutives": 8,
  "upcomingEvents": 3,
  "availableProducts": 12
}
```

**For Year Group Admins** (includes year group specific stats):
```json
{
  "totalMembers": 5000,
  "totalYearGroups": 50,
  "yearGroupMembers": 150,
  "userYearGroup": "Class of 2015",
  "upcomingEvents": 3,
  "availableProducts": 12
}
```

**For Super Admins** (comprehensive stats):
```json
{
  "totalMembers": 5000,
  "totalYearGroups": 50,
  "totalExecutives": 8,
  "activeExecutives": 8,
  "superAdmins": 3,
  "yearGroupAdmins": 50,
  "members": 4947,
  "upcomingEvents": 3,
  "availableProducts": 12
}
```

### Flutter Example - Stats
```dart
// Fetch dashboard stats
Future<Map<String, dynamic>> getDashboardStats() async {
  final response = await authService.authenticatedRequest('GET', '/api/stats');
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception('Failed to load stats');
}
```

---

## 15. Image Upload

### Upload Profile Image
```
POST /api/upload/profile-image
```

**Content-Type**: `multipart/form-data`

**Form Data**:
- `image` - The image file (JPG, PNG, WebP, max 5MB)

**Response (200 OK)**:
```json
{
  "imageUrl": "https://.../profile-images/user-uuid.jpg"
}
```

### Upload Cover Image
```
POST /api/upload/cover-image
```

**Content-Type**: `multipart/form-data`

**Form Data**:
- `image` - The image file (JPG, PNG, WebP, max 5MB)

### Update User Images
```
PUT /api/users/:id/images
```

**Request Body**:
```json
{
  "profileImage": "https://.../profile-images/user-uuid.jpg",
  "coverImage": "https://.../cover-images/user-uuid.jpg"
}
```

### Flutter Example - Image Upload
```dart
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';

// Upload profile image
Future<String> uploadProfileImage(File imageFile) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'access_token');
  
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('${ApiConfig.baseUrl}/api/upload/profile-image'),
  );
  
  request.headers['Authorization'] = 'Bearer $accessToken';
  
  request.files.add(
    await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ),
  );
  
  final response = await request.send();
  final responseBody = await response.stream.bytesToString();
  
  if (response.statusCode == 200) {
    final data = jsonDecode(responseBody);
    return data['imageUrl'];
  }
  
  throw Exception('Failed to upload image');
}

// Complete profile image update flow
Future<void> updateProfileImage(File imageFile) async {
  // 1. Upload the image
  final imageUrl = await uploadProfileImage(imageFile);
  
  // 2. Update user profile with new image URL
  final user = await authService.getCurrentUser();
  if (user == null) return;
  
  final response = await authService.authenticatedRequest(
    'PUT',
    '/api/users/${user['id']}/images',
    body: {'profileImage': imageUrl},
  );
  
  if (response.statusCode == 200) {
    print('Profile image updated successfully');
  }
}
```

**Required Package**:
```yaml
dependencies:
  http_parser: ^4.0.2
  image_picker: ^1.0.4  # For picking images from gallery/camera
```

---

## Summary of Key Endpoints

| Feature | Key Endpoints |
|---------|--------------|
| **Auth** | POST /api/auth/mobile/login, POST /api/auth/mobile/refresh |
| **Events** | GET /api/events, POST /api/events/:id/register |
| **Projects** | GET /api/projects, GET /api/projects/:id |
| **Discussions** | GET /api/discussions, POST /api/discussions, POST /api/discussions/:id/comments |
| **Year Groups** | GET /api/year-groups, GET /api/year-groups/:id/announcements |
| **Profile** | GET /api/auth/me, PATCH /api/users/:id/profile |
| **Notifications** | GET /api/notifications, PATCH /api/notifications/:id/read |
| **Executives** | GET /api/executives |
| **Stats** | GET /api/stats |
| **Images** | POST /api/upload/profile-image, POST /api/upload/cover-image |

---

## Common Patterns

### Pagination
Most list endpoints support pagination (though not all implement it yet):
```
GET /api/discussions?page=1&limit=20
```

### Filtering
Many endpoints support query parameters for filtering:
```
GET /api/search/members?graduationYear=2015&profession=engineering
```

### Error Handling
All endpoints return consistent error format:
```json
{
  "message": "Error description here"
}
```

Common status codes:
- `200` - Success
- `400` - Bad request (invalid data)
- `401` - Unauthorized (invalid/expired token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not found
- `500` - Server error

---

## For Complete API Documentation

For the full interactive API documentation with all endpoints, examples, and testing capabilities:

1. Login to the web app as super admin (superadmin@presec.edu.gh / Admin@123)
2. Visit: `https://odadee-connect.replit.app/api-docs`
3. This shows all 80+ endpoints with request/response examples
