
import 'package:flutter/material.dart';
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

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'Montserrat',
      scaffoldBackgroundColor: const Color(0xFFEAF5FB),
    ),
    initialRoute: '/home',
    routes: { // Pages routing
      '/home': (context) => LandingPage(),
      '/login': (context) => Login(),
      '/dashboard' : (context) => Dashboard(),
      '/face_registration': (context) => Face_Registration(),
      '/face_verification': (context) => Face_Verification(),
      '/history': (context) => History(),
      '/settings': (context) => Settings(),
      '/help': (context) => Help(),
      '/face_verified': (context) => Face_Verified(),
      '/account_information': (context) => AccountInformation(),
      '/change_password': (context) => ChangePassword(),
    },
  )); // MaterialApp
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFEAF5FB),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // To align the whole page in vertically centered
        children: [
          Container( // Logo
            margin: EdgeInsets.fromLTRB(0,screenHeight > 700 ? 150 : 80,0,0),
            child: Image(
              width: screenHeight > 700 ? 400 : 350,
              image: AssetImage('assets/logo.png')
            ),
          ),
          Text( // Subheader
            'Welcome to Attendly',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: screenHeight > 700 ? 16 : 14,
            ),
          ),
          Container( // Subheader
            margin: EdgeInsetsGeometry.symmetric(vertical: screenHeight > 700 ? 60 : 50),
            child: Text(
              'Secure, Fast, and Reliable class attendance monitoring with face verification and network-based authentication',
              textAlign: TextAlign.center,
              style: TextStyle( // Text Style
                fontSize: screenHeight > 700 ? 18 : 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          OutlinedButton( // Get started button
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const Login()),
              );
            },
            style: ElevatedButton.styleFrom( // Button style
              shape: RoundedRectangleBorder( // To achieved a round rectangle border radius
                borderRadius: BorderRadius.circular(50)
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5), // Button padding
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
                    size: 18, // Icon size
                    color: Color(0xFF004280),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10,0,15,0),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                )
              ],
            )
          ),
          Container( // Footer
            margin: EdgeInsets.fromLTRB(0, screenHeight > 700 ? 150 : 90,0,0),
            child: Text(
              '© 2025 Attendly. All rights reserved.',
              style: TextStyle(
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

