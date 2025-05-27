// lib/pages/InquiryMainPage.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/pages/InquiryFormPage.dart';
import 'package:project/pages/InquiryDetailPage.dart';
import 'inquiry_service.dart';

// Inquiry 모델 정의
class Inquiry {
  final String id;
  final String title;
  final String contentPreview;
  final String? fullContent;
  final String date;
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
  final Color _scaffoldBgColor = Colors.grey.shade200;
  final Color _cardBgColor = Colors.white;
  final Color _appBarBgColor = Colors.white;
  final Color _primaryTextColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey.shade700;
  final Color _accentColor = Colors.blue.shade700;

  List<Inquiry> _inquiries = [];
  bool _isLoading = true;
  final InquiryApiService _inquiryApiService = InquiryApiService();

  @override
  void initState() {
    super.initState();
    _fetchMyInquiries();
  }

  Future<void> _fetchMyInquiries() async {
    if (!mounted) return;
    if (_inquiries.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final inquiriesFromServer = await _inquiryApiService.fetchMyInquiries();
      if (mounted) {
        // 서버에서 이미 정렬된 데이터를 받는다고 가정
        setState(() {
          _inquiries = inquiriesFromServer;
        });
      }
    } catch (e) {
      print("문의 목록 가져오기 최종 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('문의 목록을 가져오는 데 실패했습니다: $e')));
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
      _fetchMyInquiries();
    }
  }

  void _navigateToInquiryDetail(Inquiry inquiryFromList) {
    if (inquiryFromList.isPrivate) {
      TextEditingController passwordController = TextEditingController();
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
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
                    Navigator.pop(dialogContext);
                    _loadAndShowDetail(
                      inquiryFromList.id,
                      password: passwordController.text,
                    );
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
      );
    } else {
      _loadAndShowDetail(inquiryFromList.id);
    }
  }

  Future<void> _loadAndShowDetail(String inquiryId, {String? password}) async {
    if (!mounted) return;

    // 로딩 상태를 UI에 직접 반영할 수도 있습니다. (예: _isLoading 변수 사용)
    // 여기서는 다이얼로그를 사용합니다.
    // 다이얼로그를 위한 새로운 context를 사용하지 않고, 현재 페이지의 context를 사용합니다.
    showDialog(
      context: context, // 현재 페이지의 context
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // 다이얼로그 자체의 context
        return const Center(child: CircularProgressIndicator());
      },
    );

    Inquiry? detailInquiry;
    String? errorMessage;

    try {
      detailInquiry = await _inquiryApiService.getInquiryDetail(
        inquiryId,
        password: password,
      );
      // API 호출 성공 후 다이ALOG 닫기
      if (mounted) {
        // mounted 확인 후 Navigator.pop 호출
        Navigator.pop(context); // showDialog를 호출한 context로 pop
      }
    } on DioException catch (e) {
      if (mounted) Navigator.pop(context); // 오류 발생 시에도 다이ALOG 닫기
      if (e.response?.statusCode == 403) {
        errorMessage = '비공개 글 접근 권한이 없거나 비밀번호가 일치하지 않습니다.';
      } else if (e.response?.data is Map &&
          (e.response!.data as Map).containsKey('message')) {
        errorMessage = (e.response!.data as Map)['message'];
      } else if (e.response?.data is String &&
          (e.response!.data as String).isNotEmpty) {
        errorMessage = e.response!.data as String;
      } else {
        errorMessage = e.message ?? '데이터 로딩 중 오류가 발생했습니다.';
      }
      print("❗ 문의 상세 API DioException: $errorMessage \nFull Error: $e");
    } catch (e) {
      if (mounted) Navigator.pop(context); // 일반 오류 발생 시에도 다이ALOG 닫기
      errorMessage = '알 수 없는 오류가 발생했습니다: $e';
      print("❗ 문의 상세 API 일반 오류: $errorMessage");
    }
    // finally 블록은 여기서 필요 없을 수 있습니다. try-catch에서 pop을 모두 처리했기 때문입니다.

    if (!mounted) return; // Navigator.pop 후 mounted 다시 확인

    if (detailInquiry != null) {
      // 다이얼로그가 확실히 닫힌 후 다음 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InquiryDetailPage(inquiry: detailInquiry!),
        ),
      );
    } else {
      if (errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('문의 상세 정보를 불러오지 못했습니다.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          '1:1 문의 내역',
          style: TextStyle(
            color: _primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _appBarBgColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: _primaryTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
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
        label: const Text(
          '새 문의 작성',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
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
                            child: Icon(
                              Icons.lock_outline,
                              size: 16,
                              color: _secondaryTextColor,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            inquiry.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: _primaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          inquiry.status == '답변 완료'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      inquiry.status,
                      style: TextStyle(
                        color:
                            inquiry.status == '답변 완료'
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
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
                style: TextStyle(
                  color: _secondaryTextColor,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (inquiry.writerName != null &&
                      inquiry.writerName!.isNotEmpty)
                    Text(
                      "${inquiry.writerName} · ",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
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
