import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  // 실제 파일 이름(youngjinN.mp4)에 맞춰 경로를 사용합니다.
  final List<String> videoAssets = [
    'assets/videos/youngjin1.mp4',
    'assets/videos/youngjin2.mp4',
    'assets/videos/youngjin3.mp4',
    'assets/videos/youngjin4.mp4',
    'assets/videos/youngjin5.mp4',
  ];

  final List<VideoPlayerController> _controllers = [];
  int _currentPageIndex = 0; // PageView가 추적하는 실제 인덱스 (0, 1, 2, 3, ...)

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var asset in videoAssets) {
      _controllers.add(
        VideoPlayerController.asset(asset)
          ..initialize().then((_) {
            setState(() {});
          }),
      );
    }
    // 첫 번째 동영상 자동 재생 (실제 동영상 인덱스: 0)
    if (_controllers.isNotEmpty) {
      _controllers[0].play();
      _controllers[0].setLooping(true);
    }
  }

  void _togglePlayPause() {
    // 현재 페이지의 실제 동영상 인덱스를 계산합니다.
    final videoIndex = _currentPageIndex % _controllers.length;
    final controller = _controllers[videoIndex];
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 동영상 피드 (무한 PageView)
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: null, // 무한 스크롤
            onPageChanged: (index) {
              setState(() {
                // 이전 페이지 정지 및 초기화
                final previousVideoIndex = _currentPageIndex % _controllers.length;
                _controllers[previousVideoIndex].pause();
                _controllers[previousVideoIndex].seekTo(Duration.zero);

                _currentPageIndex = index; // 새 인덱스 저장

                // 현재 동영상 재생
                final currentVideoIndex = _currentPageIndex % _controllers.length;
                _controllers[currentVideoIndex].play();
                _controllers[currentVideoIndex].setLooping(true);
              });
            },
            itemBuilder: (context, index) {
              final videoIndex = index % _controllers.length;
              final controller = _controllers[videoIndex];

              // 로딩/초기화 중 상태
              if (!controller.value.isInitialized) {
                return const ColoredBox(
                  color: Colors.black,
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                );
              }

              // 동영상 재생 위젯 및 UI 오버레이
              return GestureDetector(
                onTap: _togglePlayPause, // 탭하여 재생/정지 토글
                child: SizedBox.expand(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // --- 동영상 영역 ---
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      ),

                      // --- 중앙 재생/정지 버튼 오버레이 ---
                      if (!controller.value.isPlaying)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 80,
                            ),
                          ),
                        ),

                      // --- 하단 정보 (제목/사용자) 오버레이 ---
                      Positioned(
                        bottom: 80.0, // 하단 내비게이션 공간 고려
                        left: 20.0,
                        right: 60.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 닉네임 및 팔로우
                            Row(
                              children: [
                                const Text(
                                  '@but_eo_yongjin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    shadows: [Shadow(blurRadius: 2.0, color: Colors.black)],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '팔로우',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 동영상 제목/설명
                            const Text(
                              '오늘의 풋살 하이라이트 #축구 #풋살', // ⚠️ 실제 데이터로 변경 필요
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                shadows: [Shadow(blurRadius: 2.0, color: Colors.black)],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // --- 우측 액션 버튼 오버레이 ---
                      Positioned(
                        bottom: 80.0,
                        right: 0.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // 좋아요 버튼
                            IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.white, size: 32),
                              onPressed: () {
                                // TODO: 좋아요 API 호출
                              },
                            ),
                            const Text('1.2K', style: TextStyle(color: Colors.white, fontSize: 12)), // ⚠️ 실제 데이터로 변경 필요
                            const SizedBox(height: 20),

                            // 댓글 버튼
                            IconButton(
                              icon: const Icon(Icons.comment, color: Colors.white, size: 32),
                              onPressed: () {
                                // TODO: 댓글 창 모달 띄우기
                              },
                            ),
                            const Text('56', style: TextStyle(color: Colors.white, fontSize: 12)), // ⚠️ 실제 데이터로 변경 필요
                            const SizedBox(height: 20),

                            // 공유 버튼
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.white, size: 32),
                              onPressed: () {
                                // TODO: 공유 기능 로직
                              },
                            ),
                            const Text('공유', style: TextStyle(color: Colors.white, fontSize: 12)),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 3. 뒤로 가기 버튼 및 안전 영역 (가장 위에 위치)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}