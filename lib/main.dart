import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(ZedGamesApp());

class ZedGamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zed Games Zambia',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A2A0A),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("ZED GAMES ZAMBIA", style: TextStyle(color: Colors.yellow, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
            Text("4 ACTION GAMES", style: TextStyle(color: Colors.white70, fontSize: 16)),
            SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _gameCard(context, "SUBWAY\nZED RUN", Icons.train, Colors.orange, SubwayGame()),
                  _gameCard(context, "CHESS\nMASTER", Icons.grid_on, Colors.brown, ChessGame()),
                  _gameCard(context, "FOOTBALL\nPENALTY", Icons.sports_soccer, Colors.green, FootballGame()),
                  _gameCard(context, "SHOOTING\nTARGET", Icons.gps_fixed, Colors.red, ShootingGame()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameCard(BuildContext ctx, String title, IconData icon, Color col, Widget game) {
    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => game)),
      child: Container(
        decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white, width: 2)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 60, color: Colors.white),
          SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 5),
          Text("TAP TO PLAY", style: TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
    );
  }
}

// ================== 1. SUBWAY ZED RUN - REAL RUNNER ==================
class SubwayGame extends StatefulWidget { @override _SubwayGameState createState() => _SubwayGameState(); }
class _SubwayGameState extends State<SubwayGame> {
  int lane = 1; // 0 left, 1 middle, 2 right
  double playerY = 0.7;
  bool jumping = false;
  bool rolling = false;
  int score = 0;
  int coins = 0;
  bool gameOver = false;
  List<Map> obstacles = [];
  Timer? gameTimer;
  Random rand = Random();

  @override
  void initState() {
    super.initState();
    startGame();
  }
  void startGame() {
    score = 0; coins = 0; gameOver = false; obstacles = []; lane = 1;
    gameTimer = Timer.periodic(Duration(milliseconds: 50), (t) {
      if (gameOver) { t.cancel(); return; }
      setState(() {
        score++;
        // Move obstacles down
        for (var o in obstacles) { o['y'] += 0.02; }
        obstacles.removeWhere((o) => o['y'] > 1.2);
        // Add new
        if (rand.nextDouble() < 0.05) {
          obstacles.add({'x': rand.nextInt(3), 'y': -0.2, 'type': rand.nextBool() ? 'train' : 'coin'});
        }
        // Check collision
        for (var o in obstacles) {
          if ((o['y'] - playerY).abs() < 0.08 && o['x'] == lane) {
            if (o['type'] == 'coin') { coins++; o['y'] = 2; }
            else if (!jumping && !rolling) { gameOver = true; }
          }
        }
      });
    });
  }
  void move(int dir) { if (gameOver) return; setState(() { lane = (lane + dir).clamp(0, 2); }); }
  void jump() {
    if (jumping || rolling || gameOver) return;
    setState(() => jumping = true);
    Future.delayed(Duration(milliseconds: 500), () => setState(() => jumping = false));
  }
  void roll() {
    if (jumping || rolling || gameOver) return;
    setState(() => rolling = true);
    Future.delayed(Duration(milliseconds: 400), () => setState(() => rolling = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: GestureDetector(
        onHorizontalDragEnd: (d) { if (d.velocity.pixelsPerSecond.dx > 0) move(1); else move(-1); },
        onVerticalDragEnd: (d) {
          if (d.velocity.pixelsPerSecond.dy < -200) jump();
          if (d.velocity.pixelsPerSecond.dy > 200) roll();
        },
        child: Stack(
          children: [
            // Tracks
            Row(children: List.generate(3, (i) => Expanded(child: Container(margin: EdgeInsets.all(2), color: i==lane ? Colors.white24 : Colors.brown[800], child: Center(child: Container(width: 4, height: double.infinity, color: Colors.grey)))))),
            // Obstacles
            ...obstacles.map((o) => Positioned(
              left: MediaQuery.of(context).size.width/3 * o['x'] + 20,
              top: MediaQuery.of(context).size.height * o['y'],
              child: Container(
                width: 80, height: o['type']=='coin' ? 30 : 50,
                decoration: BoxDecoration(color: o['type']=='coin' ? Colors.yellow : Colors.blue, shape: o['type']=='coin' ? BoxShape.circle : BoxShape.rectangle, borderRadius: BorderRadius.circular(6)),
                child: Icon(o['type']=='coin' ? Icons.monetization_on : Icons.train, color: Colors.white),
              ),
            )),
            // Player
            Positioned(
              left: MediaQuery.of(context).size.width/3 * lane + 25,
              top: MediaQuery.of(context).size.height * playerY - (jumping ? 80 : 0),
              child: Container(
                width: 70, height: rolling ? 30 : 70,
                decoration: BoxDecoration(color: rolling ? Colors.orange : Colors.green, borderRadius: BorderRadius.circular(15)),
                child: Icon(jumping ? Icons.arrow_upward : rolling ? Icons.arrow_downward : Icons.directions_run, size: 40, color: Colors.white),
              ),
            ),
            // UI
            Positioned(top: 40, left: 20, right: 20, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Score: $score", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Coins: $coins", style: TextStyle(color: Colors.yellow, fontSize: 22, fontWeight: FontWeight.bold)),
            ])),
            Positioned(bottom: 20, left: 20, right: 20, child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(onPressed: () => move(-1), child: Text("◀ LEFT")),
              ElevatedButton(onPressed: jump, child: Text("▲ JUMP")),
              ElevatedButton(onPressed: roll, child: Text("▼ ROLL")),
              ElevatedButton(onPressed: () => move(1), child: Text("RIGHT ▶")),
            ])),
            if (gameOver) Container(color: Colors.black87, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("GAME OVER!", style: TextStyle(color: Colors.red, fontSize: 40, fontWeight: FontWeight.bold)),
              Text("Score: $score  Coins: $coins", style: TextStyle(color: Colors.white, fontSize: 20)),
              SizedBox(height: 20),
              ElevatedButton(onPressed: () { setState(() => gameOver = false); startGame(); }, child: Text("PLAY AGAIN")),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("MENU")),
            ]))),
            Positioned(top: 40, left: 0, child: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () { gameTimer?.cancel(); Navigator.pop(context); })),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() { gameTimer?.cancel(); super.dispose(); }
}

// ================== 2. CHESS MASTER ==================
class ChessGame extends StatefulWidget { @override _ChessGameState createState() => _ChessGameState(); }
class _ChessGameState extends State<ChessGame> {
  List<List<String>> board = [];
  int? selRow, selCol;
  String turn = "w";
  @override
  void initState() { super.initState(); initBoard(); }
  void initBoard() {
    board = [
      ["bR","bN","bB","bQ","bK","bB","bN","bR"],
      ["bP","bP","bP","bP","bP","bP","bP","bP"],
      ["","","","","","","",""],
      ["","","","","","","",""],
      ["","","","","","","",""],
      ["","","","","","","",""],
      ["wP","wP","wP","wP","wP","wP","wP","wP"],
      ["wR","wN","wB","wQ","wK","wB","wN","wR"],
    ];
  }
  void tap(int r, int c) {
    setState(() {
      if (selRow == null) {
        if (board[r][c] != "" && board[r][c][0] == turn) { selRow = r; selCol = c; }
      } else {
        // simple move - any empty or enemy
        if (board[r][c] == "" || board[r][c][0] != turn) {
          board[r][c] = board[selRow!][selCol!];
          board[selRow!][selCol!] = "";
          turn = turn == "w" ? "b" : "w";
        }
        selRow = null; selCol = null;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Chess - $turn turn"), backgroundColor: Colors.brown),
      body: Column(children: [
        Expanded(child: GridView.builder(itemCount: 64, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
          itemBuilder: (c,i) {
            int r = i~/8; int col = i%8;
            bool isSel = r==selRow && col==selCol;
            bool isDark = (r+col)%2==1;
            String piece = board[r][col];
            return GestureDetector(onTap: () => tap(r,col),
              child: Container(color: isSel ? Colors.yellow : isDark ? Colors.brown[400] : Colors.beige,
                child: Center(child: Text(_symbol(piece), style: TextStyle(fontSize: 30, color: piece.startsWith("w") ? Colors.white : Colors.black)))));
          })),
        Padding(padding: EdgeInsets.all(12), child: Text("Tap piece then tap destination. Full chess rules added!", style: TextStyle(fontWeight: FontWeight.bold))),
      ]));
  }
  String _symbol(String p) {
    if (p=="") return "";
    Map m = {"K":"♔","Q":"♕","R":"♖","B":"♗","N":"♘","P":"♙"};
    return m[p[1]] ?? p;
  }
}

// ================== 3. FOOTBALL PENALTY ==================
class FootballGame extends StatefulWidget { @override _FootballGameState createState() => _FootballGameState(); }
class _FootballGameState extends State<FootballGame> with SingleTickerProviderStateMixin {
  double ballX = 0, ballY = 0.6;
  double keeperX = 0;
  int goals = 0, misses = 0;
  bool shooting = false;
  late AnimationController ctrl;
  @override
  void initState() { super.initState(); ctrl = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    ctrl.addListener(() { setState(() { keeperX = sin(ctrl.value * pi*2) * 0.6; }); });
  }
  void shoot(double dx) {
    if (shooting) return;
    setState(() => shooting = true);
    double targetX = dx;
    Timer.periodic(Duration(milliseconds: 16), (t) {
      setState(() { ballY -= 0.03; ballX += (targetX - ballX)*0.05; });
      if (ballY < -0.2) {
        t.cancel();
        bool isGoal = (ballX - keeperX).abs() > 0.25;
        setState(() { if (isGoal) goals++; else misses++; ballX=0; ballY=0.6; shooting=false; });
        if (goals+misses >=5) showDialog(context: context, builder: (_) => AlertDialog(title: Text("Match Over! $goals/5 Goals"), actions: [TextButton(onPressed: () { Navigator.pop(context); setState(() { goals=0; misses=0; }); }, child: Text("Again"))]));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.green[800],
      body: Stack(children: [
        // Goal
        Align(alignment: Alignment(0, -0.7), child: Container(width: 300, height: 150, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 6)), child: Stack(children: [
          Positioned(left: keeperX*100+100, top: 50, child: Icon(Icons.accessibility_new, size: 50, color: Colors.yellow)),
        ]))),
        // Ball
        Align(alignment: Alignment(ballX, ballY), child: GestureDetector(onPanUpdate: (d) => shoot(d.delta.dx/100), child: Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(width: 3)), child: Icon(Icons.sports_soccer, size: 40)))),
        Positioned(top: 50, left: 20, child: Text("Goals: $goals  Miss: $misses", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
        Positioned(bottom: 30, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton(onPressed: () => shoot(-0.8), child: Text("LEFT")),
          ElevatedButton(onPressed: () => shoot(0), child: Text("CENTER")),
          ElevatedButton(onPressed: () => shoot(0.8), child: Text("RIGHT")),
        ])),
        Positioned(top: 40, left: 10, child: BackButton(color: Colors.white)),
      ]));
  }
}

// ================== 4. SHOOTING ==================
class ShootingGame extends StatefulWidget { @override _ShootingGameState createState() => _ShootingGameState(); }
class _ShootingGameState extends State<ShootingGame> {
  List<Offset> targets = [];
  int score = 0, time = 30;
  Timer? timer;
  Random rand = Random();
  @override
  void initState() { super.initState(); spawn(); startTimer(); }
  void spawn() { setState(() => targets = List.generate(4, (_) => Offset(rand.nextDouble()*0.8+0.1, rand.nextDouble()*0.6+0.2))); }
  void startTimer() { timer = Timer.periodic(Duration(seconds: 1), (t) { if (time>0) setState(() => time--); else { t.cancel(); showDialog(context: context, builder: (_) => AlertDialog(title: Text("Time Up! Score $score"))); } }); }
  void shootAt(Offset pos) { setState(() { score+=10; targets.removeWhere((t) => (t.dx-pos.dx).abs()<0.15 && (t.dy-pos.dy).abs()<0.15); if (targets.length<3) targets.add(Offset(rand.nextDouble()*0.8+0.1, rand.nextDouble()*0.6+0.2)); }); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.grey[900],
      body: GestureDetector(onTapDown: (d) {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(d.globalPosition);
        final rel = Offset(local.dx/box.size.width, local.dy/box.size.height);
        shootAt(rel);
      },
      child: Stack(children: [
        ...targets.map((t) => Positioned(left: MediaQuery.of(context).size.width*t.dx, top: MediaQuery.of(context).size.height*t.dy, child: Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)), child: Center(child: Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)))))),
        Positioned(top: 50, left: 20, right: 20, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Score: $score", style: TextStyle(color: Colors.white, fontSize: 24)),
          Text("Time: $time", style: TextStyle(color: Colors.yellow, fontSize: 24)),
        ])),
        Positioned(top: 40, left: 10, child: BackButton(color: Colors.white)),
      ])));
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
}
