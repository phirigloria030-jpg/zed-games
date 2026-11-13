import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(ZedGamesApp());

class ZedGamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZED GAMES ZAMBIA',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MainMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A2A0A),
      appBar: AppBar(
        title: Text('ZED GAMES ZAMBIA'),
        backgroundColor: Colors.green[900],
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(title: 'SUBWAY RUN', color: Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubwayGame()))),
            MenuButton(title: 'CHESS', color: Colors.brown, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChessGame()))),
            MenuButton(title: 'FOOTBALL KICK', color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FootballGame()))),
            MenuButton(title: 'SHOOTING', color: Colors.red, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShootingGame()))),
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;
  MenuButton({required this.title, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, padding: EdgeInsets.all(20)),
        onPressed: onTap,
        child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

// SUBWAY GAME
class SubwayGame extends StatefulWidget {
  @override
  _SubwayGameState createState() => _SubwayGameState();
}
class _SubwayGameState extends State<SubwayGame> {
  double playerX = 0;
  double obstacleX = 1.5;
  int score = 0;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 50), (t) {
      setState(() {
        obstacleX -= 0.05;
        if (obstacleX < -1.5) {
          obstacleX = 1.5;
          score++;
        }
        if ((obstacleX - playerX).abs() < 0.3) {
          score = 0;
        }
      });
    });
  }
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(title: Text('SUBWAY RUN - Score: $score')),
      body: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            playerX += d.delta.dx / 200;
            playerX = playerX.clamp(-1.0, 1.0);
          });
        },
        child: Stack(
          children: [
            Positioned(left: MediaQuery.of(context).size.width * (playerX + 1) / 2, bottom: 100, child: Container(width: 50, height: 50, color: Colors.yellow)),
            Positioned(left: MediaQuery.of(context).size.width * (obstacleX + 1) / 2, bottom: 100, child: Container(width: 50, height: 50, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

// CHESS GAME
class ChessGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CHESS')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemCount: 64,
        itemBuilder: (c, i) {
          int row = i ~/ 8;
          int col = i % 8;
          bool isWhite = (row + col) % 2 == 0;
          return Container(color: isWhite ? Colors.white : Colors.brown, child: Center(child: Text(i < 16 || i > 47 ? '♟' : '')));
        },
      ),
    );
  }
}

// FOOTBALL GAME
class FootballGame extends StatefulWidget {
  @override
  _FootballGameState createState() => _FootballGameState();
}
class _FootballGameState extends State<FootballGame> {
  double ballY = 0;
  int goals = 0;
  void kick() {
    setState(() {
      ballY = -1;
      goals++;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() => ballY = 0);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(title: Text('FOOTBALL - Goals: $goals')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(duration: Duration(milliseconds: 300), margin: EdgeInsets.only(bottom: ballY == -1 ? 200 : 0), child: Text('⚽', style: TextStyle(fontSize: 60))),
            SizedBox(height: 50),
            ElevatedButton(onPressed: kick, child: Text('KICK!')),
          ],
        ),
      ),
    );
  }
}

// SHOOTING GAME
class ShootingGame extends StatefulWidget {
  @override
  _ShootingGameState createState() => _ShootingGameState();
}
class _ShootingGameState extends State<ShootingGame> {
  double targetX = 0;
  int hits = 0;
  Random r = Random();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('SHOOTING - Hits: $hits')),
      body: GestureDetector(
        onTapDown: (d) {
          setState(() {
            hits++;
            targetX = r.nextDouble() * 2 - 1;
          });
        },
        child: Stack(
          children: [
            Align(alignment: Alignment(targetX, 0), child: Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Icon(Icons.adjust, color: Colors.white))),
            Center(child: Text('TAP TARGET!', style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
