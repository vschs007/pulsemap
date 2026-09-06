import 'crowd_category.dart';

class Place {
  final String id;
  final String name;
  final String city;
  final String category; // 'Ghat', 'Temple', 'Market', 'Corridor', 'Heritage'
  final double latitude;
  final double longitude;
  final String description;
  final String address;
  final String imageUrl;
  
  // Dynamic Crowd Intelligence State
  int currentScore; // 0 - 100
  CrowdCategory crowdCategory;
  AdvisoryVerdict advisoryVerdict;
  int approachTrafficScore; // 0 - 100 (from Google Maps traffic index)
  int distinctSnapCountLastHour;
  int communityVotesCount;
  
  // Recommendations
  final String? alternativePlaceId;
  final String? alternativePlaceName;
  final String bestTimeToVisit;
  final String? liveAlert;
  
  // 24-hour crowd forecast (0:00 to 23:00)
  final List<int> hourlyForecast;

  Place({
    required this.id,
    required this.name,
    this.city = 'Varanasi',
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.address,
    required this.imageUrl,
    this.currentScore = 50,
    this.crowdCategory = CrowdCategory.moderate,
    this.advisoryVerdict = AdvisoryVerdict.goodToGo,
    this.approachTrafficScore = 40,
    this.distinctSnapCountLastHour = 8,
    this.communityVotesCount = 14,
    this.alternativePlaceId,
    this.alternativePlaceName,
    this.bestTimeToVisit = '06:00 AM - 08:30 AM',
    this.liveAlert,
    required this.hourlyForecast,
  });

  Place copyWith({
    String? id,
    String? name,
    String? city,
    String? category,
    double? latitude,
    double? longitude,
    String? description,
    String? address,
    String? imageUrl,
    int? currentScore,
    CrowdCategory? crowdCategory,
    AdvisoryVerdict? advisoryVerdict,
    int? approachTrafficScore,
    int? distinctSnapCountLastHour,
    int? communityVotesCount,
    String? alternativePlaceId,
    String? alternativePlaceName,
    String? bestTimeToVisit,
    String? liveAlert,
    List<int>? hourlyForecast,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      currentScore: currentScore ?? this.currentScore,
      crowdCategory: crowdCategory ?? this.crowdCategory,
      advisoryVerdict: advisoryVerdict ?? this.advisoryVerdict,
      approachTrafficScore: approachTrafficScore ?? this.approachTrafficScore,
      distinctSnapCountLastHour: distinctSnapCountLastHour ?? this.distinctSnapCountLastHour,
      communityVotesCount: communityVotesCount ?? this.communityVotesCount,
      alternativePlaceId: alternativePlaceId ?? this.alternativePlaceId,
      alternativePlaceName: alternativePlaceName ?? this.alternativePlaceName,
      bestTimeToVisit: bestTimeToVisit ?? this.bestTimeToVisit,
      liveAlert: liveAlert ?? this.liveAlert,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
    );
  }
}
