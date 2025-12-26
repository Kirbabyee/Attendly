import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'navbar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0; // Set Home selected by default

  Widget textBold(tag, name) {
    return Text.rich(
      TextSpan(
        text: tag,
        style: TextStyle(fontSize: 14),
        children: [
          TextSpan(
            text: name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget classCard(String course, String classCode, String professor, String room,
      String sched, bool session) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
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
        style: const TextStyle(
          fontSize: 12,
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
                    Text(
                      course,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(classCode),
                  ],
                ),
                session
                    ? IconButton(
                  onPressed: () {},
                  icon: Icon(CupertinoIcons.right_chevron, size: 16),
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
                        Icon(CupertinoIcons.person, size: 20),
                        SizedBox(width: 5),
                        Text(professor),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.pin_drop_outlined, size: 20),
                        SizedBox(width: 5),
                        Text(room),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(CupertinoIcons.clock, size: 20),
                        SizedBox(width: 5),
                        Text(sched),
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
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
                  width: 120,
                  height: 20,
                  child: Text(
                    session ? 'Session Started' : 'Upcoming',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: session
                          ? Color(0xFF016224)
                          : Color(0x90004280),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 310,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(CupertinoIcons.line_horizontal_3,
                            color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(CupertinoIcons.square_arrow_right,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text('Welcome to Attendly',
                                style: TextStyle(color: Colors.white)),
                            Text(
                              'Alfred!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
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
                          onPressed: () {},
                          child: Text(
                            'Join a class',
                            style: TextStyle(color: Color(0xFFB09602)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/avatar.png', width: 80),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textBold('Name: ', 'Alfred Valiente'),
                            textBold('Student No.: ', '20231599'),
                            textBold('Year Level: ', 'Third Year'),
                            textBold('Section: ', 'A'),
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
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Classes',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(CupertinoIcons.archivebox),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  classCard(
                    'Introduction to Human Computer Interaction',
                    'CCS101',
                    'Mr. Leviticio Dowell',
                    'Room 301',
                    'Monday: 9:00 - 11:00 AM',
                    true,
                  ),
                  classCard(
                    'Introduction to Human Computer Interaction',
                    'CCS101',
                    'Mr. Leviticio Dowell',
                    'Room 301',
                    'Monday: 9:00 - 11:00 AM',
                    false,
                  ),
                  classCard(
                    'Introduction to Human Computer Interaction',
                    'CCS101',
                    'Mr. Leviticio Dowell',
                    'Room 301',
                    'Monday: 9:00 - 11:00 AM',
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ ADD THIS
      bottomNavigationBar: AttendlyNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}
