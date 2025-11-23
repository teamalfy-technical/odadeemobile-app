class ApiConfig {
  static const bool isDevelopment = false;
  
  static String get baseUrl {
    return 'https://odadee.net';
  }
  
  static const String loginEndpoint = '/api/auth/mobile/login';
  static const String refreshEndpoint = '/api/auth/mobile/refresh';
  static const String logoutEndpoint = '/api/auth/mobile/logout';
  static const String logoutAllEndpoint = '/api/auth/mobile/logout-all';
  static const String meEndpoint = '/api/auth/me';
  
  static const String publicEventsEndpoint = '/api/public/events';
  static const String publicProjectsEndpoint = '/api/public/projects';
  static const String eventsEndpoint = '/api/events';
  static const String projectsEndpoint = '/api/projects';
  
  static const String appVersion = '1.1.0';
  
  static const Duration accessTokenLifetime = Duration(minutes: 15);
  static const Duration refreshTokenLifetime = Duration(days: 30);
}
