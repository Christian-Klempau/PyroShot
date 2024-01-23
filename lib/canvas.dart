import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:screen_capturer/screen_capturer.dart';
import 'package:screenflutter/painters/rectPainter.dart';

import 'painters/pointPainter.dart';

enum MouseKind {
  dummy,
  move,
  down,
  up,
}

class MouseEvent {
  final Offset offset;
  final MouseKind kind;

  MouseEvent({required this.offset, required this.kind});
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
  final _notifier = ValueNotifier<MouseEvent>(MouseEvent(
    offset: Offset.zero,
    kind: MouseKind.dummy,
  ));
  late RectPainter currentPainter;

  _MyCanvasState({required this.imageData, required this.currentColor});

  @override
  void initState() {
    super.initState();
    currentPainter = RectPainter(notifier: _notifier, color: currentColor);
  }

  @override
  Widget build(BuildContext context) {
    print("BUILDING");
    return Listener(
      onPointerMove: (event) => {
        _notifier.value = MouseEvent(
          offset: event.localPosition,
          kind: MouseKind.move,
        ),
      },
      onPointerDown: (event) => {
        _notifier.value = MouseEvent(
          offset: event.localPosition,
          kind: MouseKind.down,
        ),
      },
      onPointerUp: (event) => {
        _notifier.value = MouseEvent(
          offset: event.localPosition,
          kind: MouseKind.up,
        ),
      },
      // child: CustomPaint(
      //   painter: PointPainter(notifier: _notifier),
      //   size: Size(1980, 1920),
      //   child: imageData.imagePath != null
      //       ? Image.file(File(imageData.imagePath!))
      //       : Container(),
      child: imageData.imagePath != null
          ? Stack(
              children: [
                Image.file(File(imageData.imagePath!)),
                CustomPaint(
                  key: UniqueKey(),
                  painter: currentPainter,
                ),
              ],
            )
          : Container(),
    );
  }
}
