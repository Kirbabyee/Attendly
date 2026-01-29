import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_1/Student%20Page/mainshell.dart';
import 'package:flutter_project_1/Student%20Page/terms_and_conditions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_project_1/Student Page/login.dart';
import 'package:flutter_project_1/Student Page/face_registration.dart';
import 'package:flutter_project_1/Student%20Page/Settings/account_information.dart';
import 'package:flutter_project_1/Student%20Page/Settings/change_password.dart';
import 'package:flutter_project_1/Student%20Page/archives.dart';
import 'package:flutter_project_1/Student%20Page/attendance/face_verification.dart';
import 'package:flutter_project_1/Student%20Page/attendance/face_verified.dart';
import 'package:flutter_project_1/Student%20Page/dashboard.dart';
import 'package:flutter_project_1/Student%20Page/Help/help.dart';
import 'package:flutter_project_1/Student%20Page/History/history.dart';
import 'package:flutter_project_1/Student%20Page/Settings/settings.dart';
import 'package:flutter_project_1/Student%20Page/forgot_password.dart';
import 'package:flutter_project_1/Student%20Page/new_password.dart';
import 'Student Page/Notification/notification_ui.dart';
import 'Student Page/auth_gate.dart';
import 'firebase_options.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // optional: debug
  // print('BG message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ background handler register
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationUI.initOnce();

  FirebaseMessaging.onMessage.listen((msg) async {
    // ✅ show banner even when app is open
    await NotificationUI.showFromMessage(msg);
  });

  await Supabase.initialize(
    url: 'https://ucfundmbawljngzowzgd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjZnVuZG1iYXdsam5nem93emdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc1OTY5NDQsImV4cCI6MjA4MzE3Mjk0NH0.rPcB5ZIHZ77hR2DzXHKwJp8nF-IJH-bmICzioCma5Bk',
  );

  runApp(const MyApp());
}

// optional shortcut access anywhere
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFEAF5FB),
      ),
      home: const AuthGate(), // ✅ ito na root
      routes: {
        '/login': (context) => Login(),
        '/face_registration': (context) => Face_Registration(),
        '/history': (context) => History(),
        '/settings': (context) => Settings(),
        '/help': (context) => Help(),
        '/mainshell': (context) => Mainshell(),
        '/account_information': (context) => AccountInformation(),
        '/change_password': (context) => ChangePassword(),
        '/forgot_password': (context) => ForgotPassword(),
        '/new_password': (context) => NewPassword(),
        '/terms_conditions': (context) => TermsAndConditionsPage(),
        '/twofa': (context) => const SizedBox.shrink(),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFFEAF5FB),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // To align the whole page in vertically centered
        children: [
          Container( // Logo
            margin: EdgeInsets.fromLTRB(0,screenHeight * .153,0,0),
            child: Image(
              width: screenWidth * 1,
              image: AssetImage('assets/logo.png')
            ),
          ),
          Text( // Subheader
            'Welcome to Attendly',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: screenHeight * .019,
            ),
          ),
          Container( // Subheader
            margin: EdgeInsetsGeometry.symmetric(vertical: screenHeight * .063, horizontal: 10),
            child: Text(
              'Secure, Fast, and Reliable class attendance monitoring with face verification and network-based authentication',
              textAlign: TextAlign.center,
              style: TextStyle( // Text Style
                fontSize: screenHeight * .021,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          OutlinedButton( // Get started button
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom( // Button style
              shape: RoundedRectangleBorder( // To achieved a round rectangle border radius
                borderRadius: BorderRadius.circular(50)
              ),
              padding: EdgeInsets.symmetric(vertical: screenHeight * .008, horizontal: 5), // Button padding
              backgroundColor: Color(0xFF004280), // Button BG color
            ),
            child: Row( // To arrange in row the widgets inside the button
              mainAxisSize: MainAxisSize.min, // To avoid full-width button
              children: [
                CircleAvatar( // Icon with circular border
                  radius: 15, // Circle size
                  backgroundColor: Colors.white,
                  child: Icon( // Icon
                    Icons.arrow_forward,
                    size: screenHeight * .021, // Icon size
                    color: Color(0xFF004280),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(screenHeight * .013,0,screenHeight * .018,0),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: screenHeight * .017
                    ),
                  ),
                )
              ],
            )
          ),
          Container( // Footer
            margin: EdgeInsets.fromLTRB(0, screenHeight * .153,0,0),
            child: Text(
              '© 2025 Attendly. All rights reserved.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: screenHeight * .017
              ),
            ),
          ),
        ],
      ),
    );
  }
}

