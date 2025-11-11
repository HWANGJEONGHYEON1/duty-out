import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/baby_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/sleep_tracking_provider.dart';
import 'providers/community_provider.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BabySleepApp());
}

class BabySleepApp extends StatelessWidget {
  const BabySleepApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BabyProvider()..initializeMockData()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()..initializeMockData()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()..initializeMockData()),
        ChangeNotifierProvider(create: (_) => SleepTrackingProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()..initializeMockData()),
      ],
      child: MaterialApp(
        title: '아기 수면 스케줄러',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          textTheme: GoogleFonts.notoSansKrTextTheme(),
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
