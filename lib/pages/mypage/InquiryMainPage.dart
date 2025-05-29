import 'package:dio/dio.dart'; // DioException을 사용하기 위해 추가
import 'package:flutter/material.dart';
// inquiry_service.dart 파일의 실제 경로로 수정해야 합니다.
// 예: import 'package:project/services/inquiry_service.dart';
import 'InquiryDetailPage.dart';
import 'InquiryFormPage.dart';
import 'inquiry_service.dart';


// Inquiry 모델 정의 (다른 파일로 옮기는 것이 좋음: models/inquiry_model.dart)
class Inquiry {
  final String id;
  final String title;
  final String contentPreview;
  final String? fullContent; // 상세 내용
  final String date; // "YYYY-MM-DD HH:MM" 형식의 문자열로 가정
  final String status;
  final String? answer;
  final bool isPrivate;
  final String? writerName;

  Inquiry({
    required this.id,
    required this.title,
    required this.contentPreview,
    this.fullContent,
    required this.date,
    required this.status,
    this.answer,
    this.isPrivate = false,
    this.writerName,
  });
}

class InquiryMainPage extends StatefulWidget {
  const InquiryMainPage({super.key});

  @override
  State<InquiryMainPage> createState() => _InquiryMainPageState();
}

class _InquiryMainPageState extends State<InquiryMainPage> {
  // 색상 정의
  final Color _scaffoldBgColor = Colors.grey.shade200;
  final Color _cardBgColor = Colors.white;
  final Color _appBarBgColor = Colors.white;
  final Color _primaryTextColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey.shade700;
  final Color _accentColor = Colors.blue.shade700;

  List<Inquiry> _inquiries = []; // 초기에는 빈 리스트
  bool _isLoading = true; // 초기 로딩 상태 true
  final InquiryApiService _inquiryApiService = InquiryApiService();

  @override
  void initState() {
    super.initState();
    _fetchMyInquiries();
  }

  Future<void> _fetchMyInquiries() async {
    if (!mounted) return;
    // 새로고침이 아닐 때만 (초기 로딩 시) 로딩 인디케이터를 true로 설정
    if (_inquiries.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final inquiriesFromServer = await _inquiryApiService.fetchMyInquiries();
      if (mounted) {
        // 날짜(date 필드)를 기준으로 내림차순 정렬 (최신순)
        // 서버에서 정렬해서 보내주는 것이 가장 좋음. 클라이언트 정렬은 차선책.
        inquiriesFromServer.sort((a, b) {
          try {
            // "YYYY-MM-DD HH:MM" 형식을 DateTime으로 파싱하기 위해 "T" 추가
            DateTime dateA = DateTime.parse(a.date.replaceFirst(" ", "T"));
            DateTime dateB = DateTime.parse(b.date.replaceFirst(" ", "T"));
            return dateB.compareTo(dateA); // 내림차순
          } catch (e) {
            print("날짜 파싱 오류로 정렬 실패 (문의 ID: ${a.id}, ${b.id}): $e");
            return 0; // 파싱 오류 시 순서 변경 없음
          }
        });
        setState(() {
          _inquiries = inquiriesFromServer;
        });
      }
    } catch (e) {
      print("문의 목록 가져오기 최종 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문의 목록을 가져오는 데 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToFormAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InquiryFormPage()),
    );
    if (result == true && mounted) {
      _fetchMyInquiries(); // 문의 작성 후 목록 새로고침
    }
  }

  void _navigateToInquiryDetail(Inquiry inquiryFromList) {
    if (inquiryFromList.isPrivate) {
      TextEditingController passwordController = TextEditingController();
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('비밀번호 입력'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: '비밀번호를 입력하세요'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // 비밀번호 입력 다이얼로그 닫기
                _loadAndShowDetail(inquiryFromList.id, password: passwordController.text);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      _loadAndShowDetail(inquiryFromList.id); // 공개글은 비밀번호 없이 호출
    }
  }

  // *** 여기가 수정된 _loadAndShowDetail 메소드입니다 ***
  Future<void> _loadAndShowDetail(String inquiryId, {String? password}) async {
    if (!mounted) return;

    BuildContext? dialogContext; // 다이얼로그 컨텍스트 저장 변수

    // 로딩 인디케이터 (다이얼로그) 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        dialogContext = ctx; // 다이얼로그의 context 저장
        return const Center(child: CircularProgressIndicator());
      },
    );

    Inquiry? detailInquiry;
    String? errorMessage;

    try {
      detailInquiry = await _inquiryApiService.getInquiryDetail(inquiryId, password: password);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        errorMessage = '비공개 글 접근 권한이 없거나 비밀번호가 일치하지 않습니다.';
      } else if (e.response?.data is Map && (e.response!.data as Map).containsKey('message')) {
        errorMessage = (e.response!.data as Map)['message'];
      } else if (e.response?.data is String && (e.response!.data as String).isNotEmpty) {
        errorMessage = e.response!.data as String;
      } else {
        errorMessage = e.message ?? '데이터 로딩 중 오류가 발생했습니다.';
      }
      print("❗ 문의 상세 API DioException: $errorMessage \nFull Error: $e");
    } catch (e) {
      errorMessage = '알 수 없는 오류가 발생했습니다: $e';
      print("❗ 문의 상세 API 일반 오류: $errorMessage");
    } finally {
      // 다이얼로그가 아직 떠 있다면 (즉, pop되지 않았다면) 닫기
      if (mounted && dialogContext != null && Navigator.of(dialogContext!).canPop()) {
        Navigator.pop(dialogContext!);
      }
    }

    if (!mounted) return;

    if (detailInquiry != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InquiryDetailPage(inquiry: detailInquiry!),
        ),
      );
    } else {
      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        // detailInquiry도 null이고 errorMessage도 null인 경우 (이론적으로는 잘 없지만)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('문의 상세 정보를 불러오지 못했습니다.')),
        );
      }
    }
  }
  // *** _loadAndShowDetail 메소드 수정 끝 ***

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        title: Text('1:1 문의 내역', style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: _appBarBgColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: _primaryTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _accentColor))
          : _inquiries.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _fetchMyInquiries,
        color: _accentColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _inquiries.length,
          itemBuilder: (context, index) {
            final inquiry = _inquiries[index];
            return _buildInquiryCard(inquiry);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToFormAndRefresh,
        backgroundColor: _accentColor,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: const Text('새 문의 작성', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.email_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            '문의 내역이 없습니다.',
            style: TextStyle(fontSize: 18, color: _secondaryTextColor),
          ),
          const SizedBox(height: 8),
          Text(
            '궁금한 점이나 불편한 점을 문의해보세요.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('새로고침'),
            onPressed: _fetchMyInquiries,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor.withOpacity(0.1),
              foregroundColor: _accentColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInquiryCard(Inquiry inquiry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.0,
      color: _cardBgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToInquiryDetail(inquiry),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (inquiry.isPrivate)
                          Padding(
                            padding: const EdgeInsets.only(right: 6.0, top: 2),
                            child: Icon(Icons.lock_outline, size: 16, color: _secondaryTextColor),
                          ),
                        Expanded(
                          child: Text(
                            inquiry.title,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _primaryTextColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: inquiry.status == '답변 완료' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      inquiry.status,
                      style: TextStyle(
                        color: inquiry.status == '답변 완료' ? Colors.green.shade700 : Colors.orange.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                inquiry.contentPreview,
                style: TextStyle(color: _secondaryTextColor, fontSize: 14, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(inquiry.writerName != null && inquiry.writerName!.isNotEmpty)
                    Text(
                      "${inquiry.writerName} · ",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  Text(
                    inquiry.date,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}