import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_1/Student%20Page/settings.dart';

import '../widgets/navbar.dart';
import 'dashboard.dart';
import 'Help/help.dart';
import 'History/history.dart';

class Mainshell extends StatefulWidget {
  const Mainshell({super.key});

  @override
  State<Mainshell> createState() => _MainshellState();
}

class _MainshellState extends State<Mainshell> {
  int _index = 0; // Home selected by default (match your navbar order)

  final List<Widget> _pages = const [
    Dashboard(),
    History(),
    Help(),
    Settings()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: AttendlyNavBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() {
            _index = i;
          });
        },
      ),
    );
  }
}
