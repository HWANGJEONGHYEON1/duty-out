import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'main_screen.dart';

/// 로그인 화면
///
/// 카카오톡 및 애플 소셜 로그인을 제공합니다.
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildSubtitle(),
                const Spacer(flex: 3),
                _buildLoginButtons(context),
                const SizedBox(height: 40),
                _buildFooter(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 로고
  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.bedtime_rounded,
        size: 60,
        color: Color(0xFF667EEA),
      ),
    );
  }

  /// 제목
  Widget _buildTitle() {
    return const Text(
      '육퇴의 정석',
      style: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  /// 부제목
  Widget _buildSubtitle() {
    return const Text(
      '아기 수면 교육의 시작',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// 로그인 버튼들
  Widget _buildLoginButtons(BuildContext context) {
    return Column(
      children: [
        // 카카오톡 로그인 버튼
        _buildKakaoLoginButton(context),
        const SizedBox(height: 16),
        // 애플 로그인 버튼 (iOS만)
        if (Platform.isIOS) ...[
          _buildAppleLoginButton(context),
          const SizedBox(height: 16),
        ],
        // 구글 로그인 버튼
        _buildGoogleLoginButton(context),
      ],
    );
  }

  /// 카카오톡 로그인 버튼
  Widget _buildKakaoLoginButton(BuildContext context) {
    return _buildSocialButton(
      onPressed: () => _handleKakaoLogin(context),
      backgroundColor: const Color(0xFFFFE812),
      textColor: Colors.black87,
      icon: Icons.chat_bubble,
      iconColor: Colors.black87,
      label: '카카오톡으로 시작하기',
    );
  }

  /// 애플 로그인 버튼
  Widget _buildAppleLoginButton(BuildContext context) {
    return _buildSocialButton(
      onPressed: () => _handleAppleLogin(context),
      backgroundColor: Colors.black,
      textColor: Colors.white,
      icon: Icons.apple,
      iconColor: Colors.white,
      label: 'Apple로 계속하기',
    );
  }

  /// 구글 로그인 버튼
  Widget _buildGoogleLoginButton(BuildContext context) {
    return _buildSocialButton(
      onPressed: () => _handleGoogleLogin(context),
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      icon: Icons.g_mobiledata_rounded,
      iconColor: Colors.black87,
      label: 'Google로 계속하기',
    );
  }

  /// 소셜 로그인 버튼 공통 위젯
  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 푸터
  Widget _buildFooter() {
    return const Text(
      '소셜 로그인으로 간편하게 시작하세요',
      style: TextStyle(
        color: Colors.white60,
        fontSize: 13,
      ),
    );
  }

  /// 카카오 로그인 처리
  Future<void> _handleKakaoLogin(BuildContext context) async {
    // TODO: 카카오 로그인 API 연동
    debugPrint('카카오 로그인 시도');

    // 임시: 메인 화면으로 이동
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(
        '/main',
        arguments: const MainScreen(),
      );
    }
  }

  /// 애플 로그인 처리
  Future<void> _handleAppleLogin(BuildContext context) async {
    // TODO: 애플 로그인 API 연동
    debugPrint('애플 로그인 시도');

    // 임시: 메인 화면으로 이동
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(
        '/main',
        arguments: const MainScreen(),
      );
    }
  }

  /// 구글 로그인 처리
  Future<void> _handleGoogleLogin(BuildContext context) async {
    // TODO: 구글 로그인 API 연동
    debugPrint('구글 로그인 시도');

    // 임시: 메인 화면으로 이동
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(
        '/main',
        arguments: const MainScreen(),
      );
    }
  }

  /// 로딩 다이얼로그 표시
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
