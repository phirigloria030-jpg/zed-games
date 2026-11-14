import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(ZedGamesApp());

class SoundManager {
  static void play(String f) async {
    try{
      final p = AudioPlayer();
      await p.setVolume(1.0);
      await p.play(AssetSource('sounds/'+f));
      p.onPlayerComplete.listen((_)=> p.dispose());
    }catch(e){}
  }
}

class ZedGamesApp extends StatelessWidget { @override Widget build(BuildContext c)=> MaterialApp(debugShowCheckedModeBanner: false, home: MainMenu()); }

class MainMenu extends StatelessWidget {
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF0A2A0A), body: SafeArea(child: Column(children: [
      SizedBox(height:15),
      Text('ZED GAMES V9', style: TextStyle(color: Colors.yellow, fontSize:34, fontWeight: FontWeight.w900)),
      Text('FIXED GROUND + JOYSTICK + REAL WAR 🔊', style: TextStyle(color: Colors.white, fontSize:11)),
      Spacer(),
      _btn(context,'SUBWAY ON GROUND + POLICE CHASE',Colors.blue,SubwayV9()),
      _btn(context,'FOOTBALL 22 CARTOON + JOYSTICK FIX',Colors.green,FootballV9()),
      _btn(context,'CHESS SLOW AI KING END',Colors.brown,ChessV8()),
      _btn(context,'FPS WAR REAL PEOPLE + COVER',Colors.red,ShootingV9()),
      Spacer(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(onPressed: ()=> SoundManager.play('coin.mp3'), child: Text('COIN 🔊')),
        SizedBox(width:8),
        ElevatedButton(onPressed: ()=> SoundManager.play('shoot.mp3'), child: Text('SHOOT 🔊')),
      ]),
      SizedBox(height:10),
    ])));
  }
  Widget _btn(BuildContext c,String t,Color col,Widget go){ return Container(margin: EdgeInsets.symmetric(horizontal:14,vertical:6), child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: col, minimumSize: Size(double.infinity,58)), onPressed: (){ SoundManager.play('click.mp3'); Navigator.push(c, MaterialPageRoute(builder: (_)=> go)); }, child: Text(t, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:11)))); }
}

// ================= SUBWAY V9 - REAL GROUND =================
class SubwayV9 extends StatefulWidget { @override State<SubwayV9> createState()=> _SubwayV9State(); }
class _SubwayV9State extends State<SubwayV9> {
  int lane=1; double jump=0; bool jumping=false; double dist=0, speed=0.04; int coins=0,best=0;
  List<Map> trains=[]; List<Map> coinsL=[]; Timer? timer; Random r=Random(); double runAnim=0;
  @override void initState(){
    super.initState();
    for(int i=0;i<5;i++){ trains.add({'z':6+i*4.0,'lane':r.nextInt(3),'type':r.nextInt(2)}); for(int k=0;k<3;k++) coinsL.add({'z':5+i*3.0+k*0.8,'lane':r.nextInt(3)}); }
    timer=Timer.periodic(Duration(milliseconds:32), (t){
      if(!mounted) return;
      setState((){
        runAnim+=0.25; dist+=speed; speed+=0.00007; if(speed>0.13) speed=0.13;
        for(var o in trains) o['z']-=speed; for(var c in coinsL) c['z']-=speed;
        trains.removeWhere((o)=> o['z']<-1); coinsL.removeWhere((c)=> c['z']<-1);
        while(trains.length<5){ int la=r.nextInt(3); if(r.nextDouble()<0.6) trains.add({'z':14+r.nextDouble()*4,'lane':la,'type':r.nextInt(2)}); }
        while(coinsL.length<15){ int la=r.nextInt(3); double bz=15+r.nextDouble()*3; bool hasTrain=trains.any((tr)=> (tr['z']-bz).abs()<1.2 && tr['lane']==la); if(!hasTrain) for(int k=0;k<3;k++) coinsL.add({'z':bz+k*0.7,'lane':la}); }
        for(var o in trains){ if(o['z']>-0.4 && o['z']<0.5 && o['lane']==lane && jump<0.35){ if(dist>best) best=dist.toInt(); dist=0; coins=0; speed=0.04; trains.clear(); coinsL.clear(); for(int i=0;i<5;i++) trains.add({'z':6+i*4.0,'lane':r.nextInt(3),'type':r.nextInt(2)}); return; } }
        for(var c in coinsL){ if(c['z']>-0.4 && c['z']<0.5 && c['lane']==lane){ coins++; c['z']=-10; SoundManager.play('coin.mp3'); } }
      });
    });
  }
  void doJump(){ if(jumping) return; setState((){ jumping=true; jump=1.0; }); SoundManager.play('jump.mp3'); Future.delayed(Duration(milliseconds:350), (){ if(mounted) setState(()=> jump=0.6); }); Future.delayed(Duration(milliseconds:650), (){ if(mounted) setState((){ jump=0; jumping=false; }); }); }
  @override void dispose(){ timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){
    double sw=MediaQuery.of(context).size.width, sh=MediaQuery.of(context).size.height;
    return Scaffold(body: Stack(children: [
      Container(color: Color(0xFF5D4037)), // DARK GROUND
      CustomPaint(size: Size.infinite, painter: RealGroundPainter()),
      ...trains.map((o){ double z=o['z']; if(z<-1||z>16) return SizedBox() as Widget; double sc=1.0/(z*0.24+1); if(sc<0.12) return SizedBox() as Widget; double y=sh*(0.28+0.55*(1-sc)); double off=(o['lane']-1)*120*sc; double x=sw/2+off-40*sc; return Positioned(left:x, top:y, child: Transform.scale(scale: sc*1.5, child: Container(width:80,height: o['type']==1?22:50, decoration: BoxDecoration(color: o['type']==1? Colors.grey[800]: Color(0xFF1565C0), border: Border.all(color: Colors.yellow, width:2)), child: Icon(o['type']==1? Icons.horizontal_rule: Icons.train, color: Colors.white)))); }).toList(),
      ...coinsL.map((c){ double z=c['z']; if(z<-1||z>16) return SizedBox() as Widget; double sc=1.0/(z*0.24+1); double y=sh*(0.28+0.55*(1-sc)); double off=(c['lane']-1)*120*sc; double x=sw/2+off-10*sc; return Positioned(left:x, top:y, child: Transform.scale(scale: sc, child: Text('🪙', style: TextStyle(fontSize:30)))); }).toList(),
      Align(alignment: Alignment((lane-1)*0.70, 0.50-jump), child: Column(children: [Container(padding: EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(5)), child: Text('ZED BOY', style: TextStyle(color: Colors.yellow,fontSize:8,fontWeight: FontWeight.bold))), Text(jumping? '🦸🏾‍♂️': '🏃🏾‍♂️', style: TextStyle(fontSize:48, shadows: [Shadow(color: Colors.black, blurRadius:6)]))])),
      Align(alignment: Alignment((lane-1)*0.70 + 0.18, 0.70), child: Column(children: [Text('👮‍♂️', style: TextStyle(fontSize: 36+sin(runAnim)*2)), Container(color: Colors.red, padding: EdgeInsets.symmetric(horizontal:4,vertical:1), child: Text('CATCH HIM!', style: TextStyle(color: Colors.white, fontSize:7, fontWeight: FontWeight.bold)))])),
      Positioned(top:30,left:10,right:10, child: Row(children: [Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)), child: Text('SPD ${ (speed*100).toInt()} DIST ${(dist*10).toInt()}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:11))), Spacer(), Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)), child: Text('🪙 $coins BEST $best', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold))) ])),
      Positioned(bottom:10,left:10,right:10, child: Row(children: [Expanded(child: ElevatedButton(onPressed: (){ if(lane>0){ setState(()=> lane--); SoundManager.play('click.mp3'); } }, child: Text('◀ LEFT'))), SizedBox(width:8), Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]), onPressed: doJump, child: Text('JUMP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))), SizedBox(width:8), Expanded(child: ElevatedButton(onPressed: (){ if(lane<2){ setState(()=> lane++); SoundManager.play('click.mp3'); } }, child: Text('RIGHT ▶')))])),
    ]));
  }
}
class RealGroundPainter extends CustomPainter {
  @override void paint(Canvas c,Size s){
    Paint ground=Paint()..color=Color(0xFF3E2723);
    Paint groundLight=Paint()..color=Color(0xFF6D4C41);
    c.drawRect(Rect.fromLTWH(0, s.height*0.50, s.width, s.height*0.50), ground);
    // Draw ground perspective lines
    for(int i=0;i<20;i++){
      double sc=1.0- i/25.0;
      double y=s.height*(0.50 + 0.50*(1-sc));
      c.drawLine(Offset(s.width*0.1, y), Offset(s.width*0.9, y), groundLight..strokeWidth=1*sc);
    }
    Paint rail=Paint()..color=Colors.black87..strokeWidth=4; Paint sleeper=Paint()..color=Color(0xFF4E342E);
    for(int lane=-1;lane<=1;lane++){
      for(int i=0;i<30;i++){
        double t1=i/30, sc1=1.0/(t1*8+1);
        double t2=(i+1)/30, sc2=1.0/(t2*8+1);
        double y1=s.height*(0.28+0.55*(1-sc1)), y2=s.height*(0.28+0.55*(1-sc2));
        if(i%3==0) c.drawLine(Offset(s.width/2-160*sc1,y1), Offset(s.width/2+160*sc1,y1), sleeper..strokeWidth=7*sc1);
        c.drawLine(Offset(s.width/2+lane*120*sc1-10*sc1,y1), Offset(s.width/2+lane*120*sc2-10*sc2,y2), rail..strokeWidth=5*sc1);
        c.drawLine(Offset(s.width/2+lane*120*sc1+10*sc1,y1), Offset(s.width/2+lane*120*sc2+10*sc2,y2), rail..strokeWidth=5*sc1);
      }
    }
  }
  @override bool shouldRepaint(covariant CustomPainter o)=> false;
}

// ================= FOOTBALL V9 - JOYSTICK FIXED + 22 CARTOON =================
class FootballV9 extends StatefulWidget { @override State<FootballV9> createState()=> _FootballV9State(); }
class _FootballV9State extends State<FootballV9> {
  List<Map> my=[]; List<Map> en=[]; double bx=0,by=0; int myScore=0,enScore=0; int sel=9; double ballVX=0,ballVY=0; bool ballFree=false; Timer? aiTimer; Random r=Random(); List<Map> myF=[], enF=[];
  Offset _joy=Offset(0,0); Offset _joyStart=Offset(0,0);
  @override void initState(){
    super.initState();
    myF=[{'x':0.0,'y':0.85,'n':1},{'x':-0.6,'y':0.6,'n':2},{'x':-0.2,'y':0.65,'n':4},{'x':0.2,'y':0.65,'n':5},{'x':0.6,'y':0.6,'n':3},{'x':-0.5,'y':0.3,'n':6},{'x':0.0,'y':0.35,'n':8},{'x':0.5,'y':0.3,'n':10},{'x':-0.4,'y':0.0,'n':7},{'x':0.0,'y':-0.05,'n':9},{'x':0.4,'y':0.0,'n':11}];
    enF=[{'x':0.0,'y':-0.85,'n':1},{'x':-0.6,'y':-0.6,'n':2},{'x':-0.2,'y':-0.65,'n':4},{'x':0.2,'y':-0.65,'n':5},{'x':0.6,'y':-0.6,'n':3},{'x':-0.5,'y':-0.3,'n':6},{'x':0.0,'y':-0.35,'n':8},{'x':0.5,'y':-0.3,'n':10},{'x':-0.4,'y':0.0,'n':7},{'x':0.0,'y':-0.05,'n':9},{'x':0.4,'y':0.0,'n':11}];
    my=myF.map((e)=> Map.from(e)).toList(); en=enF.map((e)=> Map.from(e)).toList(); bx=0; by=0;
    aiTimer=Timer.periodic(Duration(milliseconds:50), (t){
      if(!mounted) return;
      setState((){
        // JOYSTICK MOVE - FIXED!
        if(_joy.distance>0.05){
          my[sel]['x']=(my[sel]['x']+_joy.dx*0.035).clamp(-0.85,0.85);
          my[sel]['y']=(my[sel]['y']+_joy.dy*0.035).clamp(-0.9,0.9);
          if(!ballFree && (my[sel]['x']-bx).abs()<0.13 && (my[sel]['y']-by).abs()<0.13){ bx=my[sel]['x']; by=my[sel]['y']-0.06; }
        }
        if(ballFree){ bx+=ballVX; by+=ballVY; ballVX*=0.985; ballVY*=0.985; if(bx.abs()>0.92){ bx=bx.clamp(-0.92,0.92); ballVX*=-0.5; } if(by<-0.97){ if(bx.abs()<0.28){ myScore++; SoundManager.play('coin.mp3'); resetBall(); } else { by=-0.92; ballVY*=-0.5; } } if(by>0.97){ if(bx.abs()<0.28){ enScore++; SoundManager.play('shoot.mp3'); resetBall(); } else { by=0.92; ballVY*=-0.5; } } if(ballVX.abs()<0.004 && ballVY.abs()<0.004) ballFree=false; }
        // ENEMY AI - chase ball
        int closestEn=-1; double cd=10; for(int i=0;i<en.length;i++){ double d=sqrt(pow(en[i]['x']-bx,2)+pow(en[i]['y']-by,2)); if(d<cd){ cd=d; closestEn=i; } }
        if(closestEn!=-1){ double dx=bx-en[closestEn]['x'], dy=by-en[closestEn]['y'], len=sqrt(dx*dx+dy*dy); if(len>0.01){ en[closestEn]['x']+=(dx/len)*0.018; en[closestEn]['y']+=(dy/len)*0.018; } if(cd<0.11 && !ballFree){ bx=en[closestEn]['x']; by=en[closestEn]['y']+0.06; if(r.nextDouble()<0.05){ ballFree=true; ballVX=(r.nextDouble()-0.5)*0.07; ballVY=0.11; SoundManager.play('shoot.mp3'); } } }
        for(int i=0;i<en.length;i++){ if(i!=closestEn){ double dx=enF[i]['x']-en[i]['x'], dy=enF[i]['y']-en[i]['y']; en[i]['x']+=dx*0.02; en[i]['y']+=dy*0.02; } }
        for(int i=0;i<my.length;i++){ if(i==sel) continue; double dx=myF[i]['x']-my[i]['x'], dy=myF[i]['y']-my[i]['y']; my[i]['x']+=dx*0.025; my[i]['y']+=dy*0.025; }
      });
    });
  }
  void resetBall(){ bx=0; by=0; ballVX=0; ballVY=0; ballFree=false; }
  void shoot(){ if(ballFree) return; SoundManager.play('shoot.mp3'); setState((){ ballFree=true; ballVX=(r.nextDouble()-0.5)*0.05; ballVY=-0.14; }); }
  void passBall(){ if(ballFree) return; int nearest=-1; double nd=10; for(int i=0;i<my.length;i++){ if(i==sel) continue; double d=sqrt(pow(my[i]['x']-bx,2)+pow(my[i]['y']-by,2)); if(d<nd && d>0.15){ nd=d; nearest=i; } } if(nearest!=-1){ setState((){ ballFree=true; ballVX=(my[nearest]['x']-bx)*0.30; ballVY=(my[nearest]['y']-by)*0.30; SoundManager.play('click.mp3'); }); } }
  @override void dispose(){ aiTimer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF2E7D32), appBar: AppBar(title: Text('ZAMBIA $myScore - $enScore ENEMY JOYSTICK FIX'), backgroundColor: Colors.green[900]),
      body: Column(children: [
        // Top team list - cartoon faces
        Container(color: Colors.black87, padding: EdgeInsets.symmetric(horizontal:4,vertical:3), child: Row(children: [
          Text('ZAMBIA: ', style: TextStyle(color: Colors.yellow, fontSize:8)),
          ...my.map((p)=> Text('🧑🏾‍🦱${p['n']}', style: TextStyle(fontSize:10))).toList(),
          Spacer(),
          Text('ENEMY: ', style: TextStyle(color: Colors.redAccent, fontSize:8)),
          ...en.take(5).map((p)=> Text('🧑🏻', style: TextStyle(fontSize:10))).toList(),
        ])),
        Expanded(child: Container(color: Color(0xFF4CAF50), child: Stack(children: [
          CustomPaint(size: Size.infinite, painter: FieldPainter()),
          ...en.map((p)=> Align(alignment: Alignment(p['x'],p['y']), child: Column(children: [Text('🧑🏻‍🦱', style: TextStyle(fontSize:22)), Container(width:26,height:14,decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.white)), child: Center(child: Text(p['n'].toString(), style: TextStyle(color: Colors.white,fontSize:9,fontWeight: FontWeight.bold))))]))).toList(),
          ...my.asMap().entries.map((e){ int i=e.key; var p=e.value; bool s=i==sel; return Align(alignment: Alignment(p['x'],p['y']), child: GestureDetector(onTap: ()=> setState(()=> sel=i), child: Column(children: [Container(decoration: BoxDecoration(color: s? Colors.yellow: Colors.transparent, shape: BoxShape.circle), child: Text(s? '🏃🏾‍♂️': '🧑🏾‍🦱', style: TextStyle(fontSize: s?30:22))), Container(width: s?32:26,height: s?16:14,decoration: BoxDecoration(color: s? Colors.yellow: Color(0xFF1B5E20), borderRadius: BorderRadius.circular(8), border: Border.all(color: s? Colors.black: Colors.white, width: s?2:1)), child: Center(child: Text(p['n'].toString(), style: TextStyle(color: s? Colors.black: Colors.white, fontWeight: FontWeight.bold, fontSize: s?11:9))))]))); }).toList(),
          Align(alignment: Alignment(bx,by), child: Text('⚽', style: TextStyle(fontSize:28, shadows: [Shadow(color: Colors.black, blurRadius:4)]))),
        ]))),
        // JOYSTICK + BUTTONS - FIXED CONTROL
        Container(color: Colors.black87, padding: EdgeInsets.all(8), child: Row(children: [
          // JOYSTICK BASE
          GestureDetector(
            onPanStart: (d){ _joyStart=d.localPosition; },
            onPanUpdate: (d){ 
              Offset diff=d.localPosition - Offset(50,50);
              double dist=diff.distance; if(dist>40) diff=diff/distance*40;
              setState(()=> _joy=Offset(diff.dx/40, diff.dy/40));
            },
            onPanEnd: (_){ setState(()=> _joy=Offset(0,0)); },
            child: Container(width:100,height:100,decoration: BoxDecoration(color: Colors.grey[800], shape: BoxShape.circle, border: Border.all(color: Colors.white30, width:2)), child: Center(child: Transform.translate(offset: Offset(_joy.dx*30, _joy.dy*30), child: Container(width:45,height:45,decoration: BoxDecoration(color: Colors.yellow, shape: BoxShape.circle, border: Border.all(color: Colors.black, width:2)), child: Icon(Icons.open_with, size:22))))),
          ),
          SizedBox(width:10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('CONTROL #${my[sel]['n']} - DRAG YELLOW JOYSTICK!', style: TextStyle(color: Colors.yellow, fontSize:11, fontWeight: FontWeight.bold)), Text('You can now move! Tap cartoon to switch player', style: TextStyle(color: Colors.white70, fontSize:9)), SizedBox(height:4), Row(children: [Container(width:10,height:10, decoration: BoxDecoration(color: _joy.distance>0.1? Colors.green: Colors.grey, shape: BoxShape.circle)), SizedBox(width:5), Text(_joy.distance>0.1? 'MOVING!':'STOPPED', style: TextStyle(color: Colors.white, fontSize:9))]) ])),
          Column(children: [
            ElevatedButton(onPressed: passBall, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, minimumSize: Size(70,36)), child: Text('PASS', style: TextStyle(color: Colors.black, fontSize:11, fontWeight: FontWeight.bold))),
            SizedBox(height:6),
            ElevatedButton(onPressed: shoot, style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700], minimumSize: Size(70,36)), child: Text('SHOOT!', style: TextStyle(color: Colors.black, fontSize:11, fontWeight: FontWeight.bold))),
          ]),
        ])),
      ]),
    );
  }
}
class FieldPainter extends CustomPainter { @override void paint(Canvas c,Size s){ Paint p=Paint()..color=Colors.white..strokeWidth=2..style=PaintingStyle.stroke; c.drawRect(Rect.fromLTWH(s.width*0.05,s.height*0.02,s.width*0.9,s.height*0.96), p); c.drawLine(Offset(s.width*0.05,s.height*0.5), Offset(s.width*0.95,s.height*0.5), p); c.drawCircle(Offset(s.width*0.5,s.height*0.5), 35, p); c.drawRect(Rect.fromLTWH(s.width*0.35,s.height*0.02,s.width*0.3,s.height*0.12), p); c.drawRect(Rect.fromLTWH(s.width*0.35,s.height*0.86,s.width*0.3,s.height*0.12), p); } @override bool shouldRepaint(covariant CustomPainter o)=> false; }

// ================= CHESS V8 SAME (FINE) =================
class ChessV8 extends StatefulWidget { @override State<ChessV8> createState()=> _ChessV8State(); }
class _ChessV8State extends State<ChessV8> {
  List<String> board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; });
  int? sel; bool whiteTurn=true; String status='Your turn - White'; bool gameOver=false; String winner=''; Random r=Random();
  bool isBlack(String p)=> ['♜','♞','♝','♛','♚','♟'].contains(p);
  bool isWhite(String p)=> ['♖','♘','♗','♕','♔','♙'].contains(p);
  List<int> getMoves(int from){ String piece=board[from]; if(piece=='') return []; List<int> moves=[]; int row=from~/8, col=from%8; if(piece=='♟'){ if(row<7 && board[from+8]=='') moves.add(from+8); if(row==1 && board[from+8]=='' && board[from+16]=='') moves.add(from+16); if(row<7 && col>0 && board[from+7]!='' && isWhite(board[from+7])) moves.add(from+7); if(row<7 && col<7 && board[from+9]!='' && isWhite(board[from+9])) moves.add(from+9); } else if(piece=='♙'){ if(row>0 && board[from-8]=='') moves.add(from-8); if(row>0 && col>0 && board[from-9]!='' && isBlack(board[from-9])) moves.add(from-9); if(row>0 && col<7 && board[from-7]!='' && isBlack(board[from-7])) moves.add(from-7); } else if(piece=='♞' || piece=='♘'){ List<List<int>> d=[[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]; for(var dd in d){ int nr=row+dd[0], nc=col+dd[1]; if(nr>=0&&nr<8&&nc>=0&&nc<8){ int to=nr*8+nc; if(board[to]=='' || (isBlack(piece) && isWhite(board[to])) || (isWhite(piece) && isBlack(board[to]))) moves.add(to); } } } else { for(int dr=-1;dr<=1;dr++){ for(int dc=-1;dc<=1;dc++){ if(dr==0&&dc==0) continue; int nr=row+dr, nc=col+dc; if(nr>=0&&nr<8&&nc>=0&&nc<8){ int to=nr*8+nc; if(board[to]=='' || (isBlack(piece) && isWhite(board[to])) || (isWhite(piece) && isBlack(board[to]))) moves.add(to); } } } } return moves; }
  void checkGameOver(){ bool whiteKing=false, blackKing=false; for(var p in board){ if(p=='♔') whiteKing=true; if(p=='♚') blackKing=true; } if(!whiteKing){ setState((){ gameOver=true; winner='BLACK WINS - White King Eaten!'; status='GAME OVER'; }); } if(!blackKing){ setState((){ gameOver=true; winner='YOU WIN - Black King Eaten!'; status='YOU WON!'; }); SoundManager.play('coin.mp3'); } }
  void makeAIMove(){ if(gameOver) return; if(!whiteTurn){ setState(()=> status='Computer thinking... 🤔 (slow)'); Future.delayed(Duration(milliseconds:1500), (){ if(!mounted || gameOver) return; List<int> blackPieces=[]; for(int i=0;i<64;i++){ if(board[i]!='' && isBlack(board[i])) blackPieces.add(i); } blackPieces.shuffle(r); for(int from in blackPieces){ List<int> moves=getMoves(from); if(moves.isNotEmpty){ moves.shuffle(r); int to=moves[0]; setState((){ board[to]=board[from]; board[from]=''; whiteTurn=true; status='Your turn - White'; SoundManager.play('coin.mp3'); }); checkGameOver(); return; } } setState(()=> status='Your turn - White'); whiteTurn=true; }); } }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFEFEBE9), appBar: AppBar(title: Text(gameOver? winner: status), backgroundColor: gameOver? Colors.red: Colors.brown[700]), body: Stack(children: [Column(children: [Container(padding: EdgeInsets.all(10), color: gameOver? Colors.red[100]: whiteTurn? Colors.green[100]: Colors.orange[100], child: Row(children: [Icon(gameOver? Icons.flag: whiteTurn? Icons.person: Icons.computer), SizedBox(width:8), Expanded(child: Text(status, style: TextStyle(fontWeight: FontWeight.bold, fontSize:12)))])), Expanded(child: GridView.builder(padding: EdgeInsets.all(8), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:8), itemCount:64, itemBuilder: (c,i){ bool w=(i~/8 + i%8)%2==0; bool s=sel==i; bool canMove=sel!=null && getMoves(sel!).contains(i); return GestureDetector(onTap: (){ if(gameOver || !whiteTurn) return; setState((){ if(sel==null){ if(board[i]!='' && isWhite(board[i])){ sel=i; SoundManager.play('click.mp3'); } } else { if(getMoves(sel!).contains(i)){ if(board[i]=='♚'){ gameOver=true; winner='YOU WIN - King Eaten!'; } board[i]=board[sel!]; board[sel!]=''; sel=null; whiteTurn=false; SoundManager.play('coin.mp3'); checkGameOver(); if(!gameOver) makeAIMove(); } else if(board[i]!='' && isWhite(board[i])){ sel=i; } else { sel=null; } } }); }, child: Container(decoration: BoxDecoration(color: canMove? Colors.green[300]: s? Colors.yellow: w? Colors.white: Colors.brown[400], border: canMove? Border.all(color: Colors.green, width:3): null), child: Center(child: Text(board[i], style: TextStyle(fontSize:26))))); })), Container(padding: EdgeInsets.all(10), child: Row(children: [ElevatedButton(onPressed: (){ setState((){ board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; }); sel=null; whiteTurn=true; gameOver=false; winner=''; status='Your turn - White'; }); }, child: Text('NEW GAME')), Spacer(), Text('Tap white, green = move', style: TextStyle(fontSize:10))]))]), if(gameOver) Container(color: Colors.black87, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('♔ GAME OVER ♚', style: TextStyle(color: Colors.yellow, fontSize:32, fontWeight: FontWeight.bold)), SizedBox(height:10), Text(winner, style: TextStyle(color: Colors.white, fontSize:20, fontWeight: FontWeight.bold), textAlign: TextAlign.center), SizedBox(height:20), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, padding: EdgeInsets.symmetric(horizontal:40,vertical:15)), onPressed: (){ setState((){ board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; }); sel=null; whiteTurn=true; gameOver=false; winner=''; status='Your turn - White'; }); }, child: Text('PLAY AGAIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))), SizedBox(height:10), ElevatedButton(onPressed: ()=> Navigator.pop(context), child: Text('MENU'))])))])); }
}

// ================= SHOOTING V9 - IMPROVED REAL WAR =================
class ShootingV9 extends StatefulWidget { @override State<ShootingV9> createState()=> _ShootingV9State(); }
class _ShootingV9State extends State<ShootingV9> {
  List<Map> enemies=[]; List<Map> myB=[]; List<Map> enB=[]; List<Map> walls=[]; double px=0, py=0.8; int hp=100, score=0, ammo=30; Timer? loop, enTimer; Random r=Random(); bool isHiding=false;
  @override void initState(){
    super.initState();
    walls=[{'x':-0.5,'y':0.35,'w':0.28,'h':0.14},{'x':0.5,'y':0.35,'w':0.28,'h':0.14},{'x':0.0,'y':0.15,'w':0.32,'h':0.13},{'x':-0.65,'y':-0.15,'w':0.22,'h':0.13},{'x':0.65,'y':-0.15,'w':0.22,'h':0.13}];
    spawn();
    loop=Timer.periodic(Duration(milliseconds:30), (t){
      if(!mounted) return;
      setState((){
        for(var b in myB){ b['x']+=(b['tx']-b['x'])*0.09; b['y']-=0.035; }
        for(var b in enB){ b['y']+=0.022; }
        myB.removeWhere((b)=> b['y']<-1 || b['y']>1 || b['x'].abs()>1);
        enB.removeWhere((b){
          for(var w in walls){ if((b['x']-w['x']).abs()<w['w']/2+0.05 && (b['y']-w['y']).abs()<w['h']/2+0.05) return true; }
          if(b['y']>0.75 && (b['x']-px).abs()<0.16 && (b['y']-py).abs()<0.2 && !isHiding){ hp-=10; SoundManager.play('shoot.mp3'); return true; }
          return b['y']>1.1;
        });
        for(var b in myB){ for(var e in enemies){ if(e['alive'] && (b['x']-e['x']).abs()<0.13 && (b['y']-e['y']).abs()<0.15){ e['alive']=false; score+=10; b['y']=-2; SoundManager.play('coin.mp3'); } } }
        isHiding=false; for(var w in walls){ if((px-w['x']).abs()<w['w']/2+0.12 && (py-w['y']).abs()<w['h']/2+0.12) isHiding=true; }
        enemies.removeWhere((e)=> !e['alive'] && r.nextDouble()<0.09);
        if(enemies.length<6) spawn();
        if(hp<=0){ loop?.cancel(); enTimer?.cancel(); }
      });
    });
    enTimer=Timer.periodic(Duration(milliseconds:850), (t){
      if(!mounted) return;
      for(var e in enemies){
        if(e['alive']){
          bool canSee = !isHiding && (e['x']-px).abs()<0.35;
          if((e['x']-px).abs()<0.25 && (e['y']-py).abs()<0.7) canSee=true;
          if(canSee && r.nextDouble()<0.65){ setState(()=> enB.add({'x':e['x'],'y':e['y']})); SoundManager.play('shoot.mp3'); }
          if(r.nextDouble()<0.08){ e['x']+=(r.nextDouble()-0.5)*0.25; e['x']=e['x'].clamp(-0.8,0.8); }
        }
      }
    });
  }
  void spawn(){ List<Offset> spots=[Offset(-0.6,-0.6),Offset(-0.2,-0.6),Offset(0.2,-0.6),Offset(0.6,-0.6),Offset(0.0,-0.3),Offset(-0.4,0.0),Offset(0.4,0.0)]; for(var s in spots){ if(r.nextDouble()<0.7 && enemies.length<6){ if(!enemies.any((e)=> (e['x']-s.dx).abs()<0.2)){ enemies.add({'x':s.dx,'y':s.dy,'alive':true,'type':r.nextInt(3)}); } } } }
  void shoot(double ax, double ay){ if(ammo<=0){ setState(()=> ammo=30); SoundManager.play('click.mp3'); return; } setState((){ ammo--; myB.add({'x':px,'y':py-0.05,'tx':ax}); }); SoundManager.play('shoot.mp3'); }
  @override void dispose(){ loop?.cancel(); enTimer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF263238), appBar: AppBar(title: Text('HP $hp AMMO $ammo KILL $score ${isHiding?" HIDING 🛡️":" VISIBLE ⚠️"}'), backgroundColor: isHiding? Colors.green[900]: Colors.black87),
      body: hp<=0? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('YOU DIED!', style: TextStyle(color: Colors.red,fontSize:42,fontWeight: FontWeight.bold)), Text('KILLS $score', style: TextStyle(color: Colors.white,fontSize:24)), SizedBox(height:15), ElevatedButton(onPressed: ()=> Navigator.pop(context), child: Text('MENU'))])): Stack(children: [
        Container(color: Color(0xFF37474F)),
        ...walls.map((w)=> Align(alignment: Alignment(w['x'], w['y']), child: Container(width: MediaQuery.of(context).size.width*w['w'], height: 52, decoration: BoxDecoration(color: Color(0xFF8D6E63), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width:2)), child: Center(child: Text('🧱 COVER', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold, color: Colors.white)))))).toList(),
        ...enemies.map((e){ String icon = e['alive']? (e['type']==0? '👨🏻‍✈️🔫': e['type']==1? '👨🏿‍🦱🔫': '🥷🔫'): '💀'; return Align(alignment: Alignment(e['x'], e['y']), child: Container(width:54,height:54, decoration: BoxDecoration(color: e['alive']? Color(0xFFB71C1C): Colors.black54, borderRadius: BorderRadius.circular(10), border: Border.all(color: e['alive']? Colors.yellow: Colors.grey, width: e['alive']?2:1)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(icon, style: TextStyle(fontSize:22)), Container(width:30,height:4, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2)))]))); }).toList(),
        ...myB.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width:9,height:15,decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: Colors.yellow, blurRadius:8)])))).toList(),
        ...enB.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width:7,height:12,decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(4))))).toList(),
        Align(alignment: Alignment(px, py), child: Column(children: [Container(padding: EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: isHiding? Colors.green: Colors.blue, borderRadius: BorderRadius.circular(8)), child: Text(isHiding? 'HIDDEN 🛡️ SAFE': 'YOU 🔫 FOLLOW & KILL', style: TextStyle(color: Colors.white, fontSize:8, fontWeight: FontWeight.bold))), Text('🫡🔫', style: TextStyle(fontSize:40, shadows: [Shadow(color: Colors.black, blurRadius:6)])), Container(padding: EdgeInsets.symmetric(horizontal:6,vertical:1), decoration: BoxDecoration(color: hp>40? Colors.green: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text('HP $hp%', style: TextStyle(color: Colors.white, fontSize:9, fontWeight: FontWeight.bold)))])),
        Positioned(top:0,left:0,right:0,height:MediaQuery.of(context).size.height*0.68, child: GestureDetector(onTapDown: (d){ double ax=(d.globalPosition.dx/MediaQuery.of(context).size.width)*2-1; double ay=(d.globalPosition.dy/MediaQuery.of(context).size.height)*2-1; shoot(ax, ay); }, child: Container(color: Colors.transparent))),
        Positioned(bottom:5,left:10,right:10, child: Column(children: [
          Text(isHiding? '🛡️ HIDDEN - ENEMIES CANT SEE YOU!': '⚠️ VISIBLE - ENEMIES SHOOTING! HIDE BEHIND WALLS!', style: TextStyle(color: isHiding? Colors.greenAccent: Colors.redAccent, fontSize:10, fontWeight: FontWeight.bold)),
          SizedBox(height:4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(onPressed: (){ setState(()=> px=(px-0.20).clamp(-0.85,0.85)); }, child: Text('◀')),
            SizedBox(width:8),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(horizontal:28,vertical:14)), onPressed: (){ shoot(px, -0.5); }, child: Text(ammo==0? 'RELOAD': 'SHOOT 🔫', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
            SizedBox(width:8),
            ElevatedButton(onPressed: (){ setState(()=> px=(px+0.20).clamp(-0.85,0.85)); }, child: Text('▶')),
          ]),
          SizedBox(height:4),
          Row(children: [
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.brown), onPressed: (){ setState(()=> py=(py-0.18).clamp(-0.4,0.85)); }, child: Text('UP FOLLOW', style: TextStyle(fontSize:10)))),
            SizedBox(width:6),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.brown), onPressed: (){ setState(()=> py=(py+0.18).clamp(-0.4,0.85)); }, child: Text('DOWN HIDE', style: TextStyle(fontSize:10)))),
            SizedBox(width:6),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: ()=> setState(()=> ammo=30), child: Text('RELOAD $ammo', style: TextStyle(fontSize:10))),
          ]),
        ])),
      ]),
    );
  }
}
