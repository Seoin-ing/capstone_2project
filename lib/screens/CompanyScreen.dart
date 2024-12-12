import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:csv/csv.dart';

class CompanyListScreen extends StatefulWidget {
  @override
  _CompanyListScreenState createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  // 파일 이름과 디스플레이 이름 매핑
  final Map<String, String> companyFiles = {
    'csv/1.csv': '(주)교원구몬',
    'csv/2.csv': '(주)바로고',
    'csv/3.csv': '(주)신세계',
    'csv/4.csv': '(주)신세계L&B',
    'csv/5.csv': '(주)에이비씨마트코리아',
    'csv/6.csv': '(주)현대백화점',
    'csv/7.csv': '153구포국수',
    'csv/8.csv': '7번가피자',
    'csv/9.csv': 'aimerfeel',
    'csv/10.csv': 'CU',
    'csv/11.csv': 'H&M',
    'csv/12.csv': 'iCOOP',
    'csv/13.csv': 'KFC',
    'csv/14.csv': 'N서울타워_푸드월드',
    'csv/15.csv': 'SK매직',
    'csv/16.csv': 'SK에너지',
    'csv/17.csv': 'SSG.COM',
    'csv/18.csv': '㈜이마트',
    'csv/19.csv': '㈜이마트에브리데이',
    'csv/20.csv': '㈜초록마을',
    'csv/21.csv': '갓덴스시',
    'csv/22.csv': '경복궁_삿뽀로_엔타스',
    'csv/23.csv': '고반식당',
    'csv/24.csv': '교원웰스',
    'csv/25.csv': '교촌치킨',
    'csv/26.csv': '꽃마름',
    'csv/27.csv': '노브랜드',
    'csv/28.csv': '놀부',
    'csv/29.csv': '대교 눈높이',
    'csv/30.csv': '더플레이스',
    'csv/31.csv': '덕수파스타',
    'csv/32.csv': '도미노 피자',
    'csv/33.csv': '딘타이펑',
    'csv/34.csv': '딜리온',
    'csv/35.csv': '딜버',
    'csv/36.csv': '뚜레쥬르',
    'csv/37.csv': '롯데리아',
    'csv/38.csv': '롯데마트',
    'csv/39.csv': '롯데슈퍼',
    'csv/40.csv': '마장동고기집',
    'csv/41.csv': '만나플러스',
    'csv/42.csv': '맘스터치',
    'csv/43.csv': '매드포갈릭 & TGIF',
    'csv/44.csv': '매머드커피',
    'csv/45.csv': '맥도날드',
    'csv/46.csv': '메가마트',
    'csv/47.csv': '메가스터디',
    'csv/48.csv': '무신사스탠다드',
    'csv/49.csv': '미스사이공',
    'csv/50.csv': '백종원의 더본코리아 직,가맹점',
    'csv/51.csv': '버거킹 & 팀홀튼',
    'csv/52.csv': '빅바이트컴퍼니',
    'csv/53.csv': '빕스',
    'csv/54.csv': '성원아이북랜드',
    'csv/55.csv': '세븐일레븐',
    'csv/56.csv': '스타벅스',
    'csv/57.csv': '써브웨이',
    'csv/58.csv': '아소비',
    'csv/59.csv': '아웃백',
    'csv/60.csv': '아워홈',
    'csv/61.csv': '엔제리너스',
    'csv/62.csv': '영웅배송 스파이더',
    'csv/63.csv': '올리브영',
    'csv/64.csv': '웅진씽크빅',
    'csv/65.csv': '유니클로',
    'csv/66.csv': '이랜드이츠',
    'csv/67.csv': '이마트24',
    'csv/68.csv': '자라코리아',
    'csv/69.csv': '장원교육',
    'csv/70.csv': '제일제면소',
    'csv/71.csv': '지오다노',
    'csv/72.csv': '청호나이스',
    'csv/73.csv': '코웨이',
    'csv/74.csv': '코지하우스',
    'csv/75.csv': '쿠팡 헬퍼',
    'csv/76.csv': '크라운호프_금복주류_경성주막_토라',
    'csv/77.csv': '크리스피 크림 도넛',
    'csv/78.csv': '투썸플레이스 주식회사',
    'csv/79.csv': '파리바게뜨 & 파스쿠찌',
    'csv/80.csv': '파스퇴르 밀크바',
    'csv/81.csv': '풀무원녹즙',
    'csv/82.csv': '플레이타임중앙 주식회사',
    'csv/83.csv': '플레이팅',
    'csv/84.csv': '하남돼지집',
    'csv/85.csv': '하이디라오',
    'csv/86.csv': '하이케어솔루션 주식회사',
    'csv/87.csv': '한솔교육',
    'csv/88.csv': '할리스커피 & 디초콜릿커피앤드',
    'csv/89.csv': '호박패밀리',
    'csv/90.csv': '홈플러스 익스프레스',
  };

  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    _loadCompanyFiles();
  }

  Future<void> _loadCompanyFiles() async {
    try {
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("회사 목록 로드 중 오류 발생: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // 특정 회사의 채용 공고 화면으로 이동
  void _navigateToCompanyDetail(String csvPath, String displayName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CompanyDetailScreen(csvPath: csvPath, displayName: displayName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: companyFiles.length,
              itemBuilder: (context, index) {
                final csvPath = companyFiles.keys.elementAt(index);
                final displayName = companyFiles[csvPath]!; // 한글 이름

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        displayName,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () =>
                          _navigateToCompanyDetail(csvPath, displayName),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class CompanyDetailScreen extends StatefulWidget {
  final String csvPath; // 회사 CSV 경로
  final String displayName; // 회사 디스플레이 이름

  CompanyDetailScreen({required this.csvPath, required this.displayName});

  @override
  _CompanyDetailScreenState createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  List<List<dynamic>> jobData = []; // 채용 데이터 저장
  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    _loadCsvData();
  }

  Future<void> _loadCsvData() async {
    try {
      // CSV 파일 읽기
      final csvData = await rootBundle.loadString('assets/${widget.csvPath}');
      List<List<dynamic>> parsedCsv =
          const CsvToListConverter().convert(csvData);

      setState(() {
        jobData = parsedCsv.skip(1).toList(); // 헤더 제거 후 데이터 저장
        isLoading = false;
      });
    } catch (e) {
      print("CSV 파일 로드 중 오류 발생: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.displayName), // 디스플레이 이름
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : jobData.isEmpty
              ? Center(child: Text('표시할 데이터가 없습니다.'))
              : ListView.builder(
                  itemCount: jobData.length,
                  itemBuilder: (context, index) {
                    final job = jobData[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      child: ListTile(
                        title: Text(job[1]), // 제목
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("지역: ${job[0]}"),
                            Text("근무시간: ${job[2]}"),
                            Text("급여: ${job[3]}"),
                            Text("날짜: ${job[4]}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
