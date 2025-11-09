// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = '한국어';
  
  @override
  Widget build(BuildContext context) {
    final babyProvider = Provider.of<BabyProvider>(context);
    
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 헤더
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '프로필 & 설정',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // 아기 프로필 카드
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                child: Text(
                                  '👶',
                                  style: TextStyle(fontSize: 40),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Color(0xFF667EEA),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '민준이',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '2024년 7월 1일생',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '생후 127일 (4개월 7일)',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _showBabyEditDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 설정 섹션들
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 다중 프로필 관리
                    _buildSectionTitle('아기 프로필 관리'),
                    _buildProfileManagement(),
                    
                    SizedBox(height: 24),
                    
                    // 알림 설정
                    _buildSectionTitle('알림 설정'),
                    _buildNotificationSettings(),
                    
                    SizedBox(height: 24),
                    
                    // 앱 설정
                    _buildSectionTitle('앱 설정'),
                    _buildAppSettings(),
                    
                    SizedBox(height: 24),
                    
                    // 데이터 관리
                    _buildSectionTitle('데이터 관리'),
                    _buildDataManagement(),
                    
                    SizedBox(height: 24),
                    
                    // 계정 설정
                    _buildSectionTitle('계정'),
                    _buildAccountSettings(),
                    
                    SizedBox(height: 24),
                    
                    // 정보
                    _buildSectionTitle('정보'),
                    _buildInfoSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }
  
  Widget _buildProfileManagement() {
    return Container(
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
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF667EEA).withOpacity(0.1),
              child: Text('👶'),
            ),
            title: Text('민준이'),
            subtitle: Text('현재 선택됨'),
            trailing: Radio(
              value: true,
              groupValue: true,
              onChanged: (value) {},
              activeColor: Color(0xFF667EEA),
            ),
          ),
          Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.add, color: Color(0xFF667EEA)),
            ),
            title: Text('아기 추가'),
            subtitle: Text('최대 3명까지 관리 가능'),
            onTap: () => _showAddBabyDialog(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationSettings() {
    return Container(
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
        children: [
          SwitchListTile(
            title: Text('알림 허용'),
            subtitle: Text('수면 시간 및 일정 알림'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: Color(0xFF667EEA),
          ),
          if (_notificationsEnabled) ...[
            Divider(height: 1),
            ListTile(
              title: Text('다음 일정 알림'),
              subtitle: Text('10분 전'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _showTimePickerDialog('다음 일정 알림', '10분 전'),
            ),
            Divider(height: 1),
            ListTile(
              title: Text('수면 기록 리마인더'),
              subtitle: Text('매일 오후 9시'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _showTimePickerDialog('수면 기록 리마인더', '오후 9시'),
            ),
            Divider(height: 1),
            ListTile(
              title: Text('방해 금지 시간'),
              subtitle: Text('오후 10시 - 오전 7시'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _showDoNotDisturbDialog(),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildAppSettings() {
    return Container(
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
        children: [
          SwitchListTile(
            title: Text('다크 모드'),
            subtitle: Text('어두운 테마 사용'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
            activeColor: Color(0xFF667EEA),
          ),
          Divider(height: 1),
          ListTile(
            title: Text('언어'),
            subtitle: Text(_selectedLanguage),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          Divider(height: 1),
          ListTile(
            title: Text('시간 형식'),
            subtitle: Text('24시간'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showTimeFormatDialog(),
          ),
          Divider(height: 1),
          ListTile(
            title: Text('기본 기상 시간'),
            subtitle: Text('오전 7:00'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showDefaultWakeTimeDialog(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataManagement() {
    return Container(
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
        children: [
          ListTile(
            leading: Icon(Icons.backup, color: Color(0xFF4CAF50)),
            title: Text('데이터 백업'),
            subtitle: Text('마지막 백업: 2시간 전'),
            onTap: () => _performBackup(),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.restore, color: Color(0xFF2196F3)),
            title: Text('데이터 복원'),
            subtitle: Text('백업에서 데이터 복원'),
            onTap: () => _restoreData(),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.download, color: Color(0xFFFF9800)),
            title: Text('데이터 내보내기'),
            subtitle: Text('CSV, PDF 형식으로 저장'),
            onTap: () => _exportData(),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_sweep, color: Colors.red),
            title: Text('캐시 삭제'),
            subtitle: Text('임시 데이터 정리 (152 MB)'),
            onTap: () => _clearCache(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccountSettings() {
    return Container(
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
        children: [
          ListTile(
            leading: Icon(Icons.person, color: Color(0xFF667EEA)),
            title: Text('계정 정보'),
            subtitle: Text('example@email.com'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showAccountInfo(),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.share, color: Color(0xFF9C27B0)),
            title: Text('파트너 연동'),
            subtitle: Text('가족과 데이터 공유'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showPartnerSync(),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.grey),
            title: Text('로그아웃'),
            onTap: () => _showLogoutDialog(),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text('계정 삭제'),
            onTap: () => _showDeleteAccountDialog(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection() {
    return Container(
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
        children: [
          ListTile(
            title: Text('앱 버전'),
            subtitle: Text('1.0.0'),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '최신',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Divider(height: 1),
          ListTile(
            title: Text('이용약관'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _openTerms(),
          ),
          Divider(height: 1),
          ListTile(
            title: Text('개인정보 처리방침'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _openPrivacyPolicy(),
          ),
          Divider(height: 1),
          ListTile(
            title: Text('오픈소스 라이선스'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _openLicenses(),
          ),
          Divider(height: 1),
          ListTile(
            title: Text('문의하기'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _contactSupport(),
          ),
        ],
      ),
    );
  }
  
  // 다이얼로그 메서드들
  void _showBabyEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('아기 정보 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '이름',
                hintText: '민준이',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '생년월일',
                hintText: '2024-07-01',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '출생 주수',
                hintText: '39주',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('정보가 수정되었습니다')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667EEA),
            ),
            child: Text('저장'),
          ),
        ],
      ),
    );
  }
  
  void _showAddBabyDialog(BuildContext context) {
    // 아기 추가 다이얼로그
    _showBabyEditDialog(context);
  }
  
  void _showTimePickerDialog(String title, String currentValue) {
    // 시간 선택 다이얼로그
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                onTimerDurationChanged: (Duration duration) {
                  // 시간 변경 처리
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667EEA),
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDoNotDisturbDialog() {
    // 방해 금지 시간 설정
    _showTimePickerDialog('방해 금지 시간', '오후 10시 - 오전 7시');
  }
  
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('언어 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['한국어', 'English', '日本語', '中文'].map((lang) {
            return RadioListTile(
              title: Text(lang),
              value: lang,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value.toString();
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showTimeFormatDialog() {
    // 시간 형식 선택
  }
  
  void _showDefaultWakeTimeDialog() {
    // 기본 기상 시간 설정
  }
  
  void _performBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('백업이 완료되었습니다')),
    );
  }
  
  void _restoreData() {
    // 데이터 복원
  }
  
  void _exportData() {
    // 데이터 내보내기
  }
  
  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('캐시 삭제'),
        content: Text('임시 데이터를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('캐시가 삭제되었습니다')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }
  
  void _showAccountInfo() {
    // 계정 정보 표시
  }
  
  void _showPartnerSync() {
    // 파트너 연동 설정
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('로그아웃'),
        content: Text('로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 로그아웃 처리
            },
            child: Text('로그아웃'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('계정 삭제'),
        content: Text('계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 계정 삭제 처리
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }
  
  void _openTerms() {
    // 이용약관 페이지
  }
  
  void _openPrivacyPolicy() {
    // 개인정보 처리방침 페이지
  }
  
  void _openLicenses() {
    // 오픈소스 라이선스 페이지
  }
  
  void _contactSupport() {
    // 고객 지원 연락
  }
}
