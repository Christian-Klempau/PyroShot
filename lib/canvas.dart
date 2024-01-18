import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:screen_capturer/screen_capturer.dart';

class DrawingPoint {
  Offset offset;

  DrawingPoint({required this.offset});
}

class MyCanvas extends StatefulWidget {
  final CapturedData imageData;
  final Color currentColor;

  const MyCanvas(
      {super.key, required this.imageData, required this.currentColor});

  @override
  _MyCanvasState createState() =>
      _MyCanvasState(imageData: imageData, currentColor: currentColor);
}

class _MyCanvasState extends State<MyCanvas> {
  CapturedData imageData;
  Color currentColor;
  final _counter = ValueNotifier<Offset>(Offset.zero);

  _MyCanvasState({required this.imageData, required this.currentColor});

  @override
  Widget build(BuildContext context) {
    PointPainter currentPainter =
        PointPainter(notifier: _counter, color: currentColor);

    return Listener(
      onPointerMove: (event) => {
        _counter.value = event.localPosition,
      },
      onPointerUp: (event) => {
        _counter.value = Offset.zero,
      },
      // child: CustomPaint(
      //   painter: PointPainter(notifier: _counter),
      //   size: Size(1980, 1920),
      //   child: imageData.imagePath != null
      //       ? Image.file(File(imageData.imagePath!))
      //       : Container(),
      child: imageData.imagePath != null
          ? Stack(
              children: [
                Image.file(File(imageData.imagePath!)),
                CustomPaint(
                  painter: currentPainter,
                ),
              ],
            )
          : Container(),
    );
  }
}

void raiseAbstractError() {
  throw Exception('This method must be implemented');
}

class PointPainter extends CustomPainter {
  ValueNotifier<Offset> notifier;
  Color color;

  PointPainter({required this.notifier, required this.color})
      : super(repaint: notifier);

  List<DrawingPoint> points = [];

  @override
  void paint(Canvas canvas, Size size) {
    const pointMode = ui.PointMode.points;

    addPoint(notifier.value);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    // canvas.drawPoints(pointMode, points.map((e) => e.offset).toList(), paint);

    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i].offset;
      final p2 = points[i + 1].offset;

      if (p1 == Offset.zero || p2 == Offset.zero) continue;

      // double xDiff = p2.dx - p1.dx;
      // double yDiff = p2.dy - p1.dy;
      // if (xDiff.abs() < threshold || yDiff.abs() < threshold) {
      //   continue;
      // }
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void addPoint(Offset offset) {
    points.add(DrawingPoint(offset: offset));
  }
}
