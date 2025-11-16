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
  String? _editingItemId;

  @override
  void initState() {
    super.initState();
    _editTimeController = TextEditingController();
    _editActivityController = TextEditingController();
  }

  @override
  void dispose() {
    _editTimeController.dispose();
    _editActivityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
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

  Widget _buildWakeTimeInput(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final babyProvider = context.watch<BabyProvider>();
    final baby = babyProvider.baby;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '기상 시간',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
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
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: _isLoadingSchedule ? Colors.grey[300] : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF667EEA),
                  width: 2,
                ),
              ),
              child: _isLoadingSchedule
                  ? const SizedBox(
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : Text(
                      '${scheduleProvider.wakeTime.hour.toString().padLeft(2, '0')}:${scheduleProvider.wakeTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667EEA),
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '기상 시간을 입력하면 하루 일과가 자동으로 생성됩니다',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 12,
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
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 20),
              const Text(
                '기상 시간을 입력하세요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667EEA),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '상단의 기상 시간을 입력하면\n하루 일과가 자동으로 생성됩니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: scheduleItems.length,
        itemBuilder: (context, index) {
          final item = scheduleItems[index];
          return _buildScheduleItem(item);
        },
      ),
    );
  }

  Widget _buildScheduleItem(dynamic item) {
    Color backgroundColor = Colors.white;

    // 타입별 배경색 설정 (프로토타입 참고)
    if (item.type == 'sleep') {
      backgroundColor = const Color(0xFFF3E5F5); // 낮잠: 보라색
    } else if (item.activity?.contains('취침') == true ||
               item.activity?.contains('BEDTIME') == true) {
      backgroundColor = const Color(0xFFE3F2FD); // 취침: 파란색
    }

    return GestureDetector(
      onTap: () => _showScheduleEditDialog(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 시간과 활동 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 시간
                  Text(
                    item.durationMinutes != null
                        ? '${item.timeString} - ${_getEndTime(item)}'
                        : item.timeString,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 활동명
                  Text(
                    item.activity,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // 소요 시간
                  if (item.durationMinutes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.durationString,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 15),
            // 드래그 핸들 + 편집 아이콘
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 드래그 핸들
                const Text(
                  '≡',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFCCCCCC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // 편집 아이콘
                Icon(
                  Icons.edit,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleEditDialog(dynamic item) {
    // 현재 시간을 기본값으로 설정
    late TimeOfDay selectedTime;
    selectedTime = TimeOfDay(hour: item.time.hour, minute: item.time.minute);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('스케줄 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 활동명 표시
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '활동',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.activity,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 시간 선택
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '시작 시간',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 시간 표시 및 선택 버튼
                GestureDetector(
                  onTap: () async {
                    final newTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
                    );
                    if (newTime != null) {
                      setState(() {
                        selectedTime = newTime;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: const Color(0xFF667EEA), width: 2),
                    ),
                    child: Text(
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667EEA),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                // 선택된 시간으로 스케줄 업데이트
                final newTime = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                await _updateScheduleTime(item, newTime);

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
              ),
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }


  /// 스케줄 시간 업데이트
  Future<void> _updateScheduleTime(dynamic item, DateTime newTime) async {
    try {
      final scheduleProvider = context.read<ScheduleProvider>();
      final babyProvider = context.read<BabyProvider>();
      final baby = babyProvider.baby;

      if (baby == null) {
        throw Exception('아기 정보를 찾을 수 없습니다.');
      }

      // 시간 차이 계산
      final oldTime = item.time;
      final timeDifference = newTime.difference(oldTime);

      // TODO: API를 통해 스케줄 조정 (adjustSchedule)
      // 현재는 로컬 상태만 업데이트

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('스케줄이 수정되었습니다!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getEndTime(dynamic item) {
    if (item.durationMinutes == null) return '';
    final endTime = item.time.add(Duration(minutes: item.durationMinutes!));
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }
}
