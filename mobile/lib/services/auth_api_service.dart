import 'api_client.dart';
import 'storage_service.dart';

/// 인증 API 서비스
///
/// 회원가입, 로그인, 로그아웃 등 인증 관련 API를 제공합니다.
class AuthApiService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  /// 회원가입
  ///
  /// OAuth 제공자 정보로 회원가입합니다.
  ///
  /// [email] 이메일
  /// [name] 이름
  /// [provider] OAuth 제공자 (KAKAO, GOOGLE, APPLE)
  /// [providerId] 제공자 ID
  Future<Map<String, dynamic>> register({
    required String email,
    required String name,
    required String provider,
    required String providerId,
    String? profileImage,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/auth/register',
      data: {
        'email': email,
        'name': name,
        'provider': provider,
        'providerId': providerId,
        if (profileImage != null) 'profileImage': profileImage,
      },
    );

    if (response.statusCode == 201) {
      final data = response.data['data'];

      // 토큰 저장
      await _storageService.saveAccessToken(data['accessToken']);
      await _storageService.saveRefreshToken(data['refreshToken']);

      // 사용자 정보 저장
      await _storageService.saveUserInfo(
        userId: data['userId'],
        email: data['email'],
        name: data['name'],
      );

      return data;
    }

    throw Exception('회원가입 실패: ${response.statusCode}');
  }

  /// 로그인
  ///
  /// OAuth 제공자 정보로 로그인합니다.
  ///
  /// [provider] OAuth 제공자 (KAKAO, GOOGLE, APPLE)
  /// [providerId] 제공자 ID
  Future<Map<String, dynamic>> login({
    required String provider,
    required String providerId,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/auth/login',
      data: {
        'provider': provider,
        'providerId': providerId,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];

      // 토큰 저장
      await _storageService.saveAccessToken(data['accessToken']);
      await _storageService.saveRefreshToken(data['refreshToken']);

      // 사용자 정보 저장
      await _storageService.saveUserInfo(
        userId: data['userId'],
        email: data['email'],
        name: data['name'],
      );

      return data;
    }

    throw Exception('로그인 실패: ${response.statusCode}');
  }

  /// 로그아웃
  ///
  /// 로컬에 저장된 토큰 및 사용자 정보를 삭제합니다.
  Future<void> logout() async {
    await _storageService.clearAll();
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  /// 현재 사용자 ID 조회
  Future<int?> getCurrentUserId() async {
    return await _storageService.getUserId();
  }
}
