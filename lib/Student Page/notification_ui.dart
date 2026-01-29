import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsDrawer extends StatefulWidget {
  final bool unRead;
  final ValueChanged<bool> onUnreadChanged;

  const NotificationsDrawer({
    super.key,
    required this.unRead,
    required this.onUnreadChanged,
  });

  @override
  State<NotificationsDrawer> createState() => _NotificationsDrawerState();
}

class NotificationItem {
  final int id;
  final String text;
  int? read; // null = unread, 1 = read
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.text,
    required this.read,
    required this.createdAt,
  });

  bool get isRead => read == 1;
}

class _NotificationsDrawerState extends State<NotificationsDrawer> {
  final supabase = Supabase.instance.client;

  // pagination
  static const int _pageSize = 10;
  final ScrollController _scrollCtrl = ScrollController();

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  DateTime? _cursorCreatedAt; // last item created_at
  final Set<int> _seenIds = {}; // prevent duplicates

  List<NotificationItem> notifications = [];

  bool get hasUnread => notifications.any((n) => !n.isRead);

  @override
  void initState() {
    super.initState();
    _loadFirstPage();

    _scrollCtrl.addListener(() {
      if (!_hasMore || _loadingMore || _loading) return;

      // load more when near bottom
      final pos = _scrollCtrl.position;
      if (pos.pixels >= pos.maxScrollExtent - 120) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _loading = true;
      _hasMore = true;
      _cursorCreatedAt = null;
      _seenIds.clear();
      notifications = [];
    });

    await _fetchPage(isFirst: true);

    if (!mounted) return;
    setState(() => _loading = false);

    widget.onUnreadChanged(hasUnread);
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore) return;

    setState(() => _loadingMore = true);
    await _fetchPage(isFirst: false);
    if (!mounted) return;
    setState(() => _loadingMore = false);

    widget.onUnreadChanged(hasUnread);
  }

  Future<void> _fetchPage({required bool isFirst}) async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;

      // base query
      var query = supabase
          .from('notification_queue')
          .select('id, title, body, read, created_at')
          .eq('target_user_id', uid);

      if (!isFirst && _cursorCreatedAt != null) {
        query = query.lt('created_at', _cursorCreatedAt!.toIso8601String());
      }

      final rows = await query
          .order('created_at', ascending: false)
          .limit(_pageSize); // 10

      final page = (rows as List).cast<Map<String, dynamic>>().map((r) {
        final body = (r['body'] ?? '').toString().trim();
        final createdAt = DateTime.tryParse((r['created_at'] ?? '').toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return NotificationItem(
          id: (r['id'] as num).toInt(),
          text: body,
          read: r['read'] as int?,
          createdAt: createdAt,
        );
      }).toList();

      // if less than page size => no more
      if (page.length < _pageSize) {
        _hasMore = false;
      }

      // dedupe + append
      if (!mounted) return;
      setState(() {
        for (final n in page) {
          if (_seenIds.add(n.id)) {
            notifications.add(n);
          }
        }
        if (notifications.isNotEmpty) {
          _cursorCreatedAt = notifications.last.createdAt; // last item in list
        }
      });
    } catch (_) {
      // if error, stop loading more (optional)
      _hasMore = false;
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;

      await supabase
          .from('notification_queue')
          .update({'read': 1})
          .eq('target_user_id', uid)
          .isFilter('read', null);

      if (!mounted) return;
      setState(() {
        for (final n in notifications) {
          n.read = 1;
        }
      });

      widget.onUnreadChanged(false);
    } catch (_) {}
  }

  Future<void> _markOneAsRead(int notifId) async {
    try {
      await supabase
          .from('notification_queue')
          .update({'read': 1})
          .eq('id', notifId);

      if (!mounted) return;
      setState(() {
        final idx = notifications.indexWhere((n) => n.id == notifId);
        if (idx != -1) notifications[idx].read = 1;
      });

      widget.onUnreadChanged(hasUnread);
    } catch (_) {}
  }

  Future<void> _markOneAsUnread(int notifId) async {
    try {
      await supabase
          .from('notification_queue')
          .update({'read': null})
          .eq('id', notifId);

      if (!mounted) return;
      setState(() {
        final idx = notifications.indexWhere((n) => n.id == notifId);
        if (idx != -1) notifications[idx].read = null;
      });

      widget.onUnreadChanged(hasUnread);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _loading ? null : _markAllAsRead,
                    child: const Text(
                      'Mark all as read',
                      style: TextStyle(color: Color(0xFF043B6F)),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          widget.onUnreadChanged(hasUnread);
                          Navigator.pop(context);
                        },
                        icon: const Icon(CupertinoIcons.bell),
                      ),
                      if (hasUnread)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: _loading
                    ? const Center(child: CupertinoActivityIndicator())
                    : notifications.isEmpty
                    ? const Center(child: Text('No notifications yet.'))
                    : ListView.builder(
                  controller: _scrollCtrl,
                  itemCount: notifications.length + 1, // +1 for loader/end
                  itemBuilder: (context, index) {
                    if (index == notifications.length) {
                      if (_loadingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CupertinoActivityIndicator()),
                        );
                      }
                      if (!_hasMore) {
                        return const SizedBox(height: 8);
                      }
                      return const SizedBox(height: 8);
                    }

                    final notif = notifications[index];
                    return _NotifTile(
                      text: notif.text,
                      isRead: notif.isRead,
                      createdAt: notif.createdAt, // ✅ add
                      onMarkAsRead: () => _markOneAsRead(notif.id),
                      onMarkAsUnread: () => _markOneAsUnread(notif.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final bool isRead;
  final String text;
  final DateTime createdAt; // ✅ add
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsUnread;

  const _NotifTile({
    required this.isRead,
    required this.text,
    required this.createdAt, // ✅
    required this.onMarkAsRead,
    required this.onMarkAsUnread,
  });

  String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    final weeks = (diff.inDays / 7).floor();
    if (weeks < 4) return '${weeks}w ago';

    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo ago';

    final years = (diff.inDays / 365).floor();
    return '${years}y ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: isRead ? 0 : 1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF004280),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                color: Colors.white,
                icon: const Icon(Icons.more_vert, size: 18),
                onSelected: (value) {
                  if (value == 'read') onMarkAsRead();
                  if (value == 'unread') onMarkAsUnread();
                },
                itemBuilder: (_) => [
                  if (!isRead)
                    const PopupMenuItem(
                      value: 'read',
                      child: Text('Mark as read'),
                    ),
                  if (isRead)
                    const PopupMenuItem(
                      value: 'unread',
                      child: Text('Mark as unread'),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10,),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text(
              _timeAgo(createdAt),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
