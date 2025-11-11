import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/baby_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/sleep_tracking_provider.dart';
import 'providers/community_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const BabySleepApp());
}

class BabySleepApp extends StatelessWidget {
  const BabySleepApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BabyProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => SleepTrackingProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
      ],
      child: MaterialApp(
        title: '아기 수면 스케줄러',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          textTheme: GoogleFonts.notoSansKrTextTheme(),
        ),
        home: const AppInitializer(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      context.read<BabyProvider>().initializeMockData();
      context.read<ScheduleProvider>().initializeMockData();
      context.read<StatisticsProvider>().initializeMockData();
      context.read<CommunityProvider>().initializeMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}
