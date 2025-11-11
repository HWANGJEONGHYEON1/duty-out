import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/statistics_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildHistoryList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Text(
            '수면 기록 히스토리',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    final statsProvider = context.watch<StatisticsProvider>();
    final records = statsProvider.sleepRecords;

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bedtime_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              '아직 기록된 수면이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // 날짜별로 그룹화
    final groupedRecords = _groupRecordsByDate(records);

    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: groupedRecords.length,
        itemBuilder: (context, index) {
          final date = groupedRecords.keys.elementAt(index);
          final dayRecords = groupedRecords[date]!;

          return _buildDateSection(context, date, dayRecords);
        },
      ),
    );
  }

  Map<DateTime, List<dynamic>> _groupRecordsByDate(List<dynamic> records) {
    final Map<DateTime, List<dynamic>> grouped = {};

    for (var record in records) {
      final date = DateTime(
        record.startTime.year,
        record.startTime.month,
        record.startTime.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(record);
    }

    // 최신 날짜 순으로 정렬
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var key in sortedKeys) key: grouped[key]!};
  }

  Widget _buildDateSection(BuildContext context, DateTime date, List<dynamic> records) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String dateLabel;
    if (date == today) {
      dateLabel = '오늘';
    } else if (date == yesterday) {
      dateLabel = '어제';
    } else {
      dateLabel = DateFormat('M월 d일 (E)', 'ko').format(date);
    }

    final totalMinutes = records.fold<int>(0, (sum, record) => sum + record.durationMinutes);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '총 ${hours}h ${minutes}m',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ...records.map((record) => _buildRecordCard(context, record)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecordCard(BuildContext context, dynamic record) {
    final startTime = record.startTime;
    final endTime = record.endTime;
    final isNap = record.type == 'nap';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isNap ? const Color(0xFF764BA2) : const Color(0xFF4A90E2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isNap
                    ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                    : [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                isNap ? '😴' : '🌙',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNap ? '낮잠' : '밤잠',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.durationString,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNap
                      ? const Color(0xFFF3E5F5)
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  isNap ? '낮' : '밤',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isNap
                        ? const Color(0xFF764BA2)
                        : const Color(0xFF4A90E2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
