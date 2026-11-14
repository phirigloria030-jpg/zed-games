import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(ZedGamesApp());
class SoundManager { static final AudioPlayer p=AudioPlayer(); static void play(String f) async { try{ await p.play(AssetSource('sounds/'+f)); }catch(e){} } }

class ZedGamesApp extends StatelessWidget { @override Widget build(BuildContext context)=> MaterialApp(debugShowCheckedModeBanner: false, home: MainMenu()); }
class MainMenu extends StatelessWidget {
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFF0A2A0A), body: SafeArea(child: Column(children: [SizedBox(height:15), Text('ZED GAMES V7', style: TextStyle(color: Colors.yellow, fontSize:34, fontWeight: FontWeight.w900)), Text('REAL AI - ENEMY PLAYS! 🇿🇲', style: TextStyle(color: Colors.white, fontSize:12, fontWeight: FontWeight.bold)), Spacer(), _btn(context,'SUBWAY ZAMBIAN REAL TRACK',Colors.blueAccent,SubwayV6()), _btn(context,'FOOTBALL 11v11 REAL AI',Colors.green,FootballAI()), _btn(context,'BUILDING WAR SHOOT',Colors.red,ShootingV6()), _btn(context,'CHESS vs COMPUTER AI',Colors.brown,ChessAI()), Spacer()] ))); }
  Widget _btn(BuildContext c,String t,Color col,Widget go){ return Container(margin: EdgeInsets.symmetric(horizontal:14,vertical:5), child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: col, minimumSize: Size(double.infinity,58), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: (){ SoundManager.play('click.mp3'); Navigator.push(c, MaterialPageRoute(builder: (_)=> go)); }, child: Text(t, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:12)))); }
}

// ================= SUBWAY V6 SAME =================
class SubwayV6 extends StatefulWidget { @override State<SubwayV6> createState()=> _SubwayV6State(); }
class _SubwayV6State extends State<SubwayV6> {
  int lane=1; double jump=0; bool jumping=false; double runAnim=0, dist=0; int coins=0,best=0; List<Map> trains=[]; List<Map> coinL=[]; Timer? timer; Random r=Random();
  @override void initState(){ super.initState(); for(int i=0;i<5;i++){ trains.add({'z':6.0+i*4.0,'lane':r.nextInt(3),'type':r.nextInt(2)}); for(int k=0;k<3;k++) coinL.add({'z':5.0+i*3.0+k*0.8,'lane':r.nextInt(3)}); } timer=Timer.periodic(Duration(milliseconds:16), (t){ if(!mounted) return; setState((){ dist+=0.08; runAnim+=0.3; for(var o in trains) o['z']-=0.11; for(var c in coinL) c['z']-=0.11; trains.removeWhere((o)=>o['z']<-1); coinL.removeWhere((c)=>c['z']<-1); while(trains.length<6){ int la=r.nextInt(3); if(r.nextDouble()<0.7) trains.add({'z':14+r.nextDouble()*4,'lane':la,'type':r.nextInt(2)}); } while(coinL.length<18){ int la=r.nextInt(3); double bz=15+r.nextDouble()*3; bool hasTrain=trains.any((tr)=> (tr['z']-bz).abs()<1.5 && tr['lane']==la); if(!hasTrain) for(int k=0;k<4;k++) coinL.add({'z':bz+k*0.7,'lane':la}); } for(var o in trains){ if(o['z']>-0.4 && o['z']<0.5 && o['lane']==lane && jump<0.35){ if(dist>best) best=dist.toInt(); dist=0; coins=0; trains.clear(); coinL.clear(); for(int i=0;i<5;i++) trains.add({'z':6.0+i*4.0,'lane':r.nextInt(3),'type':r.nextInt(2)}); return; } } for(var c in coinL){ if(c['z']>-0.4 && c['z']<0.5 && c['lane']==lane){ coins++; c['z']=-10; SoundManager.play('coin.mp3'); } } }); }); }
  void doJump(){ if(jumping) return; setState((){ jumping=true; jump=1.2; }); SoundManager.play('jump.mp3'); Future.delayed(Duration(milliseconds:300), (){ if(mounted) setState(()=> jump=0.7); }); Future.delayed(Duration(milliseconds:600), (){ if(mounted) setState((){ jump=0; jumping=false; }); }); }
  @override void dispose(){ timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){ double sw=MediaQuery.of(context).size.width; double sh=MediaQuery.of(context).size.height; return Scaffold(body: GestureDetector(onHorizontalDragEnd: (d){ if(d.velocity.pixelsPerSecond.dx>200 && lane<2) setState(()=> lane++); if(d.velocity.pixelsPerSecond.dx<-200 && lane>0) setState(()=> lane--); }, onVerticalDragEnd: (d){ if(d.velocity.pixelsPerSecond.dy<-200) doJump(); }, child: Stack(children: [Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF4FC3F7), Color(0xFF81C784)]))), CustomPaint(size: Size.infinite, painter: SubwayTrackPainter()), ...trains.map((o){ double z=o['z']; if(z<-1||z>16) return SizedBox() as Widget; double sc=1.0/(z*0.22+1); if(sc<0.15) return SizedBox() as Widget; double y=sh*(0.15+0.70*(1-sc)); double off=(o['lane']-1)*115*sc; double x=sw/2+off-40*sc; bool isLow=o['type']==1; return Positioned(left:x, top:y, child: Transform.scale(scale: sc*1.4, alignment: Alignment.bottomCenter, child: isLow? Container(width:85,height:28,decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.yellow,width:2))): Container(width:80,height:55,decoration: BoxDecoration(color: Color(0xFF1565C0), borderRadius: BorderRadius.circular(6)), child: Column(children: [Container(height:12,color: Colors.black87), Expanded(child: Center(child: Icon(Icons.train,color: Colors.white,size:28)))])))); }).toList(), ...coinL.map((c){ double z=c['z']; if(z<-1||z>16) return SizedBox() as Widget; double sc=1.0/(z*0.22+1); double y=sh*(0.15+0.70*(1-sc)); double off=(c['lane']-1)*115*sc; double x=sw/2+off-12*sc; return Positioned(left:x, top:y, child: Transform.scale(scale: sc, child: Text('🪙', style: TextStyle(fontSize:30)))); }).toList(), Align(alignment: Alignment((lane-1)*0.72,0.65-jump), child: Column(children: [Container(padding: EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)), child: Text('ZED BOY', style: TextStyle(color: Colors.yellow,fontSize:8,fontWeight: FontWeight.bold))), Text(jump<0? '🤸🏾‍♂️': jumping? '🦸🏾‍♂️': '🏃🏾‍♂️', style: TextStyle(fontSize:52)), Container(width:30,height:4,decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green,Colors.red,Colors.black,Colors.orange]), borderRadius: BorderRadius.circular(2)))] )), Align(alignment: Alignment((lane-1)*0.72+0.12,0.88), child: Text('👮‍♂️💨', style: TextStyle(fontSize:32))), Positioned(top:30,left:10,right:10, child: Row(children: [Container(padding: EdgeInsets.symmetric(horizontal:12,vertical:6), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)), child: Text((dist*10).toInt().toString().padLeft(5,'0'), style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))), Spacer(), Container(padding: EdgeInsets.symmetric(horizontal:12,vertical:6), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)), child: Text('🪙 '+coins.toString()+' BEST '+best.toString(), style: TextStyle(color: Colors.yellow,fontWeight: FontWeight.bold)))])), Positioned(bottom:10,left:10,right:10, child: Row(children: [Expanded(child: ElevatedButton(onPressed: (){ if(lane>0) setState(()=> lane--); }, child: Text('◀'))), SizedBox(width:8), Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]), onPressed: doJump, child: Text('JUMP', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)))), SizedBox(width:8), Expanded(child: ElevatedButton(onPressed: (){ if(lane<2) setState(()=> lane++); }, child: Text('▶')))]))]))); }
}
class SubwayTrackPainter extends CustomPainter { @override void paint(Canvas c,Size s){ Paint rail=Paint()..color=Color(0xFF424242)..strokeWidth=4..style=PaintingStyle.stroke; Paint sleeper=Paint()..color=Color(0xFF5D4037)..strokeWidth=6; for(int lane=-1;lane<=1;lane++){ for(int i=0;i<30;i++){ double t1=i/30; double t2=(i+1)/30; double sc1=1.0/(t1*8+1); double sc2=1.0/(t2*8+1); double y1=s.height*(0.15+0.75*(1-sc1)); double y2=s.height*(0.15+0.75*(1-sc2)); double x1=s.width/2+lane*115*sc1; double x2=s.width/2+lane*115*sc2; if(i%3==0) c.drawLine(Offset(s.width/2-160*sc1,y1), Offset(s.width/2+160*sc1,y1), sleeper..strokeWidth=8*sc1); c.drawLine(Offset(x1-12*sc1,y1), Offset(x2-12*sc2,y2), rail..strokeWidth=4*sc1); c.drawLine(Offset(x1+12*sc1,y1), Offset(x2+12*sc2,y2), rail..strokeWidth=4*sc1); } } } @override bool shouldRepaint(covariant CustomPainter o)=> false; }

// ================= FOOTBALL WITH REAL AI =================
class FootballAI extends StatefulWidget { @override State<FootballAI> createState()=> _FootballAIState(); }
class _FootballAIState extends State<FootballAI> {
  List<Map> my=[]; List<Map> en=[]; double bx=0, by=0; int myScore=0, enScore=0; int sel=9; double ballVX=0, ballVY=0; bool ballFree=false; Timer? aiTimer; Random r=Random();
  @override void initState(){
    super.initState();
    my=[{'x':0.0,'y':0.85,'n':1,'vx':0.0,'vy':0.0},{'x':-0.6,'y':0.6,'n':2,'vx':0.0,'vy':0.0},{'x':-0.2,'y':0.65,'n':4,'vx':0.0,'vy':0.0},{'x':0.2,'y':0.65,'n':5,'vx':0.0,'vy':0.0},{'x':0.6,'y':0.6,'n':3,'vx':0.0,'vy':0.0},{'x':-0.5,'y':0.3,'n':6,'vx':0.0,'vy':0.0},{'x':0.0,'y':0.35,'n':8,'vx':0.0,'vy':0.0},{'x':0.5,'y':0.3,'n':10,'vx':0.0,'vy':0.0},{'x':-0.4,'y':0.0,'n':7,'vx':0.0,'vy':0.0},{'x':0.0,'y':-0.05,'n':9,'vx':0.0,'vy':0.0},{'x':0.4,'y':0.0,'n':11,'vx':0.0,'vy':0.0}];
    en=[{'x':0.0,'y':-0.85,'n':1,'vx':0.0,'vy':0.0},{'x':-0.6,'y':-0.6,'n':2,'vx':0.0,'vy':0.0},{'x':-0.2,'y':-0.65,'n':4,'vx':0.0,'vy':0.0},{'x':0.2,'y':-0.65,'n':5,'vx':0.0,'vy':0.0},{'x':0.6,'y':-0.6,'n':3,'vx':0.0,'vy':0.0},{'x':-0.5,'y':-0.3,'n':6,'vx':0.0,'vy':0.0},{'x':0.0,'y':-0.35,'n':8,'vx':0.0,'vy':0.0},{'x':0.5,'y':-0.3,'n':10,'vx':0.0,'vy':0.0},{'x':-0.4,'y':0.0,'n':7,'vx':0.0,'vy':0.0},{'x':0.0,'y':-0.05,'n':9,'vx':0.0,'vy':0.0},{'x':0.4,'y':0.0,'n':11,'vx':0.0,'vy':0.0}];
    bx=my[9]['x']; by=my[9]['y'];
    aiTimer=Timer.periodic(Duration(milliseconds:100), (t){
      if(!mounted) return;
      setState((){
        // ball physics
        if(ballFree){
          bx+=ballVX; by+=ballVY; ballVX*=0.98; ballVY*=0.98;
          if(bx.abs()>0.9){ bx=bx.clamp(-0.9,0.9); ballVX*=-0.6; }
          if(by<-0.95){
            if(bx.abs()<0.25){ myScore++; SoundManager.play('coin.mp3'); resetBall(); } else { by=-0.9; ballVY*=-0.6; }
          }
          if(by>0.95){
            if(bx.abs()<0.25){ enScore++; SoundManager.play('shoot.mp3'); resetBall(); } else { by=0.9; ballVY*=-0.6; }
          }
          if(ballVX.abs()<0.005 && ballVY.abs()<0.005) ballFree=false;
        }
        // ENEMY AI - chase ball
        int closestEn=-1; double closestDist=10;
        for(int i=0;i<en.length;i++){ double d= sqrt(pow(en[i]['x']-bx,2)+pow(en[i]['y']-by,2)); if(d<closestDist){ closestDist=d; closestEn=i; } }
        if(closestEn!=-1){
          double dx=bx-en[closestEn]['x']; double dy=by-en[closestEn]['y'];
          double len= sqrt(dx*dx+dy*dy); if(len>0.01){ en[closestEn]['x']+= (dx/len)*0.02; en[closestEn]['y']+= (dy/len)*0.02; }
          if(closestDist<0.12 && !ballFree){
            // enemy has ball, shoot to our goal
            bx=en[closestEn]['x']; by=en[closestEn]['y']+0.08;
            if(r.nextDouble()<0.03){
              ballFree=true; ballVX=(r.nextDouble()-0.5)*0.08; ballVY=0.12; SoundManager.play('shoot.mp3');
            }
          }
        }
        // move other enemies slightly to positions
        for(int i=0;i<en.length;i++){ if(i==closestEn) continue; en[i]['x']+=( (r.nextDouble()-0.5)*0.005 ); en[i]['y']+=( (r.nextDouble()-0.5)*0.005 ); en[i]['x']=en[i]['x'].clamp(-0.85,0.85); en[i]['y']=en[i]['y'].clamp(-0.9,0.9); }
        // my teammates AI - move to support
        for(int i=0;i<my.length;i++){ if(i==sel) continue; double tx=bx + (r.nextDouble()-0.5)*0.4; double ty=by + (r.nextDouble()-0.5)*0.4 + 0.2; double dx=tx-my[i]['x']; double dy=ty-my[i]['y']; my[i]['x']+=dx*0.015; my[i]['y']+=dy*0.015; my[i]['x']=my[i]['x'].clamp(-0.85,0.85); my[i]['y']=my[i]['y'].clamp(-0.9,0.9); }
      });
    });
  }
  void resetBall(){ bx=0; by=0; ballVX=0; ballVY=0; ballFree=false; }
  void move(double dx,double dy){ setState((){ my[sel]['x']=(my[sel]['x']+dx).clamp(-0.85,0.85); my[sel]['y']=(my[sel]['y']+dy).clamp(-0.9,0.9); if(!ballFree && (my[sel]['x']-bx).abs()<0.12 && (my[sel]['y']-by).abs()<0.12){ bx=my[sel]['x']; by=my[sel]['y']-0.07; } }); }
  void shoot(){ if(ballFree) return; SoundManager.play('shoot.mp3'); setState((){ ballFree=true; ballVX=(r.nextDouble()-0.5)*0.06; ballVY=-0.12; }); }
  void passBall(){ if(ballFree) return; int nearest=-1; double nd=10; for(int i=0;i<my.length;i++){ if(i==sel) continue; double d= sqrt(pow(my[i]['x']-bx,2)+pow(my[i]['y']-by,2)); if(d<nd){ nd=d; nearest=i; } } if(nearest!=-1){ setState((){ ballFree=true; double dx=my[nearest]['x']-bx; double dy=my[nearest]['y']-by; ballVX=dx*0.25; ballVY=dy*0.25; SoundManager.play('click.mp3'); }); } }
  @override void dispose(){ aiTimer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFF2E7D32), appBar: AppBar(title: Text('ZAMBIA '+myScore.toString()+' - '+enScore.toString()+' ENEMY 11v11 AI'), backgroundColor: Colors.green[900]), body: Column(children: [Expanded(child: GestureDetector(onPanUpdate: (d)=> move(d.delta.dx*0.008, d.delta.dy*0.008), child: Container(color: Color(0xFF4CAF50), child: Stack(children: [CustomPaint(size: Size.infinite, painter: FieldPainter()), ...en.map((p)=> Align(alignment: Alignment(p['x'], p['y']), child: Container(width:28,height:28,decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white)), child: Center(child: Text(p['n'].toString(), style: TextStyle(color: Colors.white,fontSize:9, fontWeight: FontWeight.bold)))))).toList(), ...my.asMap().entries.map((e){ int i=e.key; var p=e.value; bool s=i==sel; return Align(alignment: Alignment(p['x'], p['y']), child: GestureDetector(onTap: ()=> setState(()=> sel=i), child: Container(width: s?40:28, height: s?40:28, decoration: BoxDecoration(color: s? Colors.yellow: Color(0xFF1B5E20), shape: BoxShape.circle, border: Border.all(color: s? Colors.black: Colors.white, width: s?3:1)), child: Center(child: Text(p['n'].toString(), style: TextStyle(color: s? Colors.black: Colors.white, fontWeight: FontWeight.bold, fontSize: s?12:9)))))); }).toList(), Align(alignment: Alignment(bx, by), child: Text('⚽', style: TextStyle(fontSize:28, shadows: [Shadow(color: Colors.black, blurRadius:4)]))) ])))), Container(color: Colors.black87, padding: EdgeInsets.all(8), child: Row(children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('YOU CONTROL #'+my[sel]['n'].toString(), style: TextStyle(color: Colors.yellow, fontSize:11, fontWeight: FontWeight.bold)), Text('Drag to move', style: TextStyle(color: Colors.white54, fontSize:9))]), Spacer(), ElevatedButton(onPressed: passBall, style: ElevatedButton.styleFrom(backgroundColor: Colors.white), child: Text('PASS', style: TextStyle(color: Colors.black))), SizedBox(width:6), ElevatedButton(onPressed: shoot, style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]), child: Text('SHOOT!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))) ])) ])); }
}
class FieldPainter extends CustomPainter { @override void paint(Canvas c,Size s){ Paint p=Paint()..color=Colors.white..strokeWidth=2..style=PaintingStyle.stroke; c.drawRect(Rect.fromLTWH(s.width*0.05,s.height*0.02,s.width*0.9,s.height*0.96), p); c.drawLine(Offset(s.width*0.05,s.height*0.5), Offset(s.width*0.95,s.height*0.5), p); c.drawCircle(Offset(s.width*0.5,s.height*0.5), 35, p); c.drawRect(Rect.fromLTWH(s.width*0.35,s.height*0.02,s.width*0.3,s.height*0.12), p); c.drawRect(Rect.fromLTWH(s.width*0.35,s.height*0.86,s.width*0.3,s.height*0.12), p); } @override bool shouldRepaint(covariant CustomPainter o)=> false; }

// BUILDING WAR V6 SAME
class ShootingV6 extends StatefulWidget { @override State<ShootingV6> createState()=> _ShootingV6State(); }
class _ShootingV6State extends State<ShootingV6> {
  List<Map> enemies=[]; List<Map> myB=[]; List<Map> enB=[]; double px=0; int hp=100,score=0,ammo=30; Timer? loop,enTimer; Random r=Random();
  @override void initState(){ super.initState(); spawn(); loop=Timer.periodic(Duration(milliseconds:16), (t){ if(!mounted) return; setState((){ for(var b in myB) b['y']-=0.025; for(var b in enB) b['y']+=0.018; myB.removeWhere((b)=> b['y']<-1); enB.removeWhere((b){ if(b['y']>0.9 && (b['x']-px).abs()<0.18){ hp-=10; return true; } return b['y']>1; }); for(var b in myB){ for(var e in enemies){ if(e['alive'] && (b['x']-e['x']).abs()<0.13 && (b['y']-e['y']).abs()<0.13){ e['alive']=false; score+=10; b['y']=-2; SoundManager.play('coin.mp3'); } } } enemies.removeWhere((e)=> !e['alive'] && r.nextDouble()<0.05); if(enemies.length<4) spawn(); if(hp<=0){ loop?.cancel(); enTimer?.cancel(); } }); }); enTimer=Timer.periodic(Duration(milliseconds:900), (t){ if(!mounted) return; for(var e in enemies){ if(e['alive'] && r.nextDouble()<0.5){ setState(()=> enB.add({'x':e['x'],'y':e['y']})); SoundManager.play('shoot.mp3'); } } }); }
  void spawn(){ List<Offset> wins=[Offset(-0.6,-0.6),Offset(-0.2,-0.6),Offset(0.2,-0.6),Offset(0.6,-0.6),Offset(-0.4,-0.3),Offset(0.0,-0.3),Offset(0.4,-0.3),Offset(-0.6,0.0),Offset(0.6,0.0)]; for(var w in wins){ if(r.nextDouble()<0.6 && enemies.length<6){ if(!enemies.any((e)=> (e['x']-w.dx).abs()<0.15)){ enemies.add({'x':w.dx,'y':w.dy,'alive':true}); } } } }
  void shoot(){ if(ammo<=0){ setState(()=> ammo=30); SoundManager.play('click.mp3'); return; } setState((){ ammo--; myB.add({'x':px,'y':0.78}); }); SoundManager.play('shoot.mp3'); }
  @override void dispose(){ loop?.cancel(); enTimer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFF263238), appBar: AppBar(title: Text('HP '+hp.toString()+' AMMO '+ammo.toString()+' KILL '+score.toString()), backgroundColor: Colors.black), body: hp<=0? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('YOU DIED!', style: TextStyle(color: Colors.red,fontSize:42,fontWeight: FontWeight.bold)), Text('KILLS '+score.toString(), style: TextStyle(color: Colors.white,fontSize:24)), SizedBox(height:15), ElevatedButton(onPressed: ()=> Navigator.pop(context), child: Text('MENU'))])): Stack(children: [Container(color: Color(0xFF37474F)), CustomPaint(size: Size.infinite, painter: BuildingPainterV6()), ...enemies.map((e)=> Align(alignment: Alignment(e['x'], e['y']), child: Container(width:48,height:48,decoration: BoxDecoration(color: e['alive']? Color(0xFFB71C1C): Colors.black54, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.yellow,width:1)), child: Center(child: Text(e['alive']? '👤🔫': '💀', style: TextStyle(fontSize:20)))))).toList(), ...myB.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width:6,height:14,decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(3))))).toList(), ...enB.map((b)=> Align(alignment: Alignment(b['x'], b['y']), child: Container(width:6,height:12,decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(3))))).toList(), Align(alignment: Alignment(px,0.85), child: Column(children: [Text('🔫', style: TextStyle(fontSize:40)), Container(padding: EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: hp>40? Colors.green: Colors.red, borderRadius: BorderRadius.circular(8)), child: Text('YOU '+hp.toString()+'%', style: TextStyle(color: Colors.white,fontSize:10))) ])), Positioned(bottom:5,left:10,right:10, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [ElevatedButton(onPressed: (){ setState(()=> px=(px-0.18).clamp(-0.85,0.85)); }, child: Text('◀')), SizedBox(width:10), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(horizontal:35,vertical:14)), onPressed: shoot, child: Text(ammo==0? 'RELOAD': 'SHOOT 🔫', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))), SizedBox(width:10), ElevatedButton(onPressed: (){ setState(()=> px=(px+0.18).clamp(-0.85,0.85)); }, child: Text('▶'))])), Positioned(top:0,left:0,right:0,height:MediaQuery.of(context).size.height*0.72, child: GestureDetector(onTapDown: (_)=> shoot(), child: Container(color: Colors.transparent))) ])); }
}
class BuildingPainterV6 extends CustomPainter { @override void paint(Canvas c,Size s){ Paint wall=Paint()..color=Color(0xFF455A64); Paint win=Paint()..color=Color(0xFF1A1A1A); Paint frame=Paint()..color=Color(0xFF90A4AE)..style=PaintingStyle.stroke..strokeWidth=2; c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*0.04,s.height*0.03,s.width*0.92,s.height*0.62), Radius.circular(8)), wall); List<Offset> wins=[Offset(-0.6,-0.6),Offset(-0.2,-0.6),Offset(0.2,-0.6),Offset(0.6,-0.6),Offset(-0.4,-0.3),Offset(0.0,-0.3),Offset(0.4,-0.3),Offset(-0.6,0.0),Offset(0.6,0.0)]; for(var w in wins){ double x=s.width/2+w.dx*s.width*0.4; double y=s.height*0.33+w.dy*s.height*0.22; Rect rect=Rect.fromCenter(center: Offset(x,y), width:52,height:58); c.drawRect(rect, win); c.drawRect(rect, frame); } } @override bool shouldRepaint(covariant CustomPainter o)=> false; }

// ================= CHESS WITH AI =================
class ChessAI extends StatefulWidget { @override State<ChessAI> createState()=> _ChessAIState(); }
class _ChessAIState extends State<ChessAI> {
  List<String> board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; });
  int? sel; bool whiteTurn=true; String status='Your turn (White)';
  Random r=Random();

  void makeAIMove(){
    if(!whiteTurn){
      Future.delayed(Duration(milliseconds:600), (){
        if(!mounted) return;
        // Find all black pieces
        List<int> blackPieces=[];
        for(int i=0;i<64;i++){ if(board[i]!='' && isBlack(board[i])) blackPieces.add(i); }
        blackPieces.shuffle(r);
        for(int from in blackPieces){
          List<int> moves=getPossibleMoves(from);
          if(moves.isNotEmpty){
            moves.shuffle(r);
            int to=moves[0];
            setState((){
              board[to]=board[from];
              board[from]='';
              whiteTurn=true;
              status='Your turn (White) - AI moved';
              SoundManager.play('coin.mp3');
            });
            return;
          }
        }
        setState(()=> status='AI has no moves! You win!');
      });
    }
  }

  bool isBlack(String p){ return ['♜','♞','♝','♛','♚','♟'].contains(p); }
  bool isWhite(String p){ return ['♖','♘','♗','♕','♔','♙'].contains(p); }

  List<int> getPossibleMoves(int from){
    String piece=board[from];
    if(piece=='') return [];
    List<int> moves=[];
    int row=from~/8, col=from%8;
    // Simplified moves
    if(piece=='♟'){ // black pawn down
      if(row<7 && board[from+8]=='') moves.add(from+8);
      if(row==1 && board[from+8]=='' && board[from+16]=='') moves.add(from+16);
      if(row<7 && col>0 && board[from+7]!='' && isWhite(board[from+7])) moves.add(from+7);
      if(row<7 && col<7 && board[from+9]!='' && isWhite(board[from+9])) moves.add(from+9);
    } else if(piece=='♙'){ // white pawn up
      if(row>0 && board[from-8]=='') moves.add(from-8);
    } else if(piece=='♞' || piece=='♘'){ // knight
      List<List<int>> d=[[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]];
      for(var dd in d){ int nr=row+dd[0], nc=col+dd[1]; if(nr>=0&&nr<8&&nc>=0&&nc<8){ int to=nr*8+nc; if(board[to]=='' || (isBlack(piece) && isWhite(board[to])) || (isWhite(piece) && isBlack(board[to]))) moves.add(to); } }
    } else {
      // for other pieces, allow 1 step any direction (simple)
      for(int dr=-1;dr<=1;dr++){ for(int dc=-1;dc<=1;dc++){ if(dr==0&&dc==0) continue; int nr=row+dr, nc=col+dc; if(nr>=0&&nr<8&&nc>=0&&nc<8){ int to=nr*8+nc; if(board[to]=='' || (isBlack(piece) && isWhite(board[to])) || (isWhite(piece) && isBlack(board[to]))) moves.add(to); } } }
      // rook/bishop/queen extra range simplified as 2 steps
      if(piece=='♜' || piece=='♖' || piece=='♛' || piece=='♕'){
        for(int dir=0;dir<4;dir++){
          int dr=[-1,1,0,0][dir]; int dc=[0,0,-1,1][dir];
          for(int step=2;step<=3;step++){ int nr=row+dr*step, nc=col+dc*step; if(nr<0||nr>=8||nc<0||nc>=8) break; int to=nr*8+nc; if(board[to]=='') moves.add(to); else { if((isBlack(piece) && isWhite(board[to])) || (isWhite(piece) && isBlack(board[to]))) moves.add(to); break; } }
        }
      }
    }
    return moves;
  }

  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFFEFEBE9), appBar: AppBar(title: Text('CHESS AI - '+status), backgroundColor: Colors.brown[700]),
      body: Column(children: [
        Container(padding: EdgeInsets.all(10), color: whiteTurn? Colors.green[100]: Colors.red[100], child: Row(children: [Icon(whiteTurn? Icons.person: Icons.computer), SizedBox(width:8), Text(status, style: TextStyle(fontWeight: FontWeight.bold))])),
        Expanded(child: GridView.builder(padding: EdgeInsets.all(8), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:8), itemCount:64, itemBuilder: (c,i){
          bool w=(i~/8 + i%8)%2==0; bool s=sel==i;
          return GestureDetector(onTap: (){
            if(!whiteTurn) return;
            setState((){
              if(sel==null){
                if(board[i]!='' && isWhite(board[i])){ sel=i; SoundManager.play('click.mp3'); }
              } else {
                List<int> possible=getPossibleMoves(sel!);
                if(possible.contains(i)){
                  board[i]=board[sel!]; board[sel!]=''; sel=null; whiteTurn=false; status='Computer thinking...'; SoundManager.play('coin.mp3');
                  makeAIMove();
                } else if(board[i]!='' && isWhite(board[i])){ sel=i; } else { sel=null; }
              }
            });
          }, child: Container(decoration: BoxDecoration(color: s? Colors.yellow: w? Colors.white: Colors.brown[400], border: sel!=null && getPossibleMoves(sel!).contains(i)? Border.all(color: Colors.green, width:3): null), child: Center(child: Text(board[i], style: TextStyle(fontSize:26, shadows: isWhite(board[i])? [Shadow(color: Colors.black45)]: [])))) );
        })),
        Container(padding: EdgeInsets.all(12), child: Row(children: [ElevatedButton(onPressed: (){ setState((){ board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; }); sel=null; whiteTurn=true; status='Your turn (White)'; }); }, child: Text('NEW GAME')), Spacer(), Text('Tap white, then green dots', style: TextStyle(fontSize:10))]))
      ]),
    );
  }
}
