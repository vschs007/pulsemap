import 'package:flutter/material.dart';

/// Categories of crowdedness
enum CrowdCategory {
  calm,
  moderate,
  bustling,
  overloaded,
}

/// Actionable decision advice for a user planning to visit
enum AdvisoryVerdict {
  goNow,
  goodToGo,
  caution,
  avoid,
}

extension CrowdCategoryExt on CrowdCategory {
  String get displayName {
    switch (this) {
      case CrowdCategory.calm:
        return 'Calm & Serene';
      case CrowdCategory.moderate:
        return 'Pleasant / Moderate';
      case CrowdCategory.bustling:
        return 'Bustling & Active';
      case CrowdCategory.overloaded:
        return 'Overloaded / Peak Rush';
    }
  }

  String get shortLabel {
    switch (this) {
      case CrowdCategory.calm:
        return 'CALM';
      case CrowdCategory.moderate:
        return 'MODERATE';
      case CrowdCategory.bustling:
        return 'BUSTLING';
      case CrowdCategory.overloaded:
        return 'PACKED';
    }
  }

  Color get color {
    switch (this) {
      case CrowdCategory.calm:
        return const Color(0xFF00E676); // Neon Emerald
      case CrowdCategory.moderate:
        return const Color(0xFFFFD600); // Radiant Amber
      case CrowdCategory.bustling:
        return const Color(0xFFFF6D00); // Deep Orange
      case CrowdCategory.overloaded:
        return const Color(0xFFFF1744); // Crimson Neon
    }
  }

  Color get glowColor {
    switch (this) {
      case CrowdCategory.calm:
        return const Color(0x6600E676);
      case CrowdCategory.moderate:
        return const Color(0x66FFD600);
      case CrowdCategory.bustling:
        return const Color(0x66FF6D00);
      case CrowdCategory.overloaded:
        return const Color(0x80FF1744);
    }
  }

  IconData get icon {
    switch (this) {
      case CrowdCategory.calm:
        return Icons.spa_rounded;
      case CrowdCategory.moderate:
        return Icons.people_outline_rounded;
      case CrowdCategory.bustling:
        return Icons.groups_rounded;
      case CrowdCategory.overloaded:
        return Icons.warning_amber_rounded;
    }
  }

  String get description {
    switch (this) {
      case CrowdCategory.calm:
        return 'Uncrowded, easy movement, plenty of open seating, zero wait.';
      case CrowdCategory.moderate:
        return 'Typical steady crowd. Smooth walking flow and manageable queues.';
      case CrowdCategory.bustling:
        return 'High foot traffic. Expect boat & temple queues and dense spots.';
      case CrowdCategory.overloaded:
        return 'Extreme density (Aarti/festival rush). Bottlenecks & heavy road delays.';
    }
  }
}

extension AdvisoryVerdictExt on AdvisoryVerdict {
  String get title {
    switch (this) {
      case AdvisoryVerdict.goNow:
        return 'GO NOW';
      case AdvisoryVerdict.goodToGo:
        return 'GOOD TO GO';
      case AdvisoryVerdict.caution:
        return 'GO WITH CAUTION';
      case AdvisoryVerdict.avoid:
        return 'VISIT LATER / AVOID';
    }
  }

  String get subtitle {
    switch (this) {
      case AdvisoryVerdict.goNow:
        return 'Prime window! Ideal for peaceful exploration & photos.';
      case AdvisoryVerdict.goodToGo:
        return 'Comfortable vibe. Enjoyable atmosphere with minimal delays.';
      case AdvisoryVerdict.caution:
        return 'Getting busy. Arrive soon to secure seating or beat queues.';
      case AdvisoryVerdict.avoid:
        return 'Peak rush bottleneck! Consider postponing or checking a quiet spot.';
    }
  }

  Color get badgeColor {
    switch (this) {
      case AdvisoryVerdict.goNow:
        return const Color(0xFF00E676);
      case AdvisoryVerdict.goodToGo:
        return const Color(0xFF69F0AE);
      case AdvisoryVerdict.caution:
        return const Color(0xFFFFAB00);
      case AdvisoryVerdict.avoid:
        return const Color(0xFFFF5252);
    }
  }

  IconData get icon {
    switch (this) {
      case AdvisoryVerdict.goNow:
        return Icons.check_circle_rounded;
      case AdvisoryVerdict.goodToGo:
        return Icons.thumb_up_alt_rounded;
      case AdvisoryVerdict.caution:
        return Icons.info_outline_rounded;
      case AdvisoryVerdict.avoid:
        return Icons.do_not_disturb_on_rounded;
    }
  }
}
