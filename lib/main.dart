import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const ZedGamesApp());

class SoundManager {
  static final AudioPlayer p = AudioPlayer();
  static void play(String f) async {
    try { await p.play(AssetSource('sounds/$f')); } catch (e) {}
  }
}

class ZedGamesApp extends StatelessWidget {
  const ZedGamesApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainMenu());
  }
}

class MainMenu extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2A0A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('ZED GAMES V5', style: TextStyle(color: Colors.yellow, fontSize: 32, fontWeight: FontWeight.w900)),
            const Text('11v11 + BUILDING WAR', style: TextStyle(color: Colors.white, fontSize: 12)),
            const Spacer(),
            _btn(context, 'SUBWAY 3D ZAMBIAN', Colors.blue, '🏃🏾‍♂️', const SubwayGame()),
            _btn(context, 'FOOTBALL 11 vs 11 ALL', Colors.green, '⚽', const FootballGame()),
            _btn(context, 'FPS BUILDING WAR', Colors.red, '🔫', const ShootingGame()),
            _btn(context, 'CHESS', Colors.brown, '♔', const ChessGame()),
            const Spacer(),
          ],
        ),
      ),
    );
  }
  Widget _btn(BuildContext c, String t, Color col, String ic, Widget go) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: col, minimumSize: const Size(double.infinity, 60)),
        onPressed: () { SoundManager.play('click.mp3'); Navigator.push(c, MaterialPageRoute(builder: (_) => go)); },
        child: Row(children: [Text(ic, style: const TextStyle(fontSize: 24)), const SizedBox(width: 10), Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
      ),
    );
  }
}

// SUBWAY
class SubwayGame extends StatefulWidget { const SubwayGame({super.key}); @override State<SubwayGame> createState() => _SubwayState(); }
class _SubwayState extends State<SubwayGame> {
  int lane=1; double jump=0; bool jumping=false; double dist=0; int coins=0; List<Map> obs=[]; List<Map> coinL=[]; Timer? t; Random r=Random();
  @override void initState(){ super.initState(); for(int i=0;i<6;i++){ obs.add({'z':5.0+i*3.0,'lane':r.nextInt(3)}); coinL.add({'z':4.0+i*2.5,'lane':r.nextInt(3)}); } t=Timer.periodic(const Duration(milliseconds: 16), (timer){ if(!mounted) return; setState((){ dist+=0.06; for(var o in obs){ o['z']-=0.09; } for(var c in coinL){ c['z']-=0.09; } obs.removeWhere((o)=>o['z']<-1); coinL.removeWhere((c)=>c['z']<-1); while(obs.length<7){ obs.add({'z':11+r.nextDouble()*5,'lane':r.nextInt(3)}); } while(coinL.length<12){ int l=r.nextInt(3); double b=11+r.nextDouble()*5; for(int k=0;k<3;k++) coinL.add({'z':b+k*0.7,'lane':l}); } for(var o in obs){ if(o['z']>-0.3&&o['z']<0.4&&o['lane']==lane&&jump<0.4){ dist=0; coins=0; obs.clear(); coinL.clear(); } } for(var c in coinL){ if(c['z']>-0.3&&c['z']<0.4&&c['lane']==lane){ coins++; c['z']=-10; SoundManager.play('coin.mp3'); } } }); }); }
  void doJump(){ if(jumping) return; setState((){ jumping=true; jump=1.0; }); SoundManager.play('jump.mp3'); Future.delayed(const Duration(milliseconds: 250), (){ if(mounted) setState(()=> jump=0.6); }); Future.delayed(const Duration(milliseconds: 550), (){ if(mounted) setState((){ jump=0; jumping=false; }); }); }
  @override void dispose(){ t?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){ return Scaffold(body: GestureDetector(onHorizontalDragEnd: (d){ if(d.velocity.pixelsPerSecond.dx>150&&lane<2) setState(()=> lane++); if(d.velocity.pixelsPerSecond.dx<-150&&lane>0) setState(()=> lane--); }, onVerticalDragEnd: (d){ if(d.velocity.pixelsPerSecond.dy<-150) doJump(); }, child: Stack(children: [Container(color: const Color(0xFF87CEEB)), ...obs.map((o){ double z=o['z']; if(z<0||z>13) return const SizedBox(); double sc=1.0/(z*0.28+1); double y=MediaQuery.of(context).size.height*(0.18+0.62*(1-sc)); double off=(o['lane']-1)*110*sc; double x=MediaQuery.of(context).size.width/2+off-30*sc; return Positioned(left: x, top: y, child: Transform.scale(scale: sc, child: Container(width: 65, height: 44, color: Colors.blue[900], child: const Icon(Icons.train, color: Colors.white)))); }).toList(), ...coinL.map((c){ double z=c['z']; if(z<0||z>13) return const SizedBox(); double sc=1.0/(z*0.28+1); double y=MediaQuery.of(context).size.height*(0.18+0.62*(1-sc)); double off=(c['lane']-1)*110*sc; double x=MediaQuery.of(context).size.width/2+off; return Positioned(left: x, top: y, child: Transform.scale(scale: sc, child: const Text('🪙', style: TextStyle(fontSize: 32)))); }).toList(), Align(alignment: Alignment((lane-1)*0.75, 0.68-jump), child: const Text('🏃🏾‍♂️', style: TextStyle(fontSize: 50))), Positioned(top: 35, left: 10, right: 10, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: Row(children: [Text('${(dist*10).toInt().toString().padLeft(6,'0')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const Spacer(), Text('🪙 $coins', style: const TextStyle(color: Colors.yellow))]))), Positioned(bottom: 15, left: 10, right: 10, child: Row(children: [Expanded(child: ElevatedButton(onPressed: (){ if(lane>0) setState(()=> lane--); }, child: const Text('◀'))), const SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: doJump, child: const Text('JUMP'))), const SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: (){ if(lane<2) setState(()=> lane++); }, child: const Text('▶')))]))]))); }
}

// FOOTBALL 11v11
class FootballGame extends StatefulWidget { const FootballGame({super.key}); @override State<FootballGame> createState() => _FootballState(); }
class _FootballState extends State<FootballGame> {
  List<Map> myTeam=[]; List<Map> enTeam=[]; double ballX=0, ballY=0.2; int myScore=0; int sel=9;
  @override void initState(){ super.initState(); myTeam=[{'x':0.0,'y':0.85,'n':1},{'x':-0.6,'y':0.6,'n':2},{'x':-0.2,'y':0.65,'n':4},{'x':0.2,'y':0.65,'n':5},{'x':0.6,'y':0.6,'n':3},{'x':-0.5,'y':0.3,'n':6},{'x':0.0,'y':0.35,'n':8},{'x':0.5,'y':0.3,'n':10},{'x':-0.4,'y':0.0,'n':7},{'x':0.0,'y':-0.05,'n':9},{'x':0.4,'y':0.0,'n':11}]; enTeam=[{'x':0.0,'y':-0.85,'n':1},{'x':-0.6,'y':-0.6,'n':2},{'x':-0.2,'y':-0.65,'n':4},{'x':0.2,'y':-0.65,'n':5},{'x':0.6,'y':-0.6,'n':3},{'x':-0.5,'y':-0.3,'n':6},{'x':0.0,'y':-0.35,'n':8},{'x':0.5,'y':-0.3,'n':10},{'x':-0.4,'y':0.0,'n':7},{'x':0.0,'y':-0.05,'n':9},{'x':0.4,'y':0.0,'n':11}]; ballX=myTeam[9]['x']; ballY=myTeam[9]['y']; }
  void move(double dx, double dy){ setState((){ myTeam[sel]['x']=(myTeam[sel]['x']+dx).clamp(-0.85,0.85); myTeam[sel]['y']=(myTeam[sel]['y']+dy).clamp(-0.9,0.9); if((myTeam[sel]['x']-ballX).abs()<0.15&&(myTeam[sel]['y']-ballY).abs()<0.15){ ballX=myTeam[sel]['x']; ballY=myTeam[sel]['y']-0.08; } }); }
  void shoot(){ SoundManager.play('shoot.mp3'); setState(()=> ballY=-1.0); Future.delayed(const Duration(milliseconds: 800), (){ if(!mounted) return; setState((){ if(ballX.abs()<0.3){ myScore++; SoundManager.play('coin.mp3'); } ballX=myTeam[9]['x']; ballY=myTeam[9]['y']; }); }); }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: const Color(0xFF2E7D32), appBar: AppBar(title: Text('ZAMBIA $myScore - 0 ENEMY (11v11)'), backgroundColor: Colors.green[900]), body: Column(children: [Expanded(child: GestureDetector(onPanUpdate: (d){ move(d.delta.dx*0.008, d.delta.dy*0.008); }, child: Container(color: const Color(0xFF4CAF50), child: Stack(children: [CustomPaint(size: Size.infinite, painter: _FieldPainter()), ...enTeam.map((p)=> Align(alignment: Alignment(p['x'], p['y']), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white)), child: Center(child: Text('${p['n']}', style: const TextStyle(color: Colors.white, fontSize: 10)))))).toList(), ...myTeam.asMap().entries.map((e){ int i=e.key; var p=e.value; bool s=i==sel; return Align(alignment: Alignment(p['x'], p['y']), child: GestureDetector(onTap: ()=> setState(()=> sel=i), child: Container(width: s?38:30, height: s?38:30, decoration: BoxDecoration(color: s? Colors.yellow: Colors.green[800], shape: BoxShape.circle, border: Border.all(color: s? Colors.black: Colors.white, width: s?3:1)), child: Center(child: Text('${p['n']}', style: TextStyle(color: s? Colors.black: Colors.white, fontSize: s?12:9, fontWeight: FontWeight.bold)))))); }).toList(), Align(alignment: Alignment(ballX, ballY), child: const Text('⚽', style: TextStyle(fontSize: 26)))])))), Container(color: Colors.black87, padding: const EdgeInsets.all(8), child: Row(children: [Text('SEL #${myTeam[sel]['n']} drag to move', style: const TextStyle(color: Colors.yellow, fontSize: 11)), const Spacer(), ElevatedButton(onPressed: shoot, style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]), child: const Text('SHOOT GOAL!', style: TextStyle(color: Colors.black)))]))]), ); }
}
class _FieldPainter extends CustomPainter { @override void paint(Canvas c, Size s){ Paint p=Paint()..color=Colors.white..strokeWidth=2..style=PaintingStyle.stroke; c.drawRect(Rect.fromLTWH(s.width*0.05, s.height*0.02, s.width*0.9, s.height*0.96), p); c.drawLine(Offset(s.width*0.05, s.height*0.5), Offset(s.width*0.95, s.height*0.5), p); c.drawCircle(Offset(s.width*0.5, s.height*0.5), 40, p); } @override bool shouldRepaint(covariant CustomPainter o)=>false; }

// SHOOTING BUILDING WAR
class ShootingGame extends StatefulWidget { const ShootingGame({super.key}); @override State<ShootingGame> createState() => _ShootingState(); }
class _ShootingState extends State<ShootingGame> {
  List<Map> enemies=[]; List<Map> myB=[]; List<Map> enB=[]; double px=0; int hp=100, score=0, ammo=30; Timer? loop, enTimer; Random r=Random();
  @override void initState(){ super.initState(); spawn(); loop=Timer.periodic(const Duration(milliseconds: 16), (t){ if(!mounted) return; setState((){ for(var b in myB){ b['y']-=0.02; } for(var b in enB){ b['y']+=0.015; } myB.removeWhere((b)=>b['y']<-1); enB.removeWhere((b){ if(b['y']>0.9&&(b['x']-px).abs()<0.15){ hp-=10; return true; } return b['y']>1; }); for(var b in myB){ for(var e in enemies){ if(e['alive']&&(b['x']-e['x']).abs()<0.12&&(b['y']-e['y']).abs()<0.12){ e['alive']=false; score+=10; b['y']=-2; SoundManager.play('coin.mp3'); } } } enemies.removeWhere((e)=>!e['alive']&&r.nextDouble()<0.03); if(enemies.length<4) spawn(); if(hp<=0){ loop?.cancel(); enTimer?.cancel(); } }); }); enTimer=Timer.periodic(const Duration(milliseconds: 900), (t){ if(!mounted) return; for(var e in enemies){ if(e['alive']&&r.nextDouble()<0.5){ setState(()=> enB.add({'x':e['x'],'y':e['y']})); SoundManager.play('shoot.mp3'); } } }); }
  void spawn(){ List<Offset> wins=[const Offset(-0.6,-0.6), const Offset(-0.2,-0.6), const Offset(0.2,-0.6), const Offset(0.6,-0.6), const Offset(-0.4,-0.3), const Offset(0.0,-0.3), const Offset(0.4,-0.3), const Offset(-0.6,0.0), const Offset(0.6,0.0)]; for(var w in wins){ if(r.nextDouble()<0.5&&enemies.length<6){ if(!enemies.any((e)=> (e['x']-w.dx).abs()<0.1)){ enemies.add({'x':w.dx,'y':w.dy,'alive':true}); } } } }
  void shoot(double ax){ if(ammo<=0) return; setState((){ ammo--; myB.add({'x':px,'y':0.8}); }); SoundManager.play('shoot.mp3'); }
  @override void dispose(){ loop?.cancel(); enTimer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: const Color(0xFF212121), appBar: AppBar(title: Text('HP:$hp AMMO:$ammo KILL:$score'), backgroundColor: Colors.black), body: hp<=0? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('YOU DIED!', style: TextStyle(color: Colors.red, fontSize: 40, fontWeight: FontWeight.bold)), Text('Kills: $score', style: const TextStyle(color: Colors.white, fontSize: 24)), ElevatedButton(onPressed: ()=> Navigator.pop(context), child: const Text('MENU'))])): Stack(children: [Container(color: const Color(0xFF37474F)), CustomPaint(size: Size.infinite, painter: _BuildingPainter()), ...enemies.map((e)=> Align(alignment: Alignment(e['x'], e['y']), child: Container(width: 45, height: 55, decoration: BoxDecoration(color: e['alive']? Colors.red[800]: Colors.black54, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.yellow)), child: Center(child: Text(e['alive']?'👤🔫':'💀', style: const TextStyle(fontSize: 22)))))).toList(), ...myB.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width: 6, height: 12, color: Colors.yellow))).toList(), ...enB.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width: 6, height: 10, color: Colors.red))).toList(), Align(alignment: Alignment(px, 0.85), child: Column(children: [const Text('🔫', style: TextStyle(fontSize: 45)), const Text('YOU', style: TextStyle(color: Colors.yellow, fontSize: 9)), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: hp>30? Colors.green: Colors.red, borderRadius: BorderRadius.circular(5)), child: Text('$hp%', style: const TextStyle(color: Colors.white, fontSize: 10)))] )), Positioned(bottom: 5, left: 0, right: 0, child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [ElevatedButton(onPressed: (){ setState(()=> px=(px-0.15).clamp(-0.85,0.85)); }, child: const Text('◀')), const SizedBox(width: 10), GestureDetector(onTapDown: (d){ double ax=(d.globalPosition.dx/MediaQuery.of(context).size.width)*2-1; shoot(ax); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)), child: const Text('SHOOT 🔫', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), const SizedBox(width: 10), ElevatedButton(onPressed: (){ setState(()=> px=(px+0.15).clamp(-0.85,0.85)); }, child: const Text('▶'))]), const SizedBox(height: 4), ElevatedButton(onPressed: ()=> setState(()=> ammo=30), child: Text('RELOAD $ammo'))])), Positioned(top: 0, left: 0, right: 0, height: MediaQuery.of(context).size.height*0.65, child: GestureDetector(onTapDown: (d){ double ax=(d.globalPosition.dx/MediaQuery.of(context).size.width)*2-1; shoot(ax); }, child: Container(color: Colors.transparent)))])), ); }
}
class _BuildingPainter extends CustomPainter { @override void paint(Canvas c, Size s){ Paint wall=Paint()..color=const Color(0xFF455A64); Paint win=Paint()..color=const Color(0xFF263238)..style=PaintingStyle.stroke..strokeWidth=2; c.drawRect(Rect.fromLTWH(s.width*0.05, s.height*0.05, s.width*0.9, s.height*0.6), wall); List<Offset> wins=[const Offset(-0.6,-0.6), const Offset(-0.2,-0.6), const Offset(0.2,-0.6), const Offset(0.6,-0.6), const Offset(-0.4,-0.3), const Offset(0.0,-0.3), const Offset(0.4,-0.3), const Offset(-0.6,0.0), const Offset(0.6,0.0)]; for(var w in wins){ double x=s.width/2 + w.dx*s.width*0.4; double y=s.height*0.35 + w.dy*s.height*0.25; c.drawRect(Rect.fromCenter(center: Offset(x,y), width: 50, height: 55), win); } } @override bool shouldRepaint(covariant CustomPainter o)=>false; }

class ChessGame extends StatefulWidget { const ChessGame({super.key}); @override State<ChessGame> createState() => _ChessState(); }
class _ChessState extends State<ChessGame> { List<String> board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; }); int? sel; @override Widget build(BuildContext context){ return Scaffold(backgroundColor: const Color(0xFFEFEBE9), appBar: AppBar(title: const Text('CHESS'), backgroundColor: Colors.brown[700]), body: Column(children: [Expanded(child: GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), itemCount: 64, itemBuilder: (c,i){ bool w=(i~/8 + i%8)%2==0; bool s=sel==i; return GestureDetector(onTap: (){ setState((){ if(sel==null&&board[i]!=''){ sel=i; SoundManager.play('click.mp3'); } else if(sel!=null){ board[i]=board[sel!]; board[sel!]=''; sel=null; SoundManager.play('coin.mp3'); } }); }, child: Container(color: s? Colors.yellow: w? Colors.white: Colors.brown[400], child: Center(child: Text(board[i], style: const TextStyle(fontSize: 24))))); })), Text(sel!=null?'Tap square':'Tap piece')])); } }
