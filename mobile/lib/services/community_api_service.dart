import 'api_client.dart';

/// 커뮤니티 API 서비스
///
/// 커뮤니티 게시글 및 댓글 관련 API를 제공합니다.
class CommunityApiService {
  final ApiClient _apiClient = ApiClient();

  // ========== 게시글 관련 ==========

  /// 게시글 생성
  ///
  /// [title] 제목
  /// [content] 내용
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/community/posts',
      data: {
        'title': title,
        'content': content,
      },
    );

    if (response.statusCode == 201) {
      return response.data['data'];
    }

    throw Exception('게시글 생성 실패: ${response.statusCode}');
  }

  /// 게시글 목록 조회 (페이징)
  ///
  /// [page] 페이지 번호 (0부터 시작)
  /// [size] 페이지 크기
  /// [search] 검색 키워드 (선택)
  Future<Map<String, dynamic>> getPosts({
    int page = 0,
    int size = 20,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _apiClient.get(
      '/api/v1/community/posts',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('게시글 목록 조회 실패: ${response.statusCode}');
  }

  /// 게시글 단건 조회
  ///
  /// [postId] 게시글 ID
  Future<Map<String, dynamic>> getPost({required int postId}) async {
    final response = await _apiClient.get('/api/v1/community/posts/$postId');

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('게시글 조회 실패: ${response.statusCode}');
  }

  /// 게시글 수정
  ///
  /// [postId] 게시글 ID
  /// [title] 제목
  /// [content] 내용
  Future<Map<String, dynamic>> updatePost({
    required int postId,
    required String title,
    required String content,
  }) async {
    final response = await _apiClient.put(
      '/api/v1/community/posts/$postId',
      data: {
        'title': title,
        'content': content,
      },
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('게시글 수정 실패: ${response.statusCode}');
  }

  /// 게시글 삭제
  ///
  /// [postId] 게시글 ID
  Future<void> deletePost({required int postId}) async {
    final response = await _apiClient.delete('/api/v1/community/posts/$postId');

    if (response.statusCode != 200) {
      throw Exception('게시글 삭제 실패: ${response.statusCode}');
    }
  }

  /// 게시글 좋아요
  ///
  /// [postId] 게시글 ID
  Future<Map<String, dynamic>> likePost({required int postId}) async {
    final response = await _apiClient.post('/api/v1/community/posts/$postId/like');

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('좋아요 실패: ${response.statusCode}');
  }

  // ========== 댓글 관련 ==========

  /// 댓글 생성
  ///
  /// [postId] 게시글 ID
  /// [content] 댓글 내용
  Future<Map<String, dynamic>> createComment({
    required int postId,
    required String content,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/community/posts/$postId/comments',
      data: {
        'content': content,
      },
    );

    if (response.statusCode == 201) {
      return response.data['data'];
    }

    throw Exception('댓글 생성 실패: ${response.statusCode}');
  }

  /// 댓글 목록 조회
  ///
  /// [postId] 게시글 ID
  Future<List<Map<String, dynamic>>> getComments({required int postId}) async {
    final response =
        await _apiClient.get('/api/v1/community/posts/$postId/comments');

    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception('댓글 조회 실패: ${response.statusCode}');
  }

  /// 댓글 수정
  ///
  /// [commentId] 댓글 ID
  /// [content] 댓글 내용
  Future<Map<String, dynamic>> updateComment({
    required int commentId,
    required String content,
  }) async {
    final response = await _apiClient.put(
      '/api/v1/community/comments/$commentId',
      data: {
        'content': content,
      },
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('댓글 수정 실패: ${response.statusCode}');
  }

  /// 댓글 삭제
  ///
  /// [commentId] 댓글 ID
  Future<void> deleteComment({required int commentId}) async {
    final response = await _apiClient.delete('/api/v1/community/comments/$commentId');

    if (response.statusCode != 200) {
      throw Exception('댓글 삭제 실패: ${response.statusCode}');
    }
  }
}
