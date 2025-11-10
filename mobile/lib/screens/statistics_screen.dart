import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../providers/statistics_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabs(context),
          Expanded(
            child: _buildStatsContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final baby = context.watch<BabyProvider>().baby;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: Column(
        children: [
          const Text(
            '수면 통계',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            baby != null ? '👶 ${baby.name} (${baby.ageText})' : '👶',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final statsProvider = context.watch<StatisticsProvider>();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context,
              '일간',
              'daily',
              statsProvider.selectedPeriod == 'daily',
              () => statsProvider.setPeriod('daily'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildTab(
              context,
              '주간',
              'weekly',
              statsProvider.selectedPeriod == 'weekly',
              () => statsProvider.setPeriod('weekly'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildTab(
              context,
              '월간',
              'monthly',
              statsProvider.selectedPeriod == 'monthly',
              () => statsProvider.setPeriod('monthly'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, String value, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isActive ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context) {
    final statsProvider = context.watch<StatisticsProvider>();

    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTotalSleepCard(context, statsProvider),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildNapCountCard(context, statsProvider),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildNightSleepCard(context, statsProvider),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildWeeklyChartCard(context, statsProvider),
            const SizedBox(height: 15),
            _buildGoalCard(context, statsProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSleepCard(BuildContext context, StatisticsProvider provider) {
    final totalMinutes = provider.getTotalSleepMinutesToday();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$hours시간 $minutes분',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '오늘 총 수면 시간',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNapCountCard(BuildContext context, StatisticsProvider provider) {
    final napCount = provider.getNapCount();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$napCount회',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '낮잠 횟수',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNightSleepCard(BuildContext context, StatisticsProvider provider) {
    final nightMinutes = provider.getNightSleepMinutes();
    final hours = nightMinutes ~/ 60;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$hours시간',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '밤잠 시간',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChartCard(BuildContext context, StatisticsProvider provider) {
    final weeklyData = provider.getWeeklySleepData();
    final maxValue = weeklyData.reduce((a, b) => a > b ? a : b).toDouble();
    final days = ['월', '화', '수', '목', '금', '토', '일'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '주간 수면 패턴',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '최근 7일',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.grey[200]!, Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.asMap().entries.map((entry) {
                final value = entry.value.toDouble();
                final height = maxValue > 0 ? (value / maxValue * 160) : 0.0;
                return Container(
                  width: 40,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: days.map((day) {
              return Text(
                day,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, StatisticsProvider provider) {
    final percentage = provider.getSleepGoalPercentage();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA).withOpacity(0.2),
            const Color(0xFF764BA2).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '수면 목표 달성률',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667EEA),
                ),
              ),
              SizedBox(height: 5),
              Text(
                '권장: 14-15시간',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            '${percentage.toInt()}%',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
        ],
      ),
    );
  }
}
