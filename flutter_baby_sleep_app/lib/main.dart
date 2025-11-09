import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sleep_tracking_screen.dart';
import 'package:provider/provider.dart';
import 'providers/baby_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/sleep_record_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BabyProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => SleepRecordProvider()),
      ],
      child: BabySleepSchedulerApp(),
    ),
  );
}

class BabySleepSchedulerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    return MaterialApp(
      title: '아기 수면 스케줄러',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF667EEA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF667EEA),
          secondary: Color(0xFF764BA2),
        ),
        fontFamily: 'Pretendard',
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/main': (context) => MainNavigationScreen(),
        '/sleep-tracking': (context) => SleepTrackingScreen(),
        '/onboarding': (context) => OnboardingScreen(),
      },
    );
  }
}

// 스플래시 스크린
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2));
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    '🌙',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                '아기 수면 스케줄러',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '건강한 수면 습관 만들기',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 온보딩 스크린
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      emoji: '👶',
      title: '아기 정보 입력',
      description: '생년월일과 이름을 입력하면\n맞춤형 수면 스케줄을 제공합니다',
    ),
    OnboardingPage(
      emoji: '📅',
      title: '자동 스케줄 생성',
      description: '기상 시간만 입력하면\n하루 일과가 자동으로 생성됩니다',
    ),
    OnboardingPage(
      emoji: '📊',
      title: '수면 패턴 분석',
      description: '매일 기록을 통해\n아기의 수면 패턴을 분석해드립니다',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _pages[index].emoji,
                          style: TextStyle(fontSize: 80),
                        ),
                        SizedBox(height: 40),
                        Text(
                          _pages[index].title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          _pages[index].description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // 페이지 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Color(0xFF667EEA)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            // 버튼
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      child: Text('이전'),
                    ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        Navigator.pushReplacementNamed(context, '/main');
                      } else {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF667EEA),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? '시작하기' : '다음',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String emoji;
  final String title;
  final String description;

  OnboardingPage({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

// 메인 네비게이션 스크린
class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    ScheduleScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 0 
        ? FloatingActionButton(
            onPressed: () => _showQuickRecordDialog(context),
            child: Icon(Icons.add),
            backgroundColor: Color(0xFF667EEA),
            elevation: 8,
          )
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF667EEA),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: '스케줄',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: '통계',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickRecordDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickRecordSheet(),
    );
  }
}

// 빠른 기록 시트
class QuickRecordSheet extends StatefulWidget {
  @override
  _QuickRecordSheetState createState() => _QuickRecordSheetState();
}

class _QuickRecordSheetState extends State<QuickRecordSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          Text(
            '빠른 기록',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.all(20),
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                QuickRecordItem(
                  icon: Icons.bedtime,
                  label: '수면 시작',
                  color: Color(0xFF667EEA),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/sleep-tracking');
                  },
                ),
                QuickRecordItem(
                  icon: Icons.wb_sunny,
                  label: '수면 종료',
                  color: Color(0xFF764BA2),
                  onTap: () {
                    Navigator.pop(context);
                    _showSleepEndDialog(context);
                  },
                ),
                QuickRecordItem(
                  icon: Icons.baby_changing_station,
                  label: '수유',
                  color: Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeedingDialog(context);
                  },
                ),
                QuickRecordItem(
                  icon: Icons.restaurant,
                  label: '이유식',
                  color: Color(0xFFFF9800),
                  onTap: () {
                    Navigator.pop(context);
                    _showSolidFoodDialog(context);
                  },
                ),
                QuickRecordItem(
                  icon: Icons.child_care,
                  label: '기저귀',
                  color: Color(0xFF2196F3),
                  onTap: () {
                    Navigator.pop(context);
                    _showDiaperDialog(context);
                  },
                ),
                QuickRecordItem(
                  icon: Icons.note_add,
                  label: '메모',
                  color: Color(0xFF9E9E9E),
                  onTap: () {
                    Navigator.pop(context);
                    _showMemoDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSleepEndDialog(BuildContext context) {
    // 수면 종료 다이얼로그
  }

  void _showFeedingDialog(BuildContext context) {
    // 수유 기록 다이얼로그
  }

  void _showSolidFoodDialog(BuildContext context) {
    // 이유식 기록 다이얼로그
  }

  void _showDiaperDialog(BuildContext context) {
    // 기저귀 교체 다이얼로그
  }

  void _showMemoDialog(BuildContext context) {
    // 메모 추가 다이얼로그
  }
}

class QuickRecordItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  QuickRecordItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
