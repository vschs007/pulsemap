import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../providers/app_state.dart';

class SnapCameraScreen extends StatefulWidget {
  final String? preselectedPlaceId;

  const SnapCameraScreen({super.key, this.preselectedPlaceId});

  @override
  State<SnapCameraScreen> createState() => _SnapCameraScreenState();
}

class _SnapCameraScreenState extends State<SnapCameraScreen> {
  late String _selectedPlaceId;
  int _selectedCrowdRating = 2; // 1: Calm, 2: Moderate, 3: Busy, 4: Packed
  String _selectedVibeTag = '🪔 Aarti Rush';
  final _captionController = TextEditingController();

  final List<String> _vibeTags = [
    '🪔 Aarti Rush',
    '🌅 Sunrise Peace',
    '🚤 Riverfront Boats',
    '☕ Kulhad Chai',
    '🕉️ Temple Darshan',
    '🛍️ Market Buzz',
    '✨ Golden Hour',
  ];

  final List<Map<String, String>> _presetPhotos = [
    {
      'title': 'Evening Aarti',
      'url': 'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Assi Sunrise',
      'url': 'https://images.unsplash.com/photo-1571536802807-30451e3955d8?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Palace Ghat',
      'url': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Temple Corridor',
      'url': 'https://images.unsplash.com/photo-1627894483216-2138af692e32?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': 'River Boats',
      'url': 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800&auto=format&fit=crop&q=80',
    },
  ];

  late String _selectedPhotoUrl;

  @override
  void initState() {
    super.initState();
    _selectedPlaceId = widget.preselectedPlaceId ?? 'dashashwamedh_ghat';
    _selectedPhotoUrl = _presetPhotos.first['url']!;
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedPlace = appState.places.firstWhere(
      (p) => p.id == _selectedPlaceId,
      orElse: () => appState.places.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Capture City Pulse',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD600).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD600)),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, color: Color(0xFFFFD600), size: 16),
                SizedBox(width: 4),
                Text(
                  '+50 XP',
                  style: TextStyle(
                    color: Color(0xFFFFD600),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Place Selector Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF191D2C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPlaceId,
                  dropdownColor: const Color(0xFF191D2C),
                  icon: const Icon(Icons.location_on_rounded, color: Color(0xFF00E676)),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  items: appState.places.map((Place place) {
                    return DropdownMenuItem<String>(
                      value: place.id,
                      child: Row(
                        children: [
                          Text(place.name),
                          const SizedBox(width: 8),
                          Text('(${place.category})', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedPlaceId = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Snap Photo Preview with Geotag Filter Overlay
            Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(_selectedPhotoUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Top Snapchat-style Geotag Filter
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white38),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_pin, color: Color(0xFFFF1744), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              selectedPlace.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '📍 GPS Verified',
                          style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Vibe Overlay
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedVibeTag,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          _getCrowdLabel(_selectedCrowdRating),
                          style: TextStyle(
                            color: _getCrowdColor(_selectedCrowdRating),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Photo Selection Strip
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _presetPhotos.length,
                itemBuilder: (context, index) {
                  final item = _presetPhotos[index];
                  final isSelected = item['url'] == _selectedPhotoUrl;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPhotoUrl = item['url']!;
                      });
                    },
                    child: Container(
                      width: 56,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFFD600) : Colors.transparent,
                          width: 2.5,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(item['url']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // 3. Set Observed Crowd Level (1 to 4)
            const Text(
              'OBSERVED CROWD LEVEL',
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCrowdSelectorItem(1, 'Calm', const Color(0xFF00E676), Icons.spa_rounded),
                const SizedBox(width: 8),
                _buildCrowdSelectorItem(2, 'Moderate', const Color(0xFFFFD600), Icons.people_outline_rounded),
                const SizedBox(width: 8),
                _buildCrowdSelectorItem(3, 'Busy', const Color(0xFFFF6D00), Icons.groups_rounded),
                const SizedBox(width: 8),
                _buildCrowdSelectorItem(4, 'Packed', const Color(0xFFFF1744), Icons.warning_amber_rounded),
              ],
            ),
            const SizedBox(height: 18),

            // 4. Vibe Tag Picker
            const Text(
              'SELECT VIBE STICKER',
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _vibeTags.map((tag) {
                final isSelected = tag == _selectedVibeTag;
                return ChoiceChip(
                  label: Text(tag, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 12)),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFFD600),
                  backgroundColor: const Color(0xFF191D2C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedVibeTag = tag;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // 5. Caption Input
            const Text(
              'LIVE REPORT / CAPTION',
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _captionController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Aarti seats filling up fast, boats lining along the bank...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF191D2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  final caption = _captionController.text.trim().isEmpty
                      ? 'Live vibe check from ${selectedPlace.name}'
                      : _captionController.text.trim();

                  appState.postSnap(
                    placeId: _selectedPlaceId,
                    imageUrl: _selectedPhotoUrl,
                    caption: caption,
                    crowdRating: _selectedCrowdRating,
                    vibeTag: _selectedVibeTag,
                  );

                  _showCelebrationDialog(context, selectedPlace.name);
                },
                icon: const Icon(Icons.flash_on_rounded, color: Colors.black),
                label: const Text('Post Snap to Heatmap (+50 XP)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD600),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrowdSelectorItem(int rating, String label, Color color, IconData icon) {
    final isSelected = _selectedCrowdRating == rating;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCrowdRating = rating;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: isSelected ? 2.0 : 1.0),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.black : color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCrowdLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Peaceful / Calm';
      case 2:
        return 'Pleasant / Moderate';
      case 3:
        return 'Bustling / Busy';
      case 4:
      default:
        return 'Packed / Heavy Rush';
    }
  }

  Color _getCrowdColor(int rating) {
    switch (rating) {
      case 1:
        return const Color(0xFF00E676);
      case 2:
        return const Color(0xFFFFD600);
      case 3:
        return const Color(0xFFFF6D00);
      case 4:
      default:
        return const Color(0xFFFF1744);
    }
  }

  void _showCelebrationDialog(BuildContext context, String placeName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: const Color(0xFF131722),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD600),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.military_tech_rounded, color: Colors.black, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'SNAP PUBLISHED!',
                style: TextStyle(
                  color: Color(0xFFFFD600),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '+50 XP Earned',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your snap at $placeName has updated the live city heatmap for fellow travelers!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('Back to Heatmap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
