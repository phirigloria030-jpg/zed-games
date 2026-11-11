import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZedGamesApp());
}

class ZedGamesApp extends StatelessWidget {
  const ZedGamesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZED GAMES',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZED GAMES ZAMBIA - 4 ACTION'), centerTitle: true, backgroundColor: Colors.green),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          gameTile(context, 'SUBWAY RUN', Icons.directions_run, Colors.orange, const SubwayGame()),
          gameTile(context, 'CHESS', Icons.grid_on, Colors.brown, const ChessGame()),
          gameTile(context, 'FOOTBALL', Icons.sports_soccer, Colors.green, const FootballGame()),
          gameTile(context, 'SHOOTING', Icons.gps_fixed, Colors.red, const ShootingGame()),
        ],
      ),
    );
  }
  Widget gameTile(BuildContext c, String name, IconData icon, Color color, Widget game) {
    return Card(
      color: color,
      child: InkWell(
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => game)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// 1. SUBWAY RUNNER
class SubwayGame extends StatefulWidget {
  const SubwayGame({super.key});
  @override
  State<SubwayGame> createState() => _SubwayGameState();
}
class _SubwayGameState extends State<SubwayGame> {
  int lane = 1; int score = 0; double obstacleY = -1;
  final player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return false;
      setState(() {
        obstacleY += 0.02;
        if (obstacleY > 1) { obstacleY = -1; score += 10; }
        if ((obstacleY > 0.6 && obstacleY < 0.9) && Random().nextInt(3) == lane) {
          score = 0; player.play(UrlSource('https://www.soundjay.com/buttons/sounds/button-10.mp3'));
        }
      });
      return true;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SUBWAY RUN Score:$score')),
      body: GestureDetector(
        onHorizontalDragEnd: (d) {
          if (d.primaryVelocity! > 0 && lane < 2) { setState(() => lane++); player.play(UrlSource('https://www.soundjay.com/buttons/sounds/button-09.mp3')); }
          if (d.primaryVelocity! < 0 && lane > 0) { setState(() => lane--); player.play(UrlSource('https://www.soundjay.com/buttons/sounds/button-09.mp3')); }
        },
        child: Stack(
          children: [
            Container(color: Colors.grey[300]),
            Positioned(left: lane * 120 + 20, top: 500, child: const Icon(Icons.person, size: 60, color: Colors.blue)),
            Positioned(left: Random().nextInt(3) * 120 + 20, top: obstacleY * 600, child: const Icon(Icons.train, size: 50, color: Colors.red)),
            const Center(child: Text('Swipe Left/Right to Run!', style: TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }
}

// 2. CHESS SIMPLE
class ChessGame extends StatefulWidget {
  const ChessGame({super.key});
  @override
  State<ChessGame> createState() => _ChessGameState();
}
class _ChessGameState extends State<ChessGame> {
  List<List<String>> board = List.generate(8, (i) => List.generate(8, (j) => (i==1)?'♟':(i==6)?'♙':''));
  int? selRow, selCol;
  final player = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CHESS - Tap to Move')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemCount: 64,
        itemBuilder: (c, i) {
          int r = i ~/ 8, col = i % 8;
          bool isSel = selRow==r && selCol==col;
          return InkWell(
            onTap: () {
              player.play(UrlSource('https://www.soundjay.com/buttons/sounds/button-09.mp3'));
              setState(() {
                if (selRow==null) { selRow=r; selCol=col; }
                else { board[r][col]=board[selRow!][selCol!]; board[selRow!][selCol!]=''; selRow=null; }
              });
            },
            child: Container(
              color: isSel?Colors.yellow:((r+col)%2==0?Colors.white:Colors.brown[400]),
              child: Center(child: Text(board[r][col], style: const TextStyle(fontSize: 28))),
            ),
          );
        },
      ),
    );
  }
}

// 3. FOOTBALL PENALTY
class FootballGame extends StatefulWidget {
  const FootballGame({super.key});
  @override
  State<FootballGame> createState() => _FootballGameState();
}
class _FootballGameState extends State<FootballGame> {
  double ballX = 0, ballY = 0; int goals = 0;
  final player = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FOOTBALL Goals:$goals')),
      body: GestureDetector(
        onTapDown: (d) {
          setState(() { ballX = d.localPosition.dx; ballY = d.localPosition.dy; });
          if (ballY < 200) { goals++; player.play(UrlSource('https://www.soundjay.com/misc/sounds/crowd-cheer-1.mp3')); }
          else { player.play(UrlSource('https://www.soundjay.com/buttons/sounds/button-10.mp3')); }
        },
        child: Stack(
          children: [
            Container(color: Colors.green[200]),
            Positioned(top: 50, left: 100, right: 100, child: Container(height: 100, color: Colors.white, child: const Icon(Icons.sports_soccer, size: 40))),
            Positioned(left: ballX-15, top: ballY-15, child: const Icon(Icons.sports_soccer, size: 30)),
            const Positioned(bottom: 50, left: 0, right: 0, child: Center(child: Text('TAP to Shoot to Goal!'))),
          ],
        ),
      ),
    );
  }
}

// 4. SHOOTING GAME
class ShootingGame extends StatefulWidget {
  const ShootingGame({super.key});
  @override
  State<ShootingGame> createState() => _ShootingGameState();
}
class _ShootingGameState extends State<ShootingGame> {
  double targetX = 100, targetY = 200; int hits = 0;
  final player = AudioPlayer(); final rand = Random();
  void newTarget() { setState(() { targetX = rand.nextDouble()*300; targetY = rand.nextDouble()*500+100; }); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SHOOTING Hits:$hits')),
      body: GestureDetector(
        onTapDown: (d) {
          if ((d.localPosition.dx-targetX).abs()<40 && (d.localPosition.dy-targetY).abs()<40) {
            hits++; player.play(UrlSource('https://www.soundjay.com/mechanical/sounds/gun-gunshot-01.mp3')); newTarget();
          }
        },
        child: Stack(
          children: [
            Container(color: Colors.black12),
            Positioned(left: targetX, top: targetY, child: const Icon(Icons.adjust, size: 60, color: Colors.red)),
            const Positioned(bottom: 30, left: 0, right: 0, child: Center(child: Text('TAP RED TARGET TO SHOOT!'))),
          ],
        ),
      ),
    );
  }
}
