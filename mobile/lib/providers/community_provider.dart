import 'package:flutter/foundation.dart';
import '../models/community_post.dart';
import '../models/comment.dart';
import '../services/community_api_service.dart';

/// 커뮤니티 Provider
///
/// 커뮤니티 게시글 및 댓글을 관리하고, API와 연동합니다.
class CommunityProvider with ChangeNotifier {
  final CommunityApiService _communityApiService = CommunityApiService();

  List<CommunityPost> _posts = [];
  Map<String, List<Comment>> _comments = {};
  bool _isLoading = false;
  String? _error;

  List<CommunityPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Comment> getComments(String postId) {
    return _comments[postId] ?? [];
  }

  // ========== 게시글 관련 ==========

  /// 게시글 목록 조회
  ///
  /// [page] 페이지 번호
  /// [size] 페이지 크기
  /// [search] 검색 키워드
  Future<void> loadPosts({
    int page = 0,
    int size = 20,
    String? search,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _communityApiService.getPosts(
        page: page,
        size: size,
        search: search,
      );

      // 응답 파싱
      final List<dynamic> content = response['content'];
      _posts = content.map((item) => _parseCommunityPost(item)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '게시글 목록 조회 실패: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 게시글 생성
  Future<void> addPost(String title, String content) async {
    try {
      final response = await _communityApiService.createPost(
        title: title,
        content: content,
      );

      final newPost = _parseCommunityPost(response);
      _posts.insert(0, newPost); // 맨 앞에 추가

      notifyListeners();
    } catch (e) {
      _error = '게시글 생성 실패: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 게시글 수정
  Future<void> updatePost(String postId, String title, String content) async {
    try {
      final response = await _communityApiService.updatePost(
        postId: int.parse(postId),
        title: title,
        content: content,
      );

      final updatedPost = _parseCommunityPost(response);

      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _error = '게시글 수정 실패: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 게시글 삭제
  Future<void> deletePost(String postId) async {
    try {
      await _communityApiService.deletePost(postId: int.parse(postId));

      _posts.removeWhere((post) => post.id == postId);
      _comments.remove(postId); // 댓글도 함께 삭제

      notifyListeners();
    } catch (e) {
      _error = '게시글 삭제 실패: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 게시글 좋아요
  Future<void> likePost(String postId) async {
    try {
      final response =
          await _communityApiService.likePost(postId: int.parse(postId));

      final updatedPost = _parseCommunityPost(response);

      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _error = '좋아요 실패: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ========== 댓글 관련 ==========

  /// 댓글 목록 조회
  Future<void> loadComments(String postId) async {
    try {
      final response =
          await _communityApiService.getComments(postId: int.parse(postId));

      _comments[postId] = response.map((item) => _parseComment(item)).toList();

      notifyListeners();
    } catch (e) {
      _error = '댓글 조회 실패: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 댓글 생성
  Future<void> addComment(String postId, String content, String author) async {
    try {
      final response = await _communityApiService.createComment(
        postId: int.parse(postId),
        content: content,
      );

      final newComment = _parseComment(response);

      if (_comments[postId] == null) {
        _comments[postId] = [];
      }
      _comments[postId]!.add(newComment);

      // 게시글의 댓글 수 증가
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex] = CommunityPost(
          id: _posts[postIndex].id,
          title: _posts[postIndex].title,
          content: _posts[postIndex].content,
          author: _posts[postIndex].author,
          createdAt: _posts[postIndex].createdAt,
          likes: _posts[postIndex].likes,
          comments: _posts[postIndex].comments + 1,
        );
      }

      notifyListeners();
    } catch (e) {
      _error = '댓글 생성 실패: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 댓글 수정
  Future<void> updateComment(
      String postId, String commentId, String content) async {
    try {
      final response = await _communityApiService.updateComment(
        commentId: int.parse(commentId),
        content: content,
      );

      final updatedComment = _parseComment(response);

      final comments = _comments[postId];
      if (comments != null) {
        final index = comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          comments[index] = updatedComment;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = '댓글 수정 실패: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 댓글 삭제
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _communityApiService.deleteComment(commentId: int.parse(commentId));

      final comments = _comments[postId];
      if (comments != null) {
        comments.removeWhere((c) => c.id == commentId);

        // 게시글의 댓글 수 감소
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          _posts[postIndex] = CommunityPost(
            id: _posts[postIndex].id,
            title: _posts[postIndex].title,
            content: _posts[postIndex].content,
            author: _posts[postIndex].author,
            createdAt: _posts[postIndex].createdAt,
            likes: _posts[postIndex].likes,
            comments: _posts[postIndex].comments - 1,
          );
        }

        notifyListeners();
      }
    } catch (e) {
      _error = '댓글 삭제 실패: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ========== 파싱 메서드 ==========

  /// API 응답을 CommunityPost 모델로 변환
  CommunityPost _parseCommunityPost(Map<String, dynamic> data) {
    return CommunityPost(
      id: data['id'].toString(),
      title: data['title'],
      content: data['content'],
      author: data['anonymousAuthor'],
      createdAt: DateTime.parse(data['createdAt']),
      likes: data['likeCount'] ?? 0,
      comments: data['commentCount'] ?? 0,
    );
  }

  /// API 응답을 Comment 모델로 변환
  Comment _parseComment(Map<String, dynamic> data) {
    return Comment(
      id: data['id'].toString(),
      postId: data['postId'].toString(),
      content: data['content'],
      author: data['anonymousAuthor'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
