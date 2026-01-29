import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'attendance/face_verification.dart';
import 'student_session.dart'; // adjust path kung iba

import 'archives.dart';

class Dashboard extends StatefulWidget {
  final bool unRead;
  final VoidCallback onOpenNotifications;

  const Dashboard({
    super.key,
    required this.unRead,
    required this.onOpenNotifications,
  });
  @override
  State<Dashboard> createState() => _DashboardState();
}

class ClassItem {
  final String classId;
  final String course;
  final String courseCode;
  final String classCode;
  final String professor;
  final String room;
  final String sched;
  final String session;

  ClassItem({
    required this.classId,
    required this.course,
    required this.courseCode,
    required this.classCode,
    required this.professor,
    required this.room,
    required this.sched,
    required this.session,
  });
}

class _DashboardState extends State<Dashboard> {
  bool _loadingClasses = false;
  String? _classesError;

  Future<String?> _getActiveSessionId(String classId) async {
    final row = await supabase
        .from('class_sessions')
        .select('id')
        .eq('class_id', classId)
        .eq('status', 'started')
        .order('started_at', ascending: false)
        .maybeSingle();

    return row?['id'] as String?;
  }

  Future<void> _loadMyClasses() async {
    final studentId = _student?['id'] as String?;
    if (studentId == null) return;

    if (!mounted) return;
    setState(() {
      _loadingClasses = true;
      _classesError = null;
    });

    try {
      // 1) get enrollments (class_id list)
      final enrollRows = await supabase
          .from('class_enrollments')
          .select('class_id')
          .eq('student_id', studentId);

      final classIds = (enrollRows as List)
          .map((r) => (r as Map<String, dynamic>)['class_id'] as String)
          .toList();

      if (classIds.isEmpty) {
        if (!mounted) return;
        setState(() {
          _classes.clear();
        });
        return;
      }

      // 2) get classes
      final classRows = await supabase
          .from('classes')
          .select('id, course, course_code, class_code, room, schedule, professor_id')
          .inFilter('id', classIds)
          .eq('archived', false);

      // 2.5) get latest session status per class (started/ended)
      final sessionRows = await supabase
          .from('class_sessions')
          .select('class_id, status, started_at, ended_at')
          .inFilter('class_id', classIds)
          .inFilter('status', ['started', 'ended', 'system ended'])
          .order('started_at', ascending: false);

      final sessionMap = <String, Map<String, dynamic>>{};
      for (final r in (sessionRows as List)) {
        final m = r as Map<String, dynamic>;
        final classId = m['class_id'] as String;

        // since ordered desc, first time we see classId = latest
        sessionMap.putIfAbsent(classId, () => m);
      }

      // 3) get professor names (batch)
      final profIds = (classRows as List)
          .map((r) => (r as Map<String, dynamic>)['professor_id'])
          .where((x) => x != null)
          .cast<String>()
          .toSet()
          .toList();

      Map<String, String> profMap = {};
      if (profIds.isNotEmpty) {
        final profRows = await supabase
            .from('professors')
            .select('id, professor_name')
            .inFilter('id', profIds);

        profMap = {
          for (final p in (profRows as List))
            (p as Map<String, dynamic>)['id'] as String:
            (p['professor_name'] as String?) ?? 'Professor'
        };
      }

      final list = (classRows as List).map((r) {
        final m = r as Map<String, dynamic>;
        final classId = m['id'] as String;
        final sched = (m['schedule'] ?? '') as String;

        String sessionText;

        final sRow = sessionMap[classId]; // Map<String,dynamic>?
        final status = (sRow?['status'] as String?)?.toLowerCase() ?? '';

        if (status == 'started') {
          sessionText = 'Session Started';
        } else if (status == 'ended' || status == 'system ended') {
          sessionText = 'Ended';
        } else {
          sessionText = _sessionFromSched(sched);
        }

        final profId = m['professor_id'] as String?;
        final profName = profId == null ? 'Professor' : (profMap[profId] ?? 'Professor');

        return ClassItem(
          classId: classId,
          course: (m['course'] ?? '-') as String,
          courseCode: (m['course_code'] ?? '-') as String,
          classCode: (m['class_code'] ?? '-') as String,
          professor: profName,
          room: (m['room'] ?? '-') as String,
          sched: sched,
          session: sessionText,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _classes
          ..clear()
          ..addAll(list);
        _sortClasses();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _classesError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingClasses = false;
      });
    }
  }

  Future<String> _joinClassByCode(String code) async {
    final authUid = supabase.auth.currentUser?.id;
    if (authUid == null) throw 'Not logged in';

    final studentId = _student?['id'] as String?;
    if (studentId == null) throw 'Student record not found';

    final cleanCode = code.trim();

    // 1) get class row (include professor_id + course_code)
    final classRow = await supabase
        .from('classes')
        .select('id, course, course_code, room, schedule, class_code, archived, professor_id')
        .eq('class_code', cleanCode)
        .maybeSingle();

    if (classRow == null) throw 'Invalid class code';
    if (classRow['archived'] == true) throw 'This class is archived';

    final classId = classRow['id'] as String;

    // 2) already enrolled?
    final existing = await supabase
        .from('class_enrollments')
        .select('id')
        .eq('class_id', classId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (existing != null) throw 'You are already enrolled in this class';

    // 3) insert enrollment
    await supabase.from('class_enrollments').insert({
      'class_id': classId,
      'student_id': studentId,
      'joined_at': DateTime.now().toIso8601String(),
    });

    // 4) fetch professor name separately (since no FK relationship)
    String profName = 'Professor';
    final profId = classRow['professor_id'] as String?;
    if (profId != null) {
      final profRow = await supabase
          .from('professors')
          .select('professor_name')
          .eq('id', profId)
          .maybeSingle();

      profName = (profRow?['professor_name'] as String?) ?? 'Professor';
    }

    final sched = (classRow['schedule'] ?? '') as String;
    final sessionText = _sessionFromSched(sched);

    // 5) update UI (local add)
    final course = (classRow['course'] ?? 'Class').toString();
    await _loadMyClasses();
    return course;
  }

  String? _avatarUrl;

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
        _avatarUrl = s?['avatar_url'] as String?;
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

  final List<ClassItem> _classes = [];

  final List<ClassItem> _archivedClasses = [];

  Future<void> _refresh() async {
    await _loadStudent(force: true);
    await _loadMyClasses();
  }

  void _sortClasses() {
    const sessionPriority = {
      'Session Started': 0,
      'Pending': 1,
      'Upcoming': 2,
      'Ended': 3,
    };

    _classes.sort((a, b) {
      final aP = sessionPriority[a.session] ?? 99;
      final bP = sessionPriority[b.session] ?? 99;
      final bySession = aP.compareTo(bP);
      if (bySession != 0) return bySession;

      final aDay = _daysUntilFromSched(a.sched);
      final bDay = _daysUntilFromSched(b.sched);
      final byDay = aDay.compareTo(bDay);
      if (byDay != 0) return byDay;

      final aStart = _startMinutesFromSched(a.sched);
      final bStart = _startMinutesFromSched(b.sched);
      return aStart.compareTo(bStart);
    });
  }

  int _daysUntilFromSched(String sched) {
    final dayStr = sched.split(':').first.trim().toLowerCase();

    const map = {
      'sunday': DateTime.sunday,
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
    };

    final target = map[dayStr];
    if (target == null) return 999;

    final today = DateTime.now().weekday; // monday=1..sunday=7
    return (target - today + 7) % 7; // 0..6
  }

  int _startMinutesFromSched(String sched) {
    final parts = sched.split(':');
    if (parts.length < 2) return 9999;

    final timePart = parts.sublist(1).join(':').trim();
    final range = timePart.split(RegExp(r'\s*[-–]\s*'));
    if (range.length < 2) return 9999;

    return _toMinutes(range.first.trim());
  }

  int _endMinutesFromSched(String sched) {
    final parts = sched.split(':');
    if (parts.length < 2) return 9999;

    final timePart = parts.sublist(1).join(':').trim();
    final range = timePart.split(RegExp(r'\s*[-–]\s*'));
    if (range.length < 2) return 9999;

    return _toMinutes(range.last.trim());
  }

  int _toMinutes(String time) {
    final reg = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false);
    final m = reg.firstMatch(time.trim());
    if (m == null) return 9999;

    int hour = int.parse(m.group(1)!);
    final minute = int.parse(m.group(2)!);
    final ampm = m.group(3)!.toUpperCase();

    if (ampm == 'AM') {
      if (hour == 12) hour = 0;
    } else {
      if (hour != 12) hour += 12;
    }

    return hour * 60 + minute;
  }

  String _sessionFromSched(String sched) {
    final now = DateTime.now();
    final dayStr = sched.split(':').first.trim().toLowerCase();

    final startMin = _startMinutesFromSched(sched);
    final endMinRaw = _endMinutesFromSched(sched);
    final nowMin = now.hour * 60 + now.minute;

    if (startMin == 9999 || endMinRaw == 9999) return 'Upcoming';

    const map = {
      'sunday': DateTime.sunday,
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
    };

    final schedWeekday = map[dayStr];
    if (schedWeekday == null) return 'Upcoming';

    int prevDay(int d) => d == DateTime.monday ? DateTime.sunday : d - 1;
    int nextDay(int d) => d == DateTime.sunday ? DateTime.monday : d + 1;

    // overnight (ex: 11:30 PM - 12:59 AM)
    final overnight = endMinRaw <= startMin;
    final endMin = overnight ? endMinRaw + 1440 : endMinRaw;

    // pending window = 2 hours before start
    final pendingWindowStart = startMin - 120;

    int? nowAdj;

    if (now.weekday == schedWeekday) {
      nowAdj = nowMin;
    } else if (pendingWindowStart < 0 && now.weekday == prevDay(schedWeekday)) {
      nowAdj = nowMin - 1440;
    } else if (overnight && now.weekday == nextDay(schedWeekday)) {
      nowAdj = nowMin + 1440;
    } else {
      return 'Upcoming';
    }

    if (nowAdj >= endMin) return 'Ended';
    if (nowAdj >= pendingWindowStart) return 'Pending';
    return 'Upcoming';
  }

  @override
  void initState() {
    super.initState();

    _sortClasses();
    _loadStudent().then((_) => _loadMyClasses());
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
      String classId,
      String course,
      String courseCode,  // ✅ NEW
      String classCode,
      String professor,
      String room,
      String sched,
      String session,
      double screenHeight,
      Future<void> Function() onArchive,
      ) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    final isUpcoming = session == 'Upcoming' || session == 'Ended';

    final borderColor = session == 'Pending'
        ? const Color(0xFFB09602)
        : session == 'Ended'
        ? const Color(0xFFFB8C7A)
        : session == 'Session Started'
        ? const Color(0xFFBBE6CB)
        : const Color(0x90A9CBF9);

    final bgColor = session == 'Pending'
        ? const Color(0x25FBD600)
        : session == 'Ended'
        ? const Color(0xFFFDDCDC)
        : session == 'Session Started'
        ? const Color(0xFFDBFCE7)
        : const Color(0x90DBEAFE);

    final textColor = session == 'Pending'
        ? const Color(0xFFB09602)
        : session == 'Ended'
        ? const Color(0xFFFB8C7A)
        : session == 'Session Started'
        ? const Color(0xFF016224)
        : const Color(0x90004280);

    return Opacity(
      opacity: isUpcoming ? 0.5 : 1.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * .02),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: session != 'Upcoming' ? Colors.white : Colors.grey[300],
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
                      Text(courseCode),
                      const SizedBox(height: 10),
                    ],
                  ),

                  // only allow open if session started
                  session == 'Session Started'
                      ? IconButton(
                    onPressed: () async {
                      final sessionId = await _getActiveSessionId(classId);

                      if (sessionId == null) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No active session found.')),
                        );
                        return;
                      }

                      if (!context.mounted) return;

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Face_Verification(
                            classSessionId: sessionId,
                            courseTitle: course,
                            courseCode: courseCode,
                            professor: professor,
                            room: room,
                            sched: sched,
                            classCode: classCode,
                          ),
                        ),
                      );

                      await _loadMyClasses();
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
                    margin: EdgeInsets.fromLTRB(screenWidth * .001, 0, 0, 10),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75),
                      border: Border.all(
                        color: borderColor,
                      ),
                      color: bgColor,
                    ),
                    width: screenWidth * .25,
                    height: screenHeight * .025,
                    child: Text(
                      session,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenHeight * .012,
                        color: textColor,
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
                        // first confirmation (normal)
                        final ok = await _confirmArchive();
                        if (!ok) return;

                        // ✅ if session started, ask again
                        if (session == 'Session Started') {
                          final ok2 = await _confirmArchiveStartedSession();
                          if (!ok2) return;
                        }

                        await onArchive(); // will call DB archive
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

  Widget _avatarWidget(double size) {
    final url = _avatarUrl;

    if (url == null || url.trim().isEmpty) {
      return Image.asset('assets/avatar.png', width: size, height: size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/avatar.png', width: size, height: size),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      ),
    );
  }

  Future<void> _archiveClass({
    required ClassItem item,
    required int index,
  }) async {
    try {
      // ✅ update DB
      await supabase
          .from('classes')
          .update({'archived': true})
          .eq('id', item.classId);

      if (!mounted) return;

      // ✅ update UI
      setState(() {
        _archivedClasses.add(item);
        _classes.removeAt(index);
        _sortClasses();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to archive class: $e')),
      );
    }
  }

  Future<bool> _confirmArchiveStartedSession() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Session is currently started',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'This class has an ongoing session. Are you sure you want to archive it?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive anyway', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showJoinClassDialog() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool loading = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;

              setLocal(() {
                loading = true;
                error = null;
              });

              try {
                final course = await _joinClassByCode(controller.text);

                if (!mounted) return;

                // ✅ close join dialog once
                Navigator.pop(context);

                // ✅ show success dialog after closing
                Future.microtask(() {
                  if (!mounted) return;
                  _showSuccessDialog('Joined: $course');
                });
              } catch (e) {
                setLocal(() {
                  error = e.toString().replaceFirst('Exception: ', '');
                });
              } finally {
                setLocal(() => loading = false);
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: const Text(
                'Enter Class Code',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 280,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: controller,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => submit(),
                        decoration: InputDecoration(
                          hintText: 'Class code',
                          hintStyle: const TextStyle(fontSize: 12),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            const BorderSide(color: Color(0x50000000), width: 1),
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

                      if (error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Join Class',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Success',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          SizedBox(
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
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
              height: screenHeight * .30,
              decoration: BoxDecoration(
                color: Color(0xFF004280),
                borderRadius: BorderRadius.vertical(
                  top: Radius.zero,
                  bottom: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Column(
                children: [
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      widget.onOpenNotifications();
                                    },
                                    icon: const Icon(CupertinoIcons.bell),
                                    color: Colors.white,
                                  ),
                                  if (widget.unRead)
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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
                        _avatarWidget(screenWidth * .18),
                        SizedBox(width: screenWidth * .035),
                        _studentCard(screenHeight, screenWidth),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(), // ✅ para gumana kahit konti lang items
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * .05),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Classes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * .017,
                          ),
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

                    if (_loadingClasses) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 16),
                    ] else if (_classesError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load classes: $_classesError',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                    ] else if (_classes.isEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'No classes yet. Join a class using the code.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      ..._classes.asMap().entries.map((entry) {
                        final i = entry.key;
                        final c = entry.value;

                        return classCard(
                          c.classId,
                          c.course,
                          c.courseCode,
                          c.classCode,
                          c.professor,
                          c.room,
                          c.sched,
                          c.session,
                          screenHeight,
                          () async {
                            await _archiveClass(item: c, index: i);
                          },
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
