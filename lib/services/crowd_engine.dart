import 'dart:math';
import '../models/crowd_category.dart';
import '../models/place.dart';
import '../models/snap.dart';

class CrowdEngine {
  /// Weights for the multi-signal crowd detection algorithm
  static const double snapWeight = 0.35;
  static const double p2pVoteWeight = 0.30;
  static const double trafficWeight = 0.20;
  static const double historicalWeight = 0.15;

  /// Calculate time decay for a snap based on how fresh it is (0.0 to 1.0)
  static double computeSnapFreshness(DateTime timestamp, DateTime currentTime) {
    final diffMinutes = currentTime.difference(timestamp).inMinutes;
    if (diffMinutes <= 15) return 1.0;
    if (diffMinutes <= 30) return 0.85;
    if (diffMinutes <= 60) return 0.40;
    if (diffMinutes <= 120) return 0.15;
    return 0.05;
  }

  /// Calculates the fused crowd score (0 - 100)
  static int calculateFusedCrowdScore({
    required List<Snap> recentSnaps,
    required int p2pAverageRating, // 1 to 4 scale, or scaled 0-100
    required int approachTrafficScore, // 0 to 100
    required int historicalBaseline, // 0 to 100
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    // 1. Signal A: Snap Activity & Density
    double snapSignal = 0;
    if (recentSnaps.isNotEmpty) {
      double totalSnapScore = 0;
      double totalWeight = 0;
      final distinctUsers = <String>{};

      for (final snap in recentSnaps) {
        final freshness = computeSnapFreshness(snap.timestamp, currentTime);
        // snap.crowdRating is 1..4, mapped to 20, 50, 75, 95
        double ratingScaled;
        switch (snap.crowdRating) {
          case 1:
            ratingScaled = 20.0;
            break;
          case 2:
            ratingScaled = 50.0;
            break;
          case 3:
            ratingScaled = 75.0;
            break;
          case 4:
          default:
            ratingScaled = 95.0;
            break;
        }

        // Distinct user bonus
        final userBonus = distinctUsers.contains(snap.userId) ? 1.0 : 1.25;
        distinctUsers.add(snap.userId);

        final weight = freshness * userBonus;
        totalSnapScore += ratingScaled * weight;
        totalWeight += weight;
      }

      if (totalWeight > 0) {
        snapSignal = totalSnapScore / totalWeight;
      }
    } else {
      snapSignal = historicalBaseline.toDouble();
    }

    // 2. Signal B: P2P Community Consensus (scaled 0-100)
    final double p2pSignal = p2pAverageRating.toDouble().clamp(0.0, 100.0);

    // 3. Signal C: Approach Road Traffic (Google Maps Traffic telemetry)
    final double trafficSignal = approachTrafficScore.toDouble().clamp(0.0, 100.0);

    // 4. Signal D: Historical Peak & Event Curve
    final double histSignal = historicalBaseline.toDouble().clamp(0.0, 100.0);

    // Fused Score
    final fused = (snapSignal * snapWeight) +
        (p2pSignal * p2pVoteWeight) +
        (trafficSignal * trafficWeight) +
        (histSignal * historicalWeight);

    return fused.round().clamp(5, 100);
  }

  /// Classify numeric score (0 - 100) into CrowdCategory
  static CrowdCategory classifyScore(int score) {
    if (score <= 30) {
      return CrowdCategory.calm;
    } else if (score <= 60) {
      return CrowdCategory.moderate;
    } else if (score <= 80) {
      return CrowdCategory.bustling;
    } else {
      return CrowdCategory.overloaded;
    }
  }

  /// Determine actionable advisory verdict
  static AdvisoryVerdict determineVerdict(int score) {
    if (score <= 30) {
      return AdvisoryVerdict.goNow;
    } else if (score <= 60) {
      return AdvisoryVerdict.goodToGo;
    } else if (score <= 80) {
      return AdvisoryVerdict.caution;
    } else {
      return AdvisoryVerdict.avoid;
    }
  }

  /// Recommend a calmer alternative nearby if current place is crowded
  static Place? findCalmerAlternative(Place currentPlace, List<Place> allPlaces) {
    if (currentPlace.currentScore <= 60) return null;

    Place? bestAlternative;
    int lowestScore = currentPlace.currentScore;

    for (final place in allPlaces) {
      if (place.id != currentPlace.id && place.currentScore < lowestScore) {
        lowestScore = place.currentScore;
        bestAlternative = place;
      }
    }

    return bestAlternative;
  }

  /// Helper to calculate approximate distance in km
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
