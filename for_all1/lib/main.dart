import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'providers/tour_state.dart';
import 'screens/start_screen.dart';
import 'screens/option_screen.dart';
import 'screens/artwork_list_screen.dart';
import 'screens/navigate_screen.dart';
import 'screens/explanation_screen.dart';
import 'screens/end_screen.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TourState()..loadArtworks(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '전시 관람 앱',
      theme: appTheme,
      initialRoute: '/start',
      routes: {
        '/start': (_) => const StartScreen(),
        '/options': (_) => const OptionScreen(),
        '/artworks': (_) => const ArtworkListScreen(),
        '/navigate': (_) => const NavigateScreen(),
        '/explanation': (_) => const ExplanationScreen(),
        '/end': (_) => const EndScreen(),
        // 만약 새로운 화면을 구성한다면 여기에 루트 추가해주면 됩니다
      },
    );
  }
}
