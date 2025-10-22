class ApiConfig {
  static const bool isDevelopment = false;
  
  static String get baseUrl {
    return isDevelopment
        ? 'https://a784362b-4352-4c94-81a8-8c3994588922-00-1img99c8h7fps.worf.replit.dev'
        : 'https://odadee-connect.replit.app';
  }
  
  static const String loginEndpoint = '/api/auth/mobile/login';
  static const String refreshEndpoint = '/api/auth/mobile/refresh';
  static const String logoutEndpoint = '/api/auth/mobile/logout';
  static const String logoutAllEndpoint = '/api/auth/mobile/logout-all';
  static const String meEndpoint = '/api/auth/me';
  
  static const String appVersion = '1.0.0';
  
  static const Duration accessTokenLifetime = Duration(minutes: 15);
  static const Duration refreshTokenLifetime = Duration(days: 30);
}
