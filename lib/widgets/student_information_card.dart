import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Student Page/dashboard.dart';

class AttendlyBlueHeader extends StatelessWidget {
  final bool onBack;

  final IconData icon;
  final Color iconColor;

  final String courseTitle;
  final String courseCode;
  final String professor;

  final double height;

  const AttendlyBlueHeader({
    super.key,
    required this.onBack,
    this.icon = CupertinoIcons.book,
    this.iconColor = const Color(0xFFFBD600),
    required this.courseTitle,
    required this.courseCode,
    required this.professor,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF004280),
        borderRadius: BorderRadius.vertical(
          top: Radius.zero,
          bottom: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          onBack ? Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const Dashboard())
                  );
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white
                ),
              ),
              Text(
                'Back',
                style: const TextStyle(color: Colors.white),
              )
            ],
          ) : SizedBox(height: 30,),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0x30FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 80, color: iconColor),
              ),
              const SizedBox(width: 15),

              // Course details
              DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Text(
                        courseTitle,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(courseCode),
                    const SizedBox(height: 20),
                    Text(professor),
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

  final double width;
  final double height;

  const StudentInfoCard({
    super.key,
    required this.name,
    required this.studentNo,
    this.width = 350,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
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
            child: const Text(
              'Student Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Name:', style: TextStyle(fontSize: 12)),
                Flexible(
                  child: Text(
                    name,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12),
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
                const Text('Student No.', style: TextStyle(fontSize: 12)),
                Text(studentNo, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
