import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  PostDetailScreen({required this.postId});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController commentController = TextEditingController();
  DocumentSnapshot? postSnapshot;
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    final postDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get();
    setState(() {
      postSnapshot = postDoc;
    });
  }

  Future<void> _addComment() async {
    final commentContent = commentController.text.trim();
    if (commentContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 내용을 입력하세요.')),
      );
      return;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      await postRef.collection('comments').add({
        'content': commentContent,
        'userId': currentUser!.uid,
        'userName': '익명',
        'timestamp': FieldValue.serverTimestamp(),
      });

      commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글이 추가되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 추가 실패: ${e.toString()}')),
      );
    }
  }

  // 게시글 수정 함수
  void _showEditPostDialog() {
    final TextEditingController titleController =
        TextEditingController(text: postSnapshot!['title']);
    final TextEditingController contentController =
        TextEditingController(text: postSnapshot!['content']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('게시글 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '제목'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: '내용'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .update({
                    'title': titleController.text.trim(),
                    'content': contentController.text.trim(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('게시글이 수정되었습니다.')),
                  );
                  Navigator.pop(context);
                  _loadPost(); // 수정된 내용 로드
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('게시글 수정 실패: ${e.toString()}')),
                  );
                }
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // 게시글 삭제 함수
  Future<void> _deletePost() async {
    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      // 댓글 삭제
      final commentsSnapshot = await postRef.collection('comments').get();
      for (var comment in commentsSnapshot.docs) {
        await comment.reference.delete();
      }

      // 게시글 삭제
      await postRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글이 삭제되었습니다.')),
      );
      Navigator.pop(context); // 삭제 후 이전 화면으로 이동
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 삭제 실패: ${e.toString()}')),
      );
    }
  }

  // 게시글 신고 함수
  Future<void> _reportPost() async {
    if (postSnapshot == null) return;

    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      await postRef.update({
        'reportCount': FieldValue.increment(1),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글을 신고했습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('신고 실패: ${e.toString()}')),
      );
    }
  }

  // 댓글 삭제 함수
  Future<void> _deleteComment(String commentId) async {
    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.postId);

    try {
      // 댓글 삭제
      await postRef.collection('comments').doc(commentId).delete();

      // 댓글 갯수 감소
      await postRef.update({
        'commentCount': FieldValue.increment(-1),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글이 삭제되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 삭제 실패: ${e.toString()}')),
      );
    }
  }

  // 댓글 수정 함수
  Future<void> _editComment(String commentId, String currentContent) async {
    final TextEditingController editController =
        TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('댓글 수정'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              hintText: '댓글 내용을 수정하세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final newContent = editController.text.trim();
                if (newContent.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('댓글 내용을 입력하세요.')),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .doc(commentId)
                      .update({
                    'content': newContent,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('댓글이 수정되었습니다.')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('댓글 수정 실패: ${e.toString()}')),
                  );
                }
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthor =
        postSnapshot != null && postSnapshot!['userId'] == currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 상세'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deletePost();
              } else if (value == 'edit') {
                _showEditPostDialog();
              } else if (value == 'report') {
                _reportPost();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                if (isAuthor)
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('수정'),
                  ),
                if (isAuthor)
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('삭제'),
                  ),
                if (!isAuthor)
                  PopupMenuItem(
                    value: 'report',
                    child: Text('신고하기'),
                  ),
              ];
            },
          ),
        ],
      ),
      body: postSnapshot == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            postSnapshot!['title'] ?? '제목 없음',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            postSnapshot!['content'] ?? '내용 없음',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '댓글',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final comments = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final content = comment['content'];
                          final userName = comment['userName'] ?? '익명';
                          final commentId = comment.id;
                          final isCommentAuthor =
                              comment['userId'] == currentUser?.uid;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 2,
                              child: ListTile(
                                title: Text(
                                  userName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(content),
                                trailing: isCommentAuthor
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () => _editComment(
                                                commentId, content),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _deleteComment(commentId),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: '댓글을 입력하세요',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _addComment,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
