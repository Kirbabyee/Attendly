import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  List<String> classOptions = ['All', 'CCS101', 'CCS125'];

  final TextEditingController searchController = TextEditingController();

  String selectedStatus = 'All'; // chips: All/Present/Late/Absent
  String selectedClass = 'All';  // dropdown: Filter by class

  List<AttendanceRecord> allRecords = [];
  List<AttendanceRecord> filteredRecords = [];

  @override
  void initState() {
    super.initState();

    allRecords = [
      AttendanceRecord(
        courseName: 'Introduction to Computer Interaction',
        className: 'CCS101',
        date: DateTime(2025, 12, 14),
        status: 'Present',
      ),
      AttendanceRecord(
        courseName: 'Introduction to Computer Interaction',
        className: 'CCS101',
        date: DateTime(2025, 12, 14),
        status: 'Late',
      ),
      AttendanceRecord(
        courseName: 'Software Engineering',
        className: 'CCS125',
        date: DateTime(2025, 12, 14),
        status: 'Absent',
      ),
      AttendanceRecord(
        courseName: 'Software Engineering',
        className: 'CCS125',
        date: DateTime(2025, 12, 14),
        status: 'Absent',
      ),
      AttendanceRecord(
        courseName: 'Software Engineering',
        className: 'CCS125',
        date: DateTime(2025, 12, 14),
        status: 'Absent',
      ),
    ];

    filteredRecords = List.from(allRecords); // show all at start
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
            selectedClass == 'All' || record.className == selectedClass;

        return matchesSearch && matchesStatus && matchesClass;
      }).toList();
    });
  }

  Widget statusChip(String label) {
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
          fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        color: bgColor,
      ),
      child: Text(status, style: TextStyle(fontSize: 10, color: textColor)),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Search
                Center(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => applyFilters(),
                      decoration: InputDecoration(
                        hintText: 'Search course',
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
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

                // Dropdown
                Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700]
                    ),
                    value: selectedClass,
                    items: classOptions.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedClass = value;
                      });
                      applyFilters();
                    },
                  ),
                ),

                // Title + Chips
                Align(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Record Details',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          statusChip('All'),
                          statusChip('Present'),
                          statusChip('Late'),
                          statusChip('Absent'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ LIST AREA (scrollable)
                Expanded(
                  child: filteredRecords.isEmpty
                      ? const Center(child: Text('No records found.'))
                      : ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      final bg = index.isEven
                          ? Colors.white
                          : Colors.grey[300];

                      return Container(
                        height: 100,
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12
                              ),
                            ),
                            subtitle: Text(
                              '${record.className} • ${record.date.toIso8601String().split("T")[0]}',
                              style: TextStyle(
                                fontSize: 11
                              ),
                            ),
                            trailing: _statusBadge(record.status),
                          ),
                        ),
                      );
                    },
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

