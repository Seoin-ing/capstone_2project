import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String adminUid = 'vM3WIViyzWPToyez0GBLGM6Vu6A3';

  Future<void> addDefaultReportCountToPosts() async {
    final posts = await FirebaseFirestore.instance.collection('posts').get();
    for (var post in posts.docs) {
      if (!post.data().containsKey('reportCount')) {
        await post.reference.update({'reportCount': 0});
      }
    }
  }

  Future<void> _deletePostWithComments(String postId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    try {
      // 하위 컬렉션 `comments` 삭제
      final commentsSnapshot = await postRef.collection('comments').get();
      for (var comment in commentsSnapshot.docs) {
        await comment.reference.delete();
      }

      // 게시글 삭제
      await postRef.delete();
    } catch (e) {
      print('게시글 삭제 실패: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser?.uid != adminUid) {
      return Scaffold(
        body: Center(
          child: Text('접근 권한이 없습니다.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자 대시보드'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final Map<String, dynamic>? postData =
                  post.data() as Map<String, dynamic>?;
              final title = postData?['title'] ?? '제목 없음';
              final content = postData?['content'] ?? '내용 없음';
              final reportCount = postData?['reportCount'] ?? 0;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(content),
                      SizedBox(height: 8),
                      Text('신고 횟수: $reportCount',
                          style: TextStyle(
                            color: reportCount >= 5 ? Colors.red : Colors.black,
                          )),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('게시글 삭제'),
                          content: Text('이 게시글을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('삭제'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await _deletePostWithComments(post.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('게시글이 삭제되었습니다.')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('삭제 실패: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
