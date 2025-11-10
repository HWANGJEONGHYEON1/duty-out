import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ScheduleScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, '🏠', '홈'),
                _buildNavItem(1, '📅', '스케줄'),
                _buildNavItem(2, '📊', '통계'),
                _buildNavItem(3, '👤', '설정'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String icon, String label) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 24,
                color: isActive ? const Color(0xFF667EEA) : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? const Color(0xFF667EEA) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
