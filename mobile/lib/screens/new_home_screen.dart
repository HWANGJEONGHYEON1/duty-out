import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../providers/schedule_provider.dart';

class NewHomeScreen extends StatelessWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => _showRecommendedInfo(context),
          ),
        ],
      ),
    );
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

  Widget _buildScheduleList(BuildContext context) {
    final scheduleItems = context.watch<ScheduleProvider>().scheduleItems;

    if (scheduleItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.schedule,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              '스케줄을 생성해주세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
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
          return _buildScheduleCard(context, item, index);
        },
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
      builder: (context) => AlertDialog(
        title: const Text('스케줄 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: '활동'),
              controller: TextEditingController(text: item.activity),
              onChanged: (value) {
                // 활동명 수정 로직
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: '시간 (분)'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(
                text: item.durationMinutes?.toString() ?? '',
              ),
              onChanged: (value) {
                // 시간 수정 로직
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // 저장 로직
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
