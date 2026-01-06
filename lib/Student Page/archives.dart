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
    return Container(
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
    );
  }

  Future<bool> _confirmArchive() async { // Archive confirmation modal
<<<<<<< HEAD
    final screenHeight = MediaQuery.of(context).size.height;
=======
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
<<<<<<< HEAD
          title: Text('Restore this class?', style: TextStyle(fontSize: screenHeight * .025),),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('No', style: TextStyle(fontSize: screenHeight * .017, color: Colors.black),),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: screenHeight * .017
                ),
=======
          title: const Text('Restore this class?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.red),
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
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
