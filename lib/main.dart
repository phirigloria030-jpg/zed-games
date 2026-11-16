import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(ZedGamesApp());

class SoundManager {
  static final AudioPlayer _click = AudioPlayer();
  static final AudioPlayer _coin = AudioPlayer();
  static final AudioPlayer _jump = AudioPlayer();
  static final AudioPlayer _shoot = AudioPlayer();
  static final AudioPlayer _hit = AudioPlayer();

  static void play(String f) async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/$f'));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      print('Sound error $f: $e');
    }
  }
  static void click() => play('click.mp3');
  static void coin() => play('coin.mp3');
  static void jump() => play('jump.mp3');
  static void shoot() => play('shoot.mp3');
  static void hit() => play('hit.mp3');
}

class ZedGamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext c) => MaterialApp(debugShowCheckedModeBanner: false, home: MainMenu());
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF0A2A0A), body: SafeArea(child: Column(children: [
      SizedBox(height:20),
      Text('ZED GAMES V10.1', style: TextStyle(color: Colors.yellow, fontSize:34, fontWeight: FontWeight.w900)),
      Text('ALL SOUNDS FIXED 🔊✅', style: TextStyle(color: Colors.white, fontSize:12, fontWeight: FontWeight.bold)),
      Spacer(),
      _btn(context,'SUBWAY ON GROUND + COIN SOUND',Colors.blue,SubwayV10()),
      _btn(context,'FOOTBALL 1 BALL + JOYSTICK FIXED',Colors.green,FootballV10()),
      _btn(context,'CHESS SLOW AI + CLICK SOUND',Colors.brown,ChessV8()),
      _btn(context,'FPS WAR + SHOOT SOUND',Colors.red,ShootingV9()),
      Spacer(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(onPressed: ()=> SoundManager.coin(), child: Text('TEST COIN 🔊')),
        SizedBox(width:8),
        ElevatedButton(onPressed: ()=> SoundManager.shoot(), child: Text('TEST SHOOT 🔊')),
        SizedBox(width:8),
        ElevatedButton(onPressed: ()=> SoundManager.jump(), child: Text('TEST JUMP 🔊')),
      ]),
      SizedBox(height:15),
    ])));
  }
  Widget _btn(BuildContext c,String t,Color col,Widget go){ 
    return Container(margin: EdgeInsets.symmetric(horizontal:14,vertical:6), child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: col, minimumSize: Size(double.infinity,58)), onPressed: (){ SoundManager.click(); Navigator.push(c, MaterialPageRoute(builder: (_)=> go)); }, child: Text(t, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:11)))); 
  }
}

// SUBWAY V10 - REAL GROUND
class SubwayV10 extends StatefulWidget { @override State<SubwayV10> createState()=> _SubwayV10State(); }
class _SubwayV10State extends State<SubwayV10> {
  int lane=1; double jump=0; bool isJumping=false; double dist=0, speed=0.08; int coins=0,best=0;
  List<Map> objs=[]; Timer? timer; Random r=Random(); double leg=0;
  @override void initState(){
    super.initState();
    for(int i=0;i<6;i++) _addObj(5+i*2.5);
    timer=Timer.periodic(Duration(milliseconds:33), (t){
      if(!mounted) return;
      setState((){
        leg+=0.4; dist+=speed; speed+=0.00005; if(speed>0.18) speed=0.18;
        for(var o in objs) o['z']-=speed;
        objs.removeWhere((o)=> o['z']<0.2);
        while(objs.length<8) _addObj(10+r.nextDouble()*3);
        for(var o in objs){
          if(o['z']<1.2 && o['z']>0.5 && o['lane']==lane){
            if(o['type']=='train' && jump<0.4){ SoundManager.hit(); if(dist>best) best=dist.toInt(); dist=0; coins=0; speed=0.08; objs.clear(); for(int i=0;i<6;i++) _addObj(5+i*2.5); return; }
            if(o['type']=='coin'){ coins++; o['z']=-1; SoundManager.coin(); }
          }
        }
      });
    });
  }
  void _addObj(double z){ int la=r.nextInt(3); if(r.nextDouble()<0.55) objs.add({'z':z,'lane':la,'type':'train'}); else for(int k=0;k<3;k++) objs.add({'z':z+k*0.4,'lane':la,'type':'coin'}); }
  void doJump(){ if(isJumping) return; setState(()=> isJumping=true); SoundManager.jump(); jump=1; Timer.periodic(Duration(milliseconds:30), (t){ if(!mounted){t.cancel();return;} setState(()=> jump-=0.07); if(jump<=0){ jump=0; isJumping=false; t.cancel(); } }); }
  @override void dispose(){ timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){
    double sw=MediaQuery.of(context).size.width, sh=MediaQuery.of(context).size.height;
    return Scaffold(body: Stack(children: [
      Container(color: Color(0xFF8D6E63)),
      CustomPaint(size: Size.infinite, painter: SubwayGroundPainter()),
      ...((){ var sorted=[...objs]; sorted.sort((a,b)=> b['z'].compareTo(a['z'])); return sorted.map((o){
        double z=o['z']; if(z<0.3||z>12) return SizedBox() as Widget;
        double scale = 1.0 / (z*0.5+0.2);
        double perspective = 1 - scale;
        double y = sh*0.15 + perspective*sh*0.70;
        double xCenter = sw/2 + (o['lane']-1)* (perspective* sw*0.38);
        double w = (o['type']=='train'? 90: 30) * scale.clamp(0.2,1.5);
        double h = (o['type']=='train'? 50: 30) * scale.clamp(0.2,1.5);
        if(scale<0.15) return SizedBox() as Widget;
        return Positioned(left: xCenter - w/2, top: y - h, child: o['type']=='coin'? Text('🪙', style: TextStyle(fontSize: h)): Container(width:w,height:h, decoration: BoxDecoration(color: Colors.blue[700], border: Border.all(color: Colors.yellow, width:2), borderRadius: BorderRadius.circular(4)), child: Center(child: Icon(Icons.train, color: Colors.white, size: h*0.6))));
      }).toList(); }()),
      Positioned(bottom: sh*0.12, left:0, right:0, child: Center(child: Column(children: [
        Transform.translate(offset: Offset(0, -jump*120), child: Column(children: [
          Container(padding: EdgeInsets.symmetric(horizontal:8,vertical:2), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)), child: Text('ZED BOY 🏃🏾', style: TextStyle(color: Colors.yellow, fontSize:10, fontWeight: FontWeight.bold))),
          Text(isJumping? '🦸🏾‍♂️': '🏃🏾‍♂️', style: TextStyle(fontSize: 54)),
        ])),
        Container(width: sw*0.60, height:6, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(3))),
      ]))),
      Positioned(top:35,left:10,right:10, child: Row(children: [Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)), child: Text('DIST ${(dist*10).toInt()} SPD ${(speed*100).toInt()}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:11))), Spacer(), Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)), child: Text('🪙 $coins BEST $best', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold))) ])),
      Positioned(bottom:10,left:10,right:10, child: Row(children: [Expanded(child: ElevatedButton(onPressed: (){ if(lane>0){ setState(()=> lane--); SoundManager.click(); } }, child: Text('◀ LEFT'))), SizedBox(width:8), Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]), onPressed: doJump, child: Text('JUMP 🔊', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))), SizedBox(width:8), Expanded(child: ElevatedButton(onPressed: (){ if(lane<2){ setState(()=> lane++); SoundManager.click(); } }, child: Text('RIGHT ▶')))])),
    ]));
  }
}
class SubwayGroundPainter extends CustomPainter {
  @override void paint(Canvas c, Size s){
    Paint ground=Paint()..color=Color(0xFF5D4037);
    c.drawRect(Rect.fromLTWH(0, s.height*0.45, s.width, s.height*0.55), ground);
    Paint rail=Paint()..color=Colors.black87..strokeWidth=4;
    for(int lane=-1;lane<=1;lane++){
      Path p=Path();
      double startX = s.width/2 + lane*s.width*0.40;
      double endX = s.width/2 + lane*20;
      p.moveTo(startX, s.height); p.lineTo(endX, s.height*0.15);
      c.drawPath(p, Paint()..color=Color(0xFF3E2723)..strokeWidth=20..style=PaintingStyle.stroke);
      c.drawPath(p, rail..strokeWidth=4);
    }
    for(int i=0;i<25;i++){ double t = i/25; double y = s.height*0.15 + t*(s.height*0.85); double width = (1-t)*s.width*0.8; c.drawLine(Offset(s.width/2-width/2,y), Offset(s.width/2+width/2,y), Paint()..color=Color(0xFF8D6E63)..strokeWidth=3); }
  }
  @override bool shouldRepaint(covariant CustomPainter o)=> true;
}

// FOOTBALL V10 - 1 BALL FIXED
class FootballV10 extends StatefulWidget { @override State<FootballV10> createState()=> _FootballV10State(); }
class _FootballV10State extends State<FootballV10> {
  List<Map> my=[], en=[]; double bx=0,by=0; int myScore=0,enScore=0; int sel=9; Offset ballV=Offset(0,0); Timer? loop; Random r=Random(); Offset joy=Offset(0,0); bool hasBall=false;
  @override void initState(){
    super.initState();
    List<Map> myF=[{'x':0.0,'y':0.8,'n':1},{'x':-0.55,'y':0.55,'n':2},{'x':-0.18,'y':0.60,'n':4},{'x':0.18,'y':0.60,'n':5},{'x':0.55,'y':0.55,'n':3},{'x':-0.45,'y':0.25,'n':6},{'x':0.0,'y':0.30,'n':8},{'x':0.45,'y':0.25,'n':10},{'x':-0.35,'y':-0.05,'n':7},{'x':0.0,'y':0.0,'n':9},{'x':0.35,'y':-0.05,'n':11}];
    List<Map> enF=[{'x':0.0,'y':-0.8,'n':1},{'x':-0.55,'y':-0.55,'n':2},{'x':-0.18,'y':-0.60,'n':4},{'x':0.18,'y':-0.60,'n':5},{'x':0.55,'y':-0.55,'n':3},{'x':-0.45,'y':-0.25,'n':6},{'x':0.0,'y':-0.30,'n':8},{'x':0.45,'y':-0.25,'n':10},{'x':-0.35,'y':0.05,'n':7},{'x':0.0,'y':0.0,'n':9},{'x':0.35,'y':0.05,'n':11}];
    my=myF.map((e)=> Map.from(e)).toList(); en=enF.map((e)=> Map.from(e)).toList();
    loop=Timer.periodic(Duration(milliseconds:40), (t){
      if(!mounted) return;
      setState((){
        if(joy.distance>0.1){
          my[sel]['x']=(my[sel]['x']+joy.dx*0.04).clamp(-0.85,0.85);
          my[sel]['y']=(my[sel]['y']+joy.dy*0.04).clamp(-0.88,0.88);
        }
        double dToBall = sqrt(pow(my[sel]['x']-bx,2)+pow(my[sel]['y']-by,2));
        if(dToBall<0.12) hasBall=true;
        if(hasBall){ bx=my[sel]['x']; by=my[sel]['y']-0.07; ballV=Offset(0,0); }
        else {
          bx+=ballV.dx; by+=ballV.dy; ballV*=0.98;
          if(bx.abs()>0.90){ bx=bx.clamp(-0.90,0.90); ballV=Offset(-ballV.dx*0.5, ballV.dy); }
          if(by<-0.95){ if(bx.abs()<0.25){ myScore++; SoundManager.coin(); _reset(); } else { by=-0.90; ballV=Offset(ballV.dx, -ballV.dy*0.5); } }
          if(by>0.95){ if(bx.abs()<0.25){ enScore++; SoundManager.shoot(); _reset(); } else { by=0.90; ballV=Offset(ballV.dx, -ballV.dy*0.5); } }
          if(ballV.distance<0.005) ballV=Offset(0,0);
        }
        int closest=-1; double cd=10; for(int i=0;i<en.length;i++){ double d=sqrt(pow(en[i]['x']-bx,2)+pow(en[i]['y']-by,2)); if(d<cd){ cd=d; closest=i; } }
        if(closest!=-1 && !hasBall){ double dx=bx-en[closest]['x'], dy=by-en[closest]['y'], len=sqrt(dx*dx+dy*dy); if(len>0.01){ en[closest]['x']+=(dx/len)*0.012; en[closest]['y']+=(dy/len)*0.012; } if(cd<0.10){ hasBall=false; ballV=Offset((r.nextDouble()-0.5)*0.06, 0.07); SoundManager.shoot(); } }
      });
    });
  }
  void _reset(){ bx=0; by=0; ballV=Offset(0,0); hasBall=false; }
  void shoot(){ if(!hasBall) return; SoundManager.shoot(); setState((){ hasBall=false; ballV=Offset((r.nextDouble()-0.5)*0.02, -0.16); }); }
  void pass(){ if(!hasBall) return; int near=-1; double nd=10; for(int i=0;i<my.length;i++){ if(i==sel) continue; double d=sqrt(pow(my[i]['x']-bx,2)+pow(my[i]['y']-by,2)); if(d<nd && d>0.2){ nd=d; near=i; } } if(near!=-1){ setState((){ hasBall=false; ballV=Offset((my[near]['x']-bx)*0.25, (my[near]['y']-by)*0.25); sel=near; }); SoundManager.click(); } }
  @override void dispose(){ loop?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF2E7D32), appBar: AppBar(title: Text('ZAMBIA $myScore - $enScore ENEMY'), backgroundColor: Colors.green[900]),
      body: Column(children: [
        Expanded(child: Container(color: Color(0xFF4CAF50), child: Stack(children: [
          CustomPaint(size: Size.infinite, painter: FieldPainter()),
          ...en.map((p)=> Align(alignment: Alignment(p['x'],p['y']), child: Column(children: [Text('🧑🏻‍🦱', style: TextStyle(fontSize:20)), Container(width:22,height:12,decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Center(child: Text(p['n'].toString(), style: TextStyle(color: Colors.white,fontSize:8))))]))).toList(),
          ...my.asMap().entries.map((e){ int i=e.key; var p=e.value; bool s=i==sel; return Align(alignment: Alignment(p['x'],p['y']), child: GestureDetector(onTap: (){ if(hasBall) return; setState(()=> sel=i); SoundManager.click(); }, child: Column(children: [Container(decoration: BoxDecoration(color: s? Colors.yellow: Colors.transparent, shape: BoxShape.circle), child: Text(s? '🏃🏾‍♂️': '🧑🏾‍🦱', style: TextStyle(fontSize: s?28:20))), Container(width: s?28:22,height: s?14:12,decoration: BoxDecoration(color: s? Colors.yellow: Color(0xFF1B5E20), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white, width:1)), child: Center(child: Text(p['n'].toString(), style: TextStyle(color: s? Colors.black: Colors.white, fontSize:8, fontWeight: FontWeight.bold))))]))); }).toList(),
          Align(alignment: Alignment(bx,by), child: Text('⚽', style: TextStyle(fontSize:26))),
        ]))),
        Container(color: Colors.black87, padding: EdgeInsets.all(8), child: Row(children: [
          GestureDetector(
            onPanUpdate: (d){ Offset diff=d.localPosition-Offset(50,50); double dist=diff.distance; if(dist>40) diff=diff/dist*40; setState(()=> joy=Offset(diff.dx/40, diff.dy/40)); },
            onPanEnd: (_){ setState(()=> joy=Offset(0,0)); },
            child: Container(width:100,height:100,decoration: BoxDecoration(color: Colors.grey[800], shape: BoxShape.circle, border: Border.all(color: Colors.white30, width:2)), child: Center(child: Transform.translate(offset: Offset(joy.dx*30, joy.dy*30), child: Container(width:45,height:45,decoration: BoxDecoration(color: Colors.yellow, shape: BoxShape.circle, border: Border.all(color: Colors.black, width:2)), child: Icon(Icons.gamepad, size:22))))),
          ),
          SizedBox(width:10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PLAYER #${my[sel]['n']} ${hasBall?"WITH BALL":""}', style: TextStyle(color: Colors.yellow, fontSize:11, fontWeight: FontWeight.bold)), Text(joy.distance>0.1? 'MOVING':'STOPPED', style: TextStyle(color: joy.distance>0.1? Colors.greenAccent: Colors.white70, fontSize:10))])),
          Column(children: [ElevatedButton(onPressed: pass, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, minimumSize: Size(70,34)), child: Text('PASS 🔊', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize:11))), SizedBox(height:6), ElevatedButton(onPressed: shoot, style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700], minimumSize: Size(70,34)), child: Text('SHOOT! 🔊', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize:11)))]),
        ])),
      ]),
    );
  }
}
class FieldPainter extends CustomPainter { @override void paint(Canvas c,Size s){ Paint p=Paint()..color=Colors.white..strokeWidth=2..style=PaintingStyle.stroke; c.drawRect(Rect.fromLTWH(s.width*0.05,s.height*0.02,s.width*0.9,s.height*0.96), p); c.drawLine(Offset(s.width*0.05,s.height*0.5), Offset(s.width*0.95,s.height*0.5), p); c.drawCircle(Offset(s.width*0.5,s.height*0.5), 35, p); c.drawRect(Rect.fromLTWH(s.width*0.35,s.height*0.02,s.width*0.3,s.height*0.12), p); c.drawRect(Rect.fromLTWH(s.width*0.35,s.height*0.86,s.width*0.3,s.height*0.12), p); } @override bool shouldRepaint(covariant CustomPainter o)=> false; }

class ChessV8 extends StatefulWidget { @override State<ChessV8> createState()=> _ChessV8State(); }
class _ChessV8State extends State<ChessV8> {
  List<String> board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; });
  int? sel; bool whiteTurn=true; String status='Your turn - White'; bool gameOver=false; String winner=''; Random r=Random();
  bool isBlack(String p)=> ['♜','♞','♝','♛','♚','♟'].contains(p);
  bool isWhite(String p)=> ['♖','♘','♗','♕','♔','♙'].contains(p);
  List<int> getMoves(int from){ String piece=board[from]; if(piece=='') return []; List<int> moves=[]; int row=from~/8, col=from%8; if(piece=='♟'){ if(row<7 && board[from+8]=='') moves.add(from+8); if(row==1 && board[from+8]=='' && board[from+16]=='') moves.add(from+16); if(row<7 && col>0 && board[from+7]!='' && isWhite(board[from+7])) moves.add(from+7); if(row<7 && col<7 && board[from+9]!='' && isWhite(board[from+9])) moves.add(from+9); } else if(piece=='♙'){ if(row>0 && board[from-8]=='') moves.add(from-8); if(row>0 && col>0 && board[from-9]!='' && isBlack(board[from-9])) moves.add(from-9); if(row>0 && col<7 && board[from-7]!='' && isBlack(board[from-7])) moves.add(from-7); } else if(piece=='♞' || piece=='♘'){ List<List<int>> d=[[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]; for(var dd in d){ int nr=row+dd[0], nc=col+dd[1]; if(nr>=0&&nr<8&&nc>=0&&nc<8){ int to=nr*8+nc; if(board[to]=='' || (isBlack(piece) && isWhite(board[to])) || (isWhite(piece) && isBlack(board[to]))) moves.add(to); } } } else { for(int dr=-1;dr<=1;dr++){ for(int dc=-1;dc<=1;dc++){ if(dr==0&&dc==0) continue; int nr=row+dr, nc=col+dc; if(nr>=0&&nr<8&&nc>=0&&nc<8){ int to=nr*8+nc; if(board[to]=='' || (isBlack(piece) && isWhite(board[to])) || (isWhite(piece) && isBlack(board[to]))) moves.add(to); } } } } return moves; }
  void checkGameOver(){ bool whiteKing=false, blackKing=false; for(var p in board){ if(p=='♔') whiteKing=true; if(p=='♚') blackKing=true; } if(!whiteKing){ setState((){ gameOver=true; winner='BLACK WINS!'; status='GAME OVER'; SoundManager.hit(); }); } if(!blackKing){ setState((){ gameOver=true; winner='YOU WIN!'; status='YOU WON!'; }); SoundManager.coin(); } }
  void makeAIMove(){ if(gameOver || whiteTurn) return; setState(()=> status='Computer thinking... 🤔'); Future.delayed(Duration(milliseconds:1500), (){ if(!mounted || gameOver) return; List<int> blackPieces=[]; for(int i=0;i<64;i++){ if(board[i]!='' && isBlack(board[i])) blackPieces.add(i); } blackPieces.shuffle(r); for(int from in blackPieces){ List<int> moves=getMoves(from); if(moves.isNotEmpty){ moves.shuffle(r); int to=moves[0]; setState((){ board[to]=board[from]; board[from]=''; whiteTurn=true; status='Your turn - White'; SoundManager.click(); }); checkGameOver(); return; } } setState(()=> status='Your turn - White'); whiteTurn=true; }); }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFEFEBE9), appBar: AppBar(title: Text(gameOver? winner: status), backgroundColor: gameOver? Colors.red: Colors.brown[700]), body: Column(children: [Container(padding: EdgeInsets.all(10), color: whiteTurn? Colors.green[100]: Colors.orange[100], child: Row(children: [Icon(whiteTurn? Icons.person: Icons.computer), SizedBox(width:8), Expanded(child: Text(status, style: TextStyle(fontWeight: FontWeight.bold, fontSize:12)))])), Expanded(child: GridView.builder(padding: EdgeInsets.all(8), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:8), itemCount:64, itemBuilder: (c,i){ bool w=(i~/8 + i%8)%2==0; bool s=sel==i; bool canMove=sel!=null && getMoves(sel!).contains(i); return GestureDetector(onTap: (){ if(gameOver || !whiteTurn) return; setState((){ if(sel==null){ if(board[i]!='' && isWhite(board[i])){ sel=i; SoundManager.click(); } } else { if(getMoves(sel!).contains(i)){ board[i]=board[sel!]; board[sel!]=''; sel=null; whiteTurn=false; SoundManager.coin(); checkGameOver(); if(!gameOver) makeAIMove(); } else if(board[i]!='' && isWhite(board[i])){ sel=i; } else { sel=null; } } }); }, child: Container(decoration: BoxDecoration(color: canMove? Colors.green[300]: s? Colors.yellow: w? Colors.white: Colors.brown[400], border: canMove? Border.all(color: Colors.green, width:3): null), child: Center(child: Text(board[i], style: TextStyle(fontSize:26))))); })), Container(padding: EdgeInsets.all(10), child: Row(children: [ElevatedButton(onPressed: (){ setState((){ board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; }); sel=null; whiteTurn=true; gameOver=false; winner=''; status='Your turn - White'; }); SoundManager.click(); }, child: Text('NEW GAME 🔊')), Spacer(), Text('Tap white, green = move', style: TextStyle(fontSize:10))]))])); }
}

class ShootingV9 extends StatefulWidget { @override State<ShootingV9> createState()=> _ShootingV9State(); }
class _ShootingV9State extends State<ShootingV9> {
  List<Map> enemies=[]; List<Map> myB=[]; List<Map> enB=[]; List<Map> walls=[]; double px=0, py=0.8; int hp=100, score=0, ammo=30; Timer? loop, enTimer; Random r=Random(); bool isHiding=false;
  @override void initState(){
    super.initState();
    walls=[{'x':-0.5,'y':0.35,'w':0.28,'h':0.14},{'x':0.5,'y':0.35,'w':0.28,'h':0.14},{'x':0.0,'y':0.15,'w':0.32,'h':0.13},{'x':-0.65,'y':-0.15,'w':0.22,'h':0.13},{'x':0.65,'y':-0.15,'w':0.22,'h':0.13}];
    spawn();
    loop=Timer.periodic(Duration(milliseconds:30), (t){ if(!mounted) return; setState((){
        for(var b in myB){ b['x']+=(b['tx']-b['x'])*0.09; b['y']-=0.035; }
        for(var b in enB){ b['y']+=0.022; }
        myB.removeWhere((b)=> b['y']<-1 || b['y']>1 || b['x'].abs()>1);
        enB.removeWhere((b){ for(var w in walls){ if((b['x']-w['x']).abs()<w['w']/2+0.05 && (b['y']-w['y']).abs()<w['h']/2+0.05) return true; } if(b['y']>0.75 && (b['x']-px).abs()<0.16 && (b['y']-py).abs()<0.2 && !isHiding){ hp-=10; SoundManager.hit(); return true; } return b['y']>1.1; });
        for(var b in myB){ for(var e in enemies){ if(e['alive'] && (b['x']-e['x']).abs()<0.13 && (b['y']-e['y']).abs()<0.15){ e['alive']=false; score+=10; b['y']=-2; SoundManager.coin(); } } }
        isHiding=false; for(var w in walls){ if((px-w['x']).abs()<w['w']/2+0.12 && (py-w['y']).abs()<w['h']/2+0.12) isHiding=true; }
        enemies.removeWhere((e)=> !e['alive'] && r.nextDouble()<0.09); if(enemies.length<6) spawn(); if(hp<=0){ loop?.cancel(); enTimer?.cancel(); }
      }); });
    enTimer=Timer.periodic(Duration(milliseconds:850), (t){ if(!mounted) return; for(var e in enemies){ if(e['alive']){ bool canSee = !isHiding; if(canSee && r.nextDouble()<0.65){ setState(()=> enB.add({'x':e['x'],'y':e['y']})); SoundManager.shoot(); } if(r.nextDouble()<0.08){ e['x']+=(r.nextDouble()-0.5)*0.25; e['x']=e['x'].clamp(-0.8,0.8); } } } });
  }
  void spawn(){ List<Offset> spots=[Offset(-0.6,-0.6),Offset(-0.2,-0.6),Offset(0.2,-0.6),Offset(0.6,-0.6),Offset(0.0,-0.3),Offset(-0.4,0.0),Offset(0.4,0.0)]; for(var s in spots){ if(r.nextDouble()<0.7 && enemies.length<6){ if(!enemies.any((e)=> (e['x']-s.dx).abs()<0.2)){ enemies.add({'x':s.dx,'y':s.dy,'alive':true,'type':r.nextInt(3)}); } } } }
  void shoot(double ax, double ay){ if(ammo<=0){ setState(()=> ammo=30); SoundManager.click(); return; } setState((){ ammo--; myB.add({'x':px,'y':py-0.05,'tx':ax}); }); SoundManager.shoot(); }
  @override void dispose(){ loop?.cancel(); enTimer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF263238), appBar: AppBar(title: Text('HP $hp AMMO $ammo KILL $score'), backgroundColor: isHiding? Colors.green[900]: Colors.black87),
      body: hp<=0? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('YOU DIED!', style: TextStyle(color: Colors.red,fontSize:42,fontWeight: FontWeight.bold)), Text('KILLS $score', style: TextStyle(color: Colors.white,fontSize:24)), SizedBox(height:15), ElevatedButton(onPressed: ()=> Navigator.pop(context), child: Text('MENU'))])): Stack(children: [
        Container(color: Color(0xFF37474F)),
        ...walls.map((w)=> Align(alignment: Alignment(w['x'], w['y']), child: Container(width: MediaQuery.of(context).size.width*w['w'], height: 52, decoration: BoxDecoration(color: Color(0xFF8D6E63), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width:2)), child: Center(child: Text('🧱 COVER', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold, color: Colors.white)))))).toList(),
        ...enemies.map((e){ String icon = e['alive']? (e['type']==0? '👨🏻‍✈️🔫': e['type']==1? '👨🏿‍🦱🔫': '🥷🔫'): '💀'; return Align(alignment: Alignment(e['x'], e['y']), child: Container(width:54,height:54, decoration: BoxDecoration(color: e['alive']? Color(0xFFB71C1C): Colors.black54, borderRadius: BorderRadius.circular(10), border: Border.all(color: e['alive']? Colors.yellow: Colors.grey, width: e['alive']?2:1)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(icon, style: TextStyle(fontSize:22))]))); }).toList(),
        ...myB.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width:9,height:15,decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(4))))).toList(),
        ...enB.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width:7,height:12,decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(4))))).toList(),
        Align(alignment: Alignment(px, py), child: Column(children: [Text('🫡🔫', style: TextStyle(fontSize:40)), Container(padding: EdgeInsets.symmetric(horizontal:6,vertical:1), decoration: BoxDecoration(color: hp>40? Colors.green: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text('HP $hp%', style: TextStyle(color: Colors.white, fontSize:9, fontWeight: FontWeight.bold)))])),
        Positioned(top:0,left:0,right:0,height:MediaQuery.of(context).size.height*0.68, child: GestureDetector(onTapDown: (d){ double ax=(d.globalPosition.dx/MediaQuery.of(context).size.width)*2-1; double ay=(d.globalPosition.dy/MediaQuery.of(context).size.height)*2-1; shoot(ax, ay); }, child: Container(color: Colors.transparent))),
        Positioned(bottom:5,left:10,right:10, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(onPressed: (){ setState(()=> px=(px-0.20).clamp(-0.85,0.85)); SoundManager.click(); }, child: Text('◀')),
            SizedBox(width:8),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(horizontal:28,vertical:14)), onPressed: (){ shoot(px, -0.5); }, child: Text(ammo==0? 'RELOAD 🔊': 'SHOOT 🔊', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
            SizedBox(width:8),
            ElevatedButton(onPressed: (){ setState(()=> px=(px+0.20).clamp(-0.85,0.85)); SoundManager.click(); }, child: Text('▶')),
          ])),
      ]),
    );
  }
}
