import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(ZedGamesApp());

class SoundManager {
  static final AudioPlayer player = AudioPlayer();
  static void playClick() async {
    try { await player.play(AssetSource('sounds/click.mp3')); } catch(e) { print('no sound file yet'); }
  }
  static void playCoin() async {
    try { await player.play(AssetSource('sounds/coin.mp3')); } catch(e) {}
  }
  static void playShoot() async {
    try { await player.play(AssetSource('sounds/shoot.mp3')); } catch(e) {}
  }
}

class ZedGamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZED GAMES ZAMBIA V2 AUDIO',
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
            SizedBox(height: 30),
            Text('ZED GAMES', style: TextStyle(color: Colors.yellow, fontSize: 36, fontWeight: FontWeight.w900)),
            Text('ZAMBIA V2 🔊 AUDIO', style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 3)),
            Spacer(),
            MenuButton(title: 'SUBWAY RUN', color: Color(0xFF2196F3), icon: Icons.directions_run, onTap: (){ SoundManager.playClick(); Navigator.push(context, MaterialPageRoute(builder: (_) => SubwayPro())); }),
            MenuButton(title: 'CHESS MASTER', color: Color(0xFF795548), icon: Icons.apps, onTap: (){ SoundManager.playClick(); Navigator.push(context, MaterialPageRoute(builder: (_) => ChessPro())); }),
            MenuButton(title: 'PENALTY KICK', color: Color(0xFF4CAF50), icon: Icons.sports_soccer, onTap: (){ SoundManager.playClick(); Navigator.push(context, MaterialPageRoute(builder: (_) => FootballPro())); }),
            MenuButton(title: 'TARGET SHOOT', color: Color(0xFFF44336), icon: Icons.gps_fixed, onTap: (){ SoundManager.playClick(); Navigator.push(context, MaterialPageRoute(builder: (_) => ShootingPro())); }),
            Spacer(),
            Text('AUDIO ENABLED - Add mp3 to assets/sounds/', style: TextStyle(color: Colors.white54, fontSize: 10)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String title; final Color color; final IconData icon; final VoidCallback onTap;
  MenuButton({required this.title, required this.color, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
          child: Row(children: [Icon(icon, color: Colors.white), SizedBox(width: 15), Text(title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Spacer(), Icon(Icons.volume_up, color: Colors.white70)]),
        ),
      ),
    );
  }
}

// SUBWAY WITH SOUND
class SubwayPro extends StatefulWidget { @override _SubwayProState createState() => _SubwayProState(); }
class _SubwayProState extends State<SubwayPro> {
  int lane=1; double obstacleY=-1; int obstacleLane=0; double coinY=-2; int coinLane=1; int score=0, coins=0; Timer? timer; bool gameOver=false;
  @override void initState(){ super.initState(); timer=Timer.periodic(Duration(milliseconds: 30), (t){ if(gameOver) return; setState((){ obstacleY+=0.02; coinY+=0.02; if(obstacleY>1.2){ obstacleY=-1.2; obstacleLane=Random().nextInt(3); score+=10; } if(coinY>1.2){ coinY=-1.5; coinLane=Random().nextInt(3); } if(obstacleY>0.5 && obstacleY<0.9 && obstacleLane==lane){ gameOver=true; SoundManager.playShoot(); } if(coinY>0.5 && coinY<0.9 && coinLane==lane){ coins++; coinY=-1.5; coinLane=Random().nextInt(3); score+=50; SoundManager.playCoin(); } }); }); }
  @override void dispose(){ timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Colors.black, appBar: AppBar(title: Text('SCORE: $score COINS: $coins'), backgroundColor: Colors.blue[900]), body: gameOver? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('GAME OVER!', style: TextStyle(color: Colors.white, fontSize: 32)), ElevatedButton(onPressed: (){ setState((){ gameOver=false; score=0; coins=0; obstacleY=-1; coinY=-2;}); }, child: Text('RESTART'))])): Column(children: [Expanded(child: Row(children: List.generate(3, (l){ bool isPlayer=l==lane; bool isObs=l==obstacleLane && obstacleY>-1 && obstacleY<1; bool isCoin=l==coinLane && coinY>-1 && coinY<1; return Expanded(child: Container(margin: EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey[800], border: Border.all(color: isPlayer? Colors.yellow: Colors.transparent, width: 2)), child: Stack(children: [if(isObs) Positioned(top: MediaQuery.of(context).size.height*(obstacleY+1)/2, left: 0, right: 0, child: Container(height: 60, color: Colors.red, child: Icon(Icons.train, color: Colors.white))), if(isCoin) Positioned(top: MediaQuery.of(context).size.height*(coinY+1)/2, left: 0, right: 0, child: Icon(Icons.monetization_on, color: Colors.yellow, size: 40)), if(isPlayer) Align(alignment: Alignment(0, 0.7), child: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.person, color: Colors.white)))]))); }))), Container(padding: EdgeInsets.all(20), color: Colors.grey[900], child: Row(children: [Expanded(child: ElevatedButton(onPressed: (){ if(lane>0) setState(()=> lane--); SoundManager.playClick(); }, child: Text('◀ LEFT'))), SizedBox(width: 10), Expanded(child: ElevatedButton(onPressed: (){ if(lane<2) setState(()=> lane++); SoundManager.playClick(); }, child: Text('RIGHT ▶')))]))])) ;}
}

// FOOTBALL WITH SOUND
class FootballPro extends StatefulWidget { @override _FootballProState createState() => _FootballProState(); }
class _FootballProState extends State<FootballPro> with SingleTickerProviderStateMixin {
  double ballX=0, ballY=0.6, keeperX=0; int goals=0, saves=0; bool kicking=false; late AnimationController keeperCtrl;
  @override void initState(){ super.initState(); keeperCtrl=AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true); keeperCtrl.addListener(()=> setState(()=> keeperX=sin(keeperCtrl.value*pi*2)*0.7)); }
  void kick(double dx){ if(kicking) return; setState((){ kicking=true; ballX=dx; ballY=-0.6; SoundManager.playShoot(); }); Future.delayed(Duration(milliseconds: 600), (){ setState((){ if((ballX-keeperX).abs()>0.3){ goals++; SoundManager.playCoin(); } else saves++; ballY=0.6; ballX=0; kicking=false; }); }); }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFF2E7D32), appBar: AppBar(title: Text('GOALS: $goals SAVES: $saves'), backgroundColor: Colors.green[900]), body: Column(children: [Expanded(flex: 3, child: Stack(children: [Align(alignment: Alignment(0, -0.8), child: Container(width: 250, height: 10, color: Colors.white)), Align(alignment: Alignment(keeperX, -0.6), child: Text('🧤', style: TextStyle(fontSize: 50))), AnimatedAlign(duration: Duration(milliseconds: 600), alignment: Alignment(ballX, ballY), child: Text('⚽', style: TextStyle(fontSize: 40)))])), Expanded(flex: 2, child: Container(color: Colors.black87, child: Row(children: [Expanded(child: GestureDetector(onTap: ()=> kick(-0.8), child: Container(color: Colors.white10, child: Center(child: Text('LEFT', style: TextStyle(color: Colors.white)))))), Expanded(child: GestureDetector(onTap: ()=> kick(0), child: Container(color: Colors.white24, child: Center(child: Text('CENTER', style: TextStyle(color: Colors.white)))))), Expanded(child: GestureDetector(onTap: ()=> kick(0.8), child: Container(color: Colors.white10, child: Center(child: Text('RIGHT', style: TextStyle(color: Colors.white))))))])))])); }
}

// SHOOTING WITH SOUND
class ShootingPro extends StatefulWidget { @override _ShootingProState createState() => _ShootingProState(); }
class _ShootingProState extends State<ShootingPro> {
  List<Offset> targets=[Offset(0.2,0.3), Offset(0.7,0.5), Offset(0.4,0.7)]; int score=0, timeLeft=30; Timer? timer; Random r=Random();
  @override void initState(){ super.initState(); timer=Timer.periodic(Duration(seconds: 1), (t){ setState(()=> timeLeft--); if(timeLeft<=0) t.cancel(); }); }
  @override void dispose(){ timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Colors.black, appBar: AppBar(title: Text('SCORE: $score TIME: $timeLeft'), backgroundColor: Colors.red[900]), body: timeLeft<=0? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('TIME UP!', style: TextStyle(color: Colors.white, fontSize: 40)), Text('Final: $score', style: TextStyle(color: Colors.yellow, fontSize: 30)), ElevatedButton(onPressed: ()=> Navigator.pop(context), child: Text('MENU'))])): GestureDetector(onTapDown: (d){ setState((){ for(int i=0;i<targets.length;i++){ Offset pos=Offset(targets[i].dx*MediaQuery.of(context).size.width, targets[i].dy*MediaQuery.of(context).size.height); if((pos-d.localPosition).distance<40){ score+=10; targets[i]=Offset(r.nextDouble()*0.8+0.1, r.nextDouble()*0.6+0.2); SoundManager.playShoot(); } } }); }, child: Stack(children: targets.map((t)=> Positioned(left: t.dx*MediaQuery.of(context).size.width-25, top: t.dy*MediaQuery.of(context).size.height-25, child: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)), child: Icon(Icons.adjust, color: Colors.white)))).toList()))); }
}

// CHESS
class ChessPro extends StatefulWidget { @override _ChessProState createState() => _ChessProState(); }
class _ChessProState extends State<ChessPro> {
  List<String> board=List.generate(64, (i){ if(i<16) return i<8? '♜♞♝♛♚♝♞♜'[i]: '♟'; if(i>47) return i>55? '♖♘♗♕♔♗♘♖'[i-56]: '♙'; return ''; }); int? selected;
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFEFEBE9), appBar: AppBar(title: Text('CHESS - Tap to Move'), backgroundColor: Colors.brown[700]), body: Column(children: [Expanded(child: GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), itemCount: 64, itemBuilder: (c,i){ bool isWhite=(i~/8 + i%8)%2==0; bool isSel=selected==i; return GestureDetector(onTap: (){ setState((){ if(selected==null && board[i]!=''){ selected=i; SoundManager.playClick(); } else if(selected!=null){ board[i]=board[selected!]; board[selected!]=''; selected=null; SoundManager.playCoin(); } }); }, child: Container(decoration: BoxDecoration(color: isSel? Colors.yellow: isWhite? Colors.white: Colors.brown[400]), child: Center(child: Text(board[i], style: TextStyle(fontSize: 28))))); })), Padding(padding: EdgeInsets.all(10), child: Text(selected!=null? 'Selected - Now tap square': 'Tap a piece'))])); }
}
