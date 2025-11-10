import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_tracking_provider.dart';
import '../providers/statistics_provider.dart';
import '../models/sleep_record.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({Key? key}) : super(key: key);

  @override
  State<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {}); // UI 업데이트
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildContent(context),
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
            '수면 기록',
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

  Widget _buildContent(BuildContext context) {
    final trackingProvider = context.watch<SleepTrackingProvider>();
    final isTracking = trackingProvider.isTracking;

    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTimerCard(context, trackingProvider, isTracking),
            const SizedBox(height: 20),
            _buildTypeSelector(context, trackingProvider),
            const SizedBox(height: 20),
            _buildActionButton(context, trackingProvider, isTracking),
            if (isTracking) ...[
              const SizedBox(height: 20),
              _buildInfoCard(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context, SleepTrackingProvider provider, bool isTracking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isTracking ? '수면 중' : '수면 준비',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isTracking ? provider.getElapsedTimeString() : '00:00:00',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
              letterSpacing: 2,
            ),
          ),
          if (isTracking) ...[
            const SizedBox(height: 15),
            Text(
              '시작: ${_formatTime(provider.startTime!)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, SleepTrackingProvider provider) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '수면 종류',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  context,
                  '낮잠',
                  'nap',
                  '😴',
                  provider,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTypeOption(
                  context,
                  '밤잠',
                  'night',
                  '🌙',
                  provider,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context,
    String label,
    String value,
    String emoji,
    SleepTrackingProvider provider,
  ) {
    final isSelected = provider.sleepType == value;

    return GestureDetector(
      onTap: provider.isTracking ? null : () {
        // 타입 변경 로직은 여기에 추가 (Provider에 setSleepType 메서드 필요)
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isSelected ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    SleepTrackingProvider provider,
    bool isTracking,
  ) {
    return GestureDetector(
      onTap: () {
        if (isTracking) {
          _stopTracking(context, provider);
        } else {
          provider.startTracking(provider.sleepType);
        }
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isTracking
                ? [const Color(0xFFFF6B6B), const Color(0xFFEE5A6F)]
                : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: (isTracking ? const Color(0xFFFF6B6B) : const Color(0xFF667EEA))
                  .withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            isTracking ? '수면 종료' : '수면 시작',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFE69C)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFF856404),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '수면 중입니다. 종료 버튼을 눌러 기록을 저장하세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _stopTracking(BuildContext context, SleepTrackingProvider provider) {
    if (provider.startTime == null) return;

    final startTime = provider.startTime!;
    final endTime = DateTime.now();

    // 통계에 기록 추가
    final statsProvider = context.read<StatisticsProvider>();
    final newRecord = SleepRecord(
      id: 'record-${DateTime.now().millisecondsSinceEpoch}',
      startTime: startTime,
      endTime: endTime,
      type: provider.sleepType,
    );

    // 여기에 실제로 record를 추가하는 로직 필요 (StatisticsProvider에 addRecord 메서드 추가 필요)

    provider.stopTracking();

    // 완료 다이얼로그 표시
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('수면 기록 완료'),
        content: Text(
          '수면 시간: ${newRecord.durationString}\n'
          '시작: ${_formatTime(startTime)}\n'
          '종료: ${_formatTime(endTime)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 수면 기록 화면 닫기
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
