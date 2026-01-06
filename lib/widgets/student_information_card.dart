import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_1/Student%20Page/mainshell.dart';

import '../Student Page/dashboard.dart';

class AttendlyBlueHeader extends StatelessWidget {

  final bool onBack;

  final IconData icon;
  final Color iconColor;

  final String courseTitle;
  final String courseCode;
  final String professor;

  const AttendlyBlueHeader({
    super.key,
    required this.onBack,
    this.icon = CupertinoIcons.book,
    this.iconColor = const Color(0xFFFBD600),
    required this.courseTitle,
    required this.courseCode,
    required this.professor,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: onBack ? screenHeight * .23 : !onBack ? screenHeight * .21 : screenHeight * .16,
      decoration: const BoxDecoration(
        color: Color(0xFF004280),
        borderRadius: BorderRadius.vertical(
          top: Radius.zero,
          bottom: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(screenHeight * .013),
      child: Column(
        children: [
          onBack ? Container(
            padding: EdgeInsets.all(screenHeight * .013),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const Mainshell())
                    );
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: screenHeight * .023,
                  ),
                ),
                SizedBox(width: 10,),
                Text(
                  'Back',
                  style: TextStyle(color: Colors.white, fontSize: screenHeight * .017),
                )
              ],
            ),
          ) : SizedBox(height: onBack ? screenHeight * .033 : screenHeight * .013,),
          SizedBox(height: screenHeight * .013),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(screenHeight * .013),
                decoration: BoxDecoration(
                  color: const Color(0x30FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: screenHeight * .083, color: iconColor),
              ),
              SizedBox(width: 15),

              // Course details
              DefaultTextStyle(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * .017,
                  fontFamily: 'Montserrat',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * .65,
                      child: Text(
                        courseTitle,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: screenHeight * .017,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * .006),
                    Text(
                      courseCode,
                      style: TextStyle(
                        fontSize: screenHeight * .017
                      ),
                    ),
                    SizedBox(height: screenHeight * .023),
                    Text(
                      professor,
                      style: TextStyle(
                        fontSize: screenHeight * .016
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class StudentInfoCard extends StatelessWidget {
  final String name;
  final String studentNo;

  const StudentInfoCard({
    super.key,
    required this.name,
    required this.studentNo,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * .9,
      height: screenHeight * .13,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Student Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: screenHeight * .017
              ),
            ),
          ),
          SizedBox(height: screenHeight * .013),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Name:', style: TextStyle(fontSize: screenHeight * .015)),
                Flexible(
                  child: Text(
                    name,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: screenHeight * .015),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Student No.', style: TextStyle(fontSize: screenHeight * .015)),
                Text(studentNo, style: TextStyle(fontSize: screenHeight * .015)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
