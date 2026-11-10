import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

final AudioPlayer player = AudioPlayer();

void playSound() async {
  try {
    await player.play(AssetSource('sounds/click.mp3'));
  } catch(e) {
    HapticFeedback.mediumImpact();
  }
}

void main() => runApp(ZedGamesApp());

class ZedGamesApp extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return MaterialApp(title: 'ZED GAMES', debugShowCheckedModeBanner: false, theme: ThemeData(primarySwatch: Colors.green), home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🇿🇲 ZED GAMES - SOUND + VIBRATE'), backgroundColor: Colors.green[800], centerTitle: true),
      body: GridView.count(crossAxisCount: 2, padding: EdgeInsets.all(16), crossAxisSpacing: 16, mainAxisSpacing: 16, children: [
        gameCard(context, 'TAP\nMASTER', Colors.orange, Icons.touch_app, TapGame()),
        gameCard(context, 'MEMORY\nMATCH', Colors.blue, Icons.memory, MemoryGame()),
        gameCard(context, 'DODGE\nBALLS', Colors.red, Icons.sports_baseball, DodgeGame()),
        gameCard(context, 'SNAKE\nZAMBIA', Colors.green, Icons.games, SnakeGame()),
      ]),
    );
  }
  Widget gameCard(BuildContext ctx, String title, Color c, IconData icon, Widget game) {
    return GestureDetector(onTap: () { HapticFeedback.mediumImpact(); playSound(); Navigator.push(ctx, MaterialPageRoute(builder: (_) => game)); },
      child: Container(decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(20)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 50, color: Colors.white), SizedBox(height: 10), Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))])));
  }
}

class TapGame extends StatefulWidget { @override _TapGameState createState() => _TapGameState(); }
class _TapGameState extends State<TapGame> {
  int score=0; int timeLeft=15; Timer? timer; bool playing=false;
  void start(){ HapticFeedback.heavyImpact(); playSound(); setState((){score=0; timeLeft=15; playing=true;}); timer=Timer.periodic(Duration(seconds: 1),(t){ if(timeLeft>0) setState(()=>timeLeft--); else {t.cancel(); setState(()=>playing=false); HapticFeedback.vibrate();}});}
  void tap(){ if(playing){ HapticFeedback.lightImpact(); playSound(); setState(()=>score++);}}
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('TAP MASTER')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Score: $score', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), Text('Time: $timeLeft', style: TextStyle(fontSize: 24)), SizedBox(height:30), GestureDetector(onTap: tap, child: Container(width:200,height:200,decoration: BoxDecoration(color: playing?Colors.orange:Colors.grey, shape: BoxShape.circle), child: Icon(Icons.touch_app, size:100, color:Colors.white))), SizedBox(height:30), if(!playing) ElevatedButton(onPressed: start, child: Text(score==0?'START TAP!':'PLAY AGAIN'))])));}
}

class MemoryGame extends StatefulWidget { @override _MemoryGameState createState() => _MemoryGameState(); }
class _MemoryGameState extends State<MemoryGame> {
  List<String> emojis=['🐍','🐍','🦁','🦁','🐘','🐘','🦓','🦓']; List<bool> revealed=List.filled(8,false); int first=-1; int pairs=0;
  void click(int i){ if(revealed[i]) return; HapticFeedback.lightImpact(); playSound(); setState(()=>revealed[i]=true); if(first==-1) first=i; else { if(emojis[first]==emojis[i]){HapticFeedback.mediumImpact(); playSound(); pairs++; first=-1; if(pairs==4) HapticFeedback.vibrate();} else {HapticFeedback.heavyImpact(); Future.delayed(Duration(milliseconds:600),(){setState((){revealed[first]=false; revealed[i]=false; first=-1;});});}}}
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('MEMORY - $pairs/4')), body: GridView.builder(padding: EdgeInsets.all(16), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,crossAxisSpacing:10,mainAxisSpacing:10), itemCount:8, itemBuilder: (c,i)=>GestureDetector(onTap: ()=>click(i), child: Container(decoration: BoxDecoration(color: revealed[i]?Colors.blue:Colors.grey[300], borderRadius: BorderRadius.circular(10)), child: Center(child: Text(revealed[i]?emojis[i]:'?', style: TextStyle(fontSize:30)))))));}
}

class DodgeGame extends StatefulWidget { @override _DodgeGameState createState() => _DodgeGameState(); }
class _DodgeGameState extends State<DodgeGame> {
  double playerX=0; List<Map> balls=[]; int score=0; Timer? timer; bool playing=false; Random rnd=Random();
  void start(){ HapticFeedback.heavyImpact(); playSound(); setState((){score=0; playerX=0; balls=[]; playing=true;}); timer=Timer.periodic(Duration(milliseconds:30),(t){ setState((){ if(rnd.nextDouble()<0.08) balls.add({'x': rnd.nextDouble()*2-1, 'y': -1.0}); balls=balls.map((b){b['y']+=0.02; return b;}).where((b)=>b['y']<1.2).toList(); for(var b in balls){ if((b['x']-playerX).abs()<0.15 && (b['y']-0.8).abs()<0.1){playing=false; t.cancel(); HapticFeedback.vibrate();}}}}); }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('DODGE - $score')), body: playing ? GestureDetector(onHorizontalDragUpdate: (d)=>setState(()=>playerX+=d.delta.dx/100), child: Stack(children: [...balls.map((b)=>Align(alignment: Alignment(b['x'], b['y']), child: Container(width:30,height:30,decoration: BoxDecoration(color:Colors.red, shape:BoxShape.circle)))), Align(alignment: Alignment(playerX,0.8), child: Container(width:60,height:60,decoration: BoxDecoration(color:Colors.blue, borderRadius:BorderRadius.circular(10)), child: Icon(Icons.person, color:Colors.white)))])) : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Score: $score', style: TextStyle(fontSize:30)), ElevatedButton(onPressed: start, child: Text(score==0?'START DODGE':'PLAY AGAIN'))])));}
}

class SnakeGame extends StatefulWidget { @override _SnakeGameState createState() => _SnakeGameState(); }
class _SnakeGameState extends State<SnakeGame> {
  List<int> snake=[45,44,43]; int food=80; String dir='right'; int score=0; Timer? timer; bool playing=false;
  void start(){ HapticFeedback.heavyImpact(); playSound(); setState((){snake=[45,44,43]; food=80; dir='right'; score=0; playing=true;}); timer=Timer.periodic(Duration(milliseconds:200),(t){ setState((){ int head=snake.first; if(dir=='right') head+=1; if(dir=='left') head-=1; if(dir=='up') head-=10; if(dir=='down') head+=10; if(head<0||head>=100||snake.contains(head)||(dir=='right'&&head%10==0)||(dir=='left'&&head%10==9)){playing=false; t.cancel(); HapticFeedback.vibrate(); return;} snake.insert(0,head); if(head==food){HapticFeedback.mediumImpact(); playSound(); score+=10; food=Random().nextInt(100);} else snake.removeLast();});});}
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('SNAKE - $score')), body: Column(children: [Expanded(child: GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:10), itemCount:100, itemBuilder: (c,i){ if(snake.contains(i)) return Container(margin: EdgeInsets.all(1), color:Colors.green[800]); if(i==food) return Container(margin: EdgeInsets.all(1), color:Colors.red, child: Icon(Icons.apple, size:15, color:Colors.white)); return Container(margin: EdgeInsets.all(1), color:Colors.green[100]);})), if(playing) Row(mainAxisAlignment: MainAxisAlignment.center, children: [Column(children: [IconButton(icon: Icon(Icons.arrow_upward), onPressed: ()=>dir='up'), Row(children: [IconButton(icon: Icon(Icons.arrow_back), onPressed: ()=>dir='left'), SizedBox(width:40), IconButton(icon: Icon(Icons.arrow_forward), onPressed: ()=>dir='right')]), IconButton(icon: Icon(Icons.arrow_downward), onPressed: ()=>dir='down')])]), if(!playing) Padding(padding: EdgeInsets.all(20), child: ElevatedButton(onPressed: start, child: Text(score==0?'START SNAKE':'PLAY AGAIN')))]));}
}
