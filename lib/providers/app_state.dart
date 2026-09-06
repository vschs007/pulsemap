import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/crowd_category.dart';
import '../models/place.dart';
import '../models/snap.dart';
import '../models/user_profile.dart';
import '../models/vibe_ping.dart';
import '../services/crowd_engine.dart';
import '../services/mock_data.dart';
import '../services/traffic_service.dart';

class AppState extends ChangeNotifier {
  final TrafficService _trafficService = TrafficService();
  final _uuid = const Uuid();

  List<Place> _places = [];
  List<Snap> _snaps = [];
  final UserProfile _userProfile = MockData.getInitialUser();
  final List<Map<String, dynamic>> _leaderboard = MockData.getLeaderboard();
  final List<VibePing> _vibePings = MockData.getVibePings();

  Place? _selectedPlace;
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';
  String _currentCity = 'Varanasi';

  AppState() {
    _initData();
  }

  // Getters
  List<Place> get places => _places;
  List<Snap> get snaps => _snaps;
  UserProfile get userProfile => _userProfile;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  List<VibePing> get vibePings => _vibePings;
  Place? get selectedPlace => _selectedPlace;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String get searchQuery => _searchQuery;
  String get currentCity => _currentCity;

  List<Place> get filteredPlaces {
    return _places.where((p) {
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
    _places = MockData.getPlaces();
    _snaps = MockData.getInitialSnaps();
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

  void switchCity(String city) {
    _currentCity = city;
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
    final placeName = placeIndex != -1 ? _places[placeIndex].name : 'Varanasi Spot';

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

    // Gamification Reward: +50 XP for contributing a snap
    _addXp(50);
    _userProfile.totalSnapsCount += 1;

    // Advance Quests
    _advanceQuestProgress('q1', 1);

    // Recompute place crowd score dynamically
    if (placeIndex != -1) {
      await _recalculatePlaceCrowd(placeIndex);
    }

    notifyListeners();
  }

  /// P2P Crowd voting: Users directly vote on current crowd condition
  Future<void> castP2PVote(String placeId, int ratingLevel) async {
    final placeIndex = _places.indexWhere((p) => p.id == placeId);
    if (placeIndex == -1) return;

    final place = _places[placeIndex];
    place.communityVotesCount += 1;

    // Gamification: +15 XP for confirming crowd condition
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
    final trafficScore = await _trafficService.getApproachRoadCongestion(
      latitude: place.latitude,
      longitude: place.longitude,
      placeId: place.id,
    );

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

    // Check if place is quiet to advance quiet scout quest
    if (place.crowdCategory == CrowdCategory.calm) {
      _advanceQuestProgress('q3', 1);
    }

    notifyListeners();
  }

  /// Upvote a community snap
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
        _addXp(5); // +5 XP for engaging
      }
      notifyListeners();
    }
  }

  /// Re-run algorithm for a place
  Future<void> _recalculatePlaceCrowd(int placeIndex) async {
    final place = _places[placeIndex];
    final recentPlaceSnaps = getSnapsForPlace(place.id);
    place.distinctSnapCountLastHour = recentPlaceSnaps.length;

    final trafficScore = await _trafficService.getApproachRoadCongestion(
      latitude: place.latitude,
      longitude: place.longitude,
      placeId: place.id,
    );

    // Compute average snap rating
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

  /// Ask community for real-time vibe update
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

  /// Respond to a vibe ping
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
      _addXp(20); // +20 XP for helping a traveler
      notifyListeners();
    }
  }

  /// Claim quest reward
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
    // Update ranking in city leaderboard
    final myEntryIndex = _leaderboard.indexWhere((e) => e['name'].toString().contains('You'));
    if (myEntryIndex != -1) {
      _leaderboard[myEntryIndex]['xp'] = _userProfile.xp;
      _leaderboard[myEntryIndex]['tier'] = _userProfile.rankTitle;
      // Sort leaderboard
      _leaderboard.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
      // Re-assign ranks
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
}
