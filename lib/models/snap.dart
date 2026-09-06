class Snap {
  final String id;
  final String placeId;
  final String placeName;
  final String userId;
  final String userName;
  final String userAvatar;
  final String userRank;
  final String imageUrl;
  final DateTime timestamp;
  final String caption;
  final int crowdRating; // 1: Calm, 2: Moderate, 3: Bustling, 4: Overloaded
  final String vibeTag;
  int upvotes;
  bool hasUserUpvoted;
  final bool isGpsVerified;

  Snap({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.userRank = 'Local Scout',
    required this.imageUrl,
    required this.timestamp,
    required this.caption,
    required this.crowdRating,
    required this.vibeTag,
    this.upvotes = 0,
    this.hasUserUpvoted = false,
    this.isGpsVerified = true,
  });

  String get crowdLabel {
    switch (crowdRating) {
      case 1:
        return 'Peaceful / Calm';
      case 2:
        return 'Pleasant / Moderate';
      case 3:
        return 'Bustling / Crowded';
      case 4:
        return 'Packed / Heavy Rush';
      default:
        return 'Moderate';
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Snap copyWith({
    String? id,
    String? placeId,
    String? placeName,
    String? userId,
    String? userName,
    String? userAvatar,
    String? userRank,
    String? imageUrl,
    DateTime? timestamp,
    String? caption,
    int? crowdRating,
    String? vibeTag,
    int? upvotes,
    bool? hasUserUpvoted,
    bool? isGpsVerified,
  }) {
    return Snap(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userRank: userRank ?? this.userRank,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      caption: caption ?? this.caption,
      crowdRating: crowdRating ?? this.crowdRating,
      vibeTag: vibeTag ?? this.vibeTag,
      upvotes: upvotes ?? this.upvotes,
      hasUserUpvoted: hasUserUpvoted ?? this.hasUserUpvoted,
      isGpsVerified: isGpsVerified ?? this.isGpsVerified,
    );
  }
}
