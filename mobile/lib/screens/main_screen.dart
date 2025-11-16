import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import 'schedule_screen.dart';
import 'new_statistics_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import 'baby_registration_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 아기 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBaby();
    });
  }

  Future<void> _loadBaby() async {
    final babyProvider = context.read<BabyProvider>();
    try {
      await babyProvider.loadMyBabies();
    } catch (e) {
      debugPrint('아기 정보 로드 실패: $e');
    }
  }

  final List<Widget> _screens = const [
    ScheduleScreen(),
    NewStatisticsScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final babyProvider = context.watch<BabyProvider>();
    final baby = babyProvider.baby;

    // 아기 정보가 없으면 아기 등록 화면 표시
    if (baby == null) {
      return const BabyRegistrationScreen();
    }

    // 아기 정보가 있으면 메인 화면 표시
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
                _buildNavItem(0, '📅', '스케줄'),
                _buildNavItem(1, '📊', '통계'),
                _buildNavItem(2, '💬', '커뮤니티'),
                _buildNavItem(3, '👤', '설정'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String icon, String label, {bool enabled = true}) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: enabled
          ? () {
              setState(() {
                _currentIndex = index;
              });
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                icon,
                style: TextStyle(
                  fontSize: 24,
                  color: enabled
                      ? (isActive ? const Color(0xFF667EEA) : Colors.grey)
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: enabled
                      ? (isActive ? const Color(0xFF667EEA) : Colors.grey)
                      : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
