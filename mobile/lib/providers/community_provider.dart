import 'package:flutter/foundation.dart';
import '../models/community_post.dart';
import '../models/comment.dart';

class CommunityProvider with ChangeNotifier {
  List<CommunityPost> _posts = [];
  Map<String, List<Comment>> _comments = {};

  List<CommunityPost> get posts => _posts;

  List<Comment> getComments(String postId) {
    return _comments[postId] ?? [];
  }

  void initializeMockData() {
    final now = DateTime.now();
    _posts = [
      CommunityPost(
        id: '1',
        title: '4개월 아기 밤잠 통잠 성공했어요!',
        content: '드디어 통잠 성공했어요. 수면교육 시작한지 2주만에...',
        author: '익명1',
        createdAt: now.subtract(const Duration(hours: 2)),
        likes: 15,
        comments: 8,
      ),
      CommunityPost(
        id: '2',
        title: '낮잠 30분만 자고 깨는데 어떻게 하나요?',
        content: '6개월 아기인데 낮잠을 30분만 자고 깨요. 어떻게 하면 낮잠을 길게 잘 수 있을까요?',
        author: '익명2',
        createdAt: now.subtract(const Duration(hours: 5)),
        likes: 23,
        comments: 12,
      ),
      CommunityPost(
        id: '3',
        title: '수면교육 시작 시기 궁금해요',
        content: '언제부터 수면교육을 시작하는게 좋을까요? 지금 3개월인데...',
        author: '익명3',
        createdAt: now.subtract(const Duration(days: 1)),
        likes: 18,
        comments: 15,
      ),
    ];

    // Mock comments data
    _comments = {
      '1': [
        Comment(
          id: 'c1',
          postId: '1',
          content: '축하드려요! 수면교육 방법 공유해주시면 감사하겠습니다.',
          author: '익명10',
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        Comment(
          id: 'c2',
          postId: '1',
          content: '저도 수면교육 시작하려고 하는데 팁 좀 알려주세요!',
          author: '익명11',
          createdAt: now.subtract(const Duration(minutes: 30)),
        ),
      ],
      '2': [
        Comment(
          id: 'c3',
          postId: '2',
          content: '저희 아기도 똑같았는데 암막커튼 치니까 좀 나아졌어요.',
          author: '익명12',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
      ],
    };

    notifyListeners();
  }

  void addPost(String title, String content, String author) {
    final newPost = CommunityPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      author: author,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, newPost);
    notifyListeners();
  }

  void updatePost(String id, String title, String content) {
    final index = _posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      _posts[index] = CommunityPost(
        id: id,
        title: title,
        content: content,
        author: _posts[index].author,
        createdAt: _posts[index].createdAt,
        likes: _posts[index].likes,
        comments: _posts[index].comments,
      );
      notifyListeners();
    }
  }

  void deletePost(String id) {
    _posts.removeWhere((post) => post.id == id);
    notifyListeners();
  }

  void likePost(String id) {
    final index = _posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      _posts[index] = CommunityPost(
        id: id,
        title: _posts[index].title,
        content: _posts[index].content,
        author: _posts[index].author,
        createdAt: _posts[index].createdAt,
        likes: _posts[index].likes + 1,
        comments: _posts[index].comments,
      );
      notifyListeners();
    }
  }

  // Comment methods
  void addComment(String postId, String content, String author) {
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      content: content,
      author: author,
      createdAt: DateTime.now(),
    );

    if (_comments[postId] == null) {
      _comments[postId] = [];
    }
    _comments[postId]!.add(newComment);

    // Update comment count
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
  }

  void updateComment(String commentId, String postId, String content) {
    final comments = _comments[postId];
    if (comments != null) {
      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        comments[index] = Comment(
          id: commentId,
          postId: postId,
          content: content,
          author: comments[index].author,
          createdAt: comments[index].createdAt,
        );
        notifyListeners();
      }
    }
  }

  void deleteComment(String commentId, String postId) {
    final comments = _comments[postId];
    if (comments != null) {
      comments.removeWhere((c) => c.id == commentId);

      // Update comment count
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
  }
}
