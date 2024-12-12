import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/screens/admin_dashboard_screen.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart'; // LoginScreen 파일을 import 합니다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ).copyWith(
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: Colors.grey[100], // 배경 색상을 밝은 회색으로 설정
        textTheme: TextTheme(
          headlineLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal[900]),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          labelLarge: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, // ElevatedButton의 배경색 설정
            foregroundColor: Colors.white, // 텍스트 색상
            padding:
                EdgeInsets.symmetric(horizontal: 30, vertical: 15), // 버튼 패딩
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8)), // 입력 필드 테두리를 둥글게
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.teal), // 라벨 텍스트 색상
        ),
      ),
      home: LoginScreen(), // 로그인 화면을 초기 화면으로 설정
      initialRoute: '/',
      routes: {
        '/admin': (context) => AdminDashboardScreen(), // 관리자 화면 라우트 추가
        '/login': (context) => LoginScreen(), // 로그인 화면
      },
    );
  }
}
