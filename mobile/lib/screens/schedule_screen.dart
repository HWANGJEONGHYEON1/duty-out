import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../providers/schedule_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? _error;
  bool _isLoadingSchedule = false;

  // 편집 관련 변수
  late TextEditingController _editTimeController;
  late TextEditingController _editActivityController;
  late TextEditingController _feedingAmountController;
  late TextEditingController _sleepDurationController;
  String? _editingItemId;

  @override
  void initState() {
    super.initState();
    _editTimeController = TextEditingController();
    _editActivityController = TextEditingController();
    _feedingAmountController = TextEditingController();
    _sleepDurationController = TextEditingController();
  }

  @override
  void dispose() {
    _editTimeController.dispose();
    _editActivityController.dispose();
    _feedingAmountController.dispose();
    _sleepDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          _buildTodaySummary(context),
          _buildWakeTimeInput(context),
          Expanded(
            child: _buildScheduleList(context),
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
      child: Column(
        children: [
          const Text(
            '일과 스케줄 편집',
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

  // 오늘의 수유/수면 요약
  Widget _buildTodaySummary(BuildContext context) {
    final scheduleItems = context.watch<ScheduleProvider>().scheduleItems;

    // 오늘 수유량 집계
    int totalFeeding = 0;
    int feedingCount = 0;
    for (var item in scheduleItems) {
      if (item.type == 'feed' && item.feedingAmount != null) {
        totalFeeding += item.feedingAmount!;
        feedingCount++;
      }
    }

    // 오늘 수면 시간 집계
    int totalSleep = 0;
    int sleepCount = 0;
    for (var item in scheduleItems) {
      if (item.type == 'sleep' && item.actualSleepDuration != null) {
        totalSleep += item.actualSleepDuration!;
        sleepCount++;
      }
    }

    final sleepHours = totalSleep ~/ 60;
    final sleepMinutes = totalSleep % 60;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          // 오늘 수유
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF9800).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          size: 16,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '오늘 수유',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$totalFeeding ml',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$feedingCount회 기록',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 오늘 수면
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF9C27B0).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.nights_stay,
                          size: 16,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '오늘 수면',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    sleepHours > 0 ? '${sleepHours}h ${sleepMinutes}m' : '${sleepMinutes}m',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9C27B0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sleepCount회 기록',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWakeTimeInput(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final babyProvider = context.watch<BabyProvider>();
    final baby = babyProvider.baby;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '기상 시간 설정',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '하루 일과가 자동으로 생성돼요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.light_mode,
                  size: 20,
                  color: Color(0xFF667EEA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 시간 선택 카드
          GestureDetector(
            onTap: baby == null || _isLoadingSchedule
                ? null
                : () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(scheduleProvider.wakeTime),
                    );
                    if (time != null && mounted) {
                      final now = DateTime.now();
                      final newWakeTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        time.hour,
                        time.minute,
                      );
                      await _updateWakeTime(scheduleProvider, newWakeTime, baby.id);
                    }
                  },
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isLoadingSchedule)
                    const SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    )
                  else
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${scheduleProvider.wakeTime.hour.toString().padLeft(2, '0')}:${scheduleProvider.wakeTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '탭하여 변경',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // 에러 메시지
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _error = null;
                      });
                    },
                    child: Icon(Icons.close, color: Colors.red[700], size: 18),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateWakeTime(
    ScheduleProvider scheduleProvider,
    DateTime newWakeTime,
    int babyId,
  ) async {
    setState(() {
      _isLoadingSchedule = true;
      _error = null;
    });

    try {
      await scheduleProvider.updateWakeTime(newWakeTime, babyId: babyId);

      if (mounted) {
        setState(() {
          _isLoadingSchedule = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('스케줄이 생성되었습니다!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '스케줄 생성 실패: $e';
          _isLoadingSchedule = false;
        });
      }
    }
  }

  Widget _buildScheduleList(BuildContext context) {
    final scheduleItems = context.watch<ScheduleProvider>().scheduleItems;

    if (scheduleItems.isEmpty) {
      return Container(
        color: Colors.grey[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 48,
                  color: Color(0xFF667EEA),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '아직 스케줄이 없어요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '상단에서 기상 시간을 입력하면\n하루 일과가 자동으로 생성돼요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: scheduleItems.length,
        itemBuilder: (context, index) {
          final item = scheduleItems[index];
          return _buildScheduleItem(item, index);
        },
      ),
    );
  }

  Widget _buildScheduleItem(dynamic item, int index) {
    // 타입별 색상 지정
    final Map<String, Map<String, dynamic>> typeConfig = {
      'wake': {
        'color': const Color(0xFFFFF9E6),
        'icon': Icons.wb_sunny,
        'iconColor': const Color(0xFFFFA500),
      },
      'feed': {
        'color': const Color(0xFFFFF3E0),
        'icon': Icons.restaurant,
        'iconColor': const Color(0xFFFF9800),
      },
      'sleep': {
        'color': const Color(0xFFF3E5F5),
        'icon': Icons.nights_stay,
        'iconColor': const Color(0xFF9C27B0),
      },
      'play': {
        'color': const Color(0xFFE8F5E9),
        'icon': Icons.toys,
        'iconColor': const Color(0xFF4CAF50),
      },
    };

    final config = typeConfig[item.type] ?? typeConfig['wake']!;
    final backgroundColor = config['color'] as Color;
    final icon = config['icon'] as IconData;
    final iconColor = config['iconColor'] as Color;

    // 수유량 또는 수면 시간 표시
    String? recordInfo;
    if (item.type == 'feed' && item.feedingAmount != null) {
      recordInfo = '${item.feedingAmount}ml 기록됨';
    } else if (item.type == 'sleep' && item.actualSleepDuration != null) {
      final hours = item.actualSleepDuration ~/ 60;
      final minutes = item.actualSleepDuration % 60;
      recordInfo = hours > 0 ? '${hours}시간 ${minutes}분 기록됨' : '${minutes}분 기록됨';
    }

    return GestureDetector(
      onTap: () => _showScheduleEditDialog(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: iconColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 시간과 기록 정보 (수유는 수유량 함께 표시)
                    Text(
                      item.type == 'feed' && item.feedingAmount != null
                          ? '${item.timeString} - ${item.activity} (${item.feedingAmount}ml)'
                          : (item.durationMinutes != null
                              ? '${item.timeString} - ${_getEndTime(item)}'
                              : item.timeString),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 3),

                    // 활동명 (수유가 아닐 때만 표시)
                    if (item.type != 'feed') ...[
                      Text(
                        item.activity,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    // 기록 정보 (수면 시간 또는 남은 시간)
                    if (recordInfo != null && item.type != 'feed') ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: iconColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recordInfo,
                              style: TextStyle(
                                fontSize: 11,
                                color: iconColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 소요 시간
                    if (item.durationMinutes != null && item.type != 'sleep') ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.durationString,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 편집 버튼
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit,
                  size: 18,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleEditDialog(dynamic item) {
    _editTimeController.text = item.timeString;
    _editActivityController.text = item.activity;
    _feedingAmountController.text = item.feedingAmount?.toString() ?? '';
    _sleepDurationController.text = item.actualSleepDuration?.toString() ?? '';
    _editingItemId = item.id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item.activity} 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editTimeController,
                decoration: const InputDecoration(
                  labelText: '시간',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(item.time),
                  );
                  if (time != null) {
                    _editTimeController.text = time.format(context);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _editActivityController,
                decoration: const InputDecoration(
                  labelText: '활동명',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // 수유 타입인 경우 수유량 입력
              if (item.type == 'feed') ...[
                TextField(
                  controller: _feedingAmountController,
                  decoration: const InputDecoration(
                    labelText: '수유량 (ml)',
                    border: OutlineInputBorder(),
                    suffixText: 'ml',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                Text(
                  '실제 수유한 양을 입력해주세요',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],

              // 수면 타입인 경우 수면 시간 입력
              if (item.type == 'sleep') ...[
                TextField(
                  controller: _sleepDurationController,
                  decoration: const InputDecoration(
                    labelText: '실제 수면 시간 (분)',
                    border: OutlineInputBorder(),
                    suffixText: '분',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                Text(
                  '실제로 잔 시간을 분 단위로 입력해주세요',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editingItemId = null;
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveScheduleItem(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
            ),
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveScheduleItem(dynamic item) async {
    try {
      String? newTime;
      int? feedingAmount;
      int? sleepDuration;

      // 시간 변경 확인
      if (_editTimeController.text.isNotEmpty &&
          _editTimeController.text != item.timeString) {
        newTime = _editTimeController.text;
        item.timeString = newTime;
      }

      // 수유량 저장
      if (item.type == 'feed' && _feedingAmountController.text.isNotEmpty) {
        feedingAmount = int.tryParse(_feedingAmountController.text);
        item.feedingAmount = feedingAmount;
      }

      // 수면 시간 저장
      if (item.type == 'sleep' && _sleepDurationController.text.isNotEmpty) {
        sleepDuration = int.tryParse(_sleepDurationController.text);
        item.actualSleepDuration = sleepDuration;
      }

      // API 호출하여 서버에 저장
      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);
      await scheduleProvider.updateScheduleItem(
        itemId: item.id,
        scheduledTime: newTime,
        feedingAmount: feedingAmount,
        actualSleepDuration: sleepDuration,
      );

      setState(() {
        // UI 업데이트
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기록이 저장되었습니다!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getEndTime(dynamic item) {
    if (item.durationMinutes == null) return '';
    final endTime = item.time.add(Duration(minutes: item.durationMinutes!));
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }
}
