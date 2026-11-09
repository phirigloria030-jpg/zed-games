) async { try{ await player.play(AssetSource('sounds/punch.mp3')); }catch(e){} }
}

// 1. SHOOTER
class ShooterGame extends StatefulWidget{ @override _ShooterGameState createState()=> _ShooterGameState(); }
class _ShooterGameState extends State<ShooterGame>{
  double gunX = 0; List<Offset> bullets=[]; List<Offset> enemies=[]; int score=0; Timer? timer;
  @override void initState(){ super.initState(); enemies=List.generate(5, (i)=> Offset(Random().nextDouble()*300, Random().nextDouble()*200)); timer=Timer.periodic(Duration(milliseconds: 50), (t){ setState((){ bullets=bullets.map((b)=> Offset(b.dx, b.dy-10)).where((b)=> b.dy>0).toList(); for(var b in bullets){ enemies.removeWhere((e){ if((b-e).distance<30){ score++; SoundManager.playBoom(); return true;} return false; }); } if(enemies.length<5) enemies.add(Offset(Random().nextDouble()*300, 0)); }); }); }
  @override void dispose(){ timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: Text('Shooter Score: $score')), body: GestureDetector(onTapDown: (d){ setState(()=> bullets.add(Offset(d.localPosition.dx, MediaQuery.of(c).size.height-100))); SoundManager.playShoot(); }, onPanUpdate: (d){ setState(()=> gunX=d.localPosition.dx); }, child: Stack(children: 
