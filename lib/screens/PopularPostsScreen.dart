import 'package:flutter/material.dart';
import 'post_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PopularPostsScreen extends StatelessWidget {
  Stream<QuerySnapshot> fetchPopularPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('commentCount', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchPopularPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return Center(child: Text('인기 게시글이 없습니다.'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final title = post['title'] ?? '제목 없음';
              final content = post['content'] ?? '내용 없음';
              final commentCount = post['commentCount'] ?? 0;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(content),
                      SizedBox(height: 8),
                      Text(
                        '댓글 수: $commentCount',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // 게시글 상세 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(postId: post.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
