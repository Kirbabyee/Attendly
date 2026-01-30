import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../widgets/navbar.dart';

// pages
import 'dashboard.dart';
import 'History/history.dart';
import 'Help/help.dart';
import 'Settings/settings.dart';

import 'notification_ui.dart';

class Mainshell extends StatefulWidget {
  final int initialIndex;

  const Mainshell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<Mainshell> createState() => _MainshellState();
}

class _MainshellState extends State<Mainshell> {
  late int _index;

  final GlobalKey<ScaffoldState> _shellKey = GlobalKey<ScaffoldState>();

  bool _unRead = true;
  late final List<Widget> _pages;

  // ✅ internet banner (overlay, no layout shift)
  bool _offline = false;
  StreamSubscription? _connSub;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;

    _pages = [
      Dashboard(
        unRead: _unRead,
        onOpenNotifications: openNotifications,
      ),
      const History(),
      const Help(),
      const Settings(),
    ];

    _startInternetWatcher();
  }

  Future<void> _startInternetWatcher() async {
    await _updateOfflineStatus();
    _connSub = Connectivity().onConnectivityChanged.listen((_) async {
      await _updateOfflineStatus();
    });
  }

  Future<void> _updateOfflineStatus() async {
    final conn = await Connectivity().checkConnectivity();

    if (conn == ConnectivityResult.none) {
      if (!mounted) return;
      setState(() => _offline = true);
      return;
    }

    final hasInternet = await InternetConnection().hasInternetAccess;

    if (!mounted) return;
    setState(() => _offline = !hasInternet);
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  void openNotifications() {
    _shellKey.currentState?.openEndDrawer();
  }

  void _handleUnreadChanged(bool v) {
    if (!mounted) return;

    setState(() => _unRead = v);

    _pages[0] = Dashboard(
      unRead: _unRead,
      onOpenNotifications: openNotifications,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _shellKey,

      endDrawer: NotificationsDrawer(
        unRead: _unRead,
        onUnreadChanged: _handleUnreadChanged,
      ),

      // ✅ BODY: stack overlay (doesn't affect page layout)
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: _pages,
          ),

          // ✅ pretty banner overlay
          Positioned(
            left: 12,
            right: 12,
            top: MediaQuery.of(context).padding.top + 10,
            child: IgnorePointer(
              ignoring: true, // ✅ overlay lang, di nakakablock ng taps
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                offset: _offline ? Offset.zero : const Offset(0, -0.35),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _offline ? 1 : 0,
                  child: _NoInternetBanner(),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: AttendlyNavBar(
        screenHeight: screenHeight,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _NoInternetBanner extends StatelessWidget {
  const _NoInternetBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Color(0xFFFF4D4D),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.wifi_off_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No internet connection',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
