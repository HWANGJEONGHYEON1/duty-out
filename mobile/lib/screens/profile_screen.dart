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

  DateTime? _selectedBirthDate;
  int _gestationalWeeks = 39;
  bool _isRegisteringBaby = false;

  // 기존 아기 정보 편집 상태
  bool _isEditingAllInfo = false;
  DateTime? _editBirthDate;
  int _editGestationalWeeks = 39;
  String _editGender = 'MALE';

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
                child: const Text(
                  '아기 정보를 등록해주세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              _buildBabyRegistrationForm(babyProvider),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '아기 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isEditingAllInfo = !_isEditingAllInfo;
                  if (_isEditingAllInfo) {
                    // 편집 모드 진입 시 현재 값으로 초기화
                    _editBirthDate = baby.birthDate;
                    _editGestationalWeeks = baby.birthWeeks;
                  }
                });
              },
              icon: Icon(_isEditingAllInfo ? Icons.close : Icons.edit),
              label: Text(_isEditingAllInfo ? '취소' : '수정'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF667EEA),
              ),
            ),
          ],
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

        // 편집 모드: 생년월일 수정
        if (_isEditingAllInfo) ...[
          _buildEditableBirthDateField(),
          const SizedBox(height: 15),
          _buildEditableGestationalWeeksField(),
          const SizedBox(height: 15),
          _buildProfileField(
            '현재 월령',
            '${baby.ageText} (생후 ${baby.ageInDays}일)',
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : () => _saveAllBabyInfo(babyProvider, baby.id),
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
        ] else ...[
          // 읽기 모드: 정보만 표시
          _buildProfileField(
            '생년월일',
            DateFormat('yyyy년 M월 d일').format(baby.birthDate),
          ),
          const SizedBox(height: 15),
          _buildProfileField(
            '출생 주수',
            '${baby.birthWeeks}주',
          ),
          const SizedBox(height: 15),
          _buildProfileField(
            '현재 월령',
            '${baby.ageText} (생후 ${baby.ageInDays}일)',
          ),
        ],
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
                        onSubmitted: (_) => _saveBabyName(
                          context.read<BabyProvider>(),
                          baby.id,
                        ),
                        onEditingComplete: () => _saveBabyName(
                          context.read<BabyProvider>(),
                          baby.id,
                        ),
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
                    : () async {
                        if (_isEditingName) {
                          // 저장 후 닫기
                          await _saveBabyName(
                            context.read<BabyProvider>(),
                            baby.id,
                          );
                        } else {
                          // 편집 모드 활성화
                          setState(() {
                            _isEditingName = true;
                            _editError = null;
                          });
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _isEditingName ? Icons.check : Icons.edit,
                    color: _isSaving ? Colors.grey[400] : const Color(0xFF667EEA),
                    size: 18,
                  ),
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

  // 생년월일 편집 필드
  Widget _buildEditableBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '생년월일',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _editBirthDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _editBirthDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _editBirthDate != null
                      ? DateFormat('yyyy년 M월 d일').format(_editBirthDate!)
                      : '생년월일을 선택하세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: _editBirthDate != null ? Colors.black : Colors.grey[500],
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.grey[400], size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 출생 주수 편집 필드
  Widget _buildEditableGestationalWeeksField() {
    final isPreemie = _editGestationalWeeks < 37;
    final statusLabel = isPreemie ? '조산' : '정상';
    final statusColor = isPreemie ? Colors.orange : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '출생 주수',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              Text(
                '$_editGestationalWeeks주',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
              const SizedBox(height: 12),
              Slider(
                value: _editGestationalWeeks.toDouble(),
                min: 30,
                max: 42,
                divisions: 12,
                activeColor: const Color(0xFF667EEA),
                onChanged: (value) {
                  setState(() {
                    _editGestationalWeeks = value.toInt();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('30주', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text('42주', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 모든 정보 저장 메서드
  Future<void> _saveAllBabyInfo(BabyProvider babyProvider, int babyId) async {
    if (_editBirthDate == null) {
      setState(() {
        _editError = '생년월일을 선택해주세요';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _editError = null;
    });

    try {
      // TODO: 백엔드에서 모든 정보 업데이트 API 호출
      // 현재는 생년월일과 출생주수도 함께 저장해야 함
      await babyProvider.updateBabyInfo(
        babyId: babyId,
        name: _nameController.text,
      );

      if (mounted) {
        setState(() {
          _isEditingAllInfo = false;
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
}
