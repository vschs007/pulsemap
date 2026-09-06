import 'package:flutter/material.dart';
import '../services/geofence_service.dart';

class NotificationBannerWidget extends StatelessWidget {
  final InAppNotification notification;
  final VoidCallback onVerifyTap;
  final VoidCallback onSnapTap;
  final VoidCallback onDismiss;

  const NotificationBannerWidget({
    super.key,
    required this.notification,
    required this.onVerifyTap,
    required this.onSnapTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF192033),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD600), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD600).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD600),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Colors.black, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notification.body,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onVerifyTap,
                icon: const Icon(Icons.how_to_vote_rounded, size: 14),
                label: const Text('Verify Crowd (+15 XP)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onSnapTap,
                icon: const Icon(Icons.camera_alt_rounded, size: 14, color: Color(0xFFFFD600)),
                label: const Text('Post Snap (+50 XP)', style: TextStyle(color: Color(0xFFFFD600), fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFD600)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
