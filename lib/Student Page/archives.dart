import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final supabase = Supabase.instance.client;

  Future<void> _restoreClass({
    required ClassItem item,
    required int index,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // ✅ Update class_enrollments table instead of classes table
      await supabase
          .from('class_enrollments')
          .update({'archived': false})
          .eq('class_id', item.classId)
          .eq('student_id', userId);

      if (!mounted) return;

      // ✅ UI update
      setState(() {
        widget.archivedClasses.removeAt(index);
      });

      // ✅ send back to dashboard
      widget.onRestore(item);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to restore class: $e')),
      );
    }
  }

  Widget classCard(
      String classId,
      String course,
      String classCode,
      String professor,
      String room,
      String sched,
      double screenHeight,
      Future<void> Function() onRestore,
    ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * .015),
        padding: const EdgeInsets.all(12),
        width: screenWidth * .9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * .004),
                        Text(
                          classCode,
                          style: TextStyle(
                            fontSize: screenHeight * .014,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.more_vert_outlined, size: screenHeight * .023),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'restore',
                        child: Row(
                          children: [
                            Icon(Icons.restore, size: screenHeight * .021),
                            const SizedBox(width: 8),
                            Text('Restore', style: TextStyle(fontSize: screenHeight * .017)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'restore') {
                        final ok = await _confirmArchive();
                        if (ok) await onRestore();
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * .012),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(CupertinoIcons.person, professor, screenHeight),
                        SizedBox(height: screenHeight * .006),
                        _buildInfoRow(Icons.pin_drop_outlined, room, screenHeight),
                        SizedBox(height: screenHeight * .006),
                        _buildInfoRow(CupertinoIcons.clock, sched, screenHeight),
                      ],
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

  Widget _buildInfoRow(IconData icon, String text, double screenHeight) {
    return Row(
      children: [
        Icon(icon, size: screenHeight * .02),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: screenHeight * .014),
          ),
        ),
      ],
    );
  }

  Future<bool> _confirmArchive() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

          title: Text(
            'Restore this class?',
            style: TextStyle(fontSize: screenHeight * 0.019, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'This class will be moved back to the active classes.',
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
                child: const Text('Cancel'),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.039,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004280),
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
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FB),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              height: screenHeight * .13,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: const Color(0x30FFFFFF),
                    ),
                    child: Icon(
                      Icons.archive,
                      color: Colors.white,
                      size: screenHeight * .04,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Archives',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: screenHeight * .02,
                          ),
                        ),
                        SizedBox(height: screenHeight * .005),
                        Text(
                          'Manage archived classes',
                          style: TextStyle(
                            fontSize: screenHeight * .014,
                            color: Colors.white70,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(CupertinoIcons.arrow_left, size: screenHeight * .023,)
                  ),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: screenHeight * .017,
                      fontWeight: FontWeight.w500,
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
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                itemCount: widget.archivedClasses.length,
                itemBuilder: (context, index) {
                  final c = widget.archivedClasses[index];

                  return classCard(
                    c.classId,
                    c.course,
                    c.classCode,
                    c.professor,
                    c.room,
                    c.sched,
                    screenHeight,
                        () async {
                      await _restoreClass(item: c, index: index);
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
