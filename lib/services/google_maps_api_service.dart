import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleMapsConnectionResult {
  final bool isSuccess;
  final String message;
  final int? latencyMs;

  GoogleMapsConnectionResult({
    required this.isSuccess,
    required this.message,
    this.latencyMs,
  });
}

class GoogleMapsApiService {
  String? _apiKey;
  bool _useLiveGoogleApis = false;

  String? get apiKey => _apiKey;
  bool get isLiveMode => _useLiveGoogleApis && _apiKey != null && _apiKey!.isNotEmpty;

  void configureApiKey(String? key, {bool enableLive = true}) {
    _apiKey = key?.trim();
    _useLiveGoogleApis = enableLive && _apiKey != null && _apiKey!.isNotEmpty;
  }

  /// Test Google Maps API Key connectivity
  Future<GoogleMapsConnectionResult> testApiKeyConnection(String key) async {
    final cleanKey = key.trim();
    if (cleanKey.isEmpty) {
      return GoogleMapsConnectionResult(
        isSuccess: false,
        message: 'API Key cannot be empty',
      );
    }

    final stopwatch = Stopwatch()..start();
    try {
      // Test with Geocoding API endpoint or Routes API computeRoutes
      final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?address=India+Gate&key=$cleanKey');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];
        if (status == 'OK' || status == 'ZERO_RESULTS') {
          return GoogleMapsConnectionResult(
            isSuccess: true,
            message: 'Connected successfully to Google Maps Platform!',
            latencyMs: stopwatch.elapsedMilliseconds,
          );
        } else if (status == 'REQUEST_DENIED') {
          final errorMessage = data['error_message'] ?? 'Request denied. Verify API key restrictions.';
          return GoogleMapsConnectionResult(
            isSuccess: false,
            message: errorMessage,
            latencyMs: stopwatch.elapsedMilliseconds,
          );
        }
      }

      return GoogleMapsConnectionResult(
        isSuccess: false,
        message: 'Google returned status ${response.statusCode}: ${response.reasonPhrase}',
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      return GoogleMapsConnectionResult(
        isSuccess: false,
        message: 'Connection failed: ${e.toString()}',
      );
    }
  }

  /// Query Routes API with TRAFFIC_AWARE to compute traffic delay score (0 - 100)
  Future<int?> fetchRoutesTrafficCongestion({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    if (!isLiveMode || _apiKey == null) return null;

    try {
      final url = Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey!,
          'X-Goog-FieldMask': 'routes.duration,routes.staticDuration',
        },
        body: jsonEncode({
          'origin': {
            'location': {
              'latLng': {'latitude': originLat, 'longitude': originLng}
            }
          },
          'destination': {
            'location': {
              'latLng': {'latitude': destLat, 'longitude': destLng}
            }
          },
          'travelMode': 'DRIVE',
          'routingPreference': 'TRAFFIC_AWARE',
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes.first;
          final durationStr = route['duration'] as String? ?? '0s';
          final staticDurationStr = route['staticDuration'] as String? ?? '0s';

          final liveSeconds = int.tryParse(durationStr.replaceAll('s', '')) ?? 0;
          final normalSeconds = int.tryParse(staticDurationStr.replaceAll('s', '')) ?? 0;

          if (normalSeconds > 0) {
            final delayRatio = (liveSeconds - normalSeconds) / normalSeconds;
            // Map ratio to 0-100 score: 0% delay -> 25 score, +100% delay -> 95 score
            final score = (delayRatio * 65 + 25).round().clamp(10, 100);
            return score;
          }
        }
      }
    } catch (_) {
      // Return null on failure to fall back to the smart traffic model
    }
    return null;
  }
}
