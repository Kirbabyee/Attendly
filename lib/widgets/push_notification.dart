import 'package:flutter/material.dart';

Future<void> showTopPushNotification(
    BuildContext context, {
      required String title,
      required String body,
      String timeText = 'now',
    }) async {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return _TopNotificationOverlay(
        title: title,
        body: body,
        timeText: timeText,
        onClose: () => entry.remove(),
      );
    },
  );

  overlay.insert(entry);

  // auto dismiss
  Future.delayed(const Duration(seconds: 3), () {
    if (entry.mounted) entry.remove();
  });
}

class _TopNotificationOverlay extends StatefulWidget {
  final String title;
  final String body;
  final String timeText;
  final VoidCallback onClose;

  const _TopNotificationOverlay({
    required this.title,
    required this.body,
    required this.timeText,
    required this.onClose,
  });

  @override
  State<_TopNotificationOverlay> createState() =>
      _TopNotificationOverlayState();
}

class _TopNotificationOverlayState
    extends State<_TopNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slide,
        child: Material(
          borderRadius: BorderRadius.circular(14),
          elevation: 10,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF004280),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            widget.timeText,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.body,
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: widget.onClose,
                  child: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> confirmAndShowTopNotification(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Open notification?'),
      content: const Text(
        'This will show how the push notification looks.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );

  if (ok == true) {
    showTopPushNotification(
      context,
      title: 'Attendly',
      body: 'Your class session has started. Tap to verify attendance.',
    );
  }
}
