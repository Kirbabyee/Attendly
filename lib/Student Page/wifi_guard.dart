import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mainshell.dart';
import 'student_session.dart';

class WifiGuard extends StatefulWidget {
  const WifiGuard({super.key});

  @override
  State<WifiGuard> createState() => _WifiGuardState();
}

class _WifiGuardState extends State<WifiGuard> {
  final supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  String? _macAddress;
  String? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initGuard();
  }

  Future<void> _initGuard() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Kunin ang mac_address ng student
      final res = await supabase
          .from('students')
          .select('mac_address')
          .eq('id', userId)
          .maybeSingle();

      if (res != null && res['mac_address'] != null) {
        final mac = res['mac_address'].toString();
        setState(() => _macAddress = mac);

        // 2. INITIAL CHECK: Baka classroom na agad ang device
        final deviceRes = await supabase
            .from('devices')
            .select('current_location')
            .eq('mac_address', mac)
            .maybeSingle();

        if (deviceRes != null) {
          final loc = deviceRes['current_location']?.toString().toUpperCase();
          setState(() => _currentLocation = loc);
          if (loc == 'CLASSROOM') {
            _unlock();
            return;
          }
        }

        // 3. Subukan pakinggan ang mga susunod na updates
        _subscribeToDeviceLocation(mac);
      }
    } catch (e) {
      debugPrint("Error fetching student mac: $e");
    }
  }

  void _subscribeToDeviceLocation(String mac) {
    _channel = supabase
        .channel('public:device_location_guard')
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
            final newLoc = payload.newRecord['current_location']?.toString().toUpperCase();
            setState(() => _currentLocation = newLoc);
            
            // Unlock kapag naging CLASSROOM lang.
            // Pag OUTSIDE, GATE, o null, mananatili dito (Disabled).
            if (newLoc == 'CLASSROOM') {
              _unlock();
            }
          },
        )
        .subscribe();
  }

  void _unlock() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Mainshell()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    if (_channel != null) {
      supabase.removeChannel(_channel!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.lock_shield_fill,
                  size: 80,
                  color: Color(0xFF004280),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Access Restricted',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 15),
              const Text(
                'Your device location is currently outside the classroom. Access to Attendly features is restricted for security.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 50),

              const CupertinoActivityIndicator(radius: 12),
              const SizedBox(height: 10),
              const Text(
                "Waiting for Classroom Signal...",
                style: TextStyle(fontSize: 13, color: Colors.blueGrey, fontStyle: FontStyle.italic),
              ),

              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.location_north_fill, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      "Location: ${_currentLocation ?? 'Detecting...'}",
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              CupertinoButton(
                child: const Text('Log Out', style: TextStyle(color: Colors.black)),
                onPressed: () async {
                  await supabase.auth.signOut();
                  StudentSession.clear();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
