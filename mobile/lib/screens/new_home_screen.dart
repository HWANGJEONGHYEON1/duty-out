import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/baby_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/statistics_provider.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  late TextEditingController _nameController;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final baby = context.watch<BabyProvider>().baby;
    if (baby != null && _nameController.text != baby.name) {
      _nameController.text = baby.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baby = context.watch<BabyProvider>().baby;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTodaySummaryCard(context),
                  _buildNextScheduleCard(context),
                  _buildScheduleList(context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: baby != null
          ? FloatingActionButton.extended(
              onPressed: () => _showScheduleRegistrationDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('스케줄 생성'),
              backgroundColor: const Color(0xFF667EEA),
            )
          : null,
    );
  }

  // 스케줄 생성 다이얼로그
  void _showScheduleRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _ScheduleRegistrationDialog(parentContext: context);
      },
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              const Text(
                '오늘의 일과',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              if (_isEditingName && baby != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.check, color: Colors.white, size: 20),
                        onPressed: () => _saveBabyName(context),
                      ),
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditingName = true;
                    });
                  },
                  child: Text(
                    baby != null ? '👶 ${baby.name} (${baby.ageText})' : '👶',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => _showRecommendedInfo(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBabyName(BuildContext context) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이름을 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final babyProvider = context.read<BabyProvider>();
      final baby = babyProvider.baby;

      if (baby == null) {
        throw Exception('아기 정보를 찾을 수 없습니다');
      }

      await babyProvider.updateBabyInfo(
        babyId: baby.id,
        name: newName,
      );

      if (mounted) {
        setState(() {
          _isEditingName = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이름이 수정되었습니다!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이름 수정 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRecommendedInfo(BuildContext context) {
    final baby = context.read<BabyProvider>().baby;
    final ageInMonths = baby?.ageInMonths ?? 4;

    // 개월수별 권장 정보
    Map<String, String> recommendations = _getRecommendations(ageInMonths);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${ageInMonths}개월 권장 정보'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('깨어있는 시간', recommendations['wakeTime']!),
              const SizedBox(height: 10),
              _buildInfoRow('낮잠 시간', recommendations['napTime']!),
              const SizedBox(height: 10),
              _buildInfoRow('밤잠 시간', recommendations['nightTime']!),
              const SizedBox(height: 10),
              _buildInfoRow('수유량', recommendations['feedAmount']!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Map<String, String> _getRecommendations(int months) {
    if (months <= 2) {
      return {
        'wakeTime': '1시간',
        'napTime': '낮잠 4-5회\n(총 4-5시간)',
        'nightTime': '9-10시간',
        'feedAmount': '하루 6-8회\n(120-150ml/회)',
      };
    } else if (months <= 4) {
      return {
        'wakeTime': '1.5-2시간',
        'napTime': '낮잠 3-4회\n(총 3-4시간)',
        'nightTime': '10-11시간',
        'feedAmount': '하루 5-6회\n(150-180ml/회)',
      };
    } else if (months <= 6) {
      return {
        'wakeTime': '2-2.5시간',
        'napTime': '낮잠 3회\n(총 3-4시간)',
        'nightTime': '10-11시간',
        'feedAmount': '하루 4-5회\n(180-210ml/회)',
      };
    } else if (months <= 8) {
      return {
        'wakeTime': '2.5-3시간',
        'napTime': '낮잠 2-3회\n(총 2.5-3.5시간)',
        'nightTime': '10-11시간',
        'feedAmount': '하루 3-4회\n(210-240ml/회)\n+ 이유식',
      };
    } else if (months <= 11) {
      return {
        'wakeTime': '3-3.5시간',
        'napTime': '낮잠 2회\n(총 2-3시간)',
        'nightTime': '10-11시간',
        'feedAmount': '하루 3회\n(240ml/회)\n+ 이유식 2-3회',
      };
    } else {
      return {
        'wakeTime': '4-5시간',
        'napTime': '낮잠 1-2회\n(총 1.5-2.5시간)',
        'nightTime': '10-11시간',
        'feedAmount': '하루 2-3회\n(240ml/회)\n+ 식사 3회',
      };
    }
  }

  Widget _buildTodaySummaryCard(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('M월 d일 EEEE', 'ko_KR');
    final statistics = context.watch<StatisticsProvider>();

    // 오늘의 통계 계산
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // 오늘의 총 수면 시간
    final todaySleep = statistics.sleepRecords
        .where((record) =>
            record.startTime.isAfter(todayStart) &&
            record.startTime.isBefore(todayEnd))
        .fold<int>(0, (sum, record) => sum + record.durationMinutes);

    // 오늘의 총 수유량
    final todayFeeding = statistics.feedingRecords
        .where((record) =>
            record.time.isAfter(todayStart) &&
            record.time.isBefore(todayEnd))
        .fold<int>(0, (sum, record) => sum + record.amount);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat.format(now),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  '😴 오늘 수면',
                  '${(todaySleep / 60).toStringAsFixed(1)}시간',
                  const Color(0xFF764BA2),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSummaryItem(
                  '🍼 오늘 수유',
                  '${todayFeeding}ml',
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextScheduleCard(BuildContext context) {
    final scheduleItems = context.watch<ScheduleProvider>().scheduleItems;

    if (scheduleItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // 현재 시간 기준으로 다음 일정 찾기
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    dynamic nextSchedule;
    int minutesUntilNext = 0;

    for (var item in scheduleItems) {
      final scheduleMinutes = item.time.hour * 60 + item.time.minute;
      if (scheduleMinutes > currentMinutes) {
        nextSchedule = item;
        minutesUntilNext = (scheduleMinutes - currentMinutes).toInt();
        break;
      }
    }

    // 다음날 첫 일정으로 넘어가는 경우
    if (nextSchedule == null && scheduleItems.isNotEmpty) {
      nextSchedule = scheduleItems.first;
      final scheduleMinutes = nextSchedule.time.hour * 60 + nextSchedule.time.minute;
      minutesUntilNext = ((24 * 60 - currentMinutes) + scheduleMinutes).toInt();
    }

    if (nextSchedule == null) {
      return const SizedBox.shrink();
    }

    final hours = minutesUntilNext ~/ 60;
    final minutes = minutesUntilNext % 60;
    String timeText = '';
    if (hours > 0) {
      timeText = '$hours시간 $minutes분';
    } else {
      timeText = '$minutes분';
    }

    Color borderColor;
    switch (nextSchedule.type) {
      case 'sleep':
        borderColor = const Color(0xFF764BA2);
        break;
      case 'feed':
        borderColor = const Color(0xFF4CAF50);
        break;
      case 'play':
        borderColor = const Color(0xFFFF9800);
        break;
      default:
        borderColor = const Color(0xFF667EEA);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            timeText,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${nextSchedule.activity}까지',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(BuildContext context) {
    final scheduleItems = context.watch<ScheduleProvider>().scheduleItems;

    if (scheduleItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.schedule,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              '기상시간 입력하세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF667EEA),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '설정 탭에서 기상 시간을 입력하면\n하루 일과가 자동으로 생성됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Text(
                '오늘의 전체 일정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),
          ...scheduleItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildScheduleCard(context, item, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, dynamic item, int index) {
    Color borderColor;
    Color backgroundColor;

    switch (item.type) {
      case 'sleep':
        borderColor = const Color(0xFF764BA2);
        backgroundColor = const Color(0xFFF3E5F5);
        break;
      case 'feed':
        borderColor = const Color(0xFF4CAF50);
        backgroundColor = const Color(0xFFE8F5E9);
        break;
      case 'play':
        borderColor = const Color(0xFFFF9800);
        backgroundColor = const Color(0xFFFFF3E0);
        break;
      default:
        borderColor = const Color(0xFF667EEA);
        backgroundColor = const Color(0xFFF8F9FA);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [borderColor.withOpacity(0.8), borderColor],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              item.timeString,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        title: Text(
          item.activity,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: item.durationMinutes != null
            ? Text(
                item.durationString,
                style: const TextStyle(fontSize: 12),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey),
          onPressed: () => _editScheduleItem(context, item, index),
        ),
      ),
    );
  }

  void _editScheduleItem(BuildContext context, dynamic item, int index) {
    showDialog(
      context: context,
      builder: (context) => _EditScheduleItemDialog(
        parentContext: context,
        item: item,
        index: index,
      ),
    );
  }
}

// 스케줄 생성 다이얼로그
class _ScheduleRegistrationDialog extends StatefulWidget {
  final BuildContext parentContext;

  const _ScheduleRegistrationDialog({required this.parentContext});

  @override
  State<_ScheduleRegistrationDialog> createState() => _ScheduleRegistrationDialogState();
}

class _ScheduleRegistrationDialogState extends State<_ScheduleRegistrationDialog> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('기상 시간 설정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('스케줄을 생성할 기상 시간을 선택해주세요'),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _isLoading ? null : () => _selectTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF667EEA)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  const Icon(Icons.access_time, color: Color(0xFF667EEA)),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitSchedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  '생성',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final scheduleProvider =
          widget.parentContext.read<ScheduleProvider>();
      final baby = widget.parentContext.read<BabyProvider>().baby;

      if (baby == null) {
        throw Exception('아기 정보를 찾을 수 없습니다');
      }

      // 선택한 시간으로 스케줄 생성
      final wakeUpTime = DateTime(
        2000,
        1,
        1,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await scheduleProvider.updateWakeTime(wakeUpTime, babyId: baby.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          const SnackBar(
            content: Text('스케줄이 생성되었습니다!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text('스케줄 생성 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// 스케줄 항목 수정 다이얼로그
class _EditScheduleItemDialog extends StatefulWidget {
  final BuildContext parentContext;
  final dynamic item;
  final int index;

  const _EditScheduleItemDialog({
    required this.parentContext,
    required this.item,
    required this.index,
  });

  @override
  State<_EditScheduleItemDialog> createState() => _EditScheduleItemDialogState();
}

class _EditScheduleItemDialogState extends State<_EditScheduleItemDialog> {
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 기존 시간으로 초기화
    if (widget.item.time != null) {
      _selectedTime = TimeOfDay(
        hour: widget.item.time.hour,
        minute: widget.item.time.minute,
      );
    } else {
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.item.activity} 시간 수정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('새로운 시간을 선택해주세요'),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _isLoading ? null : () => _selectTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF667EEA)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  const Icon(Icons.access_time, color: Color(0xFF667EEA)),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitEdit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  '저장',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitEdit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final scheduleProvider =
          widget.parentContext.read<ScheduleProvider>();
      final baby = widget.parentContext.read<BabyProvider>().baby;

      if (baby == null) {
        throw Exception('아기 정보를 찾을 수 없습니다');
      }

      // 새로운 시간
      final newTime = DateTime(
        2000,
        1,
        1,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // 스케줄 항목 수정 (scheduleItemId 필요)
      await scheduleProvider.adjustScheduleItem(
        babyId: baby.id,
        scheduleItemId: widget.item.id,
        actualStartTime: newTime,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          const SnackBar(
            content: Text('스케줄이 수정되었습니다!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text('스케줄 수정 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
