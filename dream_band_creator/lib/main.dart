import 'package:dream_band_creator/shake_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter/services.dart';

import 'midi/MidiUtils.dart';
import 'accords.dart';

const sound_font = "Guitar.SF2";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dream Band Creator',
      home: Container(
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {

  Function(List<AccordItem> accordItems) onAccordButtonClicked;

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
    _loadSoundFont();
  }

  void _loadSoundFont() async {
    MidiUtils.unmute();
    rootBundle.load("assets/sounds/Guitar.SF2").then((sf2) {
      MidiUtils.prepare(sf2, sound_font);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        AccordsPanelWidget(),
        Expanded(
            child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/guitar_cut.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: new GestureDetector(
                  onPanUpdate: (detail) {
                  },
                  child: GuitarWidget(widget.onAccordButtonClicked),
                )),
            flex: 2)
      ],
    );
  }
}

class AccordsPanelWidget extends StatelessWidget {

  Function(String) onAccordButtonClicked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(accords.entries.length,(index){
        return Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: RaisedButton(
                onPressed: () {
                  onAccordButtonClicked(accords.entries.elementAt(index).key);
                },
                child: Text(accords.entries.elementAt(index).key, style: TextStyle(fontSize: 20))
            ),
          ),
        );
      }),
    );
  }
}

class GuitarWidget extends StatefulWidget {

  final Function(List<AccordItem> accordItems) onAccordButtonClicked;
  
  GuitarWidget(this.onAccordButtonClicked);

  @override
  State<StatefulWidget> createState() => _GuitarWidgetState();
}

class _GuitarWidgetState extends State<GuitarWidget> {
  
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        _buildGuitarStringList(context),
        Container(
            decoration: new BoxDecoration(
                borderRadius:  BorderRadius.circular(10.0)
            ),
            child: CustomPaint(
                painter: _ClampedAccord(width, height, )
            )
        ),

      ],
    );
  }
}

Widget _buildGuitarStringList(BuildContext context) {
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

class _ClampedAccord extends CustomPainter {

  double _width;
  double _height;

  _ClampedAccord(this._width, this._height);

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(0xff638965).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Offset(_width - 20, 10) & Size(_width - 20, _height - 100), paint1
    );
    _drawTextAt("@", Offset(_width - 20, 10), canvas);
  }

  void _drawTextAt(String text, Offset position, Canvas canvas) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center
    );
    textPainter.layout(minWidth: 0, maxWidth: 0);
    Offset drawPosition = Offset(position.dx, position.dy - (textPainter.height / 2));
    textPainter.paint(canvas, drawPosition);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
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