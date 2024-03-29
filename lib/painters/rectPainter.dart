import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:screenflutter/painters/basePainter.dart';

import '../canvas.dart';

class MyRect {
  Offset topLeft;
  Offset bottomRight;
  Color color;

  MyRect(
      {required this.color, required this.topLeft, required this.bottomRight});
}

class RectPainter extends BasePainter {
  ValueNotifier<MouseEvent> notifier;
  Color color;

  RectPainter({required this.notifier, required this.color})
      : super(repaint: notifier);

  List<MyRect> rects = [];

  @override
  void paint(Canvas canvas, Size size) {
    processEvent(notifier.value);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < rects.length; i++) {
      final p1 = rects[i].topLeft;
      final p2 = rects[i].bottomRight;

      if (p1 == Offset.infinite || p2 == Offset.infinite) continue;

      canvas.drawRect(Rect.fromPoints(p1, p2), paint);
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
      rects.add(MyRect(
          color: color, topLeft: event.offset, bottomRight: event.offset));
    } else if (event.kind == MouseKind.move) {
      if (rects.isEmpty) {
        rects.add(MyRect(
            color: color, topLeft: event.offset, bottomRight: event.offset));
      }
      if (rects.last.bottomRight == Offset.infinite) {
        rects.last.bottomRight = event.offset;
      }
      rects.last.topLeft = event.offset;
    } else if (event.kind == MouseKind.up) {
      if (rects.isNotEmpty) {
        rects.last.topLeft = event.offset;
      }
      rects.add(MyRect(
          color: color,
          topLeft: Offset.infinite,
          bottomRight: Offset.infinite));
    }
  }

  @override
  void undo() {
    if (rects.isNotEmpty) {
      rects.removeLast();
      if (rects.isNotEmpty) {
        rects.removeLast();
      }
      rects.add(MyRect(
          color: color,
          topLeft: Offset.infinite,
          bottomRight: Offset.infinite));
    }
  }
}
