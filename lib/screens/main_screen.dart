import 'package:flutter/material.dart';
import 'post_creation_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'WageCalculatorScreen.dart';
import 'notification_screen.dart';
import 'PopularPostsScreen.dart';
import 'CompanyScreen.dart';
import 'PdfUploadScreen.dart'; // PDF 인증 페이지 import
import 'login_screen.dart'; // 로그인 화면 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool? isVerified;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      setState(() {
        isVerified = userDoc.data()?['isVerified'] ?? false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut(); // 로그아웃
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면으로 이동
    );
  }

  void _navigateToAddPostScreen() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final isVerified = userDoc['isVerified'] ?? false;

      if (isVerified) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostCreationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사업장 인증 후 게시글 작성이 가능합니다.')),
        );
      }
    }
  }

  void _navigateToPdfUploadScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PdfUploadScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    final List<Widget> screens = [
      HomeScreen(),
      CompanyListScreen(),
      PopularPostsScreen(),
      WageCalculatorScreen(),
      NotificationScreen1(),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 왼쪽 상단 뒤로가기 버튼 제거
        backgroundColor: const Color.fromARGB(255, 150, 192, 240),
        title: Text(
          '알라인드',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(); // 로그아웃 실행
              } else if (value == 'pdf_upload') {
                _navigateToPdfUploadScreen();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'profile',
                  child: Text('닉네임: ${currentUser?.displayName ?? "익명"}'),
                  enabled: false, // 사용자 이름은 선택 불가
                ),
                if (isVerified == false) // 미인증 사용자만 PDF 인증 메뉴 표시
                  PopupMenuItem(
                    value: 'pdf_upload',
                    child: Text('PDF 인증하기'),
                  ),
                PopupMenuItem(
                  value: 'logout',
                  child: Text('로그아웃'),
                ),
              ];
            },
            icon: Icon(Icons.more_vert), // 오른쪽 상단 메뉴 아이콘
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: '회사',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '인기게시글',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            label: '시급계산기',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '알림',
            backgroundColor: Colors.blue,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPostScreen,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}
