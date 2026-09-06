import 'package:flutter_test/flutter_test.dart';
import 'package:pulsemap/models/sync_event.dart';
import 'package:pulsemap/services/city_data.dart';
import 'package:pulsemap/services/cloud_sync_service.dart';
import 'package:pulsemap/services/geofence_service.dart';
import 'package:pulsemap/services/google_maps_api_service.dart';

void main() {
  group('Multi-City Expansion Tests', () {
    test('Supported cities list contains 5 target metro/heritage hubs', () {
      final cities = CityData.getSupportedCities();
      expect(cities.length, equals(5));

      final cityNames = cities.map((c) => c.name).toList();
      expect(cityNames, contains('Varanasi'));
      expect(cityNames, contains('Delhi (NCR)'));
      expect(cityNames, contains('Mumbai'));
      expect(cityNames, contains('Bengaluru'));
      expect(cityNames, contains('Jaipur'));
    });

    test('All hotspots load properly and are mapped to respective cities', () {
      final allPlaces = CityData.getAllPlaces();
      expect(allPlaces.length, greaterThanOrEqualTo(25));

      final delhiPlaces = allPlaces.where((p) => p.city.contains('Delhi')).toList();
      expect(delhiPlaces.length, equals(6));

      final mumbaiPlaces = allPlaces.where((p) => p.city.contains('Mumbai')).toList();
      expect(mumbaiPlaces.length, equals(6));

      final blrPlaces = allPlaces.where((p) => p.city.contains('Bengaluru')).toList();
      expect(blrPlaces.length, equals(5));

      final jaipurPlaces = allPlaces.where((p) => p.city.contains('Jaipur')).toList();
      expect(jaipurPlaces.length, equals(5));
    });
  });

  group('Cloud Sync & Event Serialization Tests', () {
    test('SyncEvent serializes and deserializes correctly', () {
      final now = DateTime(2026, 9, 7, 12, 0, 0);
      final event = SyncEvent(
        id: 'evt_123',
        type: SyncEventType.snapCreated,
        cityId: 'delhi',
        placeId: 'delhi_india_gate',
        payload: {
          'caption': 'Sunset at India Gate!',
          'crowdRating': 4,
          'vibeTag': 'Evening Rush',
        },
        timestamp: now,
        originDeviceId: 'dev_alpha',
      );

      final json = event.toJson();
      expect(json['id'], equals('evt_123'));
      expect(json['type'], equals('snapCreated'));
      expect(json['cityId'], equals('delhi'));

      final restored = SyncEvent.fromJson(json);
      expect(restored.id, equals(event.id));
      expect(restored.type, equals(SyncEventType.snapCreated));
      expect(restored.payload['crowdRating'], equals(4));
    });

    test('CloudSyncService broadcasts event locally with zero-latency', () async {
      final syncService = CloudSyncService();
      final event = SyncEvent(
        id: 'test_sync',
        type: SyncEventType.crowdRated,
        cityId: 'varanasi',
        placeId: 'dashashwamedh_ghat',
        payload: {'score': 88},
        timestamp: DateTime.now(),
        originDeviceId: 'dev_local',
      );

      expect(
        syncService.eventStream,
        emits(predicate<SyncEvent>((e) => e.id == 'test_sync' && e.placeId == 'dashashwamedh_ghat')),
      );

      await syncService.broadcastEvent(event);
      syncService.dispose();
    });
  });

  group('Geofencing & Proximity Tests', () {
    test('distanceBetweenMeters computes accurate distance', () {
      // Distance between India Gate (28.6129, 77.2295) and same point should be 0
      final zeroDist = GeofenceService.distanceBetweenMeters(
        28.6129,
        77.2295,
        28.6129,
        77.2295,
      );
      expect(zeroDist, closeTo(0.0, 0.1));

      // Distance between India Gate and Connaught Place (~2.3 km)
      final cpDist = GeofenceService.distanceBetweenMeters(
        28.6129,
        77.2295,
        28.6315,
        77.2167,
      );
      expect(cpDist, greaterThan(2000));
      expect(cpDist, lessThan(2700));
    });

    test('updateLocation triggers geofence notification when entering hotspot boundary', () async {
      final geofenceService = GeofenceService();
      final allPlaces = CityData.getAllPlaces();
      final indiaGate = allPlaces.firstWhere((p) => p.id == 'delhi_india_gate');

      expect(
        geofenceService.notificationStream,
        emits(predicate<InAppNotification>((notif) => notif.placeId == 'delhi_india_gate')),
      );

      // User walks to within 100 meters of India Gate
      final enteredPlace = geofenceService.updateLocation(
        indiaGate.latitude + 0.0005,
        indiaGate.longitude + 0.0005,
        allPlaces,
      );

      expect(enteredPlace, isNotNull);
      expect(enteredPlace!.id, equals('delhi_india_gate'));
      expect(geofenceService.notificationHistory.isNotEmpty, isTrue);

      geofenceService.dispose();
    });
  });

  group('Google Maps Platform API Service Tests', () {
    test('GoogleMapsApiService handles live mode configuration and fallbacks', () {
      final service = GoogleMapsApiService();
      expect(service.isLiveMode, isFalse);

      service.configureApiKey('AIzaSyDummyKeyTest');
      expect(service.isLiveMode, isTrue);
      expect(service.apiKey, equals('AIzaSyDummyKeyTest'));

      service.configureApiKey(null);
      expect(service.isLiveMode, isFalse);
    });
  });
}
