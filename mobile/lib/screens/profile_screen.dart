import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/baby_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _nextScheduleNotification = true;
  bool _sleepRecordReminder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildProfileContent(context),
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
      child: const Center(
        child: Column(
          children: [
            Text(
              '아기 프로필',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '설정 및 관리',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final baby = context.watch<BabyProvider>().baby;

    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAvatar(),
            const SizedBox(height: 20),
            if (baby != null) ...[
              _buildProfileField('이름', baby.name, isEditable: true),
              const SizedBox(height: 15),
              _buildProfileField(
                '생년월일',
                DateFormat('yyyy년 M월 d일').format(baby.birthDate),
              ),
              const SizedBox(height: 15),
              _buildProfileField(
                '출생 주수',
                '${baby.birthWeeks}주 (정상 출산)',
              ),
              const SizedBox(height: 15),
              _buildProfileField(
                '현재 월령',
                '${baby.ageText} (생후 ${baby.ageInDays}일)',
              ),
              const SizedBox(height: 30),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    '아기 정보를 등록해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '알림 설정',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildNotificationSetting(
              '다음 일정 알림',
              '10분 전 알림',
              _nextScheduleNotification,
              (value) {
                setState(() {
                  _nextScheduleNotification = value;
                });
              },
            ),
            const SizedBox(height: 15),
            _buildNotificationSetting(
              '수면 기록 리마인더',
              '기록 누락 시 알림',
              _sleepRecordReminder,
              (value) {
                setState(() {
                  _sleepRecordReminder = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: const Center(
        child: Text(
          '👶',
          style: TextStyle(fontSize: 48),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value, {bool isEditable = false}) {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          isEditable
              ? TextField(
                  decoration: InputDecoration(
                    hintText: value,
                    border: const UnderlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildNotificationSetting(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF667EEA),
          ),
        ],
      ),
    );
  }
}
