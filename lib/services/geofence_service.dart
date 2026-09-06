import 'dart:async';
import 'dart:math';
import '../models/place.dart';

class InAppNotification {
  final String id;
  final String title;
  final String body;
  final String placeId;
  final String placeName;
  final DateTime timestamp;
  final bool isRead;

  InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.placeId,
    required this.placeName,
    required this.timestamp,
    this.isRead = false,
  });
}

class GeofenceService {
  static const double geofenceRadiusMeters = 350.0;

  double? _userLat;
  double? _userLng;
  Place? _currentInsidePlace;

  final StreamController<InAppNotification> _notificationController =
      StreamController<InAppNotification>.broadcast();
  Stream<InAppNotification> get notificationStream => _notificationController.stream;

  final List<InAppNotification> notificationHistory = [];

  Place? get currentInsidePlace => _currentInsidePlace;
  double? get userLat => _userLat;
  double? get userLng => _userLng;

  /// Calculate distance between two points in meters using Haversine formula
  static double distanceBetweenMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a)); // R = 6371 km = 6371000 meters
  }

  /// Update user location and check for geofence entries
  Place? updateLocation(double lat, double lon, List<Place> candidatePlaces) {
    _userLat = lat;
    _userLng = lon;

    Place? matchedPlace;
    double closestDistance = double.infinity;

    for (final place in candidatePlaces) {
      final distance = distanceBetweenMeters(lat, lon, place.latitude, place.longitude);
      if (distance <= geofenceRadiusMeters && distance < closestDistance) {
        closestDistance = distance;
        matchedPlace = place;
      }
    }

    // Trigger geofence entry notification if entered a new place
    if (matchedPlace != null && _currentInsidePlace?.id != matchedPlace.id) {
      _currentInsidePlace = matchedPlace;
      _triggerGeofenceNotification(matchedPlace, closestDistance.round());
    } else if (matchedPlace == null) {
      _currentInsidePlace = null;
    }

    return _currentInsidePlace;
  }

  /// Teleport for instant emulator/web testing
  Place simulateTeleportToPlace(Place place) {
    _userLat = place.latitude;
    _userLng = place.longitude;
    _currentInsidePlace = place;
    _triggerGeofenceNotification(place, 15);
    return place;
  }

  void _triggerGeofenceNotification(Place place, int distanceMeters) {
    final notif = InAppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '📍 Arrived at ${place.name}!',
      body: 'You are ${distanceMeters}m away. How crowded is it right now? Share a vibe check to earn +15 XP!',
      placeId: place.id,
      placeName: place.name,
      timestamp: DateTime.now(),
    );

    notificationHistory.insert(0, notif);
    _notificationController.add(notif);
  }

  void dispose() {
    _notificationController.close();
  }
}
