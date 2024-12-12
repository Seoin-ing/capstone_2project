import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:project/screens/PdfUploadScreen.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _registerUser(BuildContext context) async {
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력하세요.')),
      );
      return;
    }

    try {
      // Firebase Authentication 회원가입
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Firebase 사용자 이름 업데이트
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      // Firestore에 사용자 정보 저장
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'name': name,
        'email': email,
        'isVerified': false, // 초기값: 인증되지 않은 상태
      });

      // 성공 메시지 및 다음 화면으로 이동
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 성공!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PdfUploadScreen()),
      );
    } catch (e) {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기
          },
        ),
        title:
            Text('회원가입', style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진 영역
            Container(
              height:
                  MediaQuery.of(context).size.height * 0.4, // 화면의 40%를 사진으로 사용
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/signup.webp'), // 이미지 경로
                  fit: BoxFit.cover, // 이미지 크기 조정
                ),
              ),
            ),
            SizedBox(height: 20), // 사진과 입력 필드 사이 간격
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '가입 정보를 입력하세요',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  // 이름 입력란
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: '닉네임을 입력하세요',
                      hintStyle: TextStyle(color: Colors.blue, fontSize: 16),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  // 이메일 입력란
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: '이메일을 입력하세요',
                      hintStyle: TextStyle(color: Colors.blue, fontSize: 16),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  // 비밀번호 입력란
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: '비밀번호를 입력하세요',
                      hintStyle: TextStyle(color: Colors.blue, fontSize: 16),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '회원가입시 이용약관 및 개인정보 처리방침에 동의하는 것으로 간주합니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _registerUser(context); // 회원가입 동작
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '다음',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
