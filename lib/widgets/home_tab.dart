import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeTab extends StatelessWidget {
  Future<void> _reportPost(String postId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final snapshot = await postRef.get();
    final reportCount = snapshot['reports'] ?? 0;

    if (reportCount >= 4) {
      await postRef.update({'reports': reportCount + 1, 'flagged': true});
    } else {
      await postRef.update({'reports': reportCount + 1});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('홈')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['content']),
                subtitle: doc['reports'] >= 5 ? Text("신고 5회 이상 게시글") : null,
                trailing: IconButton(
                  icon: Icon(Icons.report),
                  onPressed: () => _reportPost(doc.id),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
