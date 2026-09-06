class VibeAnswer {
  final String id;
  final String responderName;
  final String responderRank;
  final String crowdStatus; // 'Peaceful', 'Moderate', 'Very Packed'
  final String comment;
  final DateTime timestamp;

  VibeAnswer({
    required this.id,
    required this.responderName,
    required this.responderRank,
    required this.crowdStatus,
    required this.comment,
    required this.timestamp,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class VibePing {
  final String id;
  final String placeId;
  final String placeName;
  final String requesterName;
  final String question;
  final DateTime timestamp;
  final List<VibeAnswer> answers;

  VibePing({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.requesterName,
    required this.question,
    required this.timestamp,
    required this.answers,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
