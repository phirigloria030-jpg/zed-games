import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(ZedGamesApp());

class SoundManager {
  static Future<void> play(String file) async {
    try {
      final p = AudioPlayer();
      await p.play(AssetSource('sounds/$file'));
      p.onPlayerComplete.listen((_) => p.dispose());
    } catch (e) {}
  }
}

class ZedGamesApp extends StatelessWidget {
  @override Widget build(BuildContext c) => MaterialApp(debugShowCheckedModeBanner:false, home: MainMenu());
}

class MainMenu extends StatelessWidget {
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF0A2A0A), body: SafeArea(child: Column(children: [
      SizedBox(height:15),
      Text('ZED GAMES V11', style: TextStyle(color: Colors.yellow, fontSize:34, fontWeight: FontWeight.w900)),
      Text('ALL FIXED ✅', style: TextStyle(color: Colors.white, fontSize:12)),
      Spacer(),
      _btn(context,'SUBWAY REAL GROUND - BOY MOVES 🔊',Colors.blue,SubwayV11()),
      _btn(context,'FOOTBALL SPREAD - 1 BALL 🔊',Colors.green,FootballV11()),
      _btn(context,'CHESS SLOW AI + SOUND 🔊',Colors.brown,ChessV8()),
      _btn(context,'FPS WAR + SOUND 🔊',Colors.red,ShootingV9()),
      Spacer(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(onPressed: (){ SoundManager.play('coin.mp3'); }, child: Text('COIN 🔊')),
        SizedBox(width:6),
        ElevatedButton(onPressed: (){ SoundManager.play('shoot.mp3'); }, child: Text('SHOOT 🔊')),
        SizedBox(width:6),
        ElevatedButton(onPressed: (){ SoundManager.play('jump.mp3'); }, child: Text('JUMP 🔊')),
      ]),
      SizedBox(height:10),
    ])));
  }
  Widget _btn(BuildContext c,String t,Color col,Widget go){ 
    return Container(margin: EdgeInsets.symmetric(horizontal:14,vertical:6), 
    child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: col, minimumSize: Size(double.infinity,58)), 
    onPressed: (){ SoundManager.play('click.mp3'); Navigator.push(c, MaterialPageRoute(builder: (_)=> go)); }, 
    child: Text(t, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:11)))); 
  }
}

// SUBWAY V11
class SubwayV11 extends StatefulWidget { @override State<SubwayV11> createState()=> _SubwayV11State(); }
class _SubwayV11State extends State<SubwayV11> {
  int lane=1; double targetLane=1; double jumpH=0; bool jumping=false;
  double dist=0, speed=0.045; int coins=0,best=0;
  List<Map> objs=[]; Timer? timer; Random r=Random();
  @override void initState(){
    super.initState();
    for(int i=0;i<7;i++) _spawn(4+i*2.2);
    timer=Timer.periodic(Duration(milliseconds:32), (t){
      setState((){
        dist+=speed; speed+=0.00008; if(speed>0.16) speed=0.16;
        targetLane += (lane-targetLane)*0.18;
        for(var o in objs) o['z']-=speed;
        objs.removeWhere((o)=> o['z']<0.15);
        while(objs.length<9) _spawn(10+r.nextDouble()*3);
        for(var o in objs){
          if(o['z']>0.45 && o['z']<0.95 && (o['lane']-targetLane).abs()<0.45){
            if(o['type']=='train' && jumpH<0.35){ SoundManager.play('hit.mp3'); if(dist>best) best=dist.toInt(); dist=0; coins=0; speed=0.045; objs.clear(); for(int i=0;i<7;i++) _spawn(4+i*2.2); return; }
            if(o['type']=='coin' && !o['hit']){ o['hit']=true; coins++; o['z']=-10; SoundManager.play('coin.mp3'); }
          }
        }
      });
    });
  }
  void _spawn(double z){ int la=r.nextInt(3); if(r.nextDouble()<0.5) objs.add({'z':z,'lane':la.toDouble(),'type':'train','hit':false}); else for(int k=0;k<3;k++) objs.add({'z':z+k*0.35,'lane':la.toDouble(),'type':'coin','hit':false}); }
  void move(int d){ int nl=(lane+d).clamp(0,2); if(nl!=lane){ lane=nl; SoundManager.play('click.mp3'); } }
  void doJump(){ if(jumping) return; jumping=true; SoundManager.play('jump.mp3'); jumpH=1; Timer.periodic(Duration(milliseconds:28), (t){ setState(()=> jumpH-=0.065); if(jumpH<=0){ jumpH=0; jumping=false; t.cancel(); } }); }
  @override void dispose(){ timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){
    double sw=MediaQuery.of(context).size.width, sh=MediaQuery.of(context).size.height;
    List<Map> sorted=[...objs]; sorted.sort((a,b)=> b['z'].compareTo(a['z']));
    return Scaffold(body: Stack(children: [
      Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF8D9EFF), Color(0xFFFFCC80)]))),
      Positioned(bottom:0,left:0,right:0,top: sh*0.18, child: CustomPaint(painter: GroundPainter(), size: Size(sw, sh*0.82))),
      ...sorted.map((o){
        double z=o['z']; if(z<0.25||z>11||o['hit']==true) return SizedBox() as Widget;
        double prog=(1-z/11); double y=sh*0.18+prog*(sh*0.68); double x=sw/2 + (o['lane']-1)*(prog*sw*0.35+10); double scale=0.12+prog*1.3;
        double w=(o['type']=='train'?110:26)*scale; double h=(o['type']=='train'?42:26)*scale;
        return Positioned(left: x-w/2, top: y-h, child: o['type']=='coin'? Container(width:w,height:h,decoration: BoxDecoration(color:Colors.yellow,shape:BoxShape.circle,border:Border.all(color:Colors.orange,width:2)),child:Center(child:Text('¢',style:TextStyle(fontSize:h*0.7,fontWeight:FontWeight.bold)))): Container(width:w,height:h,decoration: BoxDecoration(color:Color(0xFF1565C0),borderRadius:BorderRadius.circular(5),border:Border.all(color:Colors.yellow,width:2)),child:Center(child:Icon(Icons.directions_subway,color:Colors.white,size:h*0.8))));
      }).toList(),
      Positioned(bottom: sh*0.14, left:0,right:0, child: Center(child: Transform.translate(offset: Offset((targetLane-1)*sw*0.30, -jumpH*130), child: Column(children: [Container(padding:EdgeInsets.symmetric(horizontal:10,vertical:3),decoration:BoxDecoration(color:Colors.black,borderRadius:BorderRadius.circular(10)),child:Text('ZED BOY LANE ${lane+1}',style:TextStyle(color:Colors.yellow,fontSize:10,fontWeight:FontWeight.bold))), Text(jumping?'🦸🏾‍♂️':'🏃🏾‍♂️',style:TextStyle(fontSize:52))])))),
      Positioned(top:32,left:10,right:10, child: Row(children: [Container(padding:EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:Colors.black87,borderRadius:BorderRadius.circular(20)),child:Text('DIST ${dist.toInt()}',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))), Spacer(), Container(padding:EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:Colors.black87,borderRadius:BorderRadius.circular(20)),child:Text('🪙 $coins BEST $best',style:TextStyle(color:Colors.yellow,fontWeight:FontWeight.bold)))])),
      Positioned(bottom:8,left:10,right:10, child: Row(children: [Expanded(child:ElevatedButton(onPressed: ()=> move(-1), child:Text('◀ LEFT'))), SizedBox(width:8), Expanded(child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:Colors.yellow[700]), onPressed: doJump, child:Text('JUMP 🦘'))), SizedBox(width:8), Expanded(child:ElevatedButton(onPressed: ()=> move(1), child:Text('RIGHT ▶')))])),
    ]));
  }
}
class GroundPainter extends CustomPainter { @override void paint(Canvas c,Size s){ c.drawRect(Rect.fromLTWH(0,0,s.width,s.height), Paint()..color=Color(0xFF5D4037)); for(int lane=-1;lane<=1;lane++){ Path p=Path(); double topX=s.width/2+lane*18; double botX=s.width/2+lane*s.width*0.40; p.moveTo(topX,0); p.lineTo(botX,s.height); c.drawPath(p, Paint()..color=Color(0xFF3E2723)..strokeWidth=22..style=PaintingStyle.stroke); c.drawPath(p, Paint()..color=Colors.black87..strokeWidth=6..style=PaintingStyle.stroke); } } @override bool shouldRepaint(covariant CustomPainter o)=> false; }

// FOOTBALL V11
class FootballV11 extends StatefulWidget { @override State<FootballV11> createState()=> _FootballV11State(); }
class _FootballV11State extends State<FootballV11> {
  List<Map> my=[], en=[]; double bx=0, by=0; Offset ballV=Offset(0,0); int myScore=0,enScore=0; int sel=9; bool hasBall=false; Timer? loop; Random r=Random(); Offset joy=Offset(0,0);
  @override void initState(){
    super.initState();
    my=[{'x':0.0,'y':0.82,'n':1},{'x':-0.6,'y':0.55,'n':2},{'x':-0.2,'y':0.60,'n':4},{'x':0.2,'y':0.60,'n':5},{'x':0.6,'y':0.55,'n':3},{'x':-0.5,'y':0.25,'n':6},{'x':0.0,'y':0.35,'n':8},{'x':0.5,'y':0.25,'n':10},{'x':-0.35,'y':0.0,'n':7},{'x':0.0,'y':-0.05,'n':9},{'x':0.35,'y':0.0,'n':11}];
    en=[{'x':0.0,'y':-0.82,'n':1},{'x':-0.6,'y':-0.55,'n':2},{'x':-0.2,'y':-0.60,'n':4},{'x':0.2,'y':-0.60,'n':5},{'x':0.6,'y':-0.55,'n':3},{'x':-0.5,'y':-0.25,'n':6},{'x':0.0,'y':-0.35,'n':8},{'x':0.5,'y':-0.25,'n':10},{'x':-0.35,'y':0.0,'n':7},{'x':0.0,'y':0.05,'n':9},{'x':0.35,'y':0.0,'n':11}];
    loop=Timer.periodic(Duration(milliseconds:38), (t){ setState((){
        if(joy.distance>0.12){ my[sel]['x']=(my[sel]['x']+joy.dx*0.045).clamp(-0.86,0.86); my[sel]['y']=(my[sel]['y']+joy.dy*0.045).clamp(-0.86,0.86); }
        if(!hasBall){ double d=sqrt(pow(my[sel]['x']-bx,2)+pow(my[sel]['y']-by,2)); if(d<0.10){ hasBall=true; ballV=Offset(0,0); SoundManager.play('click.mp3'); } } else { bx=my[sel]['x']; by=my[sel]['y']-0.08; }
        if(!hasBall){ bx+=ballV.dx; by+=ballV.dy; ballV*=0.985; if(bx.abs()>0.92){ bx=bx.clamp(-0.92,0.92); ballV=Offset(-ballV.dx*0.6, ballV.dy); } if(by<-0.96){ if(bx.abs()<0.22){ myScore++; SoundManager.play('coin.mp3'); _reset(); } else { by=-0.92; ballV=Offset(ballV.dx, -ballV.dy*0.6); } } if(by>0.96){ if(bx.abs()<0.22){ enScore++; SoundManager.play('hit.mp3'); _reset(); } else { by=0.92; ballV=Offset(ballV.dx, -ballV.dy*0.6); } } }
      }); });
  }
  void _reset(){ bx=0; by=0; ballV=Offset(0,0); hasBall=false; sel=9; }
  void shoot(){ if(!hasBall) return; SoundManager.play('shoot.mp3'); setState((){ hasBall=false; ballV=Offset((r.nextDouble()-0.5)*0.025, -0.18); }); }
  void pass(){ if(!hasBall) return; int near=-1; double nd=10; for(int i=0;i<my.length;i++){ if(i==sel) continue; double d=sqrt(pow(my[i]['x']-bx,2)+pow(my[i]['y']-by,2)); if(d<nd && d>0.18 && d<0.7){ nd=d; near=i; } } if(near!=-1){ SoundManager.play('click.mp3'); setState((){ hasBall=false; ballV=Offset((my[near]['x']-bx)*0.28, (my[near]['y']-by)*0.28); sel=near; }); } }
  @override void dispose(){ loop?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF2E7D32), appBar: AppBar(title: Text('ZAMBIA $myScore - $enScore ENEMY'), backgroundColor: Colors.green[900]),
      body: Column(children: [
        Expanded(child: Container(color: Color(0xFF43A047), child: Stack(children: [
          CustomPaint(size: Size.infinite, painter: FieldPainter()),
          ...en.map((p)=> Align(alignment: Alignment(p['x'],p['y']), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('🤾🏻', style: TextStyle(fontSize:22)), Container(padding: EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text(p['n'].toString(), style: TextStyle(color: Colors.white, fontSize:9)))]))).toList(),
          ...my.asMap().entries.map((e){ int i=e.key; var p=e.value; bool s=i==sel; return Align(alignment: Alignment(p['x'],p['y']), child: GestureDetector(onTap: (){ setState(()=> sel=i); SoundManager.play('click.mp3'); }, child: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: EdgeInsets.all(s?4:0), decoration: BoxDecoration(color: s? Colors.yellow: Colors.transparent, shape: BoxShape.circle), child: Text(s? '🏃🏾‍♂️':'🧑🏾‍🦱', style: TextStyle(fontSize: s?30:20))), Container(padding: EdgeInsets.symmetric(horizontal: s?8:6,vertical:2), decoration: BoxDecoration(color: s? Colors.yellow: Color(0xFF1B5E20), borderRadius: BorderRadius.circular(7)), child: Text(p['n'].toString(), style: TextStyle(color: s? Colors.black: Colors.white, fontSize:9)))]))); }).toList(),
          Align(alignment: Alignment(bx,by), child: Text('⚽', style: TextStyle(fontSize:28))),
        ]))),
        Container(color: Colors.black87, padding: EdgeInsets.all(8), child: Row(children: [
          GestureDetector(onPanUpdate: (d){ Offset diff=d.localPosition-Offset(50,50); double dist=diff.distance; if(dist>42) diff=diff/dist*42; setState(()=> joy=Offset(diff.dx/42, diff.dy/42)); }, onPanEnd: (_){ setState(()=> joy=Offset(0,0)); }, child: Container(width:105,height:105,decoration: BoxDecoration(color: Colors.grey[850], shape: BoxShape.circle, border: Border.all(color: Colors.white30,width:2)), child: Center(child: Transform.translate(offset: Offset(joy.dx*32, joy.dy*32), child: Container(width:48,height:48,decoration: BoxDecoration(color: Colors.yellow, shape: BoxShape.circle), child: Icon(Icons.sports_soccer, size:24)))))),
          SizedBox(width:10),
          Expanded(child: Text('PLAYER #${my[sel]['n']} ${hasBall?"WITH BALL ⚽":""}', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold))),
          Column(children: [ElevatedButton(onPressed: pass, child: Text('PASS 🔊')), SizedBox(height:6), ElevatedButton(onPressed: shoot, style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]), child: Text('SHOOT! 🔊'))]),
        ])),
      ]),
    );
  }
}
class FieldPainter extends CustomPainter { @override void paint(Canvas c,Size s){ Paint p=Paint()..color=Colors.white..strokeWidth=2..style=PaintingStyle.stroke; c.drawRect(Rect.fromLTWH(s.width*0.05,s.height*0.02,s.width*0.9,s.height*0.96), p); c.drawLine(Offset(s.width*0.05,s.height*0.5), Offset(s.width*0.95,s.height*0.5), p); c.drawCircle(Offset(s.width*0.5,s.height*0.5), 35, p); } @override bool shouldRepaint(covariant CustomPainter o)=> false; }

// CHESS + SHOOTING KEEP SAME
class ChessV8 extends StatefulWidget { @override State<ChessV8> createState()=> _ChessV8State(); }
class _ChessV8State extends State<ChessV8> {
  List<String> board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; });
  int? sel; bool whiteTurn=true; String status='Your turn'; bool gameOver=false; Random r=Random();
  bool isBlack(String p)=> ['♜','♞','♝','♛','♚','♟'].contains(p); bool isWhite(String p)=> ['♖','♘','♗','♕','♔','♙'].contains(p);
  List<int> getMoves(int from){ String piece=board[from]; if(piece=='') return []; List<int> moves=[]; int row=from~/8, col=from%8; if(piece=='♟'){ if(row<7 && board[from+8]=='') moves.add(from+8); if(row<7 && col>0 && board[from+7]!='' && isWhite(board[from+7])) moves.add(from+7); if(row<7 && col<7 && board[from+9]!='' && isWhite(board[from+9])) moves.add(from+9); } else if(piece=='♙'){ if(row>0 && board[from-8]=='') moves.add(from-8); if(row>0 && col>0 && board[from-9]!='' && isBlack(board[from-9])) moves.add(from-9); if(row>0 && col<7 && board[from-7]!='' && isBlack(board[from-7])) moves.add(from-7); } else if(piece=='♞' || piece=='♘'){ List<List<int>> d=[[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]; for(var dd in d){ int nr=row+dd[0], nc=col+dd[1]; if(nr>=0&&nr<8&&nc>=0&&nc<8){ int to=nr*8+nc; if(board[to]=='' || (isBlack(piece) && isWhite(board[to])) || (isWhite(piece) && isBlack(board[to]))) moves.add(to); } } } else { for(int dr=-1;dr<=1;dr++){ for(int dc=-1;dc<=1;dc++){ if(dr==0&&dc==0) continue; int nr=row+dr, nc=col+dc; if(nr>=0&&nr<8&&nc>=0&&nc<8){ int to=nr*8+nc; if(board[to]=='' || (isBlack(piece) && isWhite(board[to])) || (isWhite(piece) && isBlack(board[to]))) moves.add(to); } } } } return moves; }
  void ai(){ if(gameOver || whiteTurn) return; setState(()=> status='Thinking...'); Future.delayed(Duration(milliseconds:1200), (){ List<int> black=[]; for(int i=0;i<64;i++) if(board[i]!='' && isBlack(board[i])) black.add(i); black.shuffle(r); for(int from in black){ var mv=getMoves(from); if(mv.isNotEmpty){ mv.shuffle(r); int to=mv[0]; setState((){ board[to]=board[from]; board[from]=''; whiteTurn=true; status='Your turn'; SoundManager.play('click.mp3'); }); return; } } setState(()=> status='Your turn'); whiteTurn=true; }); }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFEFEBE9), appBar: AppBar(title: Text(status), backgroundColor: Colors.brown[700]), body: Column(children: [Expanded(child: GridView.builder(padding: EdgeInsets.all(8), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:8), itemCount:64, itemBuilder: (c,i){ bool w=(i~/8 + i%8)%2==0; bool s=sel==i; bool can=sel!=null && getMoves(sel!).contains(i); return GestureDetector(onTap: (){ if(!whiteTurn) return; setState((){ if(sel==null){ if(board[i]!='' && isWhite(board[i])){ sel=i; SoundManager.play('click.mp3'); } } else { if(getMoves(sel!).contains(i)){ board[i]=board[sel!]; board[sel!]=''; sel=null; whiteTurn=false; SoundManager.play('coin.mp3'); ai(); } else if(board[i]!='' && isWhite(board[i])) sel=i; else sel=null; } }); }, child: Container(decoration: BoxDecoration(color: can? Colors.green[300]: s? Colors.yellow: w? Colors.white: Colors.brown[400]), child: Center(child: Text(board[i], style: TextStyle(fontSize:26))))); })), Container(padding: EdgeInsets.all(10), child: ElevatedButton(onPressed: (){ setState((){ board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; }); sel=null; whiteTurn=true; status='Your turn'; }); }, child: Text('NEW GAME 🔊')))])); }
}
class ShootingV9 extends StatefulWidget { @override State<ShootingV9> createState()=> _ShootingV9State(); }
class _ShootingV9State extends State<ShootingV9> {
  List<Map> enemies=[]; List<Map> myB=[]; List<Map> enB=[]; double px=0, py=0.8; int hp=100, score=0, ammo=30; Timer? loop; Random r=Random();
  @override void initState(){ super.initState(); spawn(); loop=Timer.periodic(Duration(milliseconds:35), (t){ setState((){ for(var b in myB){ b['x']+=(b['tx']-b['x'])*0.09; b['y']-=0.035; } for(var b in enB) b['y']+=0.022; myB.removeWhere((b)=> b['y']<-1); enB.removeWhere((b){ if(b['y']>0.7 && (b['x']-px).abs()<0.16){ hp-=10; SoundManager.play('hit.mp3'); return true; } return b['y']>1.1; }); for(var b in myB) for(var e in enemies) if(e['alive'] && (b['x']-e['x']).abs()<0.13 && (b['y']-e['y']).abs()<0.15){ e['alive']=false; score+=10; b['y']=-2; SoundManager.play('coin.mp3'); } enemies.removeWhere((e)=> !e['alive'] && r.nextDouble()<0.1); if(enemies.length<5) spawn(); }); }); Timer.periodic(Duration(milliseconds:900), (t){ for(var e in enemies) if(e['alive'] && r.nextDouble()<0.6){ setState(()=> enB.add({'x':e['x'],'y':e['y']})); SoundManager.play('shoot.mp3'); } }); }
  void spawn(){ List<Offset> spots=[Offset(-0.6,-0.6),Offset(0.0,-0.6),Offset(0.6,-0.6),Offset(-0.4,0.0),Offset(0.4,0.0)]; for(var s in spots) if(r.nextDouble()<0.7 && enemies.length<5) enemies.add({'x':s.dx,'y':s.dy,'alive':true}); }
  void shoot(double ax){ if(ammo<=0){ ammo=30; return; } ammo--; myB.add({'x':px,'y':py-0.05,'tx':ax}); SoundManager.play('shoot.mp3'); }
  @override void dispose(){ loop?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFF263238), appBar: AppBar(title: Text('HP $hp AMMO $ammo KILL $score')), body: Stack(children: [Container(color: Color(0xFF37474F)), ...enemies.map((e)=> Align(alignment: Alignment(e['x'], e['y']), child: Container(width:52,height:52,decoration: BoxDecoration(color: e['alive']? Colors.red[900]: Colors.black54, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(e['alive']? '👨🏻‍✈️🔫':'💀', style: TextStyle(fontSize:22)))))).toList(), ...myB.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width:9,height:14,color: Colors.yellow))).toList(), ...enB.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width:7,height:11,color: Colors.redAccent))).toList(), Align(alignment: Alignment(px, py), child: Text('🫡🔫', style: TextStyle(fontSize:38))), Positioned(top:0,left:0,right:0,bottom:100, child: GestureDetector(onTapDown: (d){ double ax=(d.globalPosition.dx/MediaQuery.of(context).size.width)*2-1; shoot(ax); }, child: Container(color: Colors.transparent))), Positioned(bottom:5,left:10,right:10, child: Row(children: [ElevatedButton(onPressed: (){ setState(()=> px=(px-0.22).clamp(-0.85,0.85)); }, child: Text('◀')), Spacer(), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: (){ shoot(px); }, child: Text('SHOOT 🔊', style: TextStyle(color: Colors.white))), Spacer(), ElevatedButton(onPressed: (){ setState(()=> px=(px+0.22).clamp(-0.85,0.85)); }, child: Text('▶'))]))])); }
}
