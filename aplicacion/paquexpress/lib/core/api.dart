import 'package:flutter/foundation.dart';

const String API_SERVER_IP = '192.168.1.XX';

String getApiBaseUrl() {
  if (kIsWeb) return 'http://127.0.0.1:8000';
  return 'http://$API_SERVER_IP:8000';
}

final String apiEndpoint = getApiBaseUrl();
