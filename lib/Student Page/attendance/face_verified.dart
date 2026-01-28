import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_1/Student%20Page/mainshell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/student_information_card.dart';
import '../dashboard.dart';
import '../student_session.dart';

class Face_Verified extends StatefulWidget {
  final String classSessionId;

  // pang header display
  final String courseTitle;
  final String courseCode;
  final String professor;

  const Face_Verified({
    super.key,
    required this.classSessionId,
    required this.courseTitle,
    required this.courseCode,
    required this.professor,
  });

  @override
  State<Face_Verified> createState() => _Face_VerifiedState();
}

class _Face_VerifiedState extends State<Face_Verified> {
  Future<void> _submitAttendance() async {
    final supabase = Supabase.instance.client;

    final s = await StudentSession.get(); // cached student profile
    final studentId = s?['id'] as String?;
    if (studentId == null) throw 'Student not found';

    // ✅ get session started_at
    final session = await supabase
        .from('class_sessions')
        .select('started_at')
        .eq('id', widget.classSessionId)
        .maybeSingle();

    final startedAtStr = session?['started_at'] as String?;
    if (startedAtStr == null) throw 'Session start time not found';

    final startedAt = DateTime.parse(startedAtStr).toLocal();
    final nowUtc = DateTime.now().toLocal();

    final diffMins = nowUtc.difference(startedAt).inMinutes;
    final status = diffMins <= 15 ? 'present' : 'late';

    print('startedAt: $startedAt | isUtc: ${startedAt.isUtc}');
    print('now: $nowUtc | isUtc: ${nowUtc.isUtc}');
    print(diffMins);
    print(status);

    await supabase.from('attendance').upsert({
      'session_id': widget.classSessionId,
      'student_id': studentId,
      'status': status, // ✅ present OR late
      'time_in': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'session_id,student_id');
  }

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
                  'Attendance submitted for ${widget.courseTitle}',
                  textAlign: TextAlign.center,
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
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    try {
      final s = await StudentSession.get(); // cached
      if (!mounted) return;
      setState(() {
        _student = s;
        _loadingStudent = false;
        _studentError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _studentError = e.toString();
        _loadingStudent = false;
      });
    }
  }

  Map<String, dynamic>? _student;
  bool _loadingStudent = true;
  String? _studentError;

  Widget _buildStudentInfoCard() {
    if (_loadingStudent) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_studentError != null) {
      return Text('Error: $_studentError');
    }

    final firstName = _student?['first_name']?.toString().trim();
    final middleName = _student?['middle_name']?.toString().trim();
    final lastName = _student?['last_name']?.toString().trim();

    final middleInitial =
    (middleName != null && middleName.isNotEmpty)
        ? '${middleName[0].toUpperCase()}.'
        : null;

    final name = [
      firstName,
      middleInitial,
      lastName,
    ].where((e) => e != null && e!.isNotEmpty).join(' ');

    final studentNo = '${_student?['student_number'] ?? '-'}';

    return StudentInfoCard(
      name: name.isEmpty ? '-' : name,
      studentNo: studentNo,
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
                  courseTitle: widget.courseTitle,
                  courseCode: widget.courseCode,
                  professor: widget.professor,
                  icon: CupertinoIcons.book,
                  iconColor: const Color(0xFFFBD600),
                ),
                SizedBox(height: screenHeight * .023),
                _buildStudentInfoCard(),
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

                        try {
                          await _submitAttendance(); // ✅ DITO INSERT/UPSERT
                          if (!mounted) return;
                          Navigator.of(context).pop(); // close loading

                          _showAttendanceSubmittedModal(); // show success
                        } catch (e) {
                          if (!mounted) return;
                          Navigator.of(context).pop(); // close loading

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to submit attendance: $e')),
                          );
                        }
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
