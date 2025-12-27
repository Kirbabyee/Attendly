import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AttendlyNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AttendlyNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _bg = Color(0xFF003B73); // dark blue
  static const _active = Colors.white;
  static const _inactive = Color(0xFFD6E3F3); // light-ish

  @override
  Widget build(BuildContext context) {
    final items = const [
      _NavItem(icon: CupertinoIcons.home, label: 'Home'),
      _NavItem(icon: CupertinoIcons.clock, label: 'History'),
      _NavItem(icon: CupertinoIcons.question_circle, label: 'Help'),
      _NavItem(icon: CupertinoIcons.gear, label: 'Settings'),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 72,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final itemW = w / items.length;

              // Center the white selected box on the selected slot
              final left = (currentIndex * itemW) + (itemW - 64) / 2;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background bar
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(items.length, (i) {
                          final selected = i == currentIndex;
                          return Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => onTap(i),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      items[i].icon,
                                      size: 22,
                                      color: selected ? Colors.transparent : _inactive,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      items[i].label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: selected ? Colors.transparent : _inactive,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // White "selected" pill (pops up)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    left: left,
                    top: -10,
                    child: Container(
                      width: 64,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _active,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 12,
                            offset: Offset(0, 6),
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[currentIndex].icon,
                            color: _bg,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[currentIndex].label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _bg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
