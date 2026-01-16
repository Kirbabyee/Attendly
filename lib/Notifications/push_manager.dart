import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class PushManager {
  static bool _listenersReady = false;

  /// Call ONCE after login/app shell
  static Future<void> initListenersOnce() async {
    if (_listenersReady) return;
    _listenersReady = true;

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) async {
      final title = message.notification?.title ?? 'Attendly';
      final body = message.notification?.body ?? '';
      await NotificationsService.show(title: title, body: body);
    });

    // User tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // TODO: navigate using message.data
    });
  }

  /// Call when user enables push OR after login to ensure token saved
  static Future<void> enableAndRegisterToken({
    required String userId,
    required bool enabled,
    String platform = 'android',
  }) async {
    final fcm = FirebaseMessaging.instance;

    // Always ask permission only when enabling
    if (enabled) {
      await fcm.requestPermission(alert: true, badge: true, sound: true);
    }

    // Save preference
    await Supabase.instance.client
        .from('students')
        .update({'push_enabled': enabled})
        .eq('id', userId);

    if (!enabled) return;

    // Register token
    final token = await fcm.getToken();
    if (token == null) return;
    print('FCM TOKEN: $token');

    // ✅ IMPORTANT: include user_id in upsert
    await Supabase.instance.client.from('device_tokens').upsert({
      'user_id': userId,
      'token': token,
      'platform': platform,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
