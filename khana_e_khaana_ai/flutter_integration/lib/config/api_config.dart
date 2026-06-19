class ApiConfig {
  // Use 10.0.2.2 for Android emulator to access localhost
  // Use localhost for iOS simulator or web
  // Use your machine's IP address for physical devices
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  static const String searchEndpoint = '$baseUrl/search';
  static const String similarEndpoint = '$baseUrl/similar';
  static const String topRatedEndpoint = '$baseUrl/top-rated-simple';
}
