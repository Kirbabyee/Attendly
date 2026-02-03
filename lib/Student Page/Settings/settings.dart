import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_1/Student%20Page/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../widgets/push_notification.dart';
import '../Notification/push_token_service.dart';
import '../student_session.dart';
import 'privacy_policy.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
    _loadStudent(force: true);
  }
  bool _notifBusy = false;

  bool is2FAOn = false;
  bool _twoFaBusy = false;

  Map<String, dynamic>? _student;
  bool _loadingStudent = true;
  String? _studentError;

  Future<void> _loadStudent({bool force = false}) async {
    setState(() {
      _studentError = null;
      if (_student == null) _loadingStudent = true;
    });

    try {
      final s = await StudentSession.get(force: force);
      if (!mounted) return;

      setState(() {
        _student = s;

        // ✅ Push switch sync
        isNotificationOn = (s?['push_enabled'] as bool?) ?? false;

        // ✅ 2FA switch sync
        is2FAOn = (s?['two_fa_enabled'] as bool?) ?? false;

        _loadingStudent = false;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _studentError = e.toString();
        _loadingStudent = false;
      });
    }
  }

  // Sa loob ng _SettingsState class

  Future<void> _handle2FAToggle(bool value) async {
    final actionText = value ? "Enable" : "Disable";
    final email = _student?['email']?.toString() ?? '';
    final studentNumber = _student?['student_number']?.toString() ?? '';

    // 1. Initial Confirmation Dialog
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        title: Text('$actionText 2FA?', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'To $actionText Two-Factor Authentication, we need to verify your identity. We will send a 6-digit OTP to your registered email address.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004280)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send OTP', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (proceed != true) {
      // Ibalik ang switch sa dating state kung cinancel
      setState(() => is2FAOn = !value);
      return;
    }

    // --- LOADING START ---
    _showLoadingDialog("Sending OTP...");

    try {
      // Step A: Send OTP via Edge Function
      // Pwede mong gamitin ang same activation function o gawa ng generic na 'send-2fa-otp'
      await _sendActivationOtp(email, studentNumber);

      if (mounted) Navigator.pop(context); // Close Loading

      // Step B: Show OTP Modal
      if (!mounted) return;
      final verified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _OtpDialog(
          email: email,
          password: "",
          cooldownSeconds: 60,
          onResend: () => _sendActivationOtp(email, studentNumber),
          onVerify: (otp) => _verifyActivationOtp(email, studentNumber, otp),
        ),
      );

      if (verified == true) {
        await _update2FAInDatabase(value); // Save 'true' or 'false'

        if (value) {
          await _show2FASuccess(); // Pakita lang ang success modal kung i-e-enable
        } else {
          _toast("Two-Factor Authentication has been disabled.");
        }
      } else {
        // Kung nag-fail ang verification, ibalik ang switch
        setState(() => is2FAOn = !value);
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      _toast(e.toString().replaceFirst('Exception: ', ''));
      setState(() => is2FAOn = !value);
    }
  }

  // ✅ Loading Dialog Helper
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(width: 20),
              Text(message, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Success Modal (Gaya ng sa Change Password)
  Future<void> _show2FASuccess() async {
    final screenHeight = MediaQuery.of(context).size.height;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7, // Mas maliit na width
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Material( // Para hindi maging weird ang text style
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Importante: kukunin lang ang space na kailangan
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: screenHeight * 0.05, // Responsive size
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '2FA Enabled',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Your account is now more secure.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004280),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it!', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Functions ---
  Future<void> _sendActivationOtp(String email, String studentNumber) async {
    final res = await supabase.functions.invoke('send-2fa-activation-otp', body: {
      'email': email,
      'student_number': studentNumber,
    });
    if (res.status != 200) throw Exception(res.data['message'] ?? 'Failed to send OTP');
  }

  Future<void> _verifyActivationOtp(String email, String studentNumber, String otp) async {
    final res = await supabase.functions.invoke('verify-2fa-activation-otp', body: {
      'email': email,
      'student_number': studentNumber,
      'otp': otp,
    });
    if (res.status != 200) throw Exception(res.data['message'] ?? 'Invalid OTP');
  }

  Future<void> _update2FAInDatabase(bool enabled) async {
    final uid = _student?['id'];
    await supabase.from('students').update({'two_fa_enabled': enabled}).eq('id', uid);
    await _loadStudent(force: true); // Refresh local state
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool isNotificationOn = false;

  String termOfService = 'Welcome to Attendly. By accessing or using the Attendly system, you agree to comply with and be bound by the following Terms of Service. If you do not agree with these terms, please refrain from using the system.\n'
  '\nAttendly is an attendance monitoring system designed for academic use. The system verifies attendance through network-based detection, hardware-assisted presence validation, and biometric face verification. Users are expected to use the system solely for its intended educational purpose.\n'
  '\nUsers must provide accurate and truthful information during account usage. Any attempt to misuse the system, falsify attendance records, impersonate another user, tamper with assigned devices, or bypass verification mechanisms is strictly prohibited and may result in account suspension or administrative action.\n'
  '\nAttendly does not guarantee uninterrupted availability and may experience temporary downtime due to maintenance or technical limitations. The system is provided “as is” for academic and institutional use.\n'
  '\nAttendly reserves the right to update, modify, or suspend system features when necessary to improve performance, security, or compliance with institutional requirements.';

  String privacyPolicy = PrivacyPolicy().privacyPolicy;

  Widget sectionTitle(String text) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * .009, top: screenHeight * .015),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenHeight * .018,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget bullet(String text) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(left: screenHeight * .011, bottom: screenHeight * .009),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: TextStyle(fontSize: screenHeight * .017)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: screenHeight * .017, height: screenHeight * .0018),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER (fixed)
            Container(
              height: screenHeight * .12,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * .08),
              decoration: BoxDecoration(
                color: Color(0xFF004280),
                borderRadius: BorderRadius.vertical(
                  top: Radius.zero,
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusGeometry.circular(7),
                      color: Color(0x30FFFFFF),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: screenHeight * .06,
                    ),
                  ),
                  SizedBox(width: 15),
                  Container(
                    height: screenHeight * .06,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: screenHeight * .018,
                          ),
                        ),
                        SizedBox(height: screenHeight * .01),
                        Text(
                          'Manage your preferences',
                          style: TextStyle(
                            fontSize: screenHeight * .014,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: screenHeight * .023),
                child: Column(
                  children: [
                    // Account Information
                    SizedBox(
                      width: screenWidth * .9,
                      height: screenHeight * .083,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                        ),
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/account_information');
                          await _loadStudent(force: true);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person_outline_outlined, color: Colors.black, size: screenHeight * .023,),
                                SizedBox(width: 10),
                                Text(
                                  'Account Information',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: screenHeight * .017
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.keyboard_arrow_right, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * .023),

                    // Notification
                    Container(
                      width: screenWidth * .9,
                      padding: EdgeInsets.all(screenHeight * .023),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.notifications_outlined, size: screenHeight * .023, color: Colors.black),
                              SizedBox(width: 10),
                              Text(
                                'Notification',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: screenHeight * .017
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * .05, vertical: screenHeight * .005),
                            decoration: BoxDecoration(
                              color: Color(0x90D9D9D9),
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Push Notification',
                                      style: TextStyle(fontSize: screenHeight * .014, fontWeight: FontWeight.w600),
                                    ),
                                    Text('Receive app notifications', style: TextStyle(fontSize: screenHeight * .014)),
                                  ],
                                ),
                                Transform.scale(
                                  scale: screenHeight * .001,
                                  child: Switch(
                                    activeTrackColor: Color(0xFF004280),
                                    value: isNotificationOn,
                                    onChanged: _notifBusy ? null : (value) async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          title: Text(
                                            value ? 'Enable notifications?' : 'Disable notifications?',
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004280)),
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok != true) return;

                                      final prev = isNotificationOn;
                                      setState(() {
                                        _notifBusy = true;
                                        isNotificationOn = value;
                                      });

                                      final studentId = _student?['id']?.toString();
                                      if (studentId == null) {
                                        if (mounted) setState(() => _notifBusy = false);
                                        return;
                                      }

                                      try {
                                        final svc = PushTokenService(supabase);

                                        // 1) save preference in students table
                                        await supabase
                                            .from('students')
                                            .update({'push_enabled': value})
                                            .eq('id', studentId);

                                        // 2) token behavior
                                        if (value) {
                                          await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

                                          await svc.replaceTokenForUser(studentId: studentId); // ✅ delete old then add new
                                          svc.listenTokenRefresh(studentId: studentId);        // ✅ keep updated
                                        } else {
                                          await svc.removeAllForUser(studentId: studentId);    // ✅ remove tokens when off
                                        }

                                        // 3) refresh cache/UI from DB
                                        await _loadStudent(force: true);
                                      } catch (e) {
                                        if (!mounted) return;
                                        setState(() => isNotificationOn = prev);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to update notifications: $e')),
                                        );
                                      } finally {
                                        if (mounted) setState(() => _notifBusy = false);
                                      }
                                    },
                                  )
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * .023),

                    // Security & Privacy
                    Container(
                      width: screenWidth * .9,
                      padding: EdgeInsets.all(screenHeight * .023),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lock_outline, size: screenHeight * .023, color: Colors.black),
                              SizedBox(width: 10),
                              Text(
                                'Security & Privacy',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: screenHeight * .017
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: screenHeight * .013),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/change_password');
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(8),
                              ),
                              side: BorderSide.none,
                              backgroundColor: Color(0x90D9D9D9),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: screenHeight * .013),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Change Password',
                                        style: TextStyle(
                                          fontSize: screenHeight * .014,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Update your account password',
                                        style: TextStyle(
                                          fontSize: screenHeight * .014,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_right,
                                    size: screenHeight * .023,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15,),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * .05, vertical: screenHeight * .005),
                            decoration: BoxDecoration(
                              color: Color(0x90D9D9D9),
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Two Factor Authentication',
                                      style: TextStyle(fontSize: screenHeight * .014, fontWeight: FontWeight.w600),
                                    ),
                                    Text('Receive OTP for verification', style: TextStyle(fontSize: screenHeight * .014)),
                                  ],
                                ),
                                Transform.scale(
                                  scale: screenHeight * .001,
                                  child: Switch(
                                    activeTrackColor: const Color(0xFF004280),
                                    value: is2FAOn,
                                    onChanged: _twoFaBusy ? null : (value) => _handle2FAToggle(value),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * .023),

                    // About
                    Container(
                      width: screenWidth * .9,
                      padding: EdgeInsets.all(screenHeight * .023),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: screenHeight * .023),
                              SizedBox(width: 10),
                              Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenHeight * .017)),
                            ],
                          ),
                          SizedBox(height: screenHeight * .023),
                          SizedBox(
                            width: screenWidth * .7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'App Version',
                                  style: TextStyle(
                                    fontSize: screenHeight * .015
                                  ),
                                ),
                                Text(
                                  '1.0.0',
                                  style: TextStyle(
                                      fontSize: screenHeight * .015
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: screenWidth * .7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Build',
                                  style: TextStyle(
                                      fontSize: screenHeight * .015
                                  ),
                                ),
                                Text(
                                  '2025.30.14',
                                  style: TextStyle(
                                      fontSize: screenHeight * .015
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10,),

                    // Terms and Privacy Policy
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: screenHeight * .021,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadiusGeometry.circular(8)
                                    ),
                                    backgroundColor: Colors.white,
                                    title: Text(
                                      'Terms of Service',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: screenHeight * .027
                                      ),
                                    ),
                                    content: SingleChildScrollView( // 👈 makes it scrollable
                                      child: Text(
                                        termOfService,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          fontSize: screenHeight * .019
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontSize: screenHeight * .015,
                                color: Colors.black
                              ),
                            )
                          )
                        ),
                        SizedBox(width: screenHeight * .023,),
                        SizedBox(
                          height: screenHeight * .021,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadiusGeometry.circular(8)
                                    ),
                                    backgroundColor: Colors.white,
                                    title: Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        fontSize: screenHeight * .027
                                      ),
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Attendly is committed to protecting user privacy and handling personal data responsibly.',
                                            style: TextStyle(fontSize: screenHeight * .017, height: screenHeight * .0019),
                                          ),

                                          sectionTitle('Information Collected'),
                                          bullet('Student and professor identification details'),
                                          bullet('Device identifiers used for presence validation'),
                                          bullet('Facial biometric data for face verification'),
                                          bullet('Attendance timestamps and class records'),

                                          sectionTitle('Use of Information'),
                                          bullet('Verifying student identity and physical presence'),
                                          bullet('Recording and managing attendance'),
                                          bullet('Supporting academic and administrative processes'),

                                          sectionTitle('Data Protection'),
                                          Text(
                                            'Facial data is stored as encrypted templates and protected through access controls.',
                                            style: TextStyle(fontSize: screenHeight * .017, height: screenHeight * .0019),
                                          ),

                                          sectionTitle('User Rights'),
                                          bullet('Access attendance records'),
                                          bullet('Request correction of inaccurate information'),
                                          bullet('Request face re-enrollment'),

                                          sectionTitle('Policy Updates'),
                                          Text(
                                            'This Privacy Policy may be updated to reflect system or regulatory changes.',
                                            style: TextStyle(fontSize: screenHeight * .017, height: screenHeight * .0019),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenHeight * .015
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * .023),

                    // Logout Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFFFDDCDC),
                        side: BorderSide.none,
                      ),
                      onPressed: () async {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.white,
                              title: Text(
                                'Sign Out',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: screenHeight * .025),
                              ),
                              content: Text(
                                'Are you sure you want to sign out?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: screenHeight * .017
                                ),
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel', style: TextStyle(color: Colors.black, fontSize: screenHeight * .017)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB60202),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Sign Out', style: TextStyle(color: Colors.white, fontSize: screenHeight * .017)),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm != true) return;

                        // Loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return Dialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: EdgeInsets.all(screenHeight * .021),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: screenHeight * .021,
                                      child: const CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('Signing out...', style: TextStyle(fontSize: screenHeight * .017)),
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                        try {
                          final supabase = Supabase.instance.client;

                          // 1) get email to use
                          final userEmail =
                          (_student?['email']?.toString().trim().toLowerCase().isNotEmpty == true)
                              ? _student!['email'].toString().trim().toLowerCase()
                              : (supabase.auth.currentUser?.email?.trim().toLowerCase() ?? '');

                          // 2) reset twofa_otps verified=false
                          if (userEmail.isNotEmpty) {
                            try {
                              await supabase
                                  .from('twofa_otps')
                                  .update({
                                'verified': false,
                                'otp_hash': null,      // optional pero recommended
                                'expires_at': null,    // optional pero recommended
                                'updated_at': DateTime.now().toUtc().toIso8601String(),
                              })
                                  .eq('email', userEmail);
                            } catch (_) {
                              // ignore: kahit magfail to, tuloy pa rin signout
                            }
                          }

                          final studentId = _student?['id']?.toString();
                          if (studentId != null) {
                            try {
                              final svc = PushTokenService(supabase);
                              await svc.removeAllForUser(studentId: studentId); // ✅ logout = remove tokens
                            } catch (_) {}
                          }

                          // 3) sign out
                          await supabase.auth.signOut();
                          StudentSession.clear();

                          if (!mounted) return;
                          Navigator.pop(context); // close loading dialog
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        } catch (e) {
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout failed: $e')),
                          );
                        }
                      },
                      icon: Icon(Icons.logout_outlined, color: Colors.red, size: screenHeight * .023,),
                      label: Text('Sign Out', style: TextStyle(color: Colors.red, fontSize: screenHeight * .017)),
                    ),

                    SizedBox(height: screenHeight * .023),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpDialog extends StatefulWidget {
  final String email; // ✅ add
  final String password;
  final int cooldownSeconds;
  final Future<void> Function() onResend;
  final Future<void> Function(String otp) onVerify;

  const _OtpDialog({
    required this.email, // ✅ add
    required this.password,
    required this.cooldownSeconds,
    required this.onResend,
    required this.onVerify,
  });

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  String? _otpError; // ✅ show warning + red border
  String maskEmail(String email) {
    final e = email.trim();
    final at = e.indexOf('@');
    if (at <= 1) return email;

    final local = e.substring(0, at);
    final domain = e.substring(at); // includes '@'

    if (local.length == 2) return '${local[0]}*$domain';
    if (local.length <= 1) return '*$domain';

    final start = local.substring(0, 1);
    final end = local.substring(local.length - 1);
    return '$start${'*' * (local.length - 2)}$end$domain';
  }

  final _otp = TextEditingController();
  Timer? _t;
  int _left = 0;

  bool _verifying = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startCooldown(widget.cooldownSeconds);
  }

  @override
  void dispose() {
    _t?.cancel();
    _otp.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _t?.cancel();
    setState(() => _left = seconds);
    _t = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_left <= 1) {
        timer.cancel();
        setState(() => _left = 0);
      } else {
        setState(() => _left -= 1);
      }
    });
  }

  String get _otpValue => _otp.text.trim();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter OTP', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit OTP to:\n${maskEmail(widget.email)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _otpError == null ? const Color(0xFFEAEAEA) : const Color(0xFFFFE5E5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _otpError == null ? Colors.transparent : Colors.red,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _otp,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w600,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (_) {
                  if (_otpError != null) setState(() => _otpError = null);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '000000',
                ),
              ),
            ),
            if (_otpError != null) ...[
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Invalid OTP',
                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],


            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _verifying ? null : () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004280),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: (_verifying || _otpValue.length != 6)
                        ? null
                        : () async {
                      setState(() => _verifying = true);
                      try {
                        await widget.onVerify(_otpValue);
                        if (!mounted) return;
                        Navigator.pop(context, true);
                      } catch (e) {
                        final msg = e.toString().replaceFirst('Exception: ', '');

                        if (!mounted) return;
                        setState(() => _otpError = msg.isEmpty ? 'Invalid OTP' : msg);

                        // optional: haptic feedback
                        HapticFeedback.mediumImpact();
                      } finally {
                        if (mounted) setState(() => _verifying = false);
                      }
                    },
                    child: _verifying
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Verify', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            InkWell(
              onTap: (_left > 0 || _resending)
                  ? null
                  : () async {
                setState(() => _resending = true);
                try {
                  await widget.onResend();
                  if (!mounted) return;
                  _startCooldown(widget.cooldownSeconds);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP resent. Please check your email.')));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                  );
                } finally {
                  if (mounted) setState(() => _resending = false);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  _left > 0 ? 'Resend OTP (${_left}s)' : 'Resend OTP',
                  style: TextStyle(
                    fontSize: 12,
                    color: (_left > 0) ? Colors.grey : const Color(0xFF004280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}