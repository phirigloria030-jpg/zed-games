import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(ZedGamesApp());

class SoundManager {
  static final AudioPlayer player = AudioPlayer();
  static void play(String f) async {
    try {
      await player.play(AssetSource('sounds/' + f));
    } catch (e) {}
  }
}

class ZedGamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A2A0A),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text('ZED GAMES V5', style: TextStyle(color: Colors.yellow, fontSize: 32, fontWeight: FontWeight.w900)),
            Text('11v11 + BUILDING WAR', style: TextStyle(color: Colors.white, fontSize: 12)),
            Spacer(),
            menuBtn(context, 'SUBWAY ZAMBIAN', Colors.blue, SubwayGame()),
            menuBtn(context, 'FOOTBALL 11v11', Colors.green, FootballGame()),
            menuBtn(context, 'BUILDING WAR', Colors.red, ShootingGame()),
            menuBtn(context, 'CHESS', Colors.brown, ChessGame()),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget menuBtn(BuildContext c, String t, Color col, Widget go) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: col, minimumSize: Size(double.infinity, 60)),
        onPressed: () {
          SoundManager.play('click.mp3');
          Navigator.push(c, MaterialPageRoute(builder: (_) => go));
        },
        child: Text(t, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class SubwayGame extends StatefulWidget { @override State<SubwayGame> createState() => SubwayState(); }
class SubwayState extends State<SubwayGame> {
  int lane = 1; double jump = 0; bool jumping = false; double dist = 0; int coins = 0;
  List<Map> obs = []; List<Map> coinL = []; Timer? timer; Random rand = Random();
  @override void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      obs.add({'z': 5.0 + i * 3.0, 'lane': rand.nextInt(3)});
      coinL.add({'z': 4.0 + i * 2.5, 'lane': rand.nextInt(3)});
    }
    timer = Timer.periodic(Duration(milliseconds: 16), (t) {
      if (!mounted) return;
      setState(() {
        dist += 0.06;
        for (var o in obs) o['z'] -= 0.09;
        for (var c in coinL) c['z'] -= 0.09;
        obs.removeWhere((o) => o['z'] < -1);
        coinL.removeWhere((c) => c['z'] < -1);
        while (obs.length < 7) obs.add({'z': 11 + rand.nextDouble() * 5, 'lane': rand.nextInt(3)});
        while (coinL.length < 12) {
          int l = rand.nextInt(3);
          double b = 11 + rand.nextDouble() * 5;
          for (int k = 0; k < 3; k++) coinL.add({'z': b + k * 0.7, 'lane': l});
        }
        for (var o in obs) {
          if (o['z'] > -0.3 && o['z'] < 0.4 && o['lane'] == lane && jump < 0.4) {
            dist = 0; coins = 0; obs.clear(); coinL.clear();
          }
        }
        for (var c in coinL) {
          if (c['z'] > -0.3 && c['z'] < 0.4 && c['lane'] == lane) {
            coins++; c['z'] = -10; SoundManager.play('coin.mp3');
          }
        }
      });
    });
  }
  void doJump() {
    if (jumping) return;
    setState(() { jumping = true; jump = 1.0; });
    SoundManager.play('jump.mp3');
    Future.delayed(Duration(milliseconds: 250), () { if (mounted) setState(() => jump = 0.6); });
    Future.delayed(Duration(milliseconds: 550), () { if (mounted) setState(() { jump = 0; jumping = false; }); });
  }
  @override void dispose() { timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (d) {
          if (d.velocity.pixelsPerSecond.dx > 150 && lane < 2) setState(() => lane++);
          if (d.velocity.pixelsPerSecond.dx < -150 && lane > 0) setState(() => lane--);
        },
        onVerticalDragEnd: (d) { if (d.velocity.pixelsPerSecond.dy < -150) doJump(); },
        child: Stack(
          children: [
            Container(color: Color(0xFF87CEEB)),
            Positioned(top: 35, left: 10, right: 10, child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: Row(children: [Text(dist.toInt().toString(), style: TextStyle(color: Colors.white)), Spacer(), Text('Coin ' + coins.toString(), style: TextStyle(color: Colors.yellow))]))),
            Align(alignment: Alignment((lane - 1) * 0.75, 0.68 - jump), child: Text('🏃🏾‍♂️', style: TextStyle(fontSize: 50))),
            Positioned(bottom: 15, left: 10, right: 10, child: Row(children: [Expanded(child: ElevatedButton(onPressed: () { if (lane > 0) setState(() => lane--); }, child: Text('<'))), SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: doJump, child: Text('JUMP'))), SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: () { if (lane < 2) setState(() => lane++); }, child: Text('>')))]))
          ],
        ),
      ),
    );
  }
}

class FootballGame extends StatefulWidget { @override State<FootballGame> createState() => FootballState(); }
class FootballState extends State<FootballGame> {
  List<Map> myTeam = []; List<Map> enTeam = []; double ballX = 0, ballY = 0.2; int myScore = 0; int sel = 9;
  @override void initState() {
    super.initState();
    myTeam = [{'x':0.0,'y':0.85,'n':1},{'x':-0.6,'y':0.6,'n':2},{'x':-0.2,'y':0.65,'n':4},{'x':0.2,'y':0.65,'n':5},{'x':0.6,'y':0.6,'n':3},{'x':-0.5,'y':0.3,'n':6},{'x':0.0,'y':0.35,'n':8},{'x':0.5,'y':0.3,'n':10},{'x':-0.4,'y':0.0,'n':7},{'x':0.0,'y':-0.05,'n':9},{'x':0.4,'y':0.0,'n':11}];
    enTeam = [{'x':0.0,'y':-0.85,'n':1},{'x':-0.6,'y':-0.6,'n':2},{'x':-0.2,'y':-0.65,'n':4},{'x':0.2,'y':-0.65,'n':5},{'x':0.6,'y':-0.6,'n':3},{'x':-0.5,'y':-0.3,'n':6},{'x':0.0,'y':-0.35,'n':8},{'x':0.5,'y':-0.3,'n':10},{'x':-0.4,'y':0.0,'n':7},{'x':0.0,'y':-0.05,'n':9},{'x':0.4,'y':0.0,'n':11}];
    ballX = myTeam[9]['x']; ballY = myTeam[9]['y'];
  }
  void move(double dx, double dy) {
    setState(() {
      myTeam[sel]['x'] = (myTeam[sel]['x'] + dx).clamp(-0.85, 0.85);
      myTeam[sel]['y'] = (myTeam[sel]['y'] + dy).clamp(-0.9, 0.9);
      if ((myTeam[sel]['x'] - ballX).abs() < 0.15 && (myTeam[sel]['y'] - ballY).abs() < 0.15) {
        ballX = myTeam[sel]['x']; ballY = myTeam[sel]['y'] - 0.08;
      }
    });
  }
  void shoot() {
    SoundManager.play('shoot.mp3');
    setState(() => ballY = -1.0);
    Future.delayed(Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        if (ballX.abs() < 0.3) { myScore++; SoundManager.play('coin.mp3'); }
        ballX = myTeam[9]['x']; ballY = myTeam[9]['y'];
      });
    });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2E7D32),
      appBar: AppBar(title: Text('ZAMBIA ' + myScore.toString() + ' - 0'), backgroundColor: Colors.green[900]),
      body: Column(
        children: [
          Expanded(child: GestureDetector(onPanUpdate: (d) { move(d.delta.dx * 0.008, d.delta.dy * 0.008); }, child: Container(color: Color(0xFF4CAF50), child: Stack(children: [CustomPaint(size: Size.infinite, painter: FieldPainter()), ...enTeam.map((p) => Align(alignment: Alignment(p['x'], p['y']), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white)), child: Center(child: Text(p['n'].toString(), style: TextStyle(color: Colors.white, fontSize: 10)))))).toList(), ...myTeam.asMap().entries.map((e) { int i = e.key; var p = e.value; bool s = i == sel; return Align(alignment: Alignment(p['x'], p['y']), child: GestureDetector(onTap: () => setState(() => sel = i), child: Container(width: s ? 38 : 30, height: s ? 38 : 30, decoration: BoxDecoration(color: s ? Colors.yellow : Colors.green[800], shape: BoxShape.circle, border: Border.all(color: s ? Colors.black : Colors.white, width: s ? 3 : 1)), child: Center(child: Text(p['n'].toString(), style: TextStyle(color: s ? Colors.black : Colors.white)))))); }).toList(), Align(alignment: Alignment(ballX, ballY), child: Text('⚽', style: TextStyle(fontSize: 26)))])))),
          Container(color: Colors.black87, padding: EdgeInsets.all(8), child: Row(children: [Text('SEL ' + myTeam[sel]['n'].toString(), style: TextStyle(color: Colors.yellow)), Spacer(), ElevatedButton(onPressed: shoot, child: Text('SHOOT'))]))
        ],
      ),
    );
  }
}
class FieldPainter extends CustomPainter { @override void paint(Canvas c, Size s) { Paint p = Paint()..color = Colors.white..strokeWidth = 2..style = PaintingStyle.stroke; c.drawRect(Rect.fromLTWH(s.width * 0.05, s.height * 0.02, s.width * 0.9, s.height * 0.96), p); } @override bool shouldRepaint(covariant CustomPainter o) => false; }

class ShootingGame extends StatefulWidget { @override State<ShootingGame> createState() => ShootingState(); }
class ShootingState extends State<ShootingGame> {
  List<Map> enemies = []; List<Map> myB = []; List<Map> enB = []; double px = 0; int hp = 100, score = 0, ammo = 30; Timer? loop, enTimer; Random r = Random();
  @override void initState() {
    super.initState();
    spawn();
    loop = Timer.periodic(Duration(milliseconds: 16), (t) {
      if (!mounted) return;
      setState(() {
        for (var b in myB) b['y'] -= 0.02;
        for (var b in enB) b['y'] += 0.015;
        myB.removeWhere((b) => b['y'] < -1);
        enB.removeWhere((b) { if (b['y'] > 0.9 && (b['x'] - px).abs() < 0.15) { hp -= 10; return true; } return b['y'] > 1; });
        for (var b in myB) { for (var e in enemies) { if (e['alive'] && (b['x'] - e['x']).abs() < 0.12 && (b['y'] - e['y']).abs() < 0.12) { e['alive'] = false; score += 10; b['y'] = -2; SoundManager.play('coin.mp3'); } } }
        enemies.removeWhere((e) => !e['alive'] && r.nextDouble() < 0.03);
        if (enemies.length < 4) spawn();
        if (hp <= 0) { loop?.cancel(); enTimer?.cancel(); }
      });
    });
    enTimer = Timer.periodic(Duration(milliseconds: 900), (t) {
      if (!mounted) return;
      for (var e in enemies) { if (e['alive'] && r.nextDouble() < 0.5) { setState(() => enB.add({'x': e['x'], 'y': e['y']})); SoundManager.play('shoot.mp3'); } }
    });
  }
  void spawn() {
    List<Offset> wins = [Offset(-0.6, -0.6), Offset(-0.2, -0.6), Offset(0.2, -0.6), Offset(0.6, -0.6), Offset(-0.4, -0.3), Offset(0.0, -0.3), Offset(0.4, -0.3)];
    for (var w in wins) { if (r.nextDouble() < 0.5 && enemies.length < 6) { enemies.add({'x': w.dx, 'y': w.dy, 'alive': true}); } }
  }
  void shoot() { if (ammo <= 0) return; setState(() { ammo--; myB.add({'x': px, 'y': 0.8}); }); SoundManager.play('shoot.mp3'); }
  @override void dispose() { loop?.cancel(); enTimer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212121),
      appBar: AppBar(title: Text('HP ' + hp.toString() + ' AMMO ' + ammo.toString() + ' KILL ' + score.toString()), backgroundColor: Colors.black),
      body: hp <= 0 ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('YOU DIED!', style: TextStyle(color: Colors.red, fontSize: 40)), Text('Kills ' + score.toString(), style: TextStyle(color: Colors.white)), ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('MENU'))])) : Stack(children: [
        Container(color: Color(0xFF37474F)),
        ...enemies.map((e) => Align(alignment: Alignment(e['x'], e['y']), child: Container(width: 45, height: 55, color: e['alive'] ? Colors.red[800] : Colors.black54, child: Center(child: Text(e['alive'] ? 'ENEMY' : 'DEAD'))))).toList(),
        ...myB.map((b) => Align(alignment: Alignment(b['x'], b['y']), child: Container(width: 6, height: 12, color: Colors.yellow))).toList(),
        ...enB.map((b) => Align(alignment: Alignment(b['x'], b['y']), child: Container(width: 6, height: 10, color: Colors.red))).toList(),
        Align(alignment: Alignment(px, 0.85), child: Text('YOU 🔫', style: TextStyle(color: Colors.yellow))),
        Positioned(bottom: 5, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [ElevatedButton(onPressed: () { setState(() => px = (px - 0.15).clamp(-0.85, 0.85)); }, child: Text('<')), SizedBox(width: 10), ElevatedButton(onPressed: shoot, child: Text('SHOOT')), SizedBox(width: 10), ElevatedButton(onPressed: () { setState(() => px = (px + 0.15).clamp(-0.85, 0.85)); }, child: Text('>'))])),
        Positioned(top: 0, left: 0, right: 0, height: MediaQuery.of(context).size.height * 0.7, child: GestureDetector(onTapDown: (d) { shoot(); }, child: Container(color: Colors.transparent))),
      ]),
    );
  }
}

class ChessGame extends StatefulWidget { @override State<ChessGame> createState() => ChessState(); }
class ChessState extends State<ChessGame> {
  List<String> board = List.generate(64, (i) { if (i < 16) return i < 8 ? '♜♞♝♛♚♝♞♜'[i] : '♟'; if (i > 47) return i > 55 ? '♖♘♗♕♔♗♘♖'[i - 56] : '♙'; return ''; });
  int? sel;
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CHESS'), backgroundColor: Colors.brown[700]),
      body: GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), itemCount: 64, itemBuilder: (c, i) {
        bool w = (i ~/ 8 + i % 8) % 2 == 0;
        bool s = sel == i;
        return GestureDetector(onTap: () { setState(() { if (sel == null && board[i] != '') { sel = i; } else if (sel != null) { board[i] = board[sel!]; board[sel!] = ''; sel = null; SoundManager.play('coin.mp3'); } }); }, child: Container(color: s ? Colors.yellow : w ? Colors.white : Colors.brown[400], child: Center(child: Text(board[i], style: TextStyle(fontSize: 24)))));
      }),
    );
  }
}
