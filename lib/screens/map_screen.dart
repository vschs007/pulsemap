import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/crowd_category.dart';
import '../providers/app_state.dart';
import '../widgets/api_settings_dialog.dart';
import '../widgets/city_switcher_modal.dart';
import '../widgets/heatmap_layer.dart';
import '../widgets/location_simulator_dialog.dart';
import '../widgets/notification_banner.dart';
import '../widgets/place_bottom_sheet.dart';
import 'snap_camera_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Ghat',
    'Temple',
    'Monument',
    'Market',
    'Park',
    'Heritage',
    'Calm Only',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _recenter(AppState appState) {
    _mapController.move(
      LatLng(appState.selectedCity.centerLat, appState.selectedCity.centerLng),
      appState.selectedCity.defaultZoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final places = appState.filteredPlaces;
    final selectedPlace = appState.selectedPlace;
    final activeNotif = appState.activeBannerNotification;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F17),
      body: Stack(
        children: [
          // 1. FlutterMap with CartoDB Dark Matter Tiles
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(appState.selectedCity.centerLat, appState.selectedCity.centerLng),
              initialZoom: appState.selectedCity.defaultZoom,
              minZoom: 10.0,
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
                                                : place.category == 'Park'
                                                    ? Icons.park_rounded
                                                    : place.category == 'Beach'
                                                        ? Icons.beach_access_rounded
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

          // 2. Top Header, Search Bar & Quick Switchers
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 14,
            right: 14,
            child: Column(
              children: [
                // Search & City Actions Row
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                          decoration: InputDecoration(
                            hintText: 'Search in ${appState.currentCity}...',
                            hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
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

                      // City Switcher Button
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => CitySwitcherModal(
                              onCitySelected: (newCity) {
                                appState.switchCity(newCity);
                                _mapController.move(
                                  LatLng(newCity.centerLat, newCity.centerLng),
                                  newCity.defaultZoom,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2979FF).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_city_rounded, color: Color(0xFF82B1FF), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                appState.currentCity,
                                style: const TextStyle(
                                  color: Color(0xFF82B1FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF82B1FF), size: 14),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Developer & API Settings Button
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, color: Colors.white70, size: 20),
                        tooltip: 'Google Maps API & Cloud Sync Settings',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const ApiSettingsDialog(),
                          );
                        },
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

                // 3. Heads-up Geofence Push Notification Banner
                if (activeNotif != null) ...[
                  const SizedBox(height: 8),
                  NotificationBannerWidget(
                    notification: activeNotif,
                    onVerifyTap: () {
                      final place = appState.places.firstWhere((p) => p.id == activeNotif.placeId);
                      appState.dismissActiveNotification();
                      appState.selectPlace(place);
                    },
                    onSnapTap: () {
                      appState.dismissActiveNotification();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SnapCameraScreen(preselectedPlaceId: activeNotif.placeId),
                        ),
                      );
                    },
                    onDismiss: () => appState.dismissActiveNotification(),
                  ),
                ],
              ],
            ),
          ),

          // 4. Floating Action Buttons (GPS Simulator, Recenter, Post Snap)
          Positioned(
            right: 16,
            bottom: selectedPlace != null ? 360 : 30,
            child: Column(
              children: [
                // Geofence & GPS Simulator Button
                FloatingActionButton.small(
                  heroTag: 'simulator_btn',
                  backgroundColor: const Color(0xFF1E283E),
                  foregroundColor: const Color(0xFF00E676),
                  tooltip: 'Simulate Geofence Arrival',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const LocationSimulatorDialog(),
                    );
                  },
                  child: const Icon(Icons.gps_fixed_rounded, size: 20),
                ),
                const SizedBox(height: 10),
                // Recenter Button
                FloatingActionButton.small(
                  heroTag: 'recenter_btn',
                  backgroundColor: const Color(0xFF191D2C),
                  foregroundColor: Colors.white,
                  onPressed: () => _recenter(appState),
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

          // 5. Slide-up Place Details Sheet
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

extension MapControllerExtension on MapController {
  void animateTo({required LatLng dest, required double zoom}) {
    move(dest, zoom);
  }
}
