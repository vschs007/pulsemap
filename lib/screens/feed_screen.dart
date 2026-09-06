import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/snap.dart';
import '../models/vibe_ping.dart';
import '../providers/app_state.dart';
import 'story_viewer_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F17),
        elevation: 0,
        title: const Text(
          'City Pulse Feed',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD600),
          labelColor: const Color(0xFFFFD600),
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: 'Live Snaps (${appState.snaps.length})'),
            Tab(text: 'Vibe Pings (${appState.vibePings.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Live Snaps Feed
          _buildSnapsFeed(context, appState),
          // Tab 2: Vibe Pings (P2P Inquiries)
          _buildVibePingsFeed(context, appState),
        ],
      ),
    );
  }

  Widget _buildSnapsFeed(BuildContext context, AppState appState) {
    if (appState.snaps.isEmpty) {
      return const Center(
        child: Text('No snaps posted yet.', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: appState.snaps.length,
      itemBuilder: (context, index) {
        final snap = appState.snaps[index];
        return _buildSnapCard(context, appState, snap, index);
      },
    );
  }

  Widget _buildSnapCard(BuildContext context, AppState appState, Snap snap, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(snap.userAvatar),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            snap.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2979FF).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              snap.userRank,
                              style: const TextStyle(
                                color: Color(0xFF82B1FF),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${snap.placeName} • ${snap.timeAgo}',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: snap.crowdRating >= 3
                        ? const Color(0xFFFF1744).withValues(alpha: 0.2)
                        : const Color(0xFF00E676).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    snap.crowdLabel,
                    style: TextStyle(
                      color: snap.crowdRating >= 3 ? const Color(0xFFFF5252) : const Color(0xFF00E676),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Snap Image (Tap to open full story)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StoryViewerScreen(
                    snaps: appState.snaps,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(snap.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      snap.vibeTag,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Caption & Actions
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snap.caption,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Upvote Button
                    GestureDetector(
                      onTap: () => appState.toggleSnapUpvote(snap.id),
                      child: Row(
                        children: [
                          Icon(
                            snap.hasUserUpvoted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: snap.hasUserUpvoted ? const Color(0xFFFF1744) : Colors.white60,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${snap.upvotes}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Verify Button
                    TextButton.icon(
                      onPressed: () {
                        appState.castP2PVote(snap.placeId, snap.crowdRating);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('👍 Verified crowd at ${snap.placeName}! +15 XP earned'),
                            backgroundColor: const Color(0xFF00E676),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF00E676)),
                      label: const Text('Confirm Vibe (+15 XP)', style: TextStyle(color: Color(0xFF00E676), fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibePingsFeed(BuildContext context, AppState appState) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: appState.vibePings.length,
      itemBuilder: (context, index) {
        final ping = appState.vibePings[index];
        return _buildVibePingCard(context, appState, ping);
      },
    );
  }

  Widget _buildVibePingCard(BuildContext context, AppState appState, VibePing ping) {
    final responseController = TextEditingController();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A26),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_rounded, color: Color(0xFF2979FF), size: 20),
              const SizedBox(width: 8),
              Text(
                ping.placeName,
                style: const TextStyle(color: Color(0xFF82B1FF), fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              Text(
                ping.timeAgo,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${ping.question}"',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
          ),
          Text(
            'Asked by ${ping.requesterName}',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const Divider(color: Colors.white12, height: 24),

          // Answers list
          if (ping.answers.isNotEmpty) ...[
            const Text(
              'SCOUT REPLIES',
              style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
            const SizedBox(height: 6),
            ...ping.answers.map((ans) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F121C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ans.responderName,
                          style: const TextStyle(color: Color(0xFFFFD600), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Text('(${ans.responderRank})', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        const Spacer(),
                        Text(ans.timeAgo, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(ans.comment, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
          ],

          // Quick Answer Action
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: responseController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Reply with on-ground info (+20 XP)...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                    filled: true,
                    fillColor: const Color(0xFF0F121C),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFF00E676), size: 20),
                onPressed: () {
                  if (responseController.text.trim().isNotEmpty) {
                    appState.answerVibePing(
                      ping.id,
                      'Current Vibe',
                      responseController.text.trim(),
                    );
                    responseController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 Scout answer posted! +20 XP earned'),
                        backgroundColor: Color(0xFF00E676),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
