import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/crowd_category.dart';
import '../models/place.dart';

class HeatmapOverlayLayer extends StatelessWidget {
  final List<Place> places;
  final Function(Place) onPlaceSelected;

  const HeatmapOverlayLayer({
    super.key,
    required this.places,
    required this.onPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CircleLayer(
      circles: places.expand<CircleMarker>((place) {
        final color = place.crowdCategory.color;

        // Outer ambient glow circle
        final outerCircle = CircleMarker(
          point: LatLng(place.latitude, place.longitude),
          radius: 48.0 + (place.currentScore * 0.25),
          useRadiusInMeter: false,
          color: color.withValues(alpha: 0.18),
          borderColor: color.withValues(alpha: 0.35),
          borderStrokeWidth: 1.5,
        );

        // Core dynamic intensity circle
        final innerCircle = CircleMarker(
          point: LatLng(place.latitude, place.longitude),
          radius: 22.0 + (place.currentScore * 0.12),
          useRadiusInMeter: false,
          color: color.withValues(alpha: 0.38),
          borderColor: color.withValues(alpha: 0.8),
          borderStrokeWidth: 2.0,
        );

        return [outerCircle, innerCircle];
      }).toList(),
    );
  }
}
