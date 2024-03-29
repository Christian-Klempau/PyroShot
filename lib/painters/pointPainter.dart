import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:screenflutter/painters/basePainter.dart';

import '../canvas.dart';

class Stroke {
  List<Offset> points = [];
  Color color;

  Stroke({required this.color});
}

class PointPainter extends BasePainter {
  ValueNotifier<MouseEvent> notifier;
  Color color;

  PointPainter({required this.notifier, required this.color})
      : super(repaint: notifier);

  List<Stroke> strokes = [];

  @override
  void paint(Canvas canvas, Size size) {
    processEvent(notifier.value);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < strokes.length; i++) {
      for (var j = 0; j < strokes[i].points.length - 1; j++) {
        final p1 = strokes[i].points[j];
        final p2 = strokes[i].points[j + 1];

        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BasePainter oldDelegate) {
    return true;
  }

  void processEvent(MouseEvent event) {
    if (event.kind == MouseKind.dummy) {
      return;
    } else if (event.kind == MouseKind.down) {
      strokes.add(Stroke(color: color));
      strokes.last.points.add(event.offset);
    } else if (event.kind == MouseKind.move) {
      if (strokes.isEmpty) {
        strokes.add(Stroke(color: color));
      }
      strokes.last.points.add(event.offset);
    } else if (event.kind == MouseKind.up) {
      strokes.last.points.add(event.offset);
      strokes.add(Stroke(color: color));
    }
  }

  @override
  void undo() {
    if (strokes.isNotEmpty) {
      strokes.removeLast();
      if (strokes.isNotEmpty) {
        strokes.removeLast();
      }
      strokes.add(Stroke(color: color));
    }
  }
}
