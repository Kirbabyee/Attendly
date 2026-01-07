import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dashboard.dart';

class Archives extends StatefulWidget {
  final List<ClassItem> archivedClasses;
  final void Function(ClassItem item) onRestore;

  const Archives({
    super.key,
    required this.archivedClasses,
    required this.onRestore,
  });

  @override
  State<Archives> createState() => _ArchivesState();
}

class _ArchivesState extends State<Archives> {

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
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * .023),
        padding: EdgeInsets.all(10),
        width: screenWidth * .9,
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
            fontSize: screenHeight * .015,
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
                        width: screenWidth * .7,
                        child: Text(
                          course,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: screenHeight * .008,),
                      Text(classCode, style: TextStyle(fontSize: screenHeight * .015),),
                      SizedBox(height: screenHeight * .013,),
                    ],
                  ),
                  PopupMenuButton<String>(
                    color: Colors.white,
                    icon: Icon(Icons.more_vert_outlined, size: screenHeight * .023,),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'restore',
                        child: Row(
                          children: [
                            Icon(Icons.restore, size: screenHeight * .021),
                            SizedBox(width: 8),
                            Text('Restore', style: TextStyle(fontSize: screenHeight * .017),),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'restore') {
                        final ok = await _confirmArchive();
                        if (ok) onArchive();
                      }
                    },
                  ),
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
                          Icon(CupertinoIcons.person, size: screenHeight * .023),
                          SizedBox(width: 5),
                          Text(professor),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.pin_drop_outlined, size: screenHeight * .023),
                          SizedBox(width: 5),
                          Text(room),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(CupertinoIcons.clock, size: screenHeight * .023),
                          SizedBox(width: 5),
                          Text(sched),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(screenWidth * .1, 0, 0, screenWidth < 370 ? 3 : 5),
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
                    width: screenWidth * .28,
                    height: screenHeight * .028,
                    child: Text(
                      session ? 'Session Started' : 'Upcoming',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenHeight * .014,
                        color: session
                            ? Color(0xFF016224)
                            : Color(0x90004280),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmArchive() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final w = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24), // smaller dialog width
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8), // tighter inside
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

          title: Text(
            'Restore this class?',
            style: TextStyle(fontSize: screenHeight * 0.019, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'This class will be moved back to the classes.',
            style: TextStyle(fontSize: screenHeight * 0.016),
          ),

          actionsAlignment: MainAxisAlignment.end,
          actions: [
            SizedBox(
              height: screenHeight * 0.039,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.015),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.039,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF004280),
                  padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.015),
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Restore', style: TextStyle(color: Colors.white)),
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
            // HEADER
            Container(
              height: screenHeight * .13,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Color(0xFF004280),
                borderRadius: BorderRadius.vertical(
                  top: Radius.zero,
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusGeometry.circular(7),
                      color: Color(0x30FFFFFF),
                    ),
                    child: Icon(
                      Icons.archive,
                      color: Colors.white,
                      size: screenHeight * .053,
                    ),
                  ),
                  SizedBox(width: 15),
                  Container(
                    height: screenHeight * .06,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Archives',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: screenHeight * .018,
                          ),
                        ),
                        SizedBox(height: screenHeight * .013),
                        Text(
                          'Manage archived classes',
                          style: TextStyle(
                            fontSize: screenHeight * .014,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(CupertinoIcons.arrow_left, size: screenHeight * .023,)
                  ),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: screenHeight * .017
                    ),
                  ),
                ],
              ),
            ),
            // Classlist
            Expanded(
              child: widget.archivedClasses.isEmpty
                  ? const Center(child: Text('No archived classes yet.'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: widget.archivedClasses.length,
                itemBuilder: (context, index) {
                  final c = widget.archivedClasses[index];

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
                        widget.archivedClasses.removeAt(index); // remove from archive UI
                      });

                      widget.onRestore(c); // send back to Dashboard classes
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
