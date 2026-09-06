import 'package:flutter/material.dart';

class ScoutBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final String? dateEarned;

  const ScoutBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.dateEarned,
  });
}

class DailyQuest {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int currentProgress;
  final int targetProgress;
  final bool isClaimed;

  DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.currentProgress,
    required this.targetProgress,
    this.isClaimed = false,
  });

  bool get isCompleted => currentProgress >= targetProgress;

  DailyQuest copyWith({
    int? currentProgress,
    bool? isClaimed,
  }) {
    return DailyQuest(
      id: id,
      title: title,
      description: description,
      xpReward: xpReward,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String handle;
  final String avatarUrl;
  int xp;
  int streakDays;
  int totalSnapsCount;
  int totalVerificationsCount;
  int cityRank;
  final List<ScoutBadge> badges;
  final List<DailyQuest> quests;

  UserProfile({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    this.xp = 850,
    this.streakDays = 5,
    this.totalSnapsCount = 14,
    this.totalVerificationsCount = 28,
    this.cityRank = 4,
    required this.badges,
    required this.quests,
  });

  String get rankTitle {
    if (xp >= 3000) return 'Varanasi Legend';
    if (xp >= 1500) return 'Pulse Ambassador';
    if (xp >= 600) return 'City Insider';
    if (xp >= 200) return 'Local Scout';
    return 'Ghat Wanderer';
  }

  int get tierLevel {
    if (xp >= 3000) return 5;
    if (xp >= 1500) return 4;
    if (xp >= 600) return 3;
    if (xp >= 200) return 2;
    return 1;
  }

  int get nextTierXp {
    if (xp >= 3000) return 5000;
    if (xp >= 1500) return 3000;
    if (xp >= 600) return 1500;
    if (xp >= 200) return 600;
    return 200;
  }

  int get currentTierBaseXp {
    if (xp >= 3000) return 3000;
    if (xp >= 1500) return 1500;
    if (xp >= 600) return 600;
    if (xp >= 200) return 200;
    return 0;
  }

  double get tierProgress {
    final range = nextTierXp - currentTierBaseXp;
    if (range <= 0) return 1.0;
    final progress = (xp - currentTierBaseXp) / range;
    return progress.clamp(0.0, 1.0);
  }
}
