enum SyncEventType {
  snapCreated,
  crowdRated,
  vibePingCreated,
  vibeAnswered,
}

class SyncEvent {
  final String id;
  final SyncEventType type;
  final String cityId;
  final String placeId;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final String originDeviceId;

  SyncEvent({
    required this.id,
    required this.type,
    required this.cityId,
    required this.placeId,
    required this.payload,
    required this.timestamp,
    required this.originDeviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'cityId': cityId,
      'placeId': placeId,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'originDeviceId': originDeviceId,
    };
  }

  factory SyncEvent.fromJson(Map<String, dynamic> json) {
    return SyncEvent(
      id: json['id'] as String,
      type: SyncEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncEventType.crowdRated,
      ),
      cityId: json['cityId'] as String? ?? 'varanasi',
      placeId: json['placeId'] as String? ?? '',
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      originDeviceId: json['originDeviceId'] as String? ?? 'device_unknown',
    );
  }
}
