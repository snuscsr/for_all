import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/tour_state.dart';


// 버튼 공통 위젯
Widget _buildButton(BuildContext context, String text, VoidCallback onPressed,
    [bool isDisabled = false, IconData? icon]) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    width: double.infinity,
    height: 65,
    child: ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFD600),
        disabledBackgroundColor: Colors.grey[700],
        foregroundColor: Colors.black,
        disabledForegroundColor: Colors.white70,
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 24),
            const SizedBox(width: 12),
          ],
          Text(isDisabled ? '해설 재생 중... ($text)' : text),
        ],
      ),
    ),
  );
}

class ExplanationScreen extends StatefulWidget {
  const ExplanationScreen({super.key});

  @override
  State<ExplanationScreen> createState() => _ExplanationScreenState();
}

class _ExplanationScreenState extends State<ExplanationScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int currentBlockIndex = 0;
  double currentSpeed = 1.0;
  bool isCompleted = false;
  bool isPlaying = false;
  bool _doubleTapDetected = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isCompleted = true;
        isPlaying = false;
      });
    });
  }

  void _startAudio(String assetPath) async {
    await _audioPlayer.play(AssetSource(assetPath));
    _audioPlayer.setPlaybackRate(currentSpeed);
    setState(() {
      isPlaying = true;
      isCompleted = false;
      currentBlockIndex = 0;
    });
  }

  void _nextBlock(List<Duration> blocks) {
    if (currentBlockIndex < blocks.length - 1) {
      currentBlockIndex++;
      _audioPlayer.seek(blocks[currentBlockIndex]);
    }
  }

  void _changeSpeed() {
    setState(() {
      if (currentSpeed == 1.0) {
        currentSpeed = 1.5;
      } else if (currentSpeed == 1.5) {
        currentSpeed = 2.0;
      } else {
        currentSpeed = 1.0;
      }
      _audioPlayer.setPlaybackRate(currentSpeed);
    });
  }

  void _showEndOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "해설 종료",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "다음 작업을 선택하세요.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<TourState>(context, listen: false).goToNextArtwork();
                Navigator.pushNamed(context, '/navigate');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD600),
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("다음 작품"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/artworks');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("다른 작품"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/end');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("관람 종료"),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.all(16),
      ),
    );
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      await _audioPlayer.resume();
      setState(() {
        isPlaying = true;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  final tourState = Provider.of<TourState>(context);
  final artwork = tourState.artworks[tourState.currentArtworkIndex];
  final selectedOptions = tourState.selectedOptions;
  final audioPath = artwork.audioAssetPath;
  final blocks = artwork.blockTimestamps;

  if (isCompleted) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEndOptions(context);
    });
  }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          artwork.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Future.delayed(const Duration(milliseconds: 250), () {
            if (!_doubleTapDetected) _togglePlayPause();
          });
        },
        onDoubleTap: () {
          _doubleTapDetected = true;
          _changeSpeed();
          Future.delayed(const Duration(milliseconds: 300), () {
            _doubleTapDetected = false;
          });
        },
        onLongPress: () => _nextBlock(blocks),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '작품 해설',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '화면을 한 번 탭하면 재생/일시정지, 두 번 탭하면 재생 속도 변경, 길게 누르면 다음 섹션으로 이동합니다.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedOptions.length,
                  itemBuilder: (context, index) {
                    final option = selectedOptions[index];
                    final content = artwork.details[option] ?? '정보 없음';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[900],
                        border: Border.all(
                          color: Colors.grey[800]!,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD600),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              content,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _buildButton(
                context, 
                isPlaying ? '일시 정지' : '해설 듣기 (x$currentSpeed)',
                isPlaying ? _togglePlayPause : () => _startAudio(audioPath),
                false,
                isPlaying ? Icons.pause : Icons.play_arrow
              ),
              _buildButton(
                context,
                '다음 작품 보러가기',
                () {
                  tourState.goToNextArtwork();
                  Navigator.pushNamed(context, '/navigate');
                },
                false,
                Icons.arrow_forward
              ),
              _buildButton(
                context,
                '작품 리스트로 돌아가기',
                () {
                  Navigator.pushNamed(context, '/artworks');
                },
                false,
                Icons.list
              ),
              _buildButton(
                context,
                '관람 종료하기',
                () {
                  Navigator.pushNamed(context, '/end');
                },
                false,
                Icons.exit_to_app
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}