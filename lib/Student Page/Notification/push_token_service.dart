import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushTokenService {
  final SupabaseClient supabase;
  PushTokenService(this.supabase);

  String _platform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  Future<String?> _getToken() async {
    final t = await FirebaseMessaging.instance.getToken();
    if (t == null || t.trim().isEmpty) return null;
    return t.trim();
  }

  /// ✅ rule: delete old tokens for this user, then add new
  Future<void> replaceTokenForUser({required String studentId}) async {
    final token = await _getToken();
    if (token == null) return;

    // remove token if assigned to another user (multi-account on same device)
    await supabase.from('device_tokens').delete().eq('token', token);

    // remove ALL tokens for this student (logout rule)
    await supabase
        .from('device_tokens')
        .delete()
        .eq('user_id', studentId)
        .eq('role', 'student');

    // insert fresh token
    await supabase.from('device_tokens').insert({
      'user_id': studentId,
      'role': 'student',
      'token': token,
      'platform': _platform(),
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> removeAllForUser({required String studentId}) async {
    await supabase
        .from('device_tokens')
        .delete()
        .eq('user_id', studentId)
        .eq('role', 'student');
  }

  void listenTokenRefresh({required String studentId}) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (newToken.trim().isEmpty) return;

      await supabase.from('device_tokens').delete().eq('token', newToken);
      await supabase
          .from('device_tokens')
          .delete()
          .eq('user_id', studentId)
          .eq('role', 'student');

      await supabase.from('device_tokens').insert({
        'user_id': studentId,
        'role': 'student',
        'token': newToken,
        'platform': _platform(),
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      });
    });
  }
}
