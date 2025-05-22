import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/tour_state.dart';

class ExplanationScreen extends StatefulWidget {
  const ExplanationScreen({super.key});

  @override
  State<ExplanationScreen> createState() => _ExplanationScreenState();
}

class _ExplanationScreenState extends State<ExplanationScreen> with WidgetsBindingObserver {
  final FlutterTts tts = FlutterTts();
  final ScrollController _scrollController = ScrollController();
  List<GlobalKey> _sectionKeys = [];

  double currentSpeed = 0.5;
  int? currentlySpeakingIndex;
  bool isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tts.setLanguage("ko-KR");
    tts.setSpeechRate(currentSpeed);
    tts.awaitSpeakCompletion(true);

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        playAllSectionsSequentially();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    tts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      tts.stop();
    }
  }

  void _changeSpeed() {
    setState(() {
      if (currentSpeed == 0.5) {
        currentSpeed = 0.7;
      } else if (currentSpeed == 0.7) {
        currentSpeed = 1.0;
      } else {
        currentSpeed = 0.5;
      }
    });
    tts.setSpeechRate(currentSpeed);
  }

  Future<void> _scrollToIndex(int index) async {
    final keyContext = _sectionKeys[index].currentContext;
    if (keyContext != null) {
      await Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _speak(String text, int index) async {
    await _scrollToIndex(index);
    await tts.stop();
    setState(() => currentlySpeakingIndex = index);
    await tts.setSpeechRate(currentSpeed);
    await tts.speak(text);
  }

  Future<void> playAllSectionsSequentially() async {
    final tourState = Provider.of<TourState>(context, listen: false);
    final artwork = tourState.artworks[tourState.currentArtworkIndex];
    final selectedOptions = tourState.selectedOptions;

    final allSections = [
      {'label': '기본 정보', 'text': artwork.description},
      ...selectedOptions.map((option) => {
            'label': option,
            'text': artwork.details[option] ?? '정보 없음',
          }),
    ];

    _sectionKeys = List.generate(allSections.length, (_) => GlobalKey());

    setState(() {
      isAutoPlaying = true;
    });

    await tts.speak(
      "각 항목을 누르면 음성으로 설명이 재생됩니다. 음성 속도는 버튼을 눌러 변경할 수 있습니다.",
    );
    await Future.delayed(const Duration(seconds: 2));

    for (int i = 0; i < allSections.length; i++) {
      final section = allSections[i];
      final label = section['label']!;
      final text = section['text']!;
      setState(() => currentlySpeakingIndex = i);
      await _scrollToIndex(i);
      await tts.speak('$label. $text');
      await Future.delayed(const Duration(seconds: 2));
    }

    setState(() {
      currentlySpeakingIndex = null;
      isAutoPlaying = false;
    });
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
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
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

    final allSections = [
      {'label': '기본 정보', 'text': artwork.description},
      ...selectedOptions.map((option) => {
            'label': option,
            'text': artwork.details[option] ?? '정보 없음',
          }),
    ];

    if (_sectionKeys.length != allSections.length) {
      _sectionKeys = List.generate(allSections.length, (_) => GlobalKey());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          artwork.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
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
              '각 항목을 누르면 음성으로 설명이 재생됩니다.\n음성 속도는 버튼을 눌러 변경할 수 있습니다.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
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
            ...allSections.asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value['label']!;
              final text = entry.value['text']!;
              final isSpeaking = index == currentlySpeakingIndex;

              return Container(
                key: _sectionKeys[index],
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _speak('$label. $text', index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSpeaking ? const Color(0xFFFFF59D) : Colors.grey[900],
                    foregroundColor: isSpeaking ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: isSpeaking ? const Color(0xFFFFD600) : Colors.grey[800]!,
                      width: 2,
                    ),
                    elevation: isSpeaking ? 4 : 0,
                  ),
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
                            '$index',
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
                          label,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
              () => Navigator.pushNamed(context, '/artworks'),
              Icons.list,
            ),
            _navButton(
              context,
              '관람 종료하기',
              () => Navigator.pushNamed(context, '/end'),
              Icons.exit_to_app,
            ),
          ],
        ),
      ),
    );
  }
}
