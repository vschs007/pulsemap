import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/crowd_category.dart';
import '../providers/app_state.dart';
import '../widgets/heatmap_layer.dart';
import '../widgets/place_bottom_sheet.dart';
import 'snap_camera_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _varanasiCenter = const LatLng(25.3076, 83.0105);
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Ghat',
    'Temple',
    'Market',
    'Heritage',
    'Calm Only',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _recenter() {
    _mapController.move(_varanasiCenter, 14.5);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final places = appState.filteredPlaces;
    final selectedPlace = appState.selectedPlace;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F17),
      body: Stack(
        children: [
          // 1. FlutterMap with CartoDB Dark Matter Tiles
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _varanasiCenter,
              initialZoom: 14.5,
              minZoom: 12.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                if (selectedPlace != null) {
                  appState.selectPlace(null);
                }
              },
            ),
            children: [
              // Tile Layer: CartoDB Dark Matter
              TileLayer(
                urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}@2x.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.pulsemap.app',
                maxZoom: 19,
              ),

              // Dynamic Glowing Heatmap Halos Layer
              HeatmapOverlayLayer(
                places: places,
                onPlaceSelected: (place) {
                  appState.selectPlace(place);
                },
              ),

              // Interactive Snapchat-style Story Markers Layer
              MarkerLayer(
                markers: places.map((place) {
                  final isSelected = selectedPlace?.id == place.id;
                  final placeSnaps = appState.getSnapsForPlace(place.id);
                  final hasSnaps = placeSnaps.isNotEmpty;
                  final color = place.crowdCategory.color;

                  return Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: 76,
                    height: 76,
                    child: GestureDetector(
                      onTap: () {
                        appState.selectPlace(place);
                        _mapController.animateTo(
                          dest: LatLng(place.latitude - 0.003, place.longitude),
                          zoom: 15.5,
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Story Ring Marker
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Pulsing Glow
                              Container(
                                width: isSelected ? 52 : 46,
                                height: isSelected ? 52 : 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withValues(alpha: 0.35),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : color,
                                    width: isSelected ? 2.5 : 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.6),
                                      blurRadius: isSelected ? 16 : 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              // Inner Avatar or Category Icon
                              CircleAvatar(
                                radius: isSelected ? 20 : 17,
                                backgroundImage: hasSnaps ? NetworkImage(placeSnaps.first.imageUrl) : null,
                                backgroundColor: const Color(0xFF161A26),
                                child: !hasSnaps
                                    ? Icon(
                                        place.category == 'Ghat'
                                            ? Icons.water_rounded
                                            : place.category == 'Temple'
                                                ? Icons.temple_hindu_rounded
                                                : Icons.storefront_rounded,
                                        color: color,
                                        size: 18,
                                      )
                                    : null,
                              ),
                              // Crowd Percentage Badge
                              Positioned(
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black45, blurRadius: 4),
                                    ],
                                  ),
                                  child: Text(
                                    '${place.currentScore}%',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          // Place Name Label
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              place.name.split(' ').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. Top Header & Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 14,
            right: 14,
            child: Column(
              children: [
                // Search Input Card
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131722).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Color(0xFFFFD600), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Search ghats, temples, markets...',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            appState.setSearchQuery(val);
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            appState.setSearchQuery('');
                          },
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2979FF).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appState.currentCity,
                          style: const TextStyle(
                            color: Color(0xFF82B1FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Category Filter Chips
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = appState.selectedCategoryFilter == filter;

                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFFFFD600),
                          backgroundColor: const Color(0xFF131722).withValues(alpha: 0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFFFFD600) : Colors.white12,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              appState.setCategoryFilter(filter);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Action Buttons (Recenter & Post Snap)
          Positioned(
            right: 16,
            bottom: selectedPlace != null ? 360 : 30,
            child: Column(
              children: [
                // Recenter Button
                FloatingActionButton.small(
                  heroTag: 'recenter_btn',
                  backgroundColor: const Color(0xFF191D2C),
                  foregroundColor: Colors.white,
                  onPressed: _recenter,
                  child: const Icon(Icons.my_location_rounded, size: 20),
                ),
                const SizedBox(height: 12),
                // Camera Capture Snap CTA
                FloatingActionButton.extended(
                  heroTag: 'camera_fab',
                  backgroundColor: const Color(0xFFFFD600),
                  foregroundColor: Colors.black,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SnapCameraScreen(preselectedPlaceId: selectedPlace?.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_rounded, color: Colors.black),
                  label: const Text(
                    'Snap (+50 XP)',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),

          // 4. Slide-up Place Details Sheet
          if (selectedPlace != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.58,
                ),
                child: PlaceBottomSheet(place: selectedPlace),
              ),
            ),
        ],
      ),
    );
  }
}

// Map animation helper extension
extension MapControllerExtension on MapController {
  void animateTo({required LatLng dest, required double zoom}) {
    move(dest, zoom);
  }
}
