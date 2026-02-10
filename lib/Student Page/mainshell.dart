import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_project_1/Student%20Page/wifi_guard.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/navbar.dart';

// pages
import 'dashboard.dart';
import 'History/history.dart';
import 'Help/help.dart';
import 'Settings/settings.dart';

import 'maintenance.dart';
import 'notification_ui.dart';
import 'student_session.dart';
import 'device_guard.dart';

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
  final supabase = Supabase.instance.client;
  RealtimeChannel? _studentSub;
  RealtimeChannel? _maintenanceSub;
  RealtimeChannel? _deviceSub;
  RealtimeChannel? _locationSub; // New for device location
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
    _startMaintenanceWatcher();
    _setupStudentWatcher();
  }

  Future<void> _showSessionExpiredDialogAndLogout() async {
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 50),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Text("Session Expired", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
              "Your account status has been changed or deactivated. You will be logged out for security.",
              style: TextStyle(fontSize: 14),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004280),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text("OK"),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await supabase.auth.signOut();
                  StudentSession.clear();
                  if (mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login', (r) => false);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setupStudentWatcher() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final res = await supabase
          .from('students')
          .select('status, archived, mac_address')
          .eq('id', userId)
          .maybeSingle();

      if (res != null) {
        final status = (res['status'] ?? '').toString().toLowerCase();
        final archived = res['archived'] == true;

        if (status == 'inactive' || archived) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSessionExpiredDialogAndLogout();
          });
          return;
        }

        final mac = res['mac_address']?.toString();
        if (mac != null && mac.isNotEmpty) {
          _setupDeviceStatusAndLocationWatcher(mac);
        }
      }
    } catch (e) {
      debugPrint("Initial student data check failed: $e");
    }

    _startRealtimeStudentListener(userId);
  }

  Future<void> _setupDeviceStatusAndLocationWatcher(String mac) async {
    // Initial Check for Online Status and Location
    try {
      final device = await supabase
          .from('devices')
          .select('is_online, current_location')
          .eq('mac_address', mac)
          .maybeSingle();

      if (device != null) {
        // Check Online Status First
        if (device['is_online'] == false) {
          _redirectToDeviceGuard(mac);
          return;
        }

        // Then Check Location
        final loc = device['current_location']?.toString().toUpperCase();
        if (loc == 'OUTSIDE' || loc == 'GATE' || loc == null || loc == 'NULL') {
          _redirectToWifiGuard();
          return;
        }
      }
    } catch (_) {}

    // Realtime Listener for Device Table (Online & Location)
    _deviceSub = supabase
        .channel('public:device_combined_check')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'devices',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'mac_address',
            value: mac,
          ),
          callback: (payload) {
            if (!mounted) return;
            final newRecord = payload.newRecord;

            // 1. Check Online Status
            final bool isOnline = newRecord['is_online'] ?? false;
            if (!isOnline) {
              _redirectToDeviceGuard(mac);
              return;
            }

            // 2. Check Location
            final String? newLoc = newRecord['current_location']?.toString().toUpperCase();
            if (newLoc == 'OUTSIDE' || newLoc == 'GATE' || newLoc == null || newLoc == 'NULL') {
              _redirectToWifiGuard();
            }
          },
        )
        .subscribe();
  }

  void _redirectToWifiGuard() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WifiGuard()),
        (route) => false,
      );
    }
  }

  void _redirectToDeviceGuard(String mac) {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => DeviceGuard(macAddress: mac)),
        (route) => false,
      );
    }
  }

  void _startMaintenanceWatcher() {
    _maintenanceSub = supabase
        .channel('public:system_check')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'system_settings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: 'maintenance_mode',
          ),
          callback: (payload) {
            final bool isUnderMaintenance =
                payload.newRecord['is_active'] ?? false;

            if (isUnderMaintenance && mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MaintenanceGuard()),
                (route) => false,
              );
            }
          },
        )
        .subscribe();
  }

  void _startRealtimeStudentListener(String userId) {
    _studentSub = supabase
        .channel('public:students_check')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'students',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) {
            if (!mounted) return;
            final newRecord = payload.newRecord;

            if (newRecord.containsKey('status')) {
              final newStatus = newRecord['status']?.toString().toLowerCase();
              if (newStatus == 'inactive') {
                _showSessionExpiredDialogAndLogout();
                return;
              }
            }

            if (newRecord.containsKey('archived')) {
              if (newRecord['archived'] == true) {
                _showSessionExpiredDialogAndLogout();
                return;
              }
            }

            if (newRecord.containsKey('mac_address')) {
              final mac = newRecord['mac_address']?.toString();
              if (mac != null && mac.isNotEmpty) {
                _deviceSub?.unsubscribe();
                _setupDeviceStatusAndLocationWatcher(mac);
              }
            }
          },
        )
        .subscribe();
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
    _studentSub?.unsubscribe();
    _maintenanceSub?.unsubscribe();
    _deviceSub?.unsubscribe();
    _locationSub?.unsubscribe();
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

      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: _pages,
          ),

          Positioned(
            left: 12,
            right: 12,
            top: MediaQuery.of(context).padding.top + 10,
            child: IgnorePointer(
              ignoring: true,
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
          color: const Color(0xFFFF4D4D),
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
