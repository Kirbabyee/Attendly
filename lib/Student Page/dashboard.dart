import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_session.dart'; // adjust path kung iba

import 'archives.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class ClassItem {
  final String course;
  final String classCode;
  final String professor;
  final String room;
  final String sched;
  final bool session;

  ClassItem({
    required this.course,
    required this.classCode,
    required this.professor,
    required this.room,
    required this.sched,
    required this.session,
  });
}


class _DashboardState extends State<Dashboard> {

  final supabase = Supabase.instance.client;

  Map<String, dynamic>? _student;
  bool _loadingStudent = true;
  String? _studentError;

  Future<void> _loadStudent({bool force = false}) async {
    setState(() {
      _studentError = null;
      if (_student == null) _loadingStudent = true; // spinner only on first load
    });

    try {
      final s = await StudentSession.get();
      if (!mounted) return;
      setState(() {
        _student = s;
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

  Widget _studentCard(double screenHeight, double screenWidth) {
    if (_loadingStudent) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_studentError != null) {
      return Text(
        'Error: $_studentError',
        style: TextStyle(fontSize: screenHeight * .013, color: Colors.red),
      );
    }

    if (_student == null) {
      return Text(
        'No student record found',
        style: TextStyle(
          fontSize: screenHeight * .013
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textBold('Name: ', '${_student?['first_name']  ?? '-'} ${_student?['last_name']  ?? '-'}', screenHeight),
        textBold('Student No.: ', '${_student?['student_number'] ?? '-'}', screenHeight),
        textBold(
        'Year Level: ',
        _student?['year_level'] == 1
        ? 'First Year'
            : _student?['year_level'] == 2
        ? 'Second Year'
            : _student?['year_level'] == 3
        ? 'Third Year'
            : _student?['year_level'] == 4
        ? 'Fourth Year'
            : '-',
        screenHeight,
        ),
    textBold('Section: ', '${_student?['section'] ?? '-'}', screenHeight),
      ],
    );
  }

  final List<ClassItem> _classes = [
    ClassItem(
      course: 'Introduction to Human Computer Interaction',
      classCode: 'CCS101',
      professor: 'Mr. Leviticio Dowell',
      room: 'Room 301',
      sched: 'Monday: 9:00 - 11:00 AM',
      session: true,
    ),
    ClassItem(
      course: 'Information Assurance and Security 2',
      classCode: 'IT 108',
      professor: 'Mrs. Mary Grace R. Pelagio',
      room: 'CSD COMLAB 1-N',
      sched: 'Thursday: 4:30 - 7:30 PM',
      session: false,
    ),
    ClassItem(
      course: 'Software Engineering 1',
      classCode: 'IT 10',
      professor: 'Mr. Jayson P. Joble',
      room: 'Room 405-N',
      sched: 'Wednesday: 2:00 - 5:00 PM',
      session: false,
    ),
  ];

  final List<ClassItem> _archivedClasses = [];

  void _sortClasses() {
    _classes.sort((a, b) {
      if (a.session == b.session) return 0;
      return a.session ? -1 : 1;
    });
  }

  @override
  void initState() {
    super.initState();
    _sortClasses();
    _loadStudent();
  }

  Widget textBold(tag, name, double screenHeight) {
    return Text.rich(
      TextSpan(
        text: tag,
        style: TextStyle(fontSize: screenHeight * .015),
        children: [
          TextSpan(
            text: name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenHeight * .015),
          ),
        ],
      ),
    );
  }

  // Classcard Template
  Widget classCard(
      String course,
      String classCode,
      String professor,
      String room,
      String sched,
      bool session,
      double screenHeight,
      VoidCallback onArchive,
      ) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // ✅ bool logic
    final isUpcoming = !session; // false = upcoming

    return Opacity(
      opacity: isUpcoming ? 0.5 : 1.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * .02),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: session ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: screenHeight * .013,
            color: Colors.black,
            fontFamily: 'Montserrat',
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenWidth * .67,
                        child: Text(course, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 5),
                      Text(classCode),
                      const SizedBox(height: 10),
                    ],
                  ),

                  // only allow open if session started
                  session
                      ? IconButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/face_verification');
                      _loadStudent(force: true);
                    },
                    icon: Icon(CupertinoIcons.right_chevron, size: screenHeight * .016),
                  )
                      : const SizedBox(),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.person, size: screenHeight * .02),
                          const SizedBox(width: 5),
                          SizedBox(
                            width: screenWidth * .4,
                            child: Text(professor, softWrap: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.pin_drop_outlined, size: screenHeight * .02),
                          const SizedBox(width: 5),
                          Text(room),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(CupertinoIcons.clock, size: screenHeight * .02),
                          const SizedBox(width: 5),
                          SizedBox(
                            width: screenWidth * .40,
                            child: Text(sched),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.fromLTRB(screenWidth * .011, 0, 0, 10),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75),
                      border: Border.all(
                        color: session ? const Color(0xFFBBE6CB) : const Color(0x90A9CBF9),
                      ),
                      color: session ? const Color(0xFFDBFCE7) : const Color(0x90DBEAFE),
                    ),
                    width: screenWidth * .25,
                    height: screenHeight * .025,
                    child: Text(
                      session ? 'Session Started' : 'Upcoming',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenHeight * .012,
                        color: session ? const Color(0xFF016224) : const Color(0x90004280),
                      ),
                    ),
                  ),

                  PopupMenuButton<String>(
                    color: Colors.white,
                    icon: Icon(Icons.more_vert_outlined, size: screenHeight * .023),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    itemBuilder: (_) => [
                      PopupMenuItem<String>(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(Icons.archive_outlined, size: screenHeight * .021),
                            SizedBox(width: screenHeight * .011),
                            Text('Archive', style: TextStyle(fontSize: screenHeight * .017)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'archive') {
                        final ok = await _confirmArchive();
                        if (ok) onArchive();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showJoinClassDialog() {
    final TextEditingController classCodeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Enter Class Code',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold
            ),
          ),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 280,
              child: TextFormField(
                controller: classCodeController,
                decoration: InputDecoration(
                  hintText: 'Classcode',
                  hintStyle: TextStyle(
                    fontSize: 12,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0x50000000),
                      width: 1
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide:
                    const BorderSide(color: Colors.black, width: .8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Class code is required';
                  }
                  return null;
                },
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);

                }
              },
              icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
              label: const Text(
                'Join Class',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmArchive() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final w = MediaQuery.of(context).size.width;

        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24), // smaller dialog width
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8), // tighter inside
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

          title: const Text(
            'Archive this class?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'This class will be moved to archive.',
            style: TextStyle(fontSize: 13),
          ),

          actionsAlignment: MainAxisAlignment.end,
          actions: [
            SizedBox(
              height: 36,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
            ),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Archive', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: screenHeight * .29,
              decoration: BoxDecoration(
                color: Color(0xFF004280),
                borderRadius: BorderRadius.vertical(
                  top: Radius.zero,
                  bottom: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome to Attendly',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight * .016
                              )
                            ),
                            Text(
                              '${_student?['first_name'] ?? '-'}!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenHeight * .025,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(100, 30),
                            backgroundColor: Color(0xFFFFF8D2),
                            side: BorderSide(color: Color(0xFFE6C402)),
                          ),
                          onPressed: () {
                            _showJoinClassDialog();
                          },
                          child: Text(
                            'Join a class',
                            style: TextStyle(
                              color: Color(0xFFB09602),
                              fontSize: screenHeight * .016
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight > 700 ? 20 : 12),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.all(screenHeight * .022),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/avatar.png', width: screenWidth * .18),
                        SizedBox(width: screenWidth * .035),
                        _studentCard(screenHeight, screenWidth),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * .05),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Classes',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: screenHeight * .017),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Archives(
                                archivedClasses: _archivedClasses,
                                onRestore: (item) {
                                  setState(() {
                                    _classes.add(item);
                                    _sortClasses();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          CupertinoIcons.archivebox,
                          size: screenHeight * .025,
                        ),
                      ),
                    ],
                  ),
                  ..._classes.asMap().entries.map((entry) {
                    final i = entry.key;
                    final c = entry.value;

                    return classCard(
                      c.course,
                      c.classCode,
                      c.professor,
                      c.room,
                      c.sched,
                      c.session,
                      screenHeight,
                        () {
                          setState(() {
                            _archivedClasses.add(_classes[i]);
                            _classes.removeAt(i);
                            _sortClasses();
                          });
                        },
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
