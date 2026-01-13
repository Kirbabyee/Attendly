import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentSession {
  static final supabase = Supabase.instance.client;

  static Map<String, dynamic>? student; // cached row
  static Completer<void>? _loading;     // prevents double fetch
  static String? _cachedUserId;         // ✅ track which user owns the cache

  static void set(Map<String, dynamic>? data) {
    student = data;
    _cachedUserId = supabase.auth.currentUser?.id;
  }

  static Future<Map<String, dynamic>?> get({bool force = false}) async {
    final user = supabase.auth.currentUser;
    final uid = user?.id;

    // ✅ if user changed, clear cache automatically
    if (_cachedUserId != uid) {
      student = null;
      _cachedUserId = uid;
      force = true;
    }

    if (!force && student != null) return student;

    // if already loading, await it
    if (_loading != null) {
      await _loading!.future;
      return student;
    }

    _loading = Completer<void>();

    try {
      if (user == null) {
        student = null;
        _loading!.complete();
        _loading = null;
        return null;
      }

      final data = await supabase
          .from('students')
          .select('*')
          .eq('id', user.id) // keep your column name
          .maybeSingle();

      student = data;
      _loading!.complete();
      _loading = null;
      return student;
    } catch (e) {
      _loading!.complete();
      _loading = null;
      rethrow;
    }
  }

  static void clear() {
    student = null;
    _cachedUserId = null;
  }
}
