import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_project_1/Student%20Page/face_registration.dart';
import 'package:flutter_project_1/Student%20Page/wifi_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_session.dart';

import '../main.dart'; // LandingPage
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
        try {
          await StudentSession.get(force: true);
        } catch (_) {}
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
        try {
          await StudentSession.get(force: true);
        } catch (_) {}
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
      // ✅ 1. Kapag hindi logged in -> Landing/Login Page
      if (session == null) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LandingPage()),
              (route) => false,
        );
        return;
      }

      String location = "NULL"; // Default
      int terms = 0;
      bool isFaceRegistered = false;

      try {
        // Idagdag ang 'location' sa select query
        final row = await supabase
            .from('students')
            .select('terms_conditions, face_registered_at, status, archived, location')
            .eq('id', session.user.id)
            .maybeSingle();

        if (row == null || row['archived'] == true || row['status'] == 'inactive') {
          await supabase.auth.signOut();
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LandingPage()),
                (route) => false,
          );
          return;
        }

        // Kunin ang current location mula sa DB
        location = (row['location'] ?? "NULL").toString().toUpperCase();

        final rawTerms = row['terms_conditions'];
        terms = (rawTerms is num) ? rawTerms.toInt() : 0;

        final faceRegisteredAt = row['face_registered_at'];
        isFaceRegistered = faceRegisteredAt != null && faceRegisteredAt.toString().isNotEmpty;

      } catch (e) {
        print("Error fetching student data: $e");
      }

      // ✅ 2. Terms Check
      if (terms != 1) {
        await supabase.auth.signOut();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LandingPage()),
              (route) => false,
        );
        return;
      }

      if (!mounted) return;

      // ✅ 3. Location-Based Routing
      // Kapag 'GATE', kahit registered na ang face, dapat dumaan sa WifiGuard
      if (location == "GATE") {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WifiGuard()), // Gawa ka ng WifiGuard page
              (route) => false,
        );
      }
      // Kapag 'CLASSROOM', check kung may face registration na
      else if (location == "CLASSROOM") {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => isFaceRegistered ? const Mainshell() : const Face_Registration(),
          ),
              (route) => false,
        );
      }
      // Default / Unknown Location
      else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Mainshell()),
              (route) => false,
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
    // show splash while loading or routing
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
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: 12),
              Text(
                _routing ? 'Checking your account...' : 'Loading Attendly...',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    // Shouldn't really reach here because we navigate away,
    // but return something non-black just in case.
    return const Scaffold(
      backgroundColor: Color(0xFFEAF5FB),
      body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
