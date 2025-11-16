import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/baby.dart';
import '../providers/baby_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _nextScheduleNotification = true;
  bool _sleepRecordReminder = true;
  late TextEditingController _nameController;
  bool _isEditingName = false;
  bool _isSaving = false;
  String? _editError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final baby = context.watch<BabyProvider>().baby;
    if (baby != null && _nameController.text.isEmpty) {
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
    final babyProvider = context.read<BabyProvider>();

    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAvatar(),
            const SizedBox(height: 30),
            // 아기 정보 표시 및 편집 (아기 정보는 항상 존재함)
            if (baby != null) ...[
              _buildBabyInfoSection(baby, babyProvider),
              const SizedBox(height: 40),
            ],
            // 알림 설정
            _buildNotificationSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBabyInfoSection(Baby baby, BabyProvider babyProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '아기 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        // 아기 이름 (편집 가능)
        _buildEditableNameField(baby),
        const SizedBox(height: 15),
        if (_editError != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              _editError!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[700],
              ),
            ),
          ),
        if (_editError != null) const SizedBox(height: 15),
        if (_isEditingName)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : () => _saveBabyName(babyProvider, baby.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                disabledBackgroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        if (_isEditingName) const SizedBox(height: 15),
        // 생년월일
        _buildProfileField(
          '생년월일',
          DateFormat('yyyy년 M월 d일').format(baby.birthDate),
        ),
        const SizedBox(height: 15),
        // 출생 주수
        _buildProfileField(
          '출생 주수',
          '${baby.birthWeeks}주',
        ),
        const SizedBox(height: 15),
        // 현재 월령
        _buildProfileField(
          '현재 월령',
          '${baby.ageText} (생후 ${baby.ageInDays}일)',
        ),
      ],
    );
  }

  Widget _buildNotificationSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '알림 설정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
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
    );
  }

  Widget _buildEditableNameField(Baby baby) {
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
          const Text(
            '이름',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _isEditingName
                    ? TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: baby.name,
                          border: const UnderlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(vertical: 5),
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        autofocus: true,
                      )
                    : Text(
                        baby.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _isSaving
                    ? null
                    : () {
                        setState(() {
                          if (_isEditingName) {
                            _isEditingName = false;
                            _editError = null;
                          } else {
                            _isEditingName = true;
                          }
                        });
                      },
                child: Icon(
                  _isEditingName ? Icons.close : Icons.edit,
                  color: Colors.grey[500],
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveBabyName(BabyProvider babyProvider, int babyId) async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _editError = '아기 이름을 입력해주세요';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _editError = null;
    });

    try {
      await babyProvider.updateBabyInfo(
        babyId: babyId,
        name: _nameController.text,
      );

      if (mounted) {
        setState(() {
          _isEditingName = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('아기 정보가 저장되었습니다!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _editError = '저장 실패: $e';
          _isSaving = false;
        });
      }
    }
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

  Widget _buildProfileField(String label, String value) {
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
          Text(
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
