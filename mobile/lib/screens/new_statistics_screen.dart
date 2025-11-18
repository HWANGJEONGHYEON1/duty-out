import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../providers/statistics_provider.dart';

class NewStatisticsScreen extends StatefulWidget {
  const NewStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<NewStatisticsScreen> createState() => _NewStatisticsScreenState();
}

class _NewStatisticsScreenState extends State<NewStatisticsScreen> {
  late Future<void> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    final babyId = context.read<BabyProvider>().baby?.id;
    if (babyId != null) {
      _statisticsFuture = context.read<StatisticsProvider>().loadWeeklyStatistics(
            babyId: babyId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
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
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: Center(
        child: Column(
          children: [
            const Text(
              '주간 통계',
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
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context) {
    final statistics = context.watch<StatisticsProvider>();

    if (statistics.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            ),
            SizedBox(height: 20),
            Text('통계 데이터 로드 중...'),
          ],
        ),
      );
    }

    if (statistics.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류: ${statistics.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStatistics,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 7일 미만 데이터 경고
            if (!statistics.hasEnoughData)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFFF9800),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '데이터가 7일 미만입니다. 충분한 데이터가 수집되면 더 정확한 통계를 볼 수 있습니다.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (!statistics.hasEnoughData) const SizedBox(height: 20),
            _buildSleepChartCard(context),
            const SizedBox(height: 15),
            _buildFeedingChartCard(context),
            const SizedBox(height: 15),
            _buildSummaryCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChartCard(BuildContext context) {
    final statistics = context.watch<StatisticsProvider>();
    final dailyStats = statistics.dailyStats;

    // 수면 데이터 추출 (분 단위)
    final sleepData = dailyStats.map((day) => (day['sleepMinutes'] ?? 0) as int).toList();
    final maxSleep = sleepData.isEmpty ? 900 : sleepData.reduce((a, b) => a > b ? a : b).toDouble();
    final displayMax = maxSleep > 0 ? maxSleep : 900;

    final days = dailyStats.map((day) => day['dayOfWeek'] as String).toList();

    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '주간 수면 패턴',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '총 ${(statistics.totalSleepMinutes! / 60).toStringAsFixed(1)}시간',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
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
            child: sleepData.isEmpty
                ? const Center(
                    child: Text('수면 데이터가 없습니다'),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: sleepData.asMap().entries.map((entry) {
                      final value = entry.value.toDouble();
                      final height = (value / displayMax * 160);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            value > 0 ? '${(value / 60).toStringAsFixed(1)}h' : '-',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: value > 0
                                  ? const Color(0xFF667EEA)
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 35,
                            height: height > 0 ? height : 2,
                            decoration: BoxDecoration(
                              gradient: value > 0
                                  ? const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2)
                                      ],
                                    )
                                  : null,
                              color: value > 0 ? null : Colors.grey[300],
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(5)),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: days.map((day) {
              return Text(
                day.substring(0, 1),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingChartCard(BuildContext context) {
    final statistics = context.watch<StatisticsProvider>();
    final dailyStats = statistics.dailyStats;

    // 수유 데이터 추출 (ml 단위)
    final feedingData =
        dailyStats.map((day) => (day['feedingAmount'] ?? 0) as int).toList();
    final maxFeeding = feedingData.isEmpty ? 1000 : feedingData.reduce((a, b) => a > b ? a : b).toDouble();
    final displayMax = maxFeeding > 0 ? maxFeeding : 1000;

    final days = dailyStats.map((day) => day['dayOfWeek'] as String).toList();

    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '주간 수유량',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '총 ${statistics.totalFeedingAmount}ml',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
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
            child: feedingData.isEmpty
                ? const Center(
                    child: Text('수유 데이터가 없습니다'),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: feedingData.asMap().entries.map((entry) {
                      final value = entry.value.toDouble();
                      final height = (value / displayMax * 160);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            value > 0 ? '${value.toInt()}ml' : '-',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  value > 0 ? const Color(0xFF4CAF50) : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 35,
                            height: height > 0 ? height : 2,
                            decoration: BoxDecoration(
                              gradient: value > 0
                                  ? const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF4CAF50),
                                        Color(0xFF388E3C)
                                      ],
                                    )
                                  : null,
                              color: value > 0 ? null : Colors.grey[300],
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(5)),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: days.map((day) {
              return Text(
                day.substring(0, 1),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final statistics = context.watch<StatisticsProvider>();

    // 평균 수면 시간 계산
    final totalSleepMinutes = statistics.totalSleepMinutes ?? 0;
    final avgSleepMinutes = statistics.averageSleepMinutes ?? 0;
    final avgSleepHours = avgSleepMinutes / 60;

    // 수면 목표 (아기 월령별로 다를 수 있음)
    final sleepGoal = 14.5; // 14.5시간 기준
    final sleepAchievementPercent = (avgSleepHours / sleepGoal * 100).clamp(0, 100);

    final avgFeedingAmount = statistics.averageFeedingAmount ?? 0;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                const Text(
                  '평균 수면',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${avgSleepHours.toStringAsFixed(1)}시간',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: sleepAchievementPercent >= 80
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    sleepAchievementPercent >= 80 ? '목표 달성!' : '더 자야해요',
                    style: TextStyle(
                      fontSize: 10,
                      color: sleepAchievementPercent >= 80
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                const Text(
                  '평균 수유량',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${avgFeedingAmount}ml',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    '적정 수준',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFFF9800),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
