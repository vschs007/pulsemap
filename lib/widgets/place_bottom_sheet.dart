import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crowd_category.dart';
import '../models/place.dart';
import '../providers/app_state.dart';
import '../screens/snap_camera_screen.dart';
import '../screens/story_viewer_screen.dart';
import 'vibe_ping_dialog.dart';

class PlaceBottomSheet extends StatelessWidget {
  final Place place;

  const PlaceBottomSheet({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final placeSnaps = appState.getSnapsForPlace(place.id);
    final alternative = place.alternativePlaceId != null
        ? appState.places.firstWhere(
            (p) => p.id == place.alternativePlaceId,
            orElse: () => place,
          )
        : null;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131722),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Top Place Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2979FF).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                place.category.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF82B1FF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              place.city,
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          place.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          place.address,
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white60),
                    onPressed: () => appState.selectPlace(null),
                  ),
                ],
              ),
            ),

            // Live Alert Banner if present
            if (place.liveAlert != null) ...[
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: place.crowdCategory == CrowdCategory.overloaded
                      ? const Color(0xFFFF1744).withValues(alpha: 0.15)
                      : const Color(0xFF00E676).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: place.crowdCategory == CrowdCategory.overloaded
                        ? const Color(0xFFFF1744).withValues(alpha: 0.4)
                        : const Color(0xFF00E676).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      place.crowdCategory == CrowdCategory.overloaded
                          ? Icons.crisis_alert_rounded
                          : Icons.check_circle_rounded,
                      color: place.crowdCategory.color,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        place.liveAlert!,
                        style: TextStyle(
                          color: place.crowdCategory.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 1. Actionable "Should I Go?" Advisory Verdict Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    place.advisoryVerdict.badgeColor.withValues(alpha: 0.22),
                    const Color(0xFF1E2433),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: place.advisoryVerdict.badgeColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: place.advisoryVerdict.badgeColor.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          place.advisoryVerdict.icon,
                          color: place.advisoryVerdict.badgeColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ADVISORY VERDICT',
                              style: TextStyle(
                                color: place.advisoryVerdict.badgeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              place.advisoryVerdict.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Fused Score Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: place.crowdCategory.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${place.currentScore}%',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    place.advisoryVerdict.subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFFFFD600)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Best visit window: ${place.bestTimeToVisit}',
                          style: const TextStyle(
                            color: Color(0xFFFFE082),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Signals Breakdown (Snaps, P2P Consensus, Traffic)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LIVE SIGNALS BREAKDOWN',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Snap Velocity
                      Expanded(
                        child: _buildSignalCard(
                          icon: Icons.camera_alt_rounded,
                          iconColor: const Color(0xFF00E676),
                          title: 'Snap Velocity',
                          value: '${place.distinctSnapCountLastHour} Snaps',
                          caption: 'Last 60 mins',
                        ),
                      ),
                      const SizedBox(width: 8),
                      // P2P Consensus
                      Expanded(
                        child: _buildSignalCard(
                          icon: Icons.how_to_vote_rounded,
                          iconColor: const Color(0xFFFFD600),
                          title: 'P2P Consensus',
                          value: '${place.communityVotesCount} Votes',
                          caption: 'Community verified',
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Road Traffic
                      Expanded(
                        child: _buildSignalCard(
                          icon: Icons.traffic_rounded,
                          iconColor: place.approachTrafficScore > 70
                              ? const Color(0xFFFF1744)
                              : const Color(0xFF2979FF),
                          title: 'Approach Traffic',
                          value: '${place.approachTrafficScore}% Delay',
                          caption: 'Google Maps Flow',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. P2P Crowd Voting Widget ("Set Crowd Level")
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B202E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.touch_app_rounded, color: Color(0xFF00E676), size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Are you here? Set Crowd Level',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '+15 XP',
                          style: TextStyle(
                            color: Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Help fellow travelers make informed decisions. Your vote updates the live heatmap instantly.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildVoteButton(context, appState, 1, 'Calm', const Color(0xFF00E676), Icons.spa_rounded),
                      const SizedBox(width: 8),
                      _buildVoteButton(context, appState, 2, 'Moderate', const Color(0xFFFFD600), Icons.people_outline_rounded),
                      const SizedBox(width: 8),
                      _buildVoteButton(context, appState, 3, 'Busy', const Color(0xFFFF6D00), Icons.groups_rounded),
                      const SizedBox(width: 8),
                      _buildVoteButton(context, appState, 4, 'Packed', const Color(0xFFFF1744), Icons.warning_amber_rounded),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Calmer Alternative Recommendation (if crowded)
            if (place.currentScore >= 60 && alternative != null) ...[
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2A28),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.nature_people_rounded, color: Color(0xFF00E676), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CALM ALTERNATIVE NEARBY',
                            style: TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            alternative.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Only ${alternative.currentScore}% crowd • Serene riverfront',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        appState.selectPlace(alternative);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      child: const Text('View Spot'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 5. Hourly Crowd Forecast Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TODAY\'S HOURLY CROWD PATTERN',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B202E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(24, (hour) {
                              final score = place.hourlyForecast[hour];
                              final isCurrentHour = hour == DateTime.now().hour;
                              Color barColor;
                              if (score <= 30) {
                                barColor = const Color(0xFF00E676);
                              } else if (score <= 60) {
                                barColor = const Color(0xFFFFD600);
                              } else if (score <= 80) {
                                barColor = const Color(0xFFFF6D00);
                              } else {
                                barColor = const Color(0xFFFF1744);
                              }

                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (isCurrentHour)
                                        Container(
                                          width: 4,
                                          height: 4,
                                          margin: const EdgeInsets.only(bottom: 2),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      Container(
                                        height: (score * 0.45).clamp(4.0, 50.0),
                                        decoration: BoxDecoration(
                                          color: isCurrentHour ? Colors.white : barColor.withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(3),
                                          border: isCurrentHour ? Border.all(color: barColor, width: 1.5) : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('12 AM', style: TextStyle(color: Colors.white38, fontSize: 10)),
                            Text('6 AM (Aarti)', style: TextStyle(color: Colors.white54, fontSize: 10)),
                            Text('12 PM', style: TextStyle(color: Colors.white38, fontSize: 10)),
                            Text('7 PM (Peak Aarti)', style: TextStyle(color: Color(0xFFFF5252), fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('11 PM', style: TextStyle(color: Colors.white38, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 6. Recent Live Snaps Carousel (Snapchat-style story ring previews)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LIVE SNAPS & STORIES',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '${placeSnaps.length} recent',
                    style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            if (placeSnaps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B202E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.camera_alt_outlined, color: Colors.white38, size: 32),
                        const SizedBox(height: 6),
                        const Text(
                          'No recent snaps for this spot yet.',
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SnapCameraScreen(preselectedPlaceId: place.id),
                              ),
                            );
                          },
                          child: const Text('Be the First to Snap (+50 XP)'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 130,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: placeSnaps.length,
                  itemBuilder: (context, index) {
                    final snap = placeSnaps[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StoryViewerScreen(
                              snaps: placeSnaps,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 95,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: snap.crowdRating >= 3 ? const Color(0xFFFF1744) : const Color(0xFF00E676),
                            width: 2.0,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(snap.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snap.timeAgo,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                snap.userName.split(' ').first,
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // 7. Bottom Action Bar: Post Snap & Vibe Ping
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SnapCameraScreen(preselectedPlaceId: place.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Post Snap (+50 XP)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD600),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => VibePingDialog(placeId: place.id, placeName: place.name),
                        );
                      },
                      icon: const Icon(Icons.campaign_rounded, size: 18),
                      label: const Text('Ask Vibe'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String caption,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B202E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
          ),
          Text(
            caption,
            style: const TextStyle(color: Colors.white38, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(
    BuildContext context,
    AppState appState,
    int rating,
    String label,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          appState.castP2PVote(place.id, rating);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🗳️ Voted "$label" for ${place.name}! +15 XP earned'),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
