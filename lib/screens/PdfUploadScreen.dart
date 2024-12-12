import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:project/screens/login_screen.dart'; // main_screen.dart 파일을 import합니다.

class PdfUploadScreen extends StatefulWidget {
  @override
  _PdfUploadScreenState createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
  PlatformFile? _insurancePdf;
  PlatformFile? _contractPdf;
  String? _insuranceBusinessName;
  String? _contractBusinessName;

  Future<void> _pickFile(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        String? businessName = await _extractBusinessName(file);

        setState(() {
          if (type == 'insurance') {
            _insurancePdf = file;
            _insuranceBusinessName = businessName;
          } else if (type == 'contract') {
            _contractPdf = file;
            _contractBusinessName = businessName;
          }
        });
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<String?> _extractBusinessName(PlatformFile pdfFile) async {
    try {
      final fileBytes =
          pdfFile.bytes ?? await File(pdfFile.path!).readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: fileBytes);
      String fullText = '';

      for (int i = 0; i < document.pages.count; i++) {
        final pageText = PdfTextExtractor(document)
            .extractText(startPageIndex: i, endPageIndex: i);
        fullText += pageText;
      }

      document.dispose();

      print("Extracted Text: $fullText");

      RegExp regex = RegExp(
          r"(사업장명칭|사업체명|회사명)[\s\S]*?([가-힣a-zA-Z0-9\-]+주식회사|[가-힣a-zA-Z0-9\-]+회사)");
      final match = regex.firstMatch(fullText);
      if (match != null && match.groupCount >= 2) {
        return match.group(2)?.trim();
      }

      return null;
    } catch (e) {
      print("Error extracting business name: $e");
      return null;
    }
  }

  bool isVerified = false;
  void _verifyAndProceed() async {
    if (_insuranceBusinessName != null &&
        _contractBusinessName != null &&
        _insuranceBusinessName == _contractBusinessName) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          // Firestore에서 인증 상태 업데이트
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({'isVerified': true});

          setState(() {
            isVerified = true;
          });

          // 성공 팝업 및 화면 전환
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("인증되었습니다"),
                content: Text("사업장 명칭이 일치합니다."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 팝업 닫기
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text("확인"),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 업데이트 실패: ${e.toString()}')),
        );
      }
    } else {
      // 인증 실패
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'isVerified': false});

        setState(() {
          isVerified = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사업장 명칭이 일치하지 않습니다.')),
        );
      }
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
        title: Text('PDF 파일 업로드', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // 상단 배경 이미지
          Container(
            height: MediaQuery.of(context).size.height * 0.6, // 이미지 높이 조정
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pdfup.webp'), // 이미지 파일 경로
                fit: BoxFit.cover, // 이미지 전체 표시
              ),
            ),
          ),
          // 하단 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '필요한 파일을 업로드하세요',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildUploadButton(
                            label: '4대보험 확인증 선택',
                            selected: _insurancePdf != null,
                            onPressed: () => _pickFile('insurance'),
                            businessName: _insuranceBusinessName,
                          ),
                          SizedBox(height: 20), // 버튼 간격 조정
                          _buildUploadButton(
                            label: '근로계약서 선택',
                            selected: _contractPdf != null,
                            onPressed: () => _pickFile('contract'),
                            businessName: _contractBusinessName,
                          ),
                          SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: _verifyAndProceed,
                            icon: Icon(Icons.upload_file, color: Colors.white),
                            label: Text(
                              '제출',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
    String? businessName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            selected ? Icons.check_circle : Icons.file_upload,
            color: Colors.white,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? Colors.green : Colors.grey[800],
            padding: EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          label: Text(
            selected ? '$label 완료' : label,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        if (businessName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '사업장 명칭: $businessName',
              style: TextStyle(color: Colors.blue, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
