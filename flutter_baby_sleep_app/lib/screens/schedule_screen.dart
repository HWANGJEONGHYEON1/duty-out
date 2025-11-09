// lib/screens/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TimeOfDay _wakeUpTime = TimeOfDay(hour: 7, minute: 0);
  DateTime _selectedDate = DateTime.now();
  bool _isEditMode = false;
  List<ScheduleItem> _scheduleItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateSchedule();
  }

  void _generateSchedule() {
    // 기상 시간 기반 자동 스케줄 생성
    setState(() {
      _scheduleItems = [
        ScheduleItem(
          time: _wakeUpTime,
          endTime: null,
          title: '기상 및 수유',
          type: ScheduleType.activity,
          icon: Icons.wb_sunny,
        ),
        ScheduleItem(
          time: _addMinutesToTime(_wakeUpTime, 110),
          endTime: _addMinutesToTime(_wakeUpTime, 180),
          title: '낮잠 1',
          type: ScheduleType.sleep,
          icon: Icons.bedtime,
          duration: '1시간 10분',
        ),
        ScheduleItem(
          time: _addMinutesToTime(_wakeUpTime, 180),
          endTime: null,
          title: '기상',
          type: ScheduleType.activity,
          icon: Icons.wb_sunny,
        ),
        ScheduleItem(
          time: _addMinutesToTime(_wakeUpTime, 225),
          endTime: null,
          title: '수유',
          type: ScheduleType.feed,
          icon: Icons.baby_changing_station,
        ),
        ScheduleItem(
          time: _addMinutesToTime(_wakeUpTime, 315),
          endTime: _addMinutesToTime(_wakeUpTime, 420),
          title: '낮잠 2',
          type: ScheduleType.sleep,
          icon: Icons.bedtime,
          duration: '1시간 45분',
        ),
        ScheduleItem(
          time: _addMinutesToTime(_wakeUpTime, 420),
          endTime: null,
          title: '기상 및 수유',
          type: ScheduleType.feed,
          icon: Icons.baby_changing_station,
        ),
        ScheduleItem(
          time: _addMinutesToTime(_wakeUpTime, 555),
          endTime: _addMinutesToTime(_wakeUpTime, 600),
          title: '낮잠 3',
          type: ScheduleType.sleep,
          icon: Icons.bedtime,
          duration: '45분',
        ),
        ScheduleItem(
          time: _addMinutesToTime(_wakeUpTime, 675),
          endTime: null,
          title: '마지막 수유',
          type: ScheduleType.feed,
          icon: Icons.baby_changing_station,
        ),
        ScheduleItem(
          time: _addMinutesToTime(_wakeUpTime, 720),
          endTime: null,
          title: '취침',
          type: ScheduleType.night,
          icon: Icons.nightlight,
        ),
      ];
    });
  }

  TimeOfDay _addMinutesToTime(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute + minutes;
    return TimeOfDay(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
              ),
              child: Column(
                children: [
                  // 앱바
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '일과 스케줄',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              DateFormat('M월 d일 EEEE', 'ko_KR').format(_selectedDate),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isEditMode ? Icons.check : Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isEditMode = !_isEditMode;
                                });
                                if (!_isEditMode) {
                                  _showSaveConfirmation();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.calendar_today, color: Colors.white),
                              onPressed: _selectDate,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 탭바
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    tabs: [
                      Tab(text: '일간'),
                      Tab(text: '주간'),
                      Tab(text: '템플릿'),
                    ],
                  ),
                ],
              ),
            ),
            
            // 탭 콘텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 일간 스케줄
                  _buildDailySchedule(),
                  // 주간 스케줄
                  _buildWeeklySchedule(),
                  // 템플릿
                  _buildTemplates(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySchedule() {
    return Column(
      children: [
        // 기상 시간 설정
        Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '기상 시간',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '기상 시간을 설정하면 일과가 자동 생성됩니다',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _isEditMode ? _selectWakeUpTime : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFF667EEA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _wakeUpTime.format(context),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isEditMode) ...[
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _wakeUpTime = TimeOfDay(hour: 6, minute: 0);
                            _generateSchedule();
                          });
                        },
                        icon: Icon(Icons.wb_twilight, size: 16),
                        label: Text('일찍 (6:00)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF667EEA),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _wakeUpTime = TimeOfDay(hour: 7, minute: 0);
                            _generateSchedule();
                          });
                        },
                        icon: Icon(Icons.wb_sunny, size: 16),
                        label: Text('보통 (7:00)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF667EEA),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _wakeUpTime = TimeOfDay(hour: 8, minute: 0);
                            _generateSchedule();
                          });
                        },
                        icon: Icon(Icons.brightness_high, size: 16),
                        label: Text('늦게 (8:00)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF667EEA),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // 스케줄 리스트
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: _scheduleItems.length,
            itemBuilder: (context, index) {
              return _buildScheduleItem(_scheduleItems[index], index);
            },
          ),
        ),
        
        // 하단 요약
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('총 수면', '14시간 30분', Icons.bedtime),
              _buildSummaryItem('낮잠 횟수', '3회', Icons.wb_sunny),
              _buildSummaryItem('깨어있는 시간', '9시간 30분', Icons.child_care),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(ScheduleItem item, int index) {
    return Dismissible(
      key: Key('schedule_$index'),
      direction: _isEditMode ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _scheduleItems.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일정이 삭제되었습니다'),
            action: SnackBarAction(
              label: '되돌리기',
              onPressed: () {
                setState(() {
                  _scheduleItems.insert(index, item);
                });
              },
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isEditMode ? () => _editScheduleItem(item, index) : null,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item.type == ScheduleType.sleep 
                    ? Color(0xFFF3E5F5) 
                    : item.type == ScheduleType.feed
                        ? Color(0xFFE8F5E9)
                        : item.type == ScheduleType.night
                            ? Color(0xFFE3F2FD)
                            : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _getItemColor(item.type).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // 시간
                  Container(
                    width: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.time.format(context),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getItemColor(item.type),
                          ),
                        ),
                        if (item.endTime != null)
                          Text(
                            '~ ${item.endTime!.format(context)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // 아이콘
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getItemColor(item.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item.icon,
                      color: _getItemColor(item.type),
                      size: 20,
                    ),
                  ),
                  
                  // 내용
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.duration != null)
                          Text(
                            item.duration!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // 드래그 핸들 또는 체크 표시
                  if (_isEditMode)
                    Icon(Icons.drag_handle, color: Colors.grey[400])
                  else if (item.isCompleted)
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getItemColor(ScheduleType type) {
    switch (type) {
      case ScheduleType.sleep:
        return Color(0xFF764BA2);
      case ScheduleType.feed:
        return Color(0xFF4CAF50);
      case ScheduleType.night:
        return Color(0xFF2196F3);
      case ScheduleType.activity:
      default:
        return Color(0xFF667EEA);
    }
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF667EEA), size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySchedule() {
    return Center(
      child: Text('주간 스케줄 뷰 (개발 중)'),
    );
  }

  Widget _buildTemplates() {
    final templates = [
      {'age': '1-2개월', 'naps': '4-5회', 'total': '16-18시간'},
      {'age': '3-4개월', 'naps': '3-4회', 'total': '14-16시간'},
      {'age': '5-6개월', 'naps': '3회', 'total': '14-15시간'},
      {'age': '7-9개월', 'naps': '2-3회', 'total': '13-14시간'},
      {'age': '10-12개월', 'naps': '2회', 'total': '12-14시간'},
      {'age': '12-18개월', 'naps': '1-2회', 'total': '11-14시간'},
    ];

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '👶',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              title: Text(
                '${template['age']} 템플릿',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text('낮잠: ${template['naps']}'),
                  Text('총 수면: ${template['total']}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _applyTemplate(template),
                child: Text('적용'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectWakeUpTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wakeUpTime,
    );
    
    if (picked != null && picked != _wakeUpTime) {
      setState(() {
        _wakeUpTime = picked;
        _generateSchedule();
      });
    }
  }

  void _editScheduleItem(ScheduleItem item, int index) {
    // 스케줄 아이템 편집 다이얼로그
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('일정 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: item.title),
              decoration: InputDecoration(labelText: '일정 이름'),
            ),
            // 시간 선택 등 추가 UI
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 저장 로직
              Navigator.pop(context);
            },
            child: Text('저장'),
          ),
        ],
      ),
    );
  }

  void _applyTemplate(Map<String, String> template) {
    // 템플릿 적용 로직
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${template['age']} 템플릿이 적용되었습니다'),
        backgroundColor: Color(0xFF667EEA),
      ),
    );
  }

  void _showSaveConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('스케줄이 저장되었습니다'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }
}

// 스케줄 아이템 모델
enum ScheduleType { sleep, feed, activity, night }

class ScheduleItem {
  final TimeOfDay time;
  final TimeOfDay? endTime;
  final String title;
  final ScheduleType type;
  final IconData icon;
  final String? duration;
  bool isCompleted;

  ScheduleItem({
    required this.time,
    this.endTime,
    required this.title,
    required this.type,
    required this.icon,
    this.duration,
    this.isCompleted = false,
  });
}
