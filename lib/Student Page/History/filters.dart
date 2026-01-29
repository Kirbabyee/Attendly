import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../student_session.dart';

class AttendanceRecord {
  final String courseName;
  final String className; // for dropdown "Filter by class"
  final DateTime date;
  final String status; // Present, Late, Absent

  AttendanceRecord({
    required this.courseName,
    required this.className,
    required this.date,
    required this.status,
  });
}

class DataFilter extends StatefulWidget {
  const DataFilter({super.key});

  @override
  State<DataFilter> createState() => _DataFilterState();
}

class _DataFilterState extends State<DataFilter> {
  Future<void> _loadAttendance() async {
    final student = await StudentSession.get();
    final studentId = student?['id']?.toString();

    if (studentId == null || studentId.isEmpty) return;

    final res = await Supabase.instance.client
        .from('attendance')
        .select('status, time_in, created_at, session_id, class_sessions!inner(class_id, started_at, created_at, classes!inner(course, class_code, course_code))')
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    final rows = (res as List).cast<Map<String, dynamic>>();

    final records = rows.map((r) {
      final sess = r['class_sessions'] as Map<String, dynamic>;
      final cl = sess['classes'] as Map<String, dynamic>;

      final course = (cl['course'] ?? '').toString();
      final classCode = (cl['course_code'] ?? '').toString();

      // prefer time_in, fallback created_at
      final dateRaw = r['time_in'] ?? r['created_at'];
      final date = DateTime.tryParse(dateRaw.toString()) ?? DateTime.now();

      String _cap(String s) => s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1).toLowerCase());
      final status = _cap((r['status'] ?? 'unknown').toString());

      return AttendanceRecord(
        courseName: course.isEmpty ? '-' : course,
        className: classCode.isEmpty ? '-' : classCode,
        date: date,
        status: status,
      );
    }).toList();

    setState(() {
      allRecords = records;
      filteredRecords = List.from(allRecords);

      classOptions = [
        'All',
        ...{ for (final r in allRecords) r.courseName }
      ].toList();
    });

    applyFilters();
  }

  List<String> classOptions = ['All'];

  final TextEditingController searchController = TextEditingController();

  String selectedStatus = 'All'; // chips: All/Present/Late/Absent
  String selectedClass = 'All';  // dropdown: Filter by class

  DateTimeRange? selectedRange;

  List<AttendanceRecord> allRecords = [];
  List<AttendanceRecord> filteredRecords = [];

  bool _refreshing = false;

  Future<void> _onRefresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      await _loadAttendance();
    } finally {
      _refreshing = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAttendance();

    filteredRecords = List.from(allRecords); // show all at start

    classOptions = [
      'All',
      ...{ for (final r in allRecords) r.courseName }
    ];
  }

  void applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      filteredRecords = allRecords.where((record) {
        // 1) Search filter
        final matchesSearch =
        record.courseName.toLowerCase().contains(query);

        // 2) Status chip filter
        final matchesStatus =
            selectedStatus == 'All' || record.status == selectedStatus;

        // 3) Dropdown class filter
        final matchesClass =
            selectedClass == 'All' || record.courseName == selectedClass;

        // Date filter (same day only)
        final matchesDate = selectedRange == null || (() {
          final d = DateTime(record.date.year, record.date.month, record.date.day);
          final start = DateTime(
            selectedRange!.start.year,
            selectedRange!.start.month,
            selectedRange!.start.day,
          );
          final end = DateTime(
            selectedRange!.end.year,
            selectedRange!.end.month,
            selectedRange!.end.day,
          );
          return !d.isBefore(start) && !d.isAfter(end);
        })();

        return matchesSearch && matchesClass && matchesStatus && matchesDate;

      }).toList();
    });
  }

  Future<void> pickDateRangeDialogCalendar() async {
    DateTimeRange? temp = selectedRange;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Select date range',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: 340,
            height: 360,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              startRangeSelectionColor: const Color(0xFF004280),
              endRangeSelectionColor: const Color(0xFF004280),
              rangeSelectionColor: const Color(0xFF004280),
              rangeTextStyle: const TextStyle(color: Colors.white),
              toggleDaySelection: true,
              todayHighlightColor: const Color(0xFF004280),
              backgroundColor: Colors.white,
              headerStyle: const DateRangePickerHeaderStyle(
                backgroundColor: Colors.white,
              ),
              initialSelectedRange: temp == null
                  ? null
                  : PickerDateRange(temp!.start, temp!.end),
              onSelectionChanged: (args) {
                final r = args.value;
                if (r is PickerDateRange) {
                  final DateTime? start = r.startDate;
                  if (start == null) return;
                  final DateTime end = r.endDate ?? start; // ✅ fallback
                  temp = DateTimeRange(start: start, end: end);
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004280),
              ),
              onPressed: () {
                setState(() => selectedRange = temp);
                applyFilters();
                Navigator.pop(context);
              },
              child: const Text('Apply', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _fmtRange(DateTimeRange r) => '${_fmt(r.start)} - ${_fmt(r.end)}';

  Widget statusChip(String label, double screenHeight) {
    return ChoiceChip(
      backgroundColor: Color(0x90D9D9D9),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(20),
      ),
      showCheckmark: false,
      label: Text(
        label,
        style: TextStyle(
          fontSize: screenHeight * .013,
          color: selectedStatus == label
              ? Colors.white
              : Colors.black,
        ),
      ),
      selected: selectedStatus == label,
      selectedColor: Color(0xFF004280),
      onSelected: (_) {
        selectedStatus = label;
        applyFilters();
      },
    );
  }

  Widget _statusBadge(String status) {
    final screenHeight = MediaQuery.of(context).size.height;
    Color borderColor;
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Present':
        borderColor = const Color(0xFF71CF93);
        bgColor = const Color(0xFFDBFCE7);
        textColor = const Color(0xFF016224);
        break;
      case 'Late':
        borderColor = const Color(0xFFB09602);
        bgColor = const Color(0xFFFFF8D2);
        textColor = const Color(0xFFB09602);
        break;
      case 'Absent':
        borderColor = const Color(0xFFFB8C7A);
        bgColor = const Color(0xFFFDDCDC);
        textColor = const Color(0xFF8E0000);
        break;
      default:
        borderColor = Colors.grey;
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenHeight * .022, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        color: bgColor,
      ),
      child: Text(status, style: TextStyle(fontSize: screenHeight * .012, color: textColor)),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: screenWidth * .9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Search
                Center(
                  child: SizedBox(
                    height: screenHeight * .042,
                    child: TextField(
                      style: TextStyle(
                        fontSize: screenHeight * .018
                      ),
                      controller: searchController,
                      onChanged: (_) => applyFilters(),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                          fontSize: screenHeight * .018
                        ),
                        hintText: 'Search course',
                        prefixIcon: Icon(
                          Icons.search,
                          size: screenHeight * .022,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: screenHeight * .012),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * .012,),

                Container(
                  child: Row(
                    children: [
                      // Date Filter Row
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: pickDateRangeDialogCalendar,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedRange == null ? 'Select date' : _fmtRange(selectedRange!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                ),
                                if (selectedRange != null)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => selectedRange = null);
                                      applyFilters();
                                    },
                                    child: const Icon(Icons.close, size: 16),
                                  ),
                                SizedBox(width: 5,),
                                Icon(CupertinoIcons.calendar, color: Colors.black,)
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.15),

                      // Dropdown
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: screenWidth * 0.35,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          height: 42,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: Colors.white, // dropdown list bg
                            underline: const SizedBox(), // ❌ remove default underline
                            iconEnabledColor: Colors.black, // arrow color
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black, // text color
                            ),
                            value: selectedClass,
                            items: classOptions.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => selectedClass = value);
                              applyFilters();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * .012,),

                // Title + Chips
                Align(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Record Details',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenHeight * .017),
                      ),
                      SizedBox(height: screenHeight * .007),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          statusChip('All', screenHeight),
                          statusChip('Present', screenHeight),
                          statusChip('Late', screenHeight),
                          statusChip('Absent', screenHeight),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight > 700 ? 10 : 5),

                // ✅ LIST AREA (scrollable)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: filteredRecords.isEmpty
                        ? ListView( // ✅ kailangan ListView pa rin para gumana pull-to-refresh kahit empty
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('No records found.')),
                      ],
                    )
                        : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(), // ✅ para kahit konti items, pwede mag pull
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        final bg = index.isEven ? Colors.white : Colors.grey[300];

                        return Container(
                          height: screenHeight * .12,
                          decoration: BoxDecoration(
                            color: bg,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: ListTile(
                              title: Text(
                                record.courseName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: screenHeight * .014,
                                ),
                              ),
                              subtitle: Text(
                                '${record.className} • ${record.date.toIso8601String().split("T")[0]}',
                                style: TextStyle(fontSize: screenHeight * .013),
                              ),
                              trailing: _statusBadge(record.status),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

