import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

final AudioPlayer player = AudioPlayer();

Future<void> playSound() async {
  try { await player.play(AssetSource('sounds/click.mp3')); } 
  catch (e) { HapticFeedback.lightImpact(); }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(ZedGamesApp());
}

class ZedGamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'ZED GAMES', debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget { @override _HomeState createState() => _HomeState(); }

class _HomeState extends State<HomeScreen> {
  BannerAd? banner;
  InterstitialAd? interstitial;

  @override
  void initState(){
    super.initState();
    banner = BannerAd(adUnitId: 'ca-app-pub-3940256099942544/6300978111', size: AdSize.banner, request: AdRequest(), listener: BannerAdListener())..load();
    InterstitialAd.load(adUnitId: 'ca-app-pub-3940256099942544/1033173712', request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad)=>interstitial=ad, onAdFailedToLoad: (e)=>print(e)));
  }

  void loadAd(){ InterstitialAd.load(adUnitId: 'ca-app-pub-3940256099942544/1033173712', request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad)=>interstitial=ad, onAdFailedToLoad: (e)=>print(e))); }
  void showAd(){ if(interstitial!=null){ interstitial!.show(); interstitial=null; loadAd(); } }

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('ZED GAMES'), backgroundColor: Colors.green, centerTitle: true),
      body: Column(children:[
        Expanded(child: GridView.count(crossAxisCount: 2, padding: EdgeInsets.all(16), crossAxisSpacing: 16, mainAxisSpacing: 16,
          children: [
            gameBtn(context, 'SUBWAY RUN', Colors.orange, Icons.directions_run, SubwayGame(showAd)),
            gameBtn(context, 'FOOTBALL', Colors.green, Icons.sports_soccer, FootballGame(showAd)),
            gameBtn(context, 'SHOOTING', Colors.red, Icons.gps_fixed, ShootingGame(showAd)),
            gameBtn(context, 'CHESS', Colors.brown, Icons.grid_on, ChessGame()),
          ],
        )),
        if(banner!=null) Container(height: 60, child: AdWidget(ad: banner!)),
      ]),
    );
  }

  Widget gameBtn(BuildContext ctx, String title, Color c, IconData icon, Widget game) {
    return GestureDetector(
      onTap: () { HapticFeedback.mediumImpact(); playSound(); Navigator.push(ctx, MaterialPageRoute(builder: (_) => game)); },
      child: Container(decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(20)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 50, color: Colors.white), SizedBox(height: 8), Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),])),
    );
  }
}

// SUBWAY RUN
class SubwayGame extends StatefulWidget { final Function showAd; SubwayGame(this.showAd); @override _SubwayState createState() => _SubwayState(); }
class _SubwayState extends State<SubwayGame> {
  int lane=1, score=0; double obstacleY=-1; int obstacleLane=1; Timer? timer; bool playing=false; Random rnd=Random();
  void start(){ playSound(); setState((){playing=true; score=0; lane=1;}); timer=Timer.periodic(Duration(milliseconds: 60), (t){ setState((){ obstacleY+=0.02; if(obstacleY>1){ obstacleY=-1; obstacleLane=rnd.nextInt(3); score+=10; playSound(); } if(obstacleY>0.6 && obstacleY<0.9 && obstacleLane==lane){ playing=false; t.cancel(); widget.showAd(); HapticFeedback.vibrate(); } }); }); }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('SUBWAY $score')), body: playing ? GestureDetector(onHorizontalDragEnd: (d){ if(d.velocity.pixelsPerSecond.dx>0 && lane<2){ setState(()=>lane++); playSound(); } if(d.velocity.pixelsPerSecond.dx<0 && lane>0){ setState(()=>lane--); playSound(); } }, child: Stack(children:[ Row(children: List.generate(3, (i)=>Expanded(child: Container(margin: EdgeInsets.all(2), color: lane==i?Colors.grey[300]:Colors.grey[100])))), Align(alignment: Alignment(lane==0?-0.6:lane==1?0:0.6, 0.7), child: Icon(Icons.directions_run, size: 50, color: Colors.blue)), Align(alignment: Alignment(obstacleLane==0?-0.6:obstacleLane==1?0:0.6, obstacleY), child: Container(width:40,height:40,color:Colors.red)), ])) : Center(child: ElevatedButton(onPressed: start, child: Text('START RUN')))); }
}

// FOOTBALL
class FootballGame extends StatefulWidget { final Function showAd; FootballGame(this.showAd); @override _FootballState createState() => _FootballState(); }
class _FootballState extends State<FootballGame> {
  double ballX=0, ballY=0.7; int goals=0; bool kicked=false;
  void kick(double dx){ playSound(); HapticFeedback.mediumImpact(); setState((){ kicked=true; }); Timer.periodic(Duration(milliseconds: 30), (t){ setState((){ ballY-=0.05; ballX+=dx; if(ballY<-1){ if(ballX.abs()<0.3){ goals++; playSound(); HapticFeedback.vibrate(); } else { widget.showAd(); } t.cancel(); ballX=0; ballY=0.7; kicked=false; } }); }); }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('FOOTBALL GOALS $goals')), body: Stack(children:[ Align(alignment: Alignment(0,-0.9), child: Container(width:150,height:60, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 4), color: Colors.black12), child: Text('GOAL', textAlign: TextAlign.center))), Align(alignment: Alignment(ballX, ballY), child: GestureDetector(onPanEnd: (d)=>kick(d.velocity.pixelsPerSecond.dx/1000), child: Container(width:50,height:50,decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all()), child: Icon(Icons.sports_soccer, size: 40)))), if(!kicked) Align(alignment: Alignment(0,0.9), child: Text('SWIPE UP TO SHOOT')), ])); }
}

// SHOOTING
class ShootingGame extends StatefulWidget { final Function showAd; ShootingGame(this.showAd); @override _ShootingState createState() => _ShootingState(); }
class _ShootingState extends State<ShootingGame> {
  List<Offset> enemies=[]; int score=0; Timer? timer; bool playing=false; Random rnd=Random();
  void start(){ playSound(); setState((){playing=true; score=0; enemies=[];}); timer=Timer.periodic(Duration(milliseconds: 800), (t){ setState((){ enemies.add(Offset(rnd.nextDouble(), 0)); }); }); Timer.periodic(Duration(milliseconds: 50), (t){ if(!playing){t.cancel(); return;} setState((){ enemies = enemies.map((e)=>Offset(e.dx, e.dy+0.01)).where((e)=>e.dy<1.2).toList(); if(enemies.length>10){ playing=false; widget.showAd(); } }); }); }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('SHOOTING $score')), body: playing ? GestureDetector(onTapDown: (d){ playSound(); setState((){ for(int i=0;i<enemies.length;i++){ if((enemies[i].dx - d.localPosition.dx/MediaQuery.of(context).size.width).abs()<0.15){ enemies.removeAt(i); score+=10; HapticFeedback.lightImpact(); break; } } }); }, child: Stack(children:[ for(var e in enemies) Align(alignment: Alignment(e.dx*2-1, e.dy*2-1), child: Icon(Icons.bug_report, size: 40, color: Colors.red)), Align(alignment: Alignment(0,0.9), child: Icon(Icons.gps_fixed, size: 60, color: Colors.black)), ])) : Center(child: ElevatedButton(onPressed: start, child: Text('START SHOOTING')))); }
}

// CHESS
class ChessGame extends StatefulWidget { @override _ChessState createState() => _ChessState(); }
class _ChessState extends State<ChessGame> {
  List<List<String>> board=[]; int selR=-1, selC=-1;
  @override void initState(){ super.initState(); reset(); }
  void reset(){ board=[ ['♜','♞','♝','♛','♚','♝','♞','♜'], ['♟','♟','♟','♟','♟','♟','♟','♟'], ['','','','','','','',''], ['','','','','','','',''], ['','','','','','','',''], ['','','','','','','',''], ['♙','♙','♙','♙','♙','♙','♙','♙'], ['♖','♘','♗','♕','♔','♗','♘','♖'] ]; }
  void tap(int r,int c){ playSound(); HapticFeedback.lightImpact(); if(selR==-1){ if(board[r][c]!='') setState((){selR=r; selC=c;}); } else { setState((){ board[r][c]=board[selR][selC]; board[selR][selC]=''; selR=-1; selC=-1; }); } }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('CHESS'), actions: [IconButton(icon: Icon(Icons.refresh), onPressed: (){ playSound(); setState(()=>reset()); })]), body: GridView.builder(padding: EdgeInsets.all(8), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), itemCount: 64, itemBuilder: (c,i){ int r=i~/8, cc=i%8; bool isSel=r==selR && cc==selC; bool dark=(r+cc)%2==1; return GestureDetector(onTap: ()=>tap(r,cc), child: Container(color: isSel?Colors.yellow: dark?Colors.brown[400]:Colors.brown[100], child: Center(child: Text(board[r][cc], style: TextStyle(fontSize: 26))))); })); }
}
