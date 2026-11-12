import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(ZedGamesApp());

class ZedGamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zed Games Zambia',
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
            Text("ZED GAMES ZAMBIA", style: TextStyle(color: Colors.yellow, fontSize: 26, fontWeight: FontWeight.bold)),
            Text("4 ACTION GAMES", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _card(context, "SUBWAY\nZED RUN", Icons.train, Colors.orange, SubwayGame()),
                  _card(context, "CHESS\nMASTER", Icons.grid_on, Colors.brown, ChessGame()),
                  _card(context, "FOOTBALL\nPENALTY", Icons.sports_soccer, Colors.green, FootballGame()),
                  _card(context, "SHOOTING\nTARGET", Icons.gps_fixed, Colors.red, ShootingGame()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _card(BuildContext ctx, String t, IconData ic, Color c, Widget g) {
    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => g)),
      child: Container(
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white, width: 2)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(ic, size: 60, color: Colors.white),
          SizedBox(height: 10),
          Text(t, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
      ),
    );
  }
}

// ========== SUBWAY ==========
class SubwayGame extends StatefulWidget { @override _SubwayGameState createState() => _SubwayGameState(); }
class _SubwayGameState extends State<SubwayGame> {
  int lane = 1; int score = 0; int coins = 0; bool gameOver = false;
  List<Map> obs = []; Timer? tm; Random r = Random();
  bool jumping = false; bool rolling = false;
  @override
  void initState() { super.initState(); start(); }
  void start() {
    score=0; coins=0; gameOver=false; obs=[]; lane=1;
    tm = Timer.periodic(Duration(milliseconds: 60), (t) {
      if (gameOver) { t.cancel(); return; }
      setState(() {
        score++;
        for (var o in obs) o['y'] = o['y'] + 0.025;
        obs.removeWhere((o) => o['y'] > 1.2);
        if (r.nextDouble() < 0.06) obs.add({'x': r.nextInt(3), 'y': -0.2, 'type': r.nextBool() ? 'train' : 'coin'});
        for (var o in obs) {
          if ((o['y']-0.7).abs()<0.08 && o['x']==lane) {
            if (o['type']=='coin') { coins++; o['y']=2; } else if (!jumping && !rolling) gameOver=true;
          }
        }
      });
    });
  }
  void move(int d) { if (!gameOver) setState(() { lane = (lane+d).clamp(0,2); }); }
  void jumpAct() { if (jumping||rolling||gameOver) return; setState(()=>jumping=true); Future.delayed(Duration(milliseconds: 500), ()=>setState(()=>jumping=false)); }
  void rollAct() { if (jumping||rolling||gameOver) return; setState(()=>rolling=true); Future.delayed(Duration(milliseconds: 400), ()=>setState(()=>rolling=false)); }
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width; double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (d){ if(d.velocity.pixelsPerSecond.dx>0) move(1); else move(-1); },
        child: Stack(children: [
          Row(children: List.generate(3, (i)=>Expanded(child: Container(color: i==lane ? Colors.white24 : Color(0xFF3E2723))))),
          ...obs.map((o)=>Positioned(left: w/3*o['x']+20, top: h*o['y'], child: Container(width: 80, height: o['type']=='coin'?30:50, decoration: BoxDecoration(color: o['type']=='coin'?Colors.yellow:Colors.blue, shape: o['type']=='coin'?BoxShape.circle:BoxShape.rectangle, borderRadius: BorderRadius.circular(6)), child: Icon(o['type']=='coin'?Icons.monetization_on:Icons.train, color: Colors.white)))),
          Positioned(left: w/3*lane+25, top: h*0.7-(jumping?80:0), child: Container(width: 70, height: rolling?30:70, decoration: BoxDecoration(color: rolling?Colors.orange:Colors.green, border
