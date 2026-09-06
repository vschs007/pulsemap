class City {
  final String id;
  final String name;
  final String state;
  final double centerLat;
  final double centerLng;
  final double defaultZoom;
  final String tagline;
  final String bannerImageUrl;
  final int hotspotCount;

  const City({
    required this.id,
    required this.name,
    required this.state,
    required this.centerLat,
    required this.centerLng,
    this.defaultZoom = 13.5,
    required this.tagline,
    required this.bannerImageUrl,
    required this.hotspotCount,
  });
}
