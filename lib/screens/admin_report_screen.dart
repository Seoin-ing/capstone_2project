import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('신고된 게시글'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('reportCount', isGreaterThan: 0) // 신고된 게시글만 가져오기
            .orderBy('reportCount', descending: true) // 신고 횟수로 정렬
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final reportedPosts = snapshot.data!.docs;

          if (reportedPosts.isEmpty) {
            return Center(child: Text('신고된 게시글이 없습니다.'));
          }

          return ListView.builder(
            itemCount: reportedPosts.length,
            itemBuilder: (context, index) {
              final post = reportedPosts[index];
              return ListTile(
                title: Text(post['title'] ?? '제목 없음'),
                subtitle: Text('신고 횟수: ${post['reportCount'] ?? 0}'),
                onTap: () {
                  // 게시글 상세 페이지로 이동
                },
              );
            },
          );
        },
      ),
    );
  }
}
