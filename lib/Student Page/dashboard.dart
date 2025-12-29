import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();

}

class _DashboardState extends State<Dashboard> {
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
  Widget classCard(String course, String classCode, String professor, String room,
      String sched, bool session, double screenHeight) {
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
                    Text(
                      course,
                      style: TextStyle(fontWeight: FontWeight.w500),
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
                        Text(professor),
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
                  width: screenHeight > 700 ? 120 : 100,
                  height: 20,
                  child: Text(
                    session ? 'Session Started' : 'Upcoming',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenHeight > 700 ? 11 : 10,
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
    final screenHeight = MediaQuery.of(context).size.height;
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
                          onPressed: () {},
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
                        onPressed: () {},
                        icon: Icon(
                          CupertinoIcons.archivebox,
                          size: screenHeight > 700 ? 25 : 20,
                        ),
                      ),
                    ],
                  ),
                  classCard(
                    'Introduction to Human Computer Interaction',
                    'CCS101',
                    'Mr. Leviticio Dowell',
                    'Room 301',
                    'Monday: 9:00 - 11:00 AM',
                    true,
                    screenHeight
                  ),
                  classCard(
                    'Introduction to Human Computer Interaction',
                    'CCS101',
                    'Mr. Leviticio Dowell',
                    'Room 301',
                    'Monday: 9:00 - 11:00 AM',
                    false,
                    screenHeight
                  ),
                  classCard(
                    'Introduction to Human Computer Interaction',
                    'CCS101',
                    'Mr. Leviticio Dowell',
                    'Room 301',
                    'Monday: 9:00 - 11:00 AM',
                    false,
                    screenHeight
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
