import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/city.dart';
import '../models/crowd_category.dart';
import '../models/place.dart';
import '../models/snap.dart';
import '../models/sync_event.dart';
import '../models/user_profile.dart';
import '../models/vibe_ping.dart';
import '../services/city_data.dart';
import '../services/cloud_sync_service.dart';
import '../services/crowd_engine.dart';
import '../services/geofence_service.dart';
import '../services/google_maps_api_service.dart';
import '../services/mock_data.dart';
import '../services/traffic_service.dart';

class AppState extends ChangeNotifier {
  final TrafficService _trafficService = TrafficService();
  final GoogleMapsApiService googleMapsService = GoogleMapsApiService();
  final CloudSyncService cloudSyncService = CloudSyncService();
  final GeofenceService geofenceService = GeofenceService();
  final _uuid = const Uuid();

  List<Place> _places = [];
  List<Snap> _snaps = [];
  final UserProfile _userProfile = MockData.getInitialUser();
  final List<Map<String, dynamic>> _leaderboard = MockData.getLeaderboard();
  final List<VibePing> _vibePings = MockData.getVibePings();

  late City _selectedCity;
  Place? _selectedPlace;
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';
  InAppNotification? _activeBannerNotification;
  StreamSubscription<SyncEvent>? _cloudSyncSub;
  StreamSubscription<InAppNotification>? _geofenceSub;

  AppState() {
    _initData();
    _setupSubscriptions();
  }

  // Getters
  List<Place> get places => _places;
  List<Snap> get snaps => _snaps;
  UserProfile get userProfile => _userProfile;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  List<VibePing> get vibePings => _vibePings;
  City get selectedCity => _selectedCity;
  String get currentCity => _selectedCity.name;
  Place? get selectedPlace => _selectedPlace;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String get searchQuery => _searchQuery;
  InAppNotification? get activeBannerNotification => _activeBannerNotification;
  Place? get currentGeofencedPlace => geofenceService.currentInsidePlace;

  List<Place> get placesForCurrentCity {
    return _places.where((p) => p.city.toLowerCase().contains(_selectedCity.name.toLowerCase()) ||
        _selectedCity.name.toLowerCase().contains(p.city.toLowerCase())).toList();
  }

  List<Place> get filteredPlaces {
    final cityPlaces = placesForCurrentCity;
    return cityPlaces.where((p) {
      final matchesQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesQuery) return false;

      if (_selectedCategoryFilter == 'All') return true;
      if (_selectedCategoryFilter == 'Calm Only') {
        return p.crowdCategory == CrowdCategory.calm;
      }
      return p.category.toLowerCase() == _selectedCategoryFilter.toLowerCase();
    }).toList();
  }

  void _initData() {
    _selectedCity = CityData.getSupportedCities().first; // Varanasi default
    _places = CityData.getAllPlaces();
    _snaps = MockData.getInitialSnaps();
  }

  void _setupSubscriptions() {
    // 1. Listen to Real-time Cloud Events
    _cloudSyncSub = cloudSyncService.eventStream.listen((event) {
      if (event.originDeviceId == cloudSyncService.deviceId) return; // ignore own echoes

      if (event.type == SyncEventType.snapCreated) {
        final snap = Snap(
          id: event.payload['id'],
          placeId: event.payload['placeId'],
          placeName: event.payload['placeName'],
          userId: event.payload['userId'],
          userName: event.payload['userName'],
          userAvatar: event.payload['userAvatar'],
          userRank: event.payload['userRank'] ?? 'Scout',
          imageUrl: event.payload['imageUrl'],
          timestamp: DateTime.parse(event.payload['timestamp']),
          caption: event.payload['caption'],
          crowdRating: event.payload['crowdRating'],
          vibeTag: event.payload['vibeTag'],
        );
        _snaps.insert(0, snap);
        _recalculatePlaceCrowdById(event.placeId);
        notifyListeners();
      } else if (event.type == SyncEventType.crowdRated) {
        final placeIndex = _places.indexWhere((p) => p.id == event.placeId);
        if (placeIndex != -1) {
          final newScore = event.payload['score'] as int? ?? 50;
          _places[placeIndex].currentScore = newScore;
          _places[placeIndex].crowdCategory = CrowdEngine.classifyScore(newScore);
          _places[placeIndex].advisoryVerdict = CrowdEngine.determineVerdict(newScore);
          _places[placeIndex].communityVotesCount += 1;
          notifyListeners();
        }
      }
    });

    // 2. Listen to Geofence Proximity Notifications
    _geofenceSub = geofenceService.notificationStream.listen((notif) {
      _activeBannerNotification = notif;
      notifyListeners();
    });
  }

  void dismissActiveNotification() {
    _activeBannerNotification = null;
    notifyListeners();
  }

  void simulateArrivalAtPlace(Place place) {
    geofenceService.simulateTeleportToPlace(place);
    selectPlace(place);
  }

  void switchCity(City city) {
    _selectedCity = city;
    _selectedPlace = null;
    _selectedCategoryFilter = 'All';
    _searchQuery = '';
    notifyListeners();
  }

  void setGoogleMapsApiKey(String key) {
    googleMapsService.configureApiKey(key, enableLive: true);
    notifyListeners();
  }

  void configureSupabaseSync({required String url, required String anonKey}) {
    cloudSyncService.configureSupabase(url: url, anonKey: anonKey);
    notifyListeners();
  }

  void selectPlace(Place? place) {
    _selectedPlace = place;
    notifyListeners();
  }

  void setCategoryFilter(String filter) {
    _selectedCategoryFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Snap> getSnapsForPlace(String placeId) {
    return _snaps.where((s) => s.placeId == placeId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Post a new geo-tagged snap with crowd rating
  Future<void> postSnap({
    required String placeId,
    required String imageUrl,
    required String caption,
    required int crowdRating,
    required String vibeTag,
  }) async {
    final placeIndex = _places.indexWhere((p) => p.id == placeId);
    final placeName = placeIndex != -1 ? _places[placeIndex].name : 'Spot';

    final newSnap = Snap(
      id: _uuid.v4(),
      placeId: placeId,
      placeName: placeName,
      userId: _userProfile.id,
      userName: _userProfile.name,
      userAvatar: _userProfile.avatarUrl,
      userRank: _userProfile.rankTitle,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      caption: caption,
      crowdRating: crowdRating,
      vibeTag: vibeTag,
      isGpsVerified: true,
    );

    _snaps.insert(0, newSnap);

    // Gamification Reward: +50 XP
    _addXp(50);
    _userProfile.totalSnapsCount += 1;
    _advanceQuestProgress('q1', 1);

    // Recompute place crowd score dynamically
    if (placeIndex != -1) {
      await _recalculatePlaceCrowd(placeIndex);
    }

    // Broadcast Event to Cloud (Supabase/Firebase/Realtime)
    cloudSyncService.broadcastEvent(
      SyncEvent(
        id: _uuid.v4(),
        type: SyncEventType.snapCreated,
        cityId: _selectedCity.id,
        placeId: placeId,
        payload: {
          'id': newSnap.id,
          'placeId': placeId,
          'placeName': placeName,
          'userId': _userProfile.id,
          'userName': _userProfile.name,
          'userAvatar': _userProfile.avatarUrl,
          'userRank': _userProfile.rankTitle,
          'imageUrl': imageUrl,
          'timestamp': newSnap.timestamp.toIso8601String(),
          'caption': caption,
          'crowdRating': crowdRating,
          'vibeTag': vibeTag,
        },
        timestamp: DateTime.now(),
        originDeviceId: cloudSyncService.deviceId,
      ),
    );

    notifyListeners();
  }

  /// P2P Crowd voting: Users directly vote on current crowd condition
  Future<void> castP2PVote(String placeId, int ratingLevel) async {
    final placeIndex = _places.indexWhere((p) => p.id == placeId);
    if (placeIndex == -1) return;

    final place = _places[placeIndex];
    place.communityVotesCount += 1;

    // Gamification: +15 XP
    _addXp(15);
    _userProfile.totalVerificationsCount += 1;
    _advanceQuestProgress('q2', 1);

    // Convert ratingLevel (1-4) to scale (20-95)
    final p2pScaled = (ratingLevel == 1)
        ? 20
        : (ratingLevel == 2)
            ? 50
            : (ratingLevel == 3)
                ? 75
                : 95;

    final placeSnaps = getSnapsForPlace(placeId);

    // Fetch Traffic Score: either Live Google Routes API or TrafficService model
    int trafficScore = 45;
    if (googleMapsService.isLiveMode) {
      final liveScore = await googleMapsService.fetchRoutesTrafficCongestion(
        originLat: place.latitude + 0.02,
        originLng: place.longitude + 0.02,
        destLat: place.latitude,
        destLng: place.longitude,
      );
      trafficScore = liveScore ?? 50;
    } else {
      trafficScore = await _trafficService.getApproachRoadCongestion(
        latitude: place.latitude,
        longitude: place.longitude,
        placeId: place.id,
      );
    }

    // Dynamic fused calculation
    final newScore = CrowdEngine.calculateFusedCrowdScore(
      recentSnaps: placeSnaps,
      p2pAverageRating: p2pScaled,
      approachTrafficScore: trafficScore,
      historicalBaseline: place.hourlyForecast[DateTime.now().hour],
    );

    place.currentScore = newScore;
    place.crowdCategory = CrowdEngine.classifyScore(newScore);
    place.advisoryVerdict = CrowdEngine.determineVerdict(newScore);
    place.approachTrafficScore = trafficScore;

    if (place.crowdCategory == CrowdCategory.calm) {
      _advanceQuestProgress('q3', 1);
    }

    // Broadcast Event to Cloud
    cloudSyncService.broadcastEvent(
      SyncEvent(
        id: _uuid.v4(),
        type: SyncEventType.crowdRated,
        cityId: _selectedCity.id,
        placeId: placeId,
        payload: {'score': newScore, 'rating': ratingLevel},
        timestamp: DateTime.now(),
        originDeviceId: cloudSyncService.deviceId,
      ),
    );

    notifyListeners();
  }

  void toggleSnapUpvote(String snapId) {
    final snapIndex = _snaps.indexWhere((s) => s.id == snapId);
    if (snapIndex != -1) {
      final snap = _snaps[snapIndex];
      if (snap.hasUserUpvoted) {
        snap.upvotes = (snap.upvotes - 1).clamp(0, 99999);
        snap.hasUserUpvoted = false;
      } else {
        snap.upvotes += 1;
        snap.hasUserUpvoted = true;
        _addXp(5);
      }
      notifyListeners();
    }
  }

  Future<void> _recalculatePlaceCrowd(int placeIndex) async {
    final place = _places[placeIndex];
    final recentPlaceSnaps = getSnapsForPlace(place.id);
    place.distinctSnapCountLastHour = recentPlaceSnaps.length;

    int trafficScore = 40;
    if (googleMapsService.isLiveMode) {
      final live = await googleMapsService.fetchRoutesTrafficCongestion(
        originLat: place.latitude + 0.02,
        originLng: place.longitude + 0.02,
        destLat: place.latitude,
        destLng: place.longitude,
      );
      trafficScore = live ?? 45;
    } else {
      trafficScore = await _trafficService.getApproachRoadCongestion(
        latitude: place.latitude,
        longitude: place.longitude,
        placeId: place.id,
      );
    }

    double avgSnapRating = 50;
    if (recentPlaceSnaps.isNotEmpty) {
      final sum = recentPlaceSnaps.fold<int>(0, (sum, s) => sum + s.crowdRating);
      final avg = sum / recentPlaceSnaps.length;
      avgSnapRating = avg == 1
          ? 20
          : avg == 2
              ? 50
              : avg == 3
                  ? 75
                  : 95;
    }

    final newScore = CrowdEngine.calculateFusedCrowdScore(
      recentSnaps: recentPlaceSnaps,
      p2pAverageRating: avgSnapRating.round(),
      approachTrafficScore: trafficScore,
      historicalBaseline: place.hourlyForecast[DateTime.now().hour],
    );

    place.currentScore = newScore;
    place.crowdCategory = CrowdEngine.classifyScore(newScore);
    place.advisoryVerdict = CrowdEngine.determineVerdict(newScore);
    place.approachTrafficScore = trafficScore;

    if (_selectedPlace?.id == place.id) {
      _selectedPlace = place;
    }
  }

  Future<void> _recalculatePlaceCrowdById(String placeId) async {
    final index = _places.indexWhere((p) => p.id == placeId);
    if (index != -1) {
      await _recalculatePlaceCrowd(index);
    }
  }

  void createVibePing(String placeId, String question) {
    final placeIndex = _places.indexWhere((p) => p.id == placeId);
    final placeName = placeIndex != -1 ? _places[placeIndex].name : 'Location';

    final newPing = VibePing(
      id: _uuid.v4(),
      placeId: placeId,
      placeName: placeName,
      requesterName: _userProfile.name,
      question: question,
      timestamp: DateTime.now(),
      answers: [],
    );

    _vibePings.insert(0, newPing);
    notifyListeners();
  }

  void answerVibePing(String pingId, String crowdStatus, String comment) {
    final pingIndex = _vibePings.indexWhere((p) => p.id == pingId);
    if (pingIndex != -1) {
      final answer = VibeAnswer(
        id: _uuid.v4(),
        responderName: _userProfile.name,
        responderRank: _userProfile.rankTitle,
        crowdStatus: crowdStatus,
        comment: comment,
        timestamp: DateTime.now(),
      );

      _vibePings[pingIndex].answers.insert(0, answer);
      _addXp(20);
      notifyListeners();
    }
  }

  void claimQuestReward(String questId) {
    final qIndex = _userProfile.quests.indexWhere((q) => q.id == questId);
    if (qIndex != -1) {
      final q = _userProfile.quests[qIndex];
      if (q.isCompleted && !q.isClaimed) {
        _userProfile.quests[qIndex] = q.copyWith(isClaimed: true);
        _addXp(q.xpReward);
        notifyListeners();
      }
    }
  }

  void _addXp(int amount) {
    _userProfile.xp += amount;
    final myEntryIndex = _leaderboard.indexWhere((e) => e['name'].toString().contains('You'));
    if (myEntryIndex != -1) {
      _leaderboard[myEntryIndex]['xp'] = _userProfile.xp;
      _leaderboard[myEntryIndex]['tier'] = _userProfile.rankTitle;
      _leaderboard.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
      for (int i = 0; i < _leaderboard.length; i++) {
        _leaderboard[i]['rank'] = i + 1;
        if (_leaderboard[i]['name'].toString().contains('You')) {
          _userProfile.cityRank = i + 1;
        }
      }
    }
  }

  void _advanceQuestProgress(String questId, int amount) {
    final qIndex = _userProfile.quests.indexWhere((q) => q.id == questId);
    if (qIndex != -1) {
      final q = _userProfile.quests[qIndex];
      if (!q.isCompleted) {
        _userProfile.quests[qIndex] = q.copyWith(
          currentProgress: (q.currentProgress + amount).clamp(0, q.targetProgress),
        );
      }
    }
  }

  @override
  void dispose() {
    _cloudSyncSub?.cancel();
    _geofenceSub?.cancel();
    cloudSyncService.dispose();
    geofenceService.dispose();
    super.dispose();
  }
}
