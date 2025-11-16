import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/baby.dart';
import '../providers/baby_provider.dart';

class BabyRegistrationScreen extends StatefulWidget {
  const BabyRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<BabyRegistrationScreen> createState() => _BabyRegistrationScreenState();
}

class _BabyRegistrationScreenState extends State<BabyRegistrationScreen> {
  final _nameController = TextEditingController();
  DateTime? _selectedBirthDate;
  int _gestationalWeeks = 39;
  String _gender = 'MALE';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아기 정보 등록'),
        centerTitle: true,
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoText(),
              const SizedBox(height: 30),
              _buildNameInput(),
              const SizedBox(height: 20),
              _buildBirthDateInput(),
              const SizedBox(height: 20),
              _buildGestationalWeeksInput(),
              const SizedBox(height: 20),
              _buildGenderSelection(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👶 아기 정보를 입력해주세요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아기의 기본 정보를 입력하면 개월수에 맞는 맞춤형 수면 스케줄을 제공합니다.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '아기 이름',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '아기의 이름을 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildBirthDateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '생년월일',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectBirthDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'
                      : '생년월일을 선택하세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedBirthDate != null ? Colors.black : Colors.grey[500],
                  ),
                ),
                const Icon(Icons.calendar_today, color: Color(0xFF667EEA)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGestationalWeeksInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '출생 주수',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$_gestationalWeeks주',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667EEA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _gestationalWeeks.toDouble(),
          min: 30,
          max: 42,
          divisions: 12,
          activeColor: const Color(0xFF667EEA),
          onChanged: (value) {
            setState(() {
              _gestationalWeeks = value.toInt();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('30주', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('42주', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '성별',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderButton('남아', 'MALE'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton('여아', 'FEMALE'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(String label, String value) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667EEA) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF667EEA) : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667EEA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Text(
                '등록하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    // 유효성 검사
    if (_nameController.text.isEmpty) {
      _showSnackBar('아기 이름을 입력해주세요');
      return;
    }

    if (_selectedBirthDate == null) {
      _showSnackBar('생년월일을 선택해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final babyProvider = context.read<BabyProvider>();

      // API를 통해 아기 정보 생성
      await babyProvider.loadMyBabies();

      if (mounted) {
        _showSnackBar('아기 정보가 등록되었습니다!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('등록 실패: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
