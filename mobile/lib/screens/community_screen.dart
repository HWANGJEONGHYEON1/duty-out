import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../models/community_post.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildPostList(context),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () => _showPostDialog(context),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 24,
          ),
        ),
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
      child: const Text(
        '수면 커뮤니티',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPostList(BuildContext context) {
    final communityProvider = context.watch<CommunityProvider>();
    final posts = communityProvider.posts;

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.forum_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              '아직 게시글이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostCard(context, post);
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, CommunityPost post) {
    return GestureDetector(
      onTap: () => _showPostDetail(context, post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('수정'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('삭제'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showPostDialog(context, post: post);
                      } else if (value == 'delete') {
                        _deletePost(context, post.id);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                post.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      post.author,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    post.timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 15),
                      Icon(Icons.comment_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${post.comments}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostDialog(BuildContext context, {CommunityPost? post}) {
    final titleController = TextEditingController(text: post?.title ?? '');
    final contentController = TextEditingController(text: post?.content ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(post == null ? '새 글 작성' : '글 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 500,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                final provider = context.read<CommunityProvider>();
                if (post == null) {
                  provider.addPost(
                    titleController.text,
                    contentController.text,
                    '익명${DateTime.now().millisecondsSinceEpoch % 1000}',
                  );
                } else {
                  provider.updatePost(
                    post.id,
                    titleController.text,
                    contentController.text,
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showPostDetail(BuildContext context, CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(post.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      post.author,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    post.timeAgo,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                post.content,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<CommunityProvider>().likePost(post.id);
                    },
                    icon: const Icon(Icons.favorite_border, size: 16),
                    label: Text('좋아요 ${post.likes}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.comment_outlined, size: 16),
                    label: Text('댓글 ${post.comments}'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _deletePost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('이 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<CommunityProvider>().deletePost(postId);
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
