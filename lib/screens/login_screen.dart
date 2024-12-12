import 'signup_screen.dart';
import 'package:flutter/material.dart';
import 'login_form.dart'; // LoginForm 파일을 import 합니다.

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Container(
            height: MediaQuery.of(context).size.height *
                0.6, // 화면 높이의 60%까지만 배경 이미지 표시
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/mainpic.webp'), // 이미지를 설정
                fit: BoxFit.cover, // 화면에 맞게 조정
              ),
            ),
          ),
          // 메인 콘텐츠
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Text(
                  '세상을 바꾸는\n100만 알바들의 목소리',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '재직중인 알바의 위치를 선택하세요',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        '대한민국',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // 회원가입 버튼 클릭 시 동작
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          '회원가입',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () {
                          // 로그인 버튼 클릭 시 로그인 폼 화면으로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginForm()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          '로그인',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
