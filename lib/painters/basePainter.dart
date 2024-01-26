import 'package:flutter/material.dart';

import '../canvas.dart';

class BasePainter extends CustomPainter {
  ValueNotifier<MouseEvent> repaint;

  BasePainter({required this.repaint}) : super(repaint: repaint);
  void undo() {}

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
