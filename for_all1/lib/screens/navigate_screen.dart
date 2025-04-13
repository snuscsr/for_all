import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/tour_state.dart';

class NavigateScreen extends StatefulWidget{
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen>{
  final AudioPlayer player = AudioPlayer();

  @override
  void initState(){
    super.initState();

    Future.delayed(Duration.zero, (){
      final tourState = Provider.of<TourState>(context, listen: false);
      final curindex = tourState.currentArtworkIndex;
      final preindex = tourState.previousArtworkIndex;
      final entry = tourState.entryPoint;

      String audioPath;
      if (entry == 1) {
        audioPath = 'audio/routes/$preindex$curindex.mp3';
      } else if (entry == 2) {
        audioPath = 'audio/routes/$preindex$curindex.mp3';
      } else {
        audioPath = 'audio/routes/9$curindex.mp3'; //시작지점에서 날아가는거임
      }
      player.play(AssetSource(audioPath));
    });
  }
  @override
  void dispose(){
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('작품 길찾기')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/explanation');
          },
          child: const Text('작품 해설 듣기'),
        ),
      ),
    );
  }
}
/*class NavigateScreen extends StatelessWidget {
  const NavigateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('작품 길찾기')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/explanation');
          },
          child: const Text('작품 해설 듣기'),
        ),
      ),
    );
  }
}*/
