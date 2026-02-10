import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_project_1/Student%20Page/face_registration.dart';
import 'package:flutter_project_1/Student%20Page/device_registration.dart'; // Siguraduhing imported ito
import 'package:flutter_project_1/Student%20Page/wifi_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'maintenance.dart';
import 'student_session.dart';

import '../main.dart';
import 'mainshell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late final StreamSubscription<AuthState> _sub;

  bool _loading = true;
  bool _routing = false;

  final Duration _minSplashDuration = const Duration(milliseconds: 2500);
  late final DateTime _start;

  late final AnimationController _logoCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.96, end: 1.03).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut),
    );

    _sub = supabase.auth.onAuthStateChange.listen((data) async {
      if (!mounted) return;
      final session = data.session;

      if (session != null) {
        StudentSession.clear();
        try { await StudentSession.get(force: true); } catch (_) {}
      } else {
        StudentSession.clear();
      }

      await _finishSplash();
      if (!mounted) return;
      await _go(session);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = supabase.auth.currentSession;
      if (session != null) {
        StudentSession.clear();
        try { await StudentSession.get(force: true); } catch (_) {}
      } else {
        StudentSession.clear();
      }
      await _finishSplash();
      if (!mounted) return;
      await _go(session);
    });
  }

  Future<void> _finishSplash() async {
    final elapsed = DateTime.now().difference(_start);
    final remaining = _minSplashDuration - elapsed;
    if (!remaining.isNegative && remaining != Duration.zero) {
      await Future.delayed(remaining);
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _go(Session? session) async {
    if (_routing) return;
    _routing = true;

    try {
      if (session == null) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LandingPage()), (route) => false,
        );
        return;
      }

      try {
        final maintenanceRow = await supabase
            .from('system_settings')
            .select('is_active')
            .eq('id', 'maintenance_mode')
            .maybeSingle();

        if (maintenanceRow != null && maintenanceRow['is_active'] == true) {
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MaintenanceGuard()),
                (route) => false,
          );
          return; // Stop further routing
        }
      } catch (e) {
        debugPrint("Error checking maintenance status: $e");
      }

      String location = "NULL";
      int terms = 0;
      bool isFaceRegistered = false;
      bool isDeviceLinked = false; // New flag for MAC address

      try {
        // Idinagdag ang mac_address sa select query
        final row = await supabase
            .from('students')
            .select('terms_conditions, face_registered_at, status, archived, location, mac_address')
            .eq('id', session.user.id)
            .maybeSingle();

        if (row == null || row['archived'] == true || row['status'] == 'inactive') {
          await supabase.auth.signOut();
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LandingPage()), (route) => false,
          );
          return;
        }

        location = (row['location'] ?? "NULL").toString().toUpperCase();
        final rawTerms = row['terms_conditions'];
        terms = (rawTerms is num) ? rawTerms.toInt() : 0;

        final faceRegisteredAt = row['face_registered_at'];
        isFaceRegistered = faceRegisteredAt != null && faceRegisteredAt.toString().isNotEmpty;

        // Check kung may valid na mac_address
        final rawMac = row['mac_address'];
        isDeviceLinked = rawMac != null && rawMac.toString().trim().isNotEmpty;

      } catch (e) {
        debugPrint("Error fetching student data: $e");
      }

      // ✅ 1. Terms Check
      if (terms != 1) {
        await supabase.auth.signOut();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LandingPage()), (route) => false,
        );
        return;
      }

      if (!mounted) return;

      // ✅ 2. Face Registration Check
      if (!isFaceRegistered) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Face_Registration()), (route) => false,
        );
        return;
      }

      // ✅ 3. Device Registration Check (MAC Address)
      if (!isDeviceLinked) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DeviceRegistration()),
              (route) => false,
        );
        return;
      }

      // ✅ 4. Location-Based Routing (Kung registered na lahat)
      if (location == "GATE") {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WifiGuard()), (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Mainshell()), (route) => false,
        );
      }

    } finally {
      _routing = false;
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _logoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _routing) {
      return Scaffold(
        backgroundColor: const Color(0xFFEAF5FB),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Image.asset('assets/logo.png', width: 180),
              ),
              const SizedBox(height: 18),
              const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(height: 12),
              Text(
                _routing ? 'Checking requirements...' : 'Loading Attendly...',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return const Scaffold(
      backgroundColor: Color(0xFFEAF5FB),
      body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}