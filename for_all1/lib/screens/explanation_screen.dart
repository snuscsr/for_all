import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/tour_state.dart';


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
      builder: (_) => AlertDialog(
        title: const Text("해설 종료"),
        content: const Text("다음 작업을 선택하세요."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<TourState>(context, listen: false).goToNextArtwork();
              Navigator.pushNamed(context, '/navigate');
            },
            child: const Text("다음 작품"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/artworks');
            },
            child: const Text("다른 작품"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/end');
            },
            child: const Text("관람 종료"),
          ),
        ],
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
    appBar: AppBar(title: Text(artwork.title)),
    body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (!_doubleTapDetected) {
            _togglePlayPause();
          }
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: selectedOptions.map((option) {
                  final content = artwork.details[option] ?? '정보 없음';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(content),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (tourState.currentArtworkIndex < tourState.artworks.length - 1) {
                      tourState.goToNextArtwork();
                      tourState.entryPoint = 1;
                      Navigator.pushNamed(context, '/navigate');
                    } else {
                      Navigator.pushNamed(context, '/end');
                    }
                  },
                  child: const Text('다음 작품 보러가기'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    tourState.entryPoint = 2;
                    Navigator.pushNamed(context, '/artworks');
                  },
                  child: const Text('작품 리스트로 돌아가기'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _startAudio(audioPath),
                  child: Text(
                    isPlaying ? '해설 재생 중... (x$currentSpeed)' : '해설 듣기 (x$currentSpeed)',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/end');
                  },
                  child: const Text('관람 종료하기'),
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