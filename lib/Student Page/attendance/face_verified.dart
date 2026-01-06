import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_1/Student%20Page/mainshell.dart';

import '../../widgets/student_information_card.dart';
import '../dashboard.dart';

class Face_Verified extends StatefulWidget {
  const Face_Verified({super.key});

  @override
  State<Face_Verified> createState() => _Face_VerifiedState();
}

class _Face_VerifiedState extends State<Face_Verified> {
  void _showAttendanceSubmittedModal() {
    final screenHeight = MediaQuery.of(context).size.height;
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const Mainshell())
        );
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const Mainshell())
            );
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: screenHeight * .08,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Attendance Submitted',
                  style: TextStyle(
                    fontSize: screenHeight * .017,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'You\'ve been mark present for CS101',
                  style: TextStyle(
                    fontSize: screenHeight * .015,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    print(screenHeight);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AttendlyBlueHeader(
                  onBack: false,
                  courseTitle: 'Introduction to Human Computer Interaction',
                  courseCode: 'CCS101',
                  professor: 'Mr. Leviticio Dowell',
                  icon: CupertinoIcons.book,
                  iconColor: const Color(0xFFFBD600),
                ),
                SizedBox(height: screenHeight * .023),
                const StudentInfoCard(
                  name: 'Alfred S. Valiente',
                  studentNo: '20231599',
                ),
                SizedBox(height: screenHeight * .033),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(15),
              width: screenWidth * .9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Face Verification',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenHeight * .018,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenHeight * .011),
                  // Grey camera box
                  Center(
                    child: Container(
                      width: screenWidth * .9,
                      height: screenHeight * .28,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1),
                        color: const Color(0xFF9BC9F5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.check_mark_circled,
                            color: Colors.green,
                            size: screenHeight * .13,
                          ),
                          Text(
                            'Face Verified Successfully',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * .015,

                            ),
                          ),
                          Text(
                            'You can now submit your attendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenHeight * .014
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * .01),
                  Center(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF043B6F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        // Loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        await Future.delayed(const Duration(seconds: 0)); // simulate API

                        if (!mounted) return;
                        Navigator.of(context).pop(); // close loading

                        _showAttendanceSubmittedModal(); // show success
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: screenHeight * .021,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Submit Attendance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * .017
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
