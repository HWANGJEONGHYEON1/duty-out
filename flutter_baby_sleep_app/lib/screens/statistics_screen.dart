import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_record_provider.dart';
import '../providers/baby_provider.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'week'; // 'week', 'month', 'year'

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
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPeriodSelector(),
                        SizedBox(height: 20),
                        _buildSleepSummary(),
                        SizedBox(height: 20),
                        _buildSleepChart(),
                        SizedBox(height: 20),
                        _buildSleepQuality(),
                        SizedBox(height: 20),
                        _buildInsights(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            '수면 통계',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              // 통계 내보내기
            },
            icon: Icon(Icons.file_download, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _buildPeriodButton('주간', 'week'),
        SizedBox(width: 10),
        _buildPeriodButton('월간', 'month'),
        SizedBox(width: 10),
        _buildPeriodButton('연간', 'year'),
      ],
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF667EEA) : Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSleepSummary() {
    final sleepProvider = Provider.of<SleepRecordProvider>(context);
    final now = DateTime.now();
    final startDate = _getStartDate(now);

    final records = sleepProvider.getRecordsForDateRange(startDate, now);
    final avgDuration = sleepProvider.getAverageSleepDuration(startDate, now);

    final totalSleep = records.fold<int>(
      0,
      (sum, record) => sum + record.actualDuration,
    );

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                '평균 수면',
                '${(avgDuration / 60).toStringAsFixed(1)}h',
                Icons.bedtime,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryItem(
                '총 수면',
                '${(totalSleep / 60).toStringAsFixed(1)}h',
                Icons.timeline,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryItem(
                '기록 수',
                '${records.length}',
                Icons.check_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSleepChart() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '수면 시간 추이',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: Center(
              child: Text(
                '차트 영역\n(fl_chart 패키지로 구현)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepQuality() {
    final sleepProvider = Provider.of<SleepRecordProvider>(context);
    final now = DateTime.now();
    final startDate = _getStartDate(now);

    final qualityStats = sleepProvider.getSleepQualityStats(startDate, now);
    final total = qualityStats.values.fold<int>(0, (sum, count) => sum + count);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '수면 품질',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildQualityBar('좋음', qualityStats['good'] ?? 0, total, Colors.green),
          SizedBox(height: 10),
          _buildQualityBar('보통', qualityStats['fair'] ?? 0, total, Colors.orange),
          SizedBox(height: 10),
          _buildQualityBar('나쁨', qualityStats['poor'] ?? 0, total, Colors.red),
        ],
      ),
    );
  }

  Widget _buildQualityBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsights() {
    final babyProvider = Provider.of<BabyProvider>(context);
    final sleepProvider = Provider.of<SleepRecordProvider>(context);

    final insights = _generateInsights(babyProvider, sleepProvider);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Color(0xFF667EEA)),
              SizedBox(width: 8),
              Text(
                '인사이트',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          ...insights.map((insight) => Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        insight,
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  DateTime _getStartDate(DateTime now) {
    switch (_selectedPeriod) {
      case 'week':
        return now.subtract(Duration(days: 7));
      case 'month':
        return DateTime(now.year, now.month - 1, now.day);
      case 'year':
        return DateTime(now.year - 1, now.month, now.day);
      default:
        return now.subtract(Duration(days: 7));
    }
  }

  List<String> _generateInsights(
      BabyProvider babyProvider, SleepRecordProvider sleepProvider) {
    final insights = <String>[];

    final now = DateTime.now();
    final startDate = _getStartDate(now);
    final avgDuration = sleepProvider.getAverageSleepDuration(startDate, now);

    if (avgDuration > 0) {
      insights.add('평균 수면 시간은 ${(avgDuration / 60).toStringAsFixed(1)}시간입니다.');
    }

    if (babyProvider.hasBaby) {
      final baby = babyProvider.currentBaby!;
      final ageMonths = baby.ageInMonths;

      if (ageMonths < 3) {
        insights.add('신생아는 하루 14-17시간의 수면이 필요합니다.');
      } else if (ageMonths < 6) {
        insights.add('이 시기의 아기는 하루 12-15시간의 수면이 필요합니다.');
      } else if (ageMonths < 12) {
        insights.add('이 시기의 아기는 하루 12-14시간의 수면이 필요합니다.');
      }
    }

    insights.add('규칙적인 수면 패턴을 유지하는 것이 중요합니다.');

    return insights;
  }
}
