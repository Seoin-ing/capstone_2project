import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WageCalculatorScreen extends StatefulWidget {
  @override
  _WageCalculatorScreenState createState() => _WageCalculatorScreenState();
}

class _WageCalculatorScreenState extends State<WageCalculatorScreen> {
  final TextEditingController _hourlyWageController = TextEditingController();
  final TextEditingController _dailyHoursController = TextEditingController();
  final TextEditingController _weeklyDaysController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();

  bool includeOvertime = false;
  bool includeTax = false;
  String result = "";

  void calculateWage() {
    try {
      double hourlyWage = double.parse(_hourlyWageController.text);
      double dailyHours = double.parse(_dailyHoursController.text);
      double weeklyDays = double.parse(_weeklyDaysController.text);

      double weeklyWage = hourlyWage * dailyHours * weeklyDays;
      double monthlyWage = weeklyWage * 4;

      if (includeOvertime) {
        double overtimePay =
            (hourlyWage * 1.5) * (dailyHours - 8 > 0 ? dailyHours - 8 : 0);
        weeklyWage += overtimePay * weeklyDays;
        monthlyWage = weeklyWage * 4;
      }

      if (includeTax) {
        double tax = double.parse(_taxController.text) / 100;
        monthlyWage -= monthlyWage * tax;
      }
      final formattedWage = NumberFormat("#,###").format(monthlyWage.floor());

      setState(() {
        result = "월 예상 급여는 ${formattedWage}원 입니다.";
      });
    } catch (e) {
      setState(() {
        result = "입력 값을 확인해주세요.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2024년 최저 시급: 9,860원',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTextField(_hourlyWageController, '시급 입력 (원)'),
            SizedBox(height: 16),
            _buildTextField(_dailyHoursController, '일일 근무 시간 (시간)'),
            SizedBox(height: 16),
            _buildTextField(_weeklyDaysController, '주간 근무일 수 (일)'),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text("초과 근무수당 포함"),
              value: includeOvertime,
              onChanged: (value) {
                setState(() {
                  includeOvertime = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text("세금 계산 포함"),
              value: includeTax,
              onChanged: (value) {
                setState(() {
                  includeTax = value!;
                });
              },
            ),
            if (includeTax) _buildTextField(_taxController, '세율 입력 (%)'),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: calculateWage,
                child: Text("계산하기"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (result.isNotEmpty)
              Text(
                result,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }
}
