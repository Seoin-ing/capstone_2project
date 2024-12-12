import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostCreationScreen extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  Future<void> _savePost(BuildContext context) async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (title.isEmpty || content.isEmpty || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("제목과 내용을 입력해주세요.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'title': title,
        'content': content,
        'userId': user.uid, // 작성자 UID 저장
        'userName': user.displayName ?? '익명', // 작성자 이름
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글이 저장되었습니다.')),
      );
      Navigator.pop(context); // 게시글 작성 후 이전 화면으로 이동
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 저장 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 게시글 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _savePost(context),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
