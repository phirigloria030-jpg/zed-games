import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(ZedGamesApp());

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();
  static void play(String file) async {
    try {
      await _player.play(AssetSource('sounds/$file'));
    } catch (e) {}
  }
  static void coin() => play('coin.mp3');
  static void jump() => play('jump.mp3');
  static void shoot() => play('shoot.mp3');
  static void click() => play('click.mp3');
}

class ZedGamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainMenu());
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
            SizedBox(height: 10),
            Text('ZED GAMES', style: TextStyle(color: Colors.yellow, fontSize: 36, fontWeight: FontWeight.w900)),
            Text('V5 - FIFA 11v11 + BUILDING WAR 🔊', style: TextStyle(color: Colors.white, fontSize: 12)),
            Spacer(),
            MenuBtn(title: 'SUBWAY 3D - ZAMBIAN BOY', col: Color(0xFF2196F3), icon: '🏃🏾‍♂️', go: Subway3D()),
            MenuBtn(title: 'FOOTBALL 11 vs 11 - ALL PLAYERS', col: Color(0xFF4CAF50), icon: '⚽', go: FootballFull()),
            MenuBtn(title: 'FPS BUILDING WAR - MOVE & SHOOT', col: Color(0xFFD32F2F), icon: '🔫', go: ShootingBuilding()),
            MenuBtn(title: 'CHESS', col: Color(0xFF795548), icon: '♔', go: ChessPro()),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class MenuBtn extends StatelessWidget {
  final String title, icon;
  final Color col;
  final Widget go;
  MenuBtn({required this.title, required this.col, required this.icon, required this.go});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: InkWell(
        onTap: () {
          SoundManager.click();
          Navigator.push(context, MaterialPageRoute(builder: (_) => go));
        },
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Text(icon, style: TextStyle(fontSize: 26)),
              SizedBox(width: 10),
              Expanded(child: Text(title, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
              Icon(Icons.play_arrow, color: Colors.white)
            ],
          ),
        ),
      ),
    );
  }
}

// SUBWAY
class Subway3D extends StatefulWidget { @override _Subway3DState createState() => _Subway3DState(); }
class _Subway3DState extends State<Subway3D> {
  int lane = 1;
  double jump = 0;
  bool jumping = false;
  double dist = 0;
  int coins = 0;
  List<Map> obs = [], coinL = [];
  Timer? timer;
  Random rand = Random();
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      obs.add({'z': 5.0 + i * 3.0, 'lane': rand.nextInt(3)});
      coinL.add({'z': 4.0 + i * 2.5, 'lane': rand.nextInt(3)});
    }
    timer = Timer.periodic(Duration(milliseconds: 16), (t) {
      if (!mounted) return;
      setState(() {
        dist += 0.06;
        for (var o in obs) { o['z'] -= 0.09; }
        for (var c in coinL) { c['z'] -= 0.09; }
        obs.removeWhere((o) => o['z'] < -1);
        coinL.removeWhere((c) => c['z'] < -1);
        while (obs.length < 7) { obs.add({'z': 11 + rand.nextDouble() * 5, 'lane': rand.nextInt(3)}); }
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
            coins++; c['z'] = -10; SoundManager.coin();
          }
        }
      });
    });
  }
  void doJump() {
    if (jumping) return;
    setState(() {
      jumping = true;
      jump = 1.0;
    });
    SoundManager.jump();
    Future.delayed(Duration(milliseconds: 250), () {
      if (mounted) setState(() => jump = 0.6);
    });
    Future.delayed(Duration(milliseconds: 550), () {
      if (mounted) setState(() { jump = 0; jumping = false; });
    });
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (d) {
          if (d.velocity.pixelsPerSecond.dx > 150 && lane < 2) setState(() => lane++);
          if (d.velocity.pixelsPerSecond.dx < -150 && lane > 0) setState(() => lane--);
        },
        onVerticalDragEnd: (d) { if (d.velocity.pixelsPerSecond.dy < -150) doJump(); },
        child: Stack(children: [
          Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF87CEEB), Color(0xFF1B5E20)]))),
          CustomPaint(size: Size.infinite, painter: TunnelPainter()),
          ...obs.map((o) {
            double z = o['z'];
            if (z < 0 || z > 13) return SizedBox() as Widget;
            double sc = 1.0 / (z * 0.28 + 1);
            double y = MediaQuery.of(context).size.height * (0.18 + 0.62 * (1 - sc));
            double off = (o['lane'] - 1) * 110 * sc;
            double x = MediaQuery.of(context).size.width / 2 + off - 30 * sc;
            return Positioned(left: x, top: y, child: Transform.scale(scale: sc, child: Container(width: 65, height: 44, color: Colors.blue[900], child: Icon(Icons.train, color: Colors.white))));
          }).toList(),
          ...coinL.map((c) {
            double z = c['z'];
            if (z < 0 || z > 13) return SizedBox() as Widget;
            double sc = 1.0 / (z * 0.28 + 1);
            double y = MediaQuery.of(context).size.height * (0.18 + 0.62 * (1 - sc));
            double off = (c['lane'] - 1) * 110 * sc;
            double x = MediaQuery.of(context).size.width / 2 + off;
            return Positioned(left: x, top: y, child: Transform.scale(scale: sc, child: Text('🪙', style: TextStyle(fontSize: 32))));
          }).toList(),
          Align(alignment: Alignment((lane - 1) * 0.75, 0.68 - jump), child: Text('🏃🏾‍♂️', style: TextStyle(fontSize: 50))),
          Align(alignment: Alignment((lane - 1) * 0.75 + 0.08, 0.86), child: Text('👮‍♂️', style: TextStyle(fontSize: 38))),
          Positioned(top: 35, left: 10, right: 10, child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: Row(children: [Text('${(dist * 10).toInt().toString().padLeft(6, '0')}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Spacer(), Text('🪙 $coins', style: TextStyle(color: Colors.yellow))]))),
          Positioned(bottom: 15, left: 10, right: 10, child: Row(children: [Expanded(child: ElevatedButton(onPressed: () { if (lane > 0) setState(() => lane--); }, child: Text('◀'))), SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: doJump, child: Text('JUMP'))), SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: () { if (lane < 2) setState(() => lane++); }, child: Text('▶')))]))
        ]),
      ),
    );
  }
}
class TunnelPainter extends CustomPainter { @override void paint(Canvas c, Size s){ Paint p=Paint()..color=Color(0xFF388E3C).withOpacity(0.5)..style=PaintingStyle.stroke..strokeWidth=3; for(int i=0;i<7;i++){ double t=i/7; double y=s.height*(0.05+t*0.65); double w=s.width*(0.12+t*0.85); c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width/2, y), width: w, height: 26), Radius.circular(13)), p); } } @override bool shouldRepaint(covariant CustomPainter o)=>false; }

// FOOTBALL 11v11
class FootballFull extends StatefulWidget { @override _FootballFullState createState()=> _FootballFullState(); }
class _FootballFullState extends State<FootballFull> {
  List<Map> myTeam=[], enemyTeam=[]; double ballX=0, ballY=0.2; int myScore=0, enScore=0; int selectedPlayer=9;
  @override void initState(){
    super.initState();
    myTeam = [{'x':0.0,'y':0.85,'num':1},{'x':-0.6,'y':0.6,'num':2},{'x':-0.2,'y':0.65,'num':4},{'x':0.2,'y':0.65,'num':5},{'x':0.6,'y':0.6,'num':3},{'x':-0.5,'y':0.3,'num':6},{'x':0.0,'y':0.35,'num':8},{'x':0.5,'y':0.3,'num':10},{'x':-0.4,'y':0.0,'num':7},{'x':0.0,'y':-0.05,'num':9},{'x':0.4,'y':0.0,'num':11}];
    enemyTeam = [{'x':0.0,'y':-0.85,'num':1},{'x':-0.6,'y':-0.6,'num':2},{'x':-0.2,'y':-0.65,'num':4},{'x':0.2,'y':-0.65,'num':5},{'x':0.6,'y':-0.6,'num':3},{'x':-0.5,'y':-0.3,'num':6},{'x':0.0,'y':-0.35,'num':8},{'x':0.5,'y':-0.3,'num':10},{'x':-0.4,'y':0.0,'num':7},{'x':0.0,'y':-0.05,'num':9},{'x':0.4,'y':0.0,'num':11}];
    ballX=myTeam[9]['x']; ballY=myTeam[9]['y'];
  }
  void moveSelected(double dx, double dy){ setState((){ myTeam[selectedPlayer]['x']=(myTeam[selectedPlayer]['x']+dx).clamp(-0.85,0.85); myTeam[selectedPlayer]['y']=(myTeam[selectedPlayer]['y']+dy).clamp(-0.9,0.9); if((myTeam[selectedPlayer]['x']-ballX).abs()<0.15 && (myTeam[selectedPlayer]['y']-ballY).abs()<0.15){ ballX=myTeam[selectedPlayer]['x']; ballY=myTeam[selectedPlayer]['y']-0.08; } }); }
  void shootGoal(){ Sound
