
// import 'package:dream_band_creator/shake_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:vector_math/vector_math_64.dart' as vector_math;

import 'midi/MidiUtils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tutorials',
      home: HomeScreen(),
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
  Widget build(BuildContext context) => GuitarWidget();

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
    GuitarStringWidget(thickness: 4, color: Colors.orangeAccent,  width: width),
    GuitarStringWidget(thickness: 3.5, color: Colors.orangeAccent, width: width),
    GuitarStringWidget(thickness: 3, color: Colors.orangeAccent,  width: width),
    GuitarStringWidget(thickness: 2.5, color: Colors.orangeAccent,  width: width),
    GuitarStringWidget(thickness: 2, color: Colors.white,  width: width),
    GuitarStringWidget(thickness: 1.5, color: Colors.white, width: width)
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

  const GuitarStringWidget({
    this.thickness = 3,
    this.color = Colors.white,
    this.width,
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
    // FlutterMidi.unmute();
    // rootBundle.load("assets/sounds/Piano.SF2").then((sf2) {
    //   FlutterMidi.prepare(sf2: sf2, name: "Piano.SF2");
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ShakeView(
        controller: _shakeController,
        child: new GestureDetector(
            onTap: () {
                print("11111");
                FlutterMidi.playMidiNote(midi: 60);
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

class ShakeView extends StatelessWidget {
  final Widget child;
  final ShakeController controller;
  final Animation _anim;

  ShakeView({@required this.child, @required this.controller})
      : _anim = Tween<double>(begin: 50, end: 120).animate(controller);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (context, child) => Transform(
          child: child,
          transform: Matrix4.translation(_shake(_anim.value)),
        ));
  }

  vector_math.Vector3 _shake(double progress) {
    double offset = sin(progress * pi * 10.0);
    return vector_math.Vector3(0.0, offset * 4, 0.0);
  }
}

class ShakeController extends AnimationController {
  ShakeController(
      {@required TickerProvider vsync,
        Duration duration = const Duration(milliseconds: 200)})
      : super(vsync: vsync, duration: duration);

  shake() async {
    if (status == AnimationStatus.completed) {
      await this.reverse();
    } else {
      await this.forward();
    }
  }
}

