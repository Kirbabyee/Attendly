import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

// pages
import 'dashboard.dart';
import 'History/history.dart';
import 'Help/help.dart';
import 'Settings/settings.dart';

// ✅ import your student notifications drawer UI
import 'notification_ui.dart'; // adjust path kung iba

class Mainshell extends StatefulWidget {
  final int initialIndex;

  const Mainshell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<Mainshell> createState() => _MainshellState();
}

class _MainshellState extends State<Mainshell> {
  late int _index;

  // ✅ para matakpan pati navbar kapag binuksan drawer
  final GlobalKey<ScaffoldState> _shellKey = GlobalKey<ScaffoldState>();

  // ✅ unread state (red dot)
  bool _unRead = true;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;

    _pages = [
      Dashboard(
        unRead: _unRead,
        onOpenNotifications: openNotifications,
      ),
      const History(),
      const Help(),
      const Settings(),
    ];
  }

  void openNotifications() {
    _shellKey.currentState?.openEndDrawer();
  }

  void _handleUnreadChanged(bool v) {
    if (!mounted) return;

    setState(() => _unRead = v);

    // ✅ rebuild dashboard page so bell updates (since _pages is fixed)
    _pages[0] = Dashboard(
      unRead: _unRead,
      onOpenNotifications: openNotifications,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _shellKey,

      // ✅ drawer covers screen + navbar
      endDrawer: NotificationsDrawer(
        unRead: _unRead,
        onUnreadChanged: _handleUnreadChanged,
      ),

      body: IndexedStack(
        index: _index,
        children: _pages,
      ),

      bottomNavigationBar: AttendlyNavBar(
        screenHeight: screenHeight,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
