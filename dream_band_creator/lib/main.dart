import 'package:dream_band_creator/shake_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter/services.dart';

import 'midi/MidiUtils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tutorials',
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/guitar_cut.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  @override
  initState() {
    _loadSoundFont();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("State: $state");
    _loadSoundFont();
  }

  void _loadSoundFont() async {
    MidiUtils.unmute();
    rootBundle.load("assets/sounds/Guitar.SF2").then((sf2) {
      MidiUtils.prepare(sf2, "Guitar.SF2");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new GestureDetector(
          onPanUpdate: (detail){
            print("its Dragged");
            print("global dx : "+detail.globalPosition.dx.toString());
            print("global dy : "+detail.globalPosition.dy.toString());

            RenderBox box = context.findRenderObject();
            Offset local = box.globalToLocal(detail.globalPosition);

            print("local dx : "+local.dx.toString());
            print("local dy : "+local.dy.toString());
          },
        child: GuitarWidget(),
      )
    );
  }

}

class GuitarWidget extends StatelessWidget {
  static const int amount = 6;

  @override
  Widget build(BuildContext context) {
    return _buildGuitarStringList(context, amount);
  }
}

Widget _buildGuitarStringList(BuildContext context, int stringAmount) {
  final width = MediaQuery.of(context).size.width;
  List<GuitarStringWidget> guitarStringWidgets = [
    GuitarStringWidget(thickness: 4, color: Colors.orangeAccent,  width: width, midi: 40),
    GuitarStringWidget(thickness: 3.5, color: Colors.orangeAccent, width: width, midi: 45),
    GuitarStringWidget(thickness: 3, color: Colors.orangeAccent,  width: width, midi: 50),
    GuitarStringWidget(thickness: 2.5, color: Colors.orangeAccent,  width: width, midi: 55),
    GuitarStringWidget(thickness: 2, color: Colors.white,  width: width, midi: 59),
    GuitarStringWidget(thickness: 1.5, color: Colors.white, width: width, midi: 64)
  ];

  return new Container(
    alignment: FractionalOffset.center,
    child: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(guitarStringWidgets.length, (index) {
        return guitarStringWidgets[index];
      }),
    ),
  );
}

class GuitarStringWidget extends StatefulWidget {

  final double thickness;
  final Color color;
  final double width;
  final int midi;

  const GuitarStringWidget({
    this.thickness = 3,
    this.color = Colors.white,
    this.width,
    this.midi
  });

  @override
  _GuitarStringState createState() {
    return _GuitarStringState();
  }
}

class _GuitarStringState extends State<GuitarStringWidget> with SingleTickerProviderStateMixin{

  ShakeController _shakeController;

  @override
  void initState() {
    _shakeController = ShakeController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ShakeView(
        controller: _shakeController,
        child: new GestureDetector(
            onTap: () {},
            onTapDown: (_) {
              FlutterMidi.playMidiNote(midi: widget.midi);
              _shakeController.shake();
            },
            child: Container(
              width: widget.width,
              height: 20,
              margin: new EdgeInsets.symmetric(vertical: 10),
              child: CustomPaint(
                painter: StringPainter(widget.color, widget.thickness),
              ),
            )));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
}

class StringPainter extends CustomPainter {
  Color _color;
  double _strokeWidth;

  StringPainter(this._color, this._strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = _color
      ..isAntiAlias = true
      ..strokeWidth = _strokeWidth;

    Offset startingPoint = Offset(0, size.height / 2);
    Offset endingPoint = Offset(size.width, size.height / 2);

    canvas.drawLine(startingPoint, endingPoint, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}