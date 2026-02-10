import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mainshell.dart';
import 'student_session.dart';

class DeviceGuard extends StatefulWidget {
  final String macAddress;
  const DeviceGuard({super.key, required this.macAddress});

  @override
  State<DeviceGuard> createState() => _DeviceGuardState();
}

class _DeviceGuardState extends State<DeviceGuard> {
  final supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _subscribeToDeviceStatus();
  }

  void _subscribeToDeviceStatus() {
    _channel = supabase
        .channel('public:device_status_guard')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'devices',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'mac_address',
            value: widget.macAddress,
          ),
          callback: (payload) {
            final bool isOnline = payload.newRecord['is_online'] ?? false;
            if (isOnline && mounted) {
              // Balik sa Mainshell kapag nag-true (online) na
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const Mainshell()),
                (route) => false,
              );
            }
          },
        )
        .subscribe();
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
                  CupertinoIcons.device_desktop,
                  size: 80,
                  color: Color(0xFF004280),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Device Offline',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 15),
              const Text(
                'Your assigned Attendly device is currently offline. Please ensure it is powered on and connected to the internet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 50),

              const CupertinoActivityIndicator(radius: 12),
              const SizedBox(height: 10),
              const Text(
                "Waiting for Device Signal...",
                style: TextStyle(fontSize: 13, color: Colors.blueGrey, fontStyle: FontStyle.italic),
              ),

              const SizedBox(height: 40),
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
