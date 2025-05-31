import 'package:flutter/material.dart';
import 'package:project/widgets/image_slider_widgets.dart';

class Teaminvitationpage extends StatelessWidget {
  const Teaminvitationpage({super.key});

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: _buildList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() => ListView(
    children: [
      _tile("안녕하세요", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요1", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요2", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요3", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요4", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요5", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요2", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요3", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요4", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요5", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요2", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요3", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요4", "반갑습니다", "2025-04-08"),
      _tile("안녕하세요5", "반갑습니다", "2025-04-08"),
    ],
  );

  Widget _tile(String title, String subtitle, String createdAt) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 팀 로고
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                "assets/images/whitedog.png",
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            // 텍스트 및 버튼
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ✅ 타이틀 + 날짜를 한 줄로
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        createdAt,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(subtitle),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: ElevatedButton(
                          onPressed: () {
                            print("수락 누름");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF20fc24),
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Icon(Icons.check, size: 30,),
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: OutlinedButton(
                          onPressed: () {
                            print("거절 누름");
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color(0xFFfc2f2f),
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Icon(Icons.close, size: 30,),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


// ListTile _tile(String title, String subtitle, String createdAt) => ListTile(
//   title: Text(title),
//   subtitle: Text(subtitle),
//   trailing: Text(createdAt), // 초대를 보낼때 그 시간 받아옴
//   leading: ClipRRect(
//     borderRadius: BorderRadius.circular(100),
//     child: Image.asset("assets/images/whitedog.png"),// 팀 초대를 보낸 팀의 로고 받아와야함(이건임시)
//   ),
// );
}

