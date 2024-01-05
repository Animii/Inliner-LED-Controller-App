import 'package:flutter/material.dart';

class HuePicker extends StatefulWidget {
  final ValueChanged<double> onHueChanged;

  const HuePicker({super.key, required this.onHueChanged});
  @override
  _HuePickerState createState() => _HuePickerState();
}

class _HuePickerState extends State<HuePicker> {
  double _huePercentage = 0.0; // Ranges from 0 to 1

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _huePercentage =
              (details.localPosition.dx / context.size!.width).clamp(0.0, 1.0);
          widget.onHueChanged(_huePercentage * 360);
        });
      },
      child: Container(
        height: 20,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 0, 0),
              Color.fromARGB(255, 255, 128, 0),
              Color.fromARGB(255, 255, 255, 0),
              Color.fromARGB(255, 128, 255, 0),
              Color.fromARGB(255, 0, 255, 0),
              Color.fromARGB(255, 0, 255, 128),
              Color.fromARGB(255, 0, 255, 255),
              Color.fromARGB(255, 0, 128, 255),
              Color.fromARGB(255, 0, 0, 255),
              Color.fromARGB(255, 127, 0, 255),
              Color.fromARGB(255, 255, 0, 255),
              Color.fromARGB(255, 255, 0, 127),
            ],
          ),
        ),
        child: CustomPaint(
          painter: _ThumbPainter(_huePercentage),
        ),
      ),
    );
  }
}

class _ThumbPainter extends CustomPainter {
  final double huePercentage;
  _ThumbPainter(this.huePercentage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(
        Offset(huePercentage * size.width, size.height / 2), 15, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
