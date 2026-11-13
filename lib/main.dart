import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(ZedGamesApp());
class SoundManager { 
  static final AudioPlayer _p = AudioPlayer(); 
  static void play(String f) async { try{ await _p.play(AssetSource('sounds/$f')); }catch(e){} } 
  static void coin()=>play('coin.mp3'); static void shoot()=>play('shoot.mp3'); static void click()=>play('click.mp3'); static void hurt()=>play('shoot.mp3'); 
}

class ZedGamesApp extends StatelessWidget { @override Widget build(BuildContext context){ return MaterialApp(debugShowCheckedModeBanner: false, home: MainMenu()); } }

class MainMenu extends StatelessWidget {
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF0A2A0A), body: SafeArea(child: Column(children: [
      SizedBox(height: 10), Text('ZED GAMES', style: TextStyle(color: Colors.yellow, fontSize: 36, fontWeight: FontWeight.w900)), Text('ZAMBIA V5 - FIFA + COD 🔊', style: TextStyle(color: Colors.white, fontSize: 12)),
      Spacer(),
      MenuBtn(title: 'SUBWAY 3D - ZAMBIAN BOY', col: Color(0xFF2196F3), icon: '🏃🏾‍♂️', go: ()=> Subway3D()),
      MenuBtn(title: 'FOOTBALL 11 vs 11 - ALL PLAYERS', col: Color(0xFF4CAF50), icon: '⚽', go: ()=> FootballFull()),
      MenuBtn(title: 'FPS SHOOTING - BUILDING WAR', col: Color(0xFFD32F2F), icon: '🔫', go: ()=> ShootingBuilding()),
      MenuBtn(title: 'CHESS', col: Color(0xFF795548), icon: '♔', go: ()=> ChessPro()),
      Spacer(), SizedBox(height: 10),
    ])),);
  }
}
class MenuBtn extends StatelessWidget {
  final String title, icon; final Color col; final Widget Function() go; MenuBtn({required this.title, required this.col, required this.icon, required this.go});
  @override Widget build(BuildContext context){ return Container(margin: EdgeInsets.symmetric(horizontal: 14, vertical: 5), child: InkWell(onTap: (){ SoundManager.click(); Navigator.push(context, MaterialPageRoute(builder: (_)=> go())); }, child: Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(12)), child: Row(children: [Text(icon, style: TextStyle(fontSize: 26)), SizedBox(width: 10), Expanded(child: Text(title, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))), Icon(Icons.play_arrow, color: Colors.white)])))); }
}

// ================= SUBWAY V4 KEEP SAME =================
class Subway3D extends StatefulWidget { @override _Subway3DState createState()=> _Subway3DState(); }
class _Subway3DState extends State<Subway3D> {
  int lane=1; double jump=0; bool jumping=false; double dist=0; int coins=0; List<Map> obs=[], coinL=[]; Timer? timer; Random rand=Random();
  @override void initState(){ super.initState(); for(int i=0;i<6;i++){ obs.add({'z':5.0+i*3.0,'lane':rand.nextInt(3),'type':'train'}); coinL.add({'z':4.0+i*2.5,'lane':rand.nextInt(3)}); } timer=Timer.periodic(Duration(milliseconds: 16), (t){ setState((){ dist+=0.06; for(var o in obs){ o['z']-=0.09; } for(var c in coinL){ c['z']-=0.09; } obs.removeWhere((o)=>o['z']<-1); coinL.removeWhere((c)=>c['z']<-1); while(obs.length<7){ obs.add({'z':11+rand.nextDouble()*5,'lane':rand.nextInt(3),'type':'train'}); } while(coinL.length<12){ int l=rand.nextInt(3); double b=11+rand.nextDouble()*5; for(int k=0;k<3;k++) coinL.add({'z':b+k*0.7,'lane':l}); } for(var o in obs){ if(o['z']>-0.3&&o['z']<0.4&&o['lane']==lane&&jump<0.4){ dist=0; coins=0; obs.clear(); coinL.clear(); } } for(var c in coinL){ if(c['z']>-0.3&&c['z']<0.4&&c['lane']==lane){ coins++; c['z']=-10; SoundManager.coin(); } } }); }); }
  void doJump(){ if(jumping) return; setState(){ jumping=true; jump=1.0; SoundManager.play('jump.mp3'); } Future.delayed(Duration(milliseconds: 250), ()=> setState(()=> jump=0.6)); Future.delayed(Duration(milliseconds: 550), ()=> setState((){ jump=0; jumping=false; })); }
  @override void dispose(){ timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){ return Scaffold(body: GestureDetector(onHorizontalDragEnd: (d){ if(d.velocity.pixelsPerSecond.dx>150&&lane<2) setState(()=> lane++); if(d.velocity.pixelsPerSecond.dx<-150&&lane>0) setState(()=> lane--); }, onVerticalDragEnd: (d){ if(d.velocity.pixelsPerSecond.dy<-150) doJump(); }, child: Stack(children: [Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF87CEEB), Color(0xFF1B5E20)]))), CustomPaint(size: Size.infinite, painter: TunnelPainter()), ...obs.map((o){ double z=o['z']; if(z<0||z>13) return SizedBox() as Widget; double sc=1.0/(z*0.28+1); double y=MediaQuery.of(context).size.height*(0.18+0.62*(1-sc)); double off=(o['lane']-1)*110*sc; double x=MediaQuery.of(context).size.width/2+off-30*sc; return Positioned(left: x, top: y, child: Transform.scale(scale: sc, child: Container(width: 65, height: 44, color: Colors.blue[900], child: Icon(Icons.train, color: Colors.white)))); }).toList(), ...coinL.map((c){ double z=c['z']; if(z<0||z>13) return SizedBox() as Widget; double sc=1.0/(z*0.28+1); double y=MediaQuery.of(context).size.height*(0.18+0.62*(1-sc)); double off=(c['lane']-1)*110*sc; double x=MediaQuery.of(context).size.width/2+off; return Positioned(left: x, top: y, child: Transform.scale(scale: sc, child: Text('🪙', style: TextStyle(fontSize: 32)))); }).toList(), Align(alignment: Alignment((lane-1)*0.75, 0.68-jump), child: Text('🏃🏾‍♂️', style: TextStyle(fontSize: 50))), Align(alignment: Alignment((lane-1)*0.75+0.08, 0.86), child: Text('👮‍♂️', style: TextStyle(fontSize: 38))), Positioned(top: 35, left: 10, right: 10, child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: Row(children: [Text('${(dist*10).toInt().toString().padLeft(6,'0')}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Spacer(), Text('🪙 $coins', style: TextStyle(color: Colors.yellow))]))), Positioned(bottom: 15, left: 10, right: 10, child: Row(children: [Expanded(child: ElevatedButton(onPressed: (){ if(lane>0) setState(()=> lane--); }, child: Text('◀'))), SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: doJump, child: Text('JUMP'))), SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: (){ if(lane<2) setState(()=> lane++); }, child: Text('▶')))]))]))); }
}
class TunnelPainter extends CustomPainter { @override void paint(Canvas c, Size s){ Paint p=Paint()..color=Color(0xFF388E3C).withOpacity(0.5)..style=PaintingStyle.stroke..strokeWidth=3; for(int i=0;i<7;i++){ double t=i/7; double y=s.height*(0.05+t*0.65); double w=s.width*(0.12+t*0.85); c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width/2, y), width: w, height: 26), Radius.circular(13)), p); } } @override bool shouldRepaint(covariant CustomPainter o)=>false; }

// ================= FOOTBALL 11 vs 11 FULL =================
class FootballFull extends StatefulWidget { @override _FootballFullState createState()=> _FootballFullState(); }
class _FootballFullState extends State<FootballFull> {
  // 11 players per team - positions
  List<Map> myTeam=[], enemyTeam=[]; double ballX=0, ballY=0.2; int myScore=0, enScore=0; int selectedPlayer=9; // striker
  @override void initState(){
    super.initState();
    myTeam = [
      {'x':0.0,'y':0.85,'pos':'GK','num':1}, // Keeper
      {'x':-0.6,'y':0.6,'pos':'DEF','num':2}, {'x':-0.2,'y':0.65,'pos':'DEF','num':4}, {'x':0.2,'y':0.65,'pos':'DEF','num':5}, {'x':0.6,'y':0.6,'pos':'DEF','num':3},
      {'x':-0.5,'y':0.3,'pos':'MID','num':6}, {'x':0.0,'y':0.35,'pos':'MID','num':8}, {'x':0.5,'y':0.3,'pos':'MID','num':10},
      {'x':-0.4,'y':0.0,'pos':'FW','num':7}, {'x':0.0,'y':-0.05,'pos':'FW','num':9}, {'x':0.4,'y':0.0,'pos':'FW','num':11},
    ];
    enemyTeam = [
      {'x':0.0,'y':-0.85,'pos':'GK','num':1},
      {'x':-0.6,'y':-0.6,'pos':'DEF','num':2}, {'x':-0.2,'y':-0.65,'pos':'DEF','num':4}, {'x':0.2,'y':-0.65,'pos':'DEF','num':5}, {'x':0.6,'y':-0.6,'pos':'DEF','num':3},
      {'x':-0.5,'y':-0.3,'pos':'MID','num':6}, {'x':0.0,'y':-0.35,'pos':'MID','num':8}, {'x':0.5,'y':-0.3,'pos':'MID','num':10},
      {'x':-0.4,'y':0.0,'pos':'FW','num':7}, {'x':0.0,'y':-0.05,'pos':'FW','num':9}, {'x':0.4,'y':0.0,'pos':'FW','num':11},
    ];
    ballX=myTeam[9]['x']; ballY=myTeam[9]['y'];
  }
  void moveSelected(double dx, double dy){ setState((){ myTeam[selectedPlayer]['x']=(myTeam[selectedPlayer]['x']+dx).clamp(-0.85,0.85); myTeam[selectedPlayer]['y']=(myTeam[selectedPlayer]['y']+dy).clamp(-0.9,0.9); if((myTeam[selectedPlayer]['x']-ballX).abs()<0.15 && (myTeam[selectedPlayer]['y']-ballY).abs()<0.15){ ballX=myTeam[selectedPlayer]['x']; ballY=myTeam[selectedPlayer]['y']-0.08; } }); }
  void shootGoal(){ setState((){ ballY=-1.0; SoundManager.shoot(); }); Future.delayed(Duration(milliseconds: 800), (){ setState((){ if((ballX).abs()<0.3){ myScore++; SoundManager.coin(); } ballX=myTeam[9]['x']; ballY=myTeam[9]['y']; }); }); }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF2E7D32), appBar: AppBar(title: Text('ZAMBIA $myScore - $enScore ENEMY - ALL 11 PLAYERS'), backgroundColor: Colors.green[900]),
      body: Column(children: [
        Expanded(child: GestureDetector(
          onPanUpdate: (d){ moveSelected(d.delta.dx*0.008, d.delta.dy*0.008); },
          child: Container(decoration: BoxDecoration(color: Color(0xFF4CAF50)), child: Stack(children: [
            // Field lines
            CustomPaint(size: Size.infinite, painter: FieldPainter()),
            // Enemy team RED
            ...enemyTeam.map((p)=> Align(alignment: Alignment(p['x'], p['y']), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white)), child: Center(child: Text('${p['num']}', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))))).toList(),
            // My team YELLOW/GREEN - Zambia
            ...myTeam.asMap().entries.map((e){ int idx=e.key; var p=e.value; bool sel=idx==selectedPlayer; return Align(alignment: Alignment(p['x'], p['y']), child: GestureDetector(onTap: ()=> setState(()=> selectedPlayer=idx), child: Container(width: sel?38:30, height: sel?38:30, decoration: BoxDecoration(color: sel? Colors.yellow: Colors.green[800], shape: BoxShape.circle, border: Border.all(color: sel? Colors.black: Colors.white, width: sel?3:1)), child: Center(child: Text('${p['num']}', style: TextStyle(color: sel? Colors.black: Colors.white, fontSize: sel?12:9, fontWeight: FontWeight.bold)))))); }).toList(),
            // Ball
            Align(alignment: Alignment(ballX, ballY), child: Text('⚽', style: TextStyle(fontSize: 26))),
          ])),
        )),
        Container(color: Colors.black87, padding: EdgeInsets.all(8), child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('SELECTED: ${myTeam[selectedPlayer]['pos']} #${myTeam[selectedPlayer]['num']}', style: TextStyle(color: Colors.yellow, fontSize: 11)), Text('Drag to move, tap player to switch', style: TextStyle(color: Colors.white54, fontSize: 9))]),
          Spacer(),
          ElevatedButton(onPressed: shootGoal, style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]), child: Text('SHOOT GOAL!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
        ]))
      ]),
    );
  }
}
class FieldPainter extends CustomPainter { @override void paint(Canvas c, Size s){ Paint p=Paint()..color=Colors.white..strokeWidth=2..style=PaintingStyle.stroke; c.drawRect(Rect.fromLTWH(s.width*0.05, s.height*0.02, s.width*0.9, s.height*0.96), p); c.drawLine(Offset(s.width*0.05, s.height*0.5), Offset(s.width*0.95, s.height*0.5), p); c.drawCircle(Offset(s.width*0.5, s.height*0.5), 40, p); c.drawRect(Rect.fromCenter(center: Offset(s.width*0.5, s.height*0.08), width: 120, height: 50), p); c.drawRect(Rect.fromCenter(center: Offset(s.width*0.5, s.height*0.92), width: 120, height: 50), p); } @override bool shouldRepaint(covariant CustomPainter o)=>false; }

// ================= SHOOTING - BUILDING + YOU MOVE + ENEMIES SHOOT BACK =================
class ShootingBuilding extends StatefulWidget { @override _ShootingBuildingState createState()=> _ShootingBuildingState(); }
class _ShootingBuildingState extends State<ShootingBuilding> {
  List<Map> enemies=[]; List<Map> myBullets=[], enBullets=[]; double playerX=0; int health=100, score=0, ammo=30; Timer? gameLoop, enemyShootTimer; Random rand=Random();
  @override void initState(){
    super.initState();
    spawnEnemies();
    gameLoop=Timer.periodic(Duration(milliseconds: 16), (t){ setState((){ 
      for(var b in myBullets){ b['y']-=0.02; } for(var b in enBullets){ b['y']+=0.015; }
      myBullets.removeWhere((b)=>b['y']<-1);
      enBullets.removeWhere((b){ if(b['y']>0.9 && (b['x']-playerX).abs()<0.15){ health-=10; SoundManager.hurt(); return true; } return b['y']>1; });
      for(var b in myBullets){ for(var e in enemies){ if(e['alive'] && (b['x']-e['x']).abs()<0.12 && (b['y']-e['y']).abs()<0.12){ e['alive']=false; score+=10; SoundManager.coin(); b['y']=-2; } } }
      enemies.removeWhere((e)=>!e['alive'] && rand.nextDouble()<0.02);
      if(enemies.length<4) spawnEnemies();
      if(health<=0){ gameLoop?.cancel(); enemyShootTimer?.cancel(); }
    }); });
    enemyShootTimer=Timer.periodic(Duration(milliseconds: 800), (t){ for(var e in enemies){ if(e['alive'] && rand.nextDouble()<0.4){ enBullets.add({'x':e['x'],'y':e['y']}); SoundManager.shoot(); } } });
  }
  void spawnEnemies(){
    // Building windows positions
    List<Offset> windows=[Offset(-0.6,-0.6), Offset(-0.2,-0.6), Offset(0.2,-0.6), Offset(0.6,-0.6), Offset(-0.4,-0.3), Offset(0.0,-0.3), Offset(0.4,-0.3), Offset(-0.6,0.0), Offset(0.6,0.0)];
    for(var w in windows){ if(rand.nextDouble()<0.5 && enemies.length<6){ if(!enemies.any((e)=> (e['x']-w.dx).abs()<0.1 && (e['y']-w.dy).abs()<0.1)){ enemies.add({'x':w.dx,'y':w.dy,'alive':true}); } } }
  }
  void playerShoot(double aimX){
    if(ammo<=0) return;
    setState((){ ammo--; myBullets.add({'x':playerX,'y':0.8,'tx':aimX}); SoundManager.shoot(); });
  }
  @override void dispose(){ gameLoop?.cancel(); enemyShootTimer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF212121), appBar: AppBar(title: Text('HEALTH:$health AMMO:$ammo KILLS:$score'), backgroundColor: Colors.black, leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: ()=> Navigator.pop(context))),
      body: health<=0? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('YOU DIED!', style: TextStyle(color: Colors.red, fontSize: 40, fontWeight: FontWeight.bold)), Text('Kills: $score', style: TextStyle(color: Colors.white, fontSize: 24)), ElevatedButton(onPressed: ()=> Navigator.pop(context), child: Text('MENU'))])): Stack(children: [
        // Building
        Container(color: Color(0xFF37474F)),
        CustomPaint(size: Size.infinite, painter: BuildingPainter()),
        // Enemies in windows
        ...enemies.map((e)=> Align(alignment: Alignment(e['x'], e['y']), child: Container(width: 45, height: 55, decoration: BoxDecoration(color: e['alive']? Colors.red[800]: Colors.black54, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.yellow, width: 1)), child: Column(children: [Text(e['alive']?'👤🔫':'💀', style: TextStyle(fontSize: e['alive']?22:26)), if(e['alive']) Container(width: 30, height: 4, color: Colors.red)])))).toList(),
        // My bullets
        ...myBullets.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width: 6, height: 12, color: Colors.yellow))).toList(),
        // Enemy bullets
        ...enBullets.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width: 6, height: 10, color: Colors.red))).toList(),
        // Player at bottom - YOU move
        Align(alignment: Alignment(playerX, 0.85), child: Column(children: [Container(width: 50, height: 10, color: Colors.black45), Text('🔫', style: TextStyle(fontSize: 45)), Text('YOU', style: TextStyle(color: Colors.yellow, fontSize: 9, fontWeight: FontWeight.bold)), Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: health>30? Colors.green: Colors.red, borderRadius: BorderRadius.circular(5)), child: Text('$health%', style: TextStyle(color: Colors.white, fontSize: 10)))])),
        // Controls - Move + Shoot
        Positioned(bottom: 5, left: 0, right: 0, child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(onPressed: (){ setState(()=> playerX=(playerX-0.15).clamp(-0.85,0.85)); }, child: Text('◀ MOVE')),
            SizedBox(width: 10),
            GestureDetector(onTapDown: (d){ double aim = (d.globalPosition.dx / MediaQuery.of(context).size.width)*2-1; playerShoot(aim); }, child: Container(padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)), child: Text('SHOOT 🔫', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            SizedBox(width: 10),
            ElevatedButton(onPressed: (){ setState(()=> playerX=(playerX+0.15).clamp(-0.85,0.85)); }, child: Text('MOVE ▶')),
          ]),
          SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Tap top to aim, bottom to move', style: TextStyle(color: Colors.white54, fontSize: 9)), SizedBox(width: 10), ElevatedButton(onPressed: ()=> setState(()=> ammo=30), child: Text('RELOAD $ammo'))]),
        ])),
        // Aim area - tap building to shoot
        Positioned(top: 0, left: 0, right: 0, height: MediaQuery.of(context).size.height*0.65, child: GestureDetector(onTapDown: (d){ double aim = (d.globalPosition.dx / MediaQuery.of(context).size.width)*2-1; playerShoot(aim); }, child: Container(color: Colors.transparent))),
      ]),
    );
  }
}
class BuildingPainter extends CustomPainter {
  @override void paint(Canvas c, Size s){
    Paint wall=Paint()..color=Color(0xFF455A64);
    Paint window=Paint()..color=Color(0xFF263238)..style=PaintingStyle.stroke..strokeWidth=2;
    c.drawRect(Rect.fromLTWH(s.width*0.05, s.height*0.05, s.width*0.9, s.height*0.6), wall);
    List<Offset> wins=[Offset(-0.6,-0.6), Offset(-0.2,-0.6), Offset(0.2,-0.6), Offset(0.6,-0.6), Offset(-0.4,-0.3), Offset(0.0,-0.3), Offset(0.4,-0.3), Offset(-0.6,0.0), Offset(0.6,0.0)];
    for(var w in wins){
      double x=s.width/2 + w.dx*s.width*0.4; double y=s.height*0.35 + w.dy*s.height*0.25;
      c.drawRect(Rect.fromCenter(center: Offset(x,y), width: 50, height: 55), window);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}

// ================= CHESS SAME =================
class ChessPro extends StatefulWidget { @override _ChessProState createState()=> _ChessProState(); }
class _ChessProState extends State<ChessPro> { List<String> board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; }); int? sel; @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFEFEBE9), appBar: AppBar(title: Text('CHESS'), backgroundColor: Colors.brown[700]), body: Column(children: [Expanded(child: GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), itemCount: 64, itemBuilder: (c,i){ bool white=(i~/8 + i%8)%2==0; bool s=sel==i; return GestureDetector(onTap: (){ setState((){ if(sel==null&&board[i]!=''){ sel=i; } else if(sel!=null){ board[i]=board[sel!]; board[sel!]=''; sel=null; } }); }, child: Container(color: s? Colors.yellow: white? Colors.white: Colors.brown[400], child: Center(child: Text(board[i], style: TextStyle(fontSize: 24))))); })), Text(sel!=null?'Tap square':'Tap piece')])) ; } }
