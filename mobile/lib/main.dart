import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/baby_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/statistics_provider.dart';
import 'screens/main_screen.dart';

void main() {
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
      ],
      child: MaterialApp(
        title: '아기 수면 스케줄러',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
