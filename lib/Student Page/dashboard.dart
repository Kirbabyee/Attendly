import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  }

  Widget textBold(tag, name, double screenHeight) {
    return Text.rich(
      TextSpan(
        text: tag,
        style: TextStyle(fontSize: screenHeight > 700 ? 14 : 13),
        children: [
          TextSpan(
            text: name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenHeight > 700 ? 14 : 13),
          ),
        ],
      ),
    );
  }

  // Classcard Template
  Widget classCard(String course,
      String classCode,
      String professor,
      String room,
      String sched,
      bool session,
      double screenHeight,
      VoidCallback onArchive,
    ) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight > 700 ? 20 : 12),
      padding: EdgeInsets.all(10),
      width: 350,
      decoration: BoxDecoration(
        color: session ? Colors.white : Colors.grey[300],
        borderRadius: BorderRadiusGeometry.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: screenHeight > 700 ? 12 : 11,
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
                    Container(
                      width: 280,
                      child: Text(
                        course,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text(classCode),
                    SizedBox(height: 10,),
                  ],
                ),
                session
                    ? IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/face_verification');
                  },
                  icon: Icon(CupertinoIcons.right_chevron, size: screenHeight > 700 ? 16 : 14),
                )
                    : SizedBox(),
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
                        Icon(CupertinoIcons.person, size: screenHeight > 700 ? 20 : 18),
                        SizedBox(width: 5),
                        Container(width: 145,child: Text(professor,softWrap: true,)),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.pin_drop_outlined, size: screenHeight > 700 ? 20 : 18),
                        SizedBox(width: 5),
                        Text(room),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(CupertinoIcons.clock, size: screenHeight > 700 ? 20 : 18),
                        SizedBox(width: 5),
                        Container(width: 140,child: Text(sched)),
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(screenWidth > 400 ? 37 : screenWidth < 370 ? 9 : 10, 0, 0, screenWidth < 370 ? 3 : 10),
                  padding: EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusGeometry.circular(75),
                    border: Border.all(
                      color: session
                          ? Color(0xFFBBE6CB)
                          : Color(0x90A9CBF9),
                    ),
                    color:
                    session ? Color(0xFFDBFCE7) : Color(0x90DBEAFE),
                  ),
                  width: screenHeight > 700 ? 100 : 100,
                  height: screenWidth < 370 ? 18 : 20,
                  child: Text(
                    session ? 'Session Started' : 'Upcoming',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenHeight > 700 ? 11 : screenWidth < 370 ? 9 : 10,
                      color: session
                          ? Color(0xFF016224)
                          : Color(0x90004280),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  color: Colors.white,
                  icon: const Icon(Icons.more_vert_outlined),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'archive',
                      child: Row(
                        children: [
                          Icon(Icons.archive_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Archive'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'archive') {
                      onArchive();
                    }
                  },
                ),
              ],
            )
          ],
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


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    print(screenWidth);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: screenHeight > 700 ? 250 : 230,
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
                                fontSize: screenHeight > 700 ? 14 : 12
                              )
                            ),
                            Text(
                              'Alfred!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenHeight > 700 ? 30 : 25,
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
                              fontSize: screenHeight > 700 ? 14 : 12
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight > 700 ? 20 : 12),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/avatar.png', width: screenHeight > 700 ? 80 : 75),
                        SizedBox(width: screenHeight > 700 ? 20 : 25),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textBold('Name: ', 'Alfred Valiente', screenHeight),
                            textBold('Student No.: ', '20231599', screenHeight),
                            textBold('Year Level: ', 'Third Year', screenHeight),
                            textBold('Section: ', 'A', screenHeight),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: screenHeight > 700 ? 20 : 15),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Classes',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: screenHeight > 700 ? 16 : 14),
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
                          size: screenHeight > 700 ? 25 : 20,
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
