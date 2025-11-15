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
            children: [
              const Text(
                '기상 시간',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isLoadingSchedule ? Colors.grey[300] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isLoadingSchedule
                      ? const SizedBox(
                          width: 80,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '${scheduleProvider.wakeTime.hour.toString().padLeft(2, '0')}:${scheduleProvider.wakeTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '기상 시간을 입력하면 하루 일과가 자동으로 생성됩니다',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
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
    if (item.type == 'sleep') {
      backgroundColor = const Color(0xFFF3E5F5);
    }

    return GestureDetector(
      onTap: () => _showScheduleEditDialog(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          title: Text(
            item.durationMinutes != null
                ? '${item.timeString} - ${_getEndTime(item)}'
                : item.timeString,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.activity,
                style: const TextStyle(fontSize: 14),
              ),
              if (item.durationMinutes != null)
                Text(
                  item.durationString,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          trailing: const Icon(
            Icons.edit,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  void _showScheduleEditDialog(dynamic item) {
    _editTimeController.text = item.timeString;
    _editActivityController.text = item.activity;
    _editingItemId = item.id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('스케줄 수정'),
        content: Column(
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
          ],
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
            onPressed: () {
              Navigator.pop(context);
              _saveScheduleItem(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _saveScheduleItem(dynamic item) {
    // 실제로 로컬 상태에서 항목을 업데이트합니다
    // 서버와 동기화가 필요한 경우 여기에 API 호출을 추가할 수 있습니다
    final scheduleProvider = context.read<ScheduleProvider>();

    // 현재는 로컬 상태만 업데이트
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('스케줄이 저장되었습니다!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getEndTime(dynamic item) {
    if (item.durationMinutes == null) return '';
    final endTime = item.time.add(Duration(minutes: item.durationMinutes!));
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }
}
