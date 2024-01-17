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

  const MyCanvas({super.key, required this.imageData});

  @override
  _MyCanvasState createState() => _MyCanvasState(imageData: imageData);
}

class _MyCanvasState extends State<MyCanvas> {
  CapturedData imageData;
  final _counter = ValueNotifier<Offset>(Offset.zero);

  _MyCanvasState({required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) => {
        _counter.value = event.localPosition,
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
                Text(imageData.imagePath!),
                Image.file(File(imageData.imagePath!)),
                CustomPaint(
                  painter: PointPainter(notifier: _counter),
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

class BasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    return;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void addPoint(Offset offset) {
    return;
  }
}

class PointPainter extends CustomPainter {
  ValueNotifier<Offset> notifier;

  PointPainter({required this.notifier}) : super(repaint: notifier);

  final myColor = Colors.red;
  final double threshold = 1;
  List<DrawingPoint> points = [];

  @override
  void paint(Canvas canvas, Size size) {
    const pointMode = ui.PointMode.points;

    addPoint(notifier.value);

    final paint = Paint()
      ..color = myColor
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // canvas.drawPoints(pointMode, points.map((e) => e.offset).toList(), paint);

    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i].offset;
      final p2 = points[i + 1].offset;
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