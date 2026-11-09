import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(ZedGamesApp());

class ZedGamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZED GAMES Zambia',
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('ZED GAMES 🇿🇲 - 4 Action Games + SOUND'), backgroundColor: Colors.green[800]),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        children: [
          gameCard(context, '🔫 ZED SHOOTER', Colors.red, ShooterGame()),
          gameCard(context, '🏃 ZED RUNNER', Colors.orange, RunnerGame()),
          gameCard(context, '👊 ZED FIGHTER', Colors.blue, FighterGame()),
          gameCard(context, '🏎️ ZED RACING', Colors.purple, RacingGame()),
        ],
      ),
    );
  }
  Widget gameCard(BuildContext c, String title, Color col, Widget game){
    return Card(
      color: col,
      child: InkWell(
        onTap: ()=> Navigator.push(c, MaterialPageRoute(builder: (_)=> game)),
        child: Center(child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize:22, fontWeight: FontWeight.bold))),
      ),
    );
  }
}

// SOUND HELPER
class SoundManager {
  static final player = AudioPlayer();
  static void playShoot() async { try{ await player.play(AssetSource('sounds/shoot.mp3')); }catch(e){} }
  static void playBoom() async { try{ await player.play(AssetSource('sounds/boom.mp3')); }catch(e){} }
  static void playJump() async { try{ await player.play(AssetSource('sounds/jump.mp3')); }catch(e){} }
  static void playPunch() async { try{ await player.play(AssetSource('sounds/punch.mp3')); }catch(e){} }
}

// 1. SHOOTER
class ShooterGame extends StatefulWidget{ @override _ShooterGameState createState()=> _ShooterGameState(); }
class _ShooterGameState extends State<ShooterGame>{
  double gunX = 0; List<Offset> bullets=[]; List<Offset> enemies=[]; int score=0; Timer? timer;
  @override void initState(){ super.initState(); enemies=List.generate(5, (i)=> Offset(Random().nextDouble()*300, Random().nextDouble()*200)); timer=Timer.periodic(Duration(milliseconds: 50), (t){ setState((){ bullets=bullets.map((b)=> Offset(b.dx, b.dy-10)).where((b)=> b.dy>0).toList(); for(var b in bullets){ enemies.removeWhere((e){ if((b-e).distance<30){ score++; SoundManager.playBoom(); return true;} return false; }); } if(enemies.length<5) enemies.add(Offset(Random().nextDouble()*300, 0)); }); }); }
  @override void dispose(){ timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: Text('Shooter Score: $score')), body: GestureDetector(onTapDown: (d){ setState(()=> bullets.add(Offset(d.localPosition.dx, MediaQuery.of(c).size.height-100))); SoundManager.playShoot(); }, onPanUpdate: (d){ setState(()=> gunX=d.localPosition.dx); }, child: Stack(children: 
