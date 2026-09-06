import 'package:flutter_test/flutter_test.dart';
import 'package:pulsemap/models/crowd_category.dart';
import 'package:pulsemap/models/place.dart';
import 'package:pulsemap/models/snap.dart';
import 'package:pulsemap/services/crowd_engine.dart';

void main() {
  group('CrowdEngine Unit Tests', () {
    test('computeSnapFreshness decays over time', () {
      final now = DateTime(2026, 9, 7, 18, 0, 0);

      // Snap taken 10 mins ago -> 1.0
      final fresh = CrowdEngine.computeSnapFreshness(
        now.subtract(const Duration(minutes: 10)),
        now,
      );
      expect(fresh, equals(1.0));

      // Snap taken 25 mins ago -> 0.85
      final medium = CrowdEngine.computeSnapFreshness(
        now.subtract(const Duration(minutes: 25)),
        now,
      );
      expect(medium, equals(0.85));

      // Snap taken 50 mins ago -> 0.40
      final oldSnap = CrowdEngine.computeSnapFreshness(
        now.subtract(const Duration(minutes: 50)),
        now,
      );
      expect(oldSnap, equals(0.40));
    });

    test('classifyScore correctly categorizes crowd levels', () {
      expect(CrowdEngine.classifyScore(15), equals(CrowdCategory.calm));
      expect(CrowdEngine.classifyScore(30), equals(CrowdCategory.calm));
      expect(CrowdEngine.classifyScore(45), equals(CrowdCategory.moderate));
      expect(CrowdEngine.classifyScore(60), equals(CrowdCategory.moderate));
      expect(CrowdEngine.classifyScore(75), equals(CrowdCategory.bustling));
      expect(CrowdEngine.classifyScore(80), equals(CrowdCategory.bustling));
      expect(CrowdEngine.classifyScore(92), equals(CrowdCategory.overloaded));
    });

    test('determineVerdict provides proper action recommendations', () {
      expect(CrowdEngine.determineVerdict(20), equals(AdvisoryVerdict.goNow));
      expect(CrowdEngine.determineVerdict(50), equals(AdvisoryVerdict.goodToGo));
      expect(CrowdEngine.determineVerdict(70), equals(AdvisoryVerdict.caution));
      expect(CrowdEngine.determineVerdict(90), equals(AdvisoryVerdict.avoid));
    });

    test('calculateFusedCrowdScore fuses snaps, traffic, and P2P consensus', () {
      final now = DateTime(2026, 9, 7, 19, 0, 0);

      // High rush signals
      final packedSnaps = [
        Snap(
          id: 's1',
          placeId: 'dashashwamedh',
          placeName: 'Dashashwamedh',
          userId: 'u1',
          userName: 'User 1',
          userAvatar: '',
          imageUrl: '',
          timestamp: now.subtract(const Duration(minutes: 5)),
          caption: 'Packed!',
          crowdRating: 4, // Overloaded
          vibeTag: 'Aarti Rush',
        ),
        Snap(
          id: 's2',
          placeId: 'dashashwamedh',
          placeName: 'Dashashwamedh',
          userId: 'u2',
          userName: 'User 2',
          userAvatar: '',
          imageUrl: '',
          timestamp: now.subtract(const Duration(minutes: 12)),
          caption: 'Very crowded',
          crowdRating: 4, // Overloaded
          vibeTag: 'Aarti Rush',
        ),
      ];

      final fusedScore = CrowdEngine.calculateFusedCrowdScore(
        recentSnaps: packedSnaps,
        p2pAverageRating: 95,
        approachTrafficScore: 90,
        historicalBaseline: 90,
        now: now,
      );

      // Should be heavily crowded (> 80)
      expect(fusedScore, greaterThanOrEqualTo(85));
      expect(CrowdEngine.classifyScore(fusedScore), equals(CrowdCategory.overloaded));
      expect(CrowdEngine.determineVerdict(fusedScore), equals(AdvisoryVerdict.avoid));
    });

    test('findCalmerAlternative suggests lower crowd haven when primary spot is packed', () {
      final crowdedPlace = Place(
        id: 'p_crowded',
        name: 'Crowded Ghat',
        category: 'Ghat',
        latitude: 25.30,
        longitude: 83.01,
        description: 'Busy place',
        address: 'Main Rd',
        imageUrl: '',
        currentScore: 92,
        hourlyForecast: List.filled(24, 50),
      );

      final calmPlace = Place(
        id: 'p_calm',
        name: 'Peaceful Ghat',
        category: 'Heritage',
        latitude: 25.29,
        longitude: 83.00,
        description: 'Quiet fort ghat',
        address: 'Quiet Rd',
        imageUrl: '',
        currentScore: 20,
        hourlyForecast: List.filled(24, 20),
      );

      final alternative = CrowdEngine.findCalmerAlternative(
        crowdedPlace,
        [crowdedPlace, calmPlace],
      );

      expect(alternative, isNotNull);
      expect(alternative!.id, equals('p_calm'));
      expect(alternative.currentScore, equals(20));
    });
  });
}
