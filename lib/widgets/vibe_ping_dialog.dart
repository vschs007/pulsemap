import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class VibePingDialog extends StatefulWidget {
  final String placeId;
  final String placeName;

  const VibePingDialog({
    super.key,
    required this.placeId,
    required this.placeName,
  });

  @override
  State<VibePingDialog> createState() => _VibePingDialogState();
}

class _VibePingDialogState extends State<VibePingDialog> {
  final _questionController = TextEditingController();

  final List<String> _quickQuestions = [
    'How packed is it right now? Can I find parking?',
    'Is the Aarti crowd overwhelming or can I get a spot?',
    'Are boat rides operating smoothly or long queues?',
    'Is there open seating along the steps?',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Dialog(
      backgroundColor: const Color(0xFF161A26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2979FF).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.campaign_rounded, color: Color(0xFF2979FF), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'P2P Live Vibe Ping',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.placeName,
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Ask active scouts currently near this location for on-the-ground intelligence.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Quick Questions chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickQuestions.map((q) {
                return ActionChip(
                  label: Text(q, style: const TextStyle(fontSize: 11, color: Colors.white)),
                  backgroundColor: const Color(0xFF212738),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () {
                    _questionController.text = q;
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Custom Question Input
            TextField(
              controller: _questionController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type your question (e.g. queue status, crowd, boats)...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF0F121C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_questionController.text.trim().isNotEmpty) {
                      appState.createVibePing(widget.placeId, _questionController.text.trim());
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📡 Vibe Ping broadcast to active scouts nearby!'),
                          backgroundColor: Color(0xFF2979FF),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Broadcast Ping'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2979FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
