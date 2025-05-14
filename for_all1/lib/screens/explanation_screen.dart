import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/tour_state.dart';

class ExplanationScreen extends StatefulWidget {
  const ExplanationScreen({super.key});

  @override
  State<ExplanationScreen> createState() => _ExplanationScreenState();
}

class _ExplanationScreenState extends State<ExplanationScreen> {
  final FlutterTts tts = FlutterTts();
  double currentSpeed = 1.0;
  int? currentlySpeakingIndex;


  @override
  void initState() {
    super.initState();
    tts.setSpeechRate(currentSpeed);
    tts.setLanguage("ko-KR"); // Korean TTS
    tts.setCompletionHandler(() {
    setState(() => currentlySpeakingIndex = null);
});

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
    });
    tts.setSpeechRate(currentSpeed);
  }

  Future<void> _speak(String text) async {
    await tts.stop(); // Stop any ongoing speech
    await tts.setSpeechRate(currentSpeed);
    await tts.speak(text);
  }

  Widget _navButton(BuildContext context, String text, VoidCallback onPressed, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD600),
          foregroundColor: Colors.black,
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
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tourState = Provider.of<TourState>(context);
    final artwork = tourState.artworks[tourState.currentArtworkIndex];
    final selectedOptions = tourState.selectedOptions;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '작품 해설',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '각 항목을 누르면 음성으로 설명이 재생됩니다. 속도 조절 버튼을 통해 음성 속도를 변경할 수 있습니다.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Speed control button
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _changeSpeed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('음성 속도: x$currentSpeed'),
              ),
            ),

            // Explanation blocks
            ...selectedOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final content = artwork.details[option] ?? '정보 없음';
              final isSpeaking = index == currentlySpeakingIndex;

              return ExcludeSemantics(
                child: GestureDetector(
                  onTap: () async {
                    setState(() => currentlySpeakingIndex = index);
                    await _speak('$option. $content');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSpeaking ? const Color(0xFFFFF59D) : Colors.grey[900],
                      border: Border.all(
                        color: isSpeaking ? const Color(0xFFFFD600) : Colors.grey[800]!,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSpeaking ? Colors.black : const Color(0xFFFFD600),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSpeaking ? Colors.yellow : Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSpeaking ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),


            const SizedBox(height: 20),
            _navButton(
              context,
              '다음 작품 보러가기',
              () {
                tourState.goToNextArtwork();
                Navigator.pushNamed(context, '/navigate');
              },
              Icons.arrow_forward,
            ),
            _navButton(
              context,
              '작품 리스트로 돌아가기',
              () {
                Navigator.pushNamed(context, '/artworks');
              },
              Icons.list,
            ),
            _navButton(
              context,
              '관람 종료하기',
              () {
                Navigator.pushNamed(context, '/end');
              },
              Icons.exit_to_app,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }
}
