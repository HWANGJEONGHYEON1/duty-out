class CommunityPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final int likes;
  final int comments;

  CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
