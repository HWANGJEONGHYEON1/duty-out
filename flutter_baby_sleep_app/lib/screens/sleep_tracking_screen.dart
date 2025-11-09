// lib/screens/statistics_screen.dart (계속)
          ),
          
          SizedBox(height = 20),
          
          // 주간 평균 지표
          Row(
            children = [
              Expanded(
                child: _buildStatCard(
                  title: '평균 수면',
                  value: '14.2시간',
                  icon: Icons.bedtime,
                  color: Color(0xFF667EEA),
                  trend: '적정',
                  isPositive: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: '평균 낮잠',
                  value: '3.2회',
                  icon: Icons.wb_sunny,
                  color: Color(0xFFFF9800),
                  trend: '안정적',
                  isPositive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // 월간 캘린더 뷰
          Container(
            padding: EdgeInsets.all(20),
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
                Text(
                  '월간 수면 달력',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                // 캘린더 그리드 (간략한 표현)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    final quality = (index % 3 == 0) ? 0.9 : (index % 2 == 0) ? 0.7 : 0.5;
                    return Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Color(0xFF667EEA).withOpacity(quality),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // 월간 요약
          _buildMonthSummary(),
        ],
      ),
    );
  }

  Widget _buildMonthSummary() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            '이번 달 요약',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          _buildSummaryRow('총 수면 시간', '425시간', '일 평균 14.2시간'),
          Divider(height: 24),
          _buildSummaryRow('최고 기록', '15.5시간', '11월 15일'),
          Divider(height: 24),
          _buildSummaryRow('수면 목표 달성', '23일/30일', '77% 달성'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667EEA),
          ),
        ),
      ],
    );
  }

  String _getDateRangeText() {
    if (_selectedPeriod == '일간') {
      return DateFormat('M월 d일').format(_selectedDate);
    } else if (_selectedPeriod == '주간') {
      final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final weekEnd = weekStart.add(Duration(days: 6));
      return '${DateFormat('M.d').format(weekStart)} - ${DateFormat('M.d').format(weekEnd)}';
    } else {
      return DateFormat('yyyy년 M월').format(_selectedDate);
    }
  }

  void _previousPeriod() {
    setState(() {
      if (_selectedPeriod == '일간') {
        _selectedDate = _selectedDate.subtract(Duration(days: 1));
      } else if (_selectedPeriod == '주간') {
        _selectedDate = _selectedDate.subtract(Duration(days: 7));
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_selectedPeriod == '일간') {
        _selectedDate = _selectedDate.add(Duration(days: 1));
      } else if (_selectedPeriod == '주간') {
        _selectedDate = _selectedDate.add(Duration(days: 7));
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      }
    });
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('데이터 내보내기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text('PDF로 내보내기'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF 생성 중...')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Colors.green),
              title: Text('Excel로 내보내기'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Excel 파일 생성 중...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareStats() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('공유 기능 준비 중...')),
    );
  }
}

// 수면 패턴 페인터
class SleepPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final hourWidth = size.width / 24;
    
    // 24시간 패턴 그리기 (예시)
    final patterns = [
      {'start': 0, 'end': 7, 'type': 'sleep'},
      {'start': 7, 'end': 9, 'type': 'awake'},
      {'start': 9, 'end': 10.5, 'type': 'sleep'},
      {'start': 10.5, 'end': 12.5, 'type': 'awake'},
      {'start': 12.5, 'end': 14, 'type': 'sleep'},
      {'start': 14, 'end': 16, 'type': 'awake'},
      {'start': 16, 'end': 17, 'type': 'sleep'},
      {'start': 17, 'end': 19, 'type': 'awake'},
      {'start': 19, 'end': 24, 'type': 'sleep'},
    ];
    
    for (var pattern in patterns) {
      final startX = (pattern['start'] as num) * hourWidth;
      final endX = (pattern['end'] as num) * hourWidth;
      
      if (pattern['type'] == 'sleep') {
        paint.color = Color(0xFF667EEA);
      } else if (pattern['type'] == 'awake') {
        paint.color = Color(0xFFFFA726);
      } else {
        paint.color = Color(0xFF4CAF50);
      }
      
      canvas.drawRect(
        Rect.fromLTWH(startX, 20, endX - startX, 60),
        paint,
      );
    }
    
    // 시간 마커
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    for (int i = 0; i <= 24; i += 6) {
      textPainter.text = TextSpan(
        text: '$i시',
        style: TextStyle(fontSize: 10, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(i * hourWidth - 10, 85));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// lib/screens/sleep_tracking_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class SleepTrackingScreen extends StatefulWidget {
  @override
  _SleepTrackingScreenState createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> 
    with TickerProviderStateMixin {
  Timer? _timer;
  DateTime _startTime = DateTime.now();
  Duration _elapsed = Duration.zero;
  bool _isTracking = true;
  
  // 애니메이션 컨트롤러
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  // 수면 단계
  String _sleepStage = '입면 중';
  List<String> _events = [];
  
  @override
  void initState() {
    super.initState();
    
    // 애니메이션 설정
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _waveController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_waveController);
    
    // 타이머 시작
    _startTimer();
    
    // 시스템 UI 어둡게
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }
  
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime);
        
        // 수면 단계 자동 업데이트 (시뮬레이션)
        if (_elapsed.inMinutes > 20) {
          _sleepStage = '깊은 수면';
        } else if (_elapsed.inMinutes > 10) {
          _sleepStage = '얕은 수면';
        }
      });
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.dispose();
  }
  
  void _stopTracking() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SleepEndBottomSheet(
        duration: _elapsed,
        onSave: () {
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('수면 기록이 저장되었습니다'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        },
      ),
    );
  }
  
  void _addEvent(String event) {
    setState(() {
      _events.add('${_formatTime(_elapsed)} - $event');
    });
    
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('이벤트가 기록되었습니다: $event'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1B3A),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('수면 추적 중단'),
                          content: Text('수면 추적을 중단하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('계속 추적'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text('중단'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Text(
                    '수면 추적 중',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      // 설정 다이얼로그
                    },
                  ),
                ],
              ),
            ),
            
            // 메인 수면 추적 UI
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 수면 시각화
                  Container(
                    width: 250,
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 물결 애니메이션
                        AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    0.3 * (1 - _waveAnimation.value),
                                  ),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // 중앙 원
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Color(0xFF667EEA),
                                      Color(0xFF764BA2),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF667EEA).withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bedtime,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      _formatTime(_elapsed),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // 수면 단계
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _sleepStage,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 60),
                  
                  // 이벤트 버튼들
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _EventButton(
                          icon: Icons.notifications_off,
                          label: '깨어남',
                          onTap: () => _addEvent('깨어남'),
                        ),
                        _EventButton(
                          icon: Icons.airline_seat_individual_suite,
                          label: '뒤집기',
                          onTap: () => _addEvent('뒤집기'),
                        ),
                        _EventButton(
                          icon: Icons.volume_up,
                          label: '울음',
                          onTap: () => _addEvent('울음'),
                        ),
                        _EventButton(
                          icon: Icons.baby_changing_station,
                          label: '수유',
                          onTap: () => _addEvent('수유'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 종료 버튼
            Container(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _stopTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    '수면 종료',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 이벤트 버튼 위젯
class _EventButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  _EventButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 수면 종료 바텀시트
class _SleepEndBottomSheet extends StatefulWidget {
  final Duration duration;
  final VoidCallback onSave;
  
  _SleepEndBottomSheet({
    required this.duration,
    required this.onSave,
  });
  
  @override
  __SleepEndBottomSheetState createState() => __SleepEndBottomSheetState();
}

class __SleepEndBottomSheetState extends State<_SleepEndBottomSheet> {
  double _quality = 3;
  String _memo = '';
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          
          Text(
            '수면 기록 완료',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 20),
          
          // 수면 시간
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, color: Color(0xFF667EEA)),
                SizedBox(width: 10),
                Text(
                  '총 수면 시간: ${widget.duration.inHours}시간 ${widget.duration.inMinutes.remainder(60)}분',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // 수면 품질
          Text('수면 품질', style: TextStyle(fontSize: 14)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _quality ? Icons.star : Icons.star_border,
                  color: Color(0xFFFFC107),
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _quality = index + 1.0;
                  });
                },
              );
            }),
          ),
          
          SizedBox(height: 20),
          
          // 메모
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '메모 (선택사항)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              _memo = value;
            },
          ),
          
          SizedBox(height: 20),
          
          // 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('취소'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onSave,
                  child: Text('저장'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667EEA),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
