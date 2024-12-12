import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> registerWithEmailAndPassword(
    String email, String password, String name) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 사용자 이름 저장
    await userCredential.user?.updateDisplayName(name);
    await userCredential.user?.reload();

    // Firestore에 사용자 정보 저장
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .set({
      'name': name,
      'email': email,
      'isVerified': false,
    });
  } catch (e) {
    throw Exception('회원가입 실패: $e');
  }
}
