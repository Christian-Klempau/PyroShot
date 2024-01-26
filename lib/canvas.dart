import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

enum PaintKind {
  line,
  rect,
}

class MouseEvent {
  final Offset offset;
  final MouseKind kind;

  MouseEvent({required this.offset, required this.kind});
}

class MyCanvas extends StatefulWidget {
  final CapturedData imageData;
  final Color currentColor;
  final PaintKind paintMode;

  const MyCanvas(
      {super.key,
      required this.imageData,
      required this.currentColor,
      required this.paintMode});

  @override
  _MyCanvasState createState() => _MyCanvasState(
      imageData: imageData, currentColor: currentColor, paintMode: paintMode);
}

class _MyCanvasState extends State<MyCanvas> {
  CapturedData imageData;
  Color currentColor;
  PaintKind paintMode;
  late CustomPainter currentPainter;

  final _notifier = ValueNotifier<MouseEvent>(MouseEvent(
    offset: Offset.zero,
    kind: MouseKind.dummy,
  ));

  _MyCanvasState(
      {required this.imageData,
      required this.currentColor,
      required this.paintMode});
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    switch (paintMode) {
      case PaintKind.line:
        currentPainter = PointPainter(notifier: _notifier, color: currentColor);
        break;
      case PaintKind.rect:
        currentPainter =
            RectPainter(notifier: _notifier, color: currentColor);
        break;
    }
  }

  Future<Uint8List> captureImage() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return Uint8List(0);
    }
    Uint8List pngBytes = byteData.buffer.asUint8List();
    // save to disk
    File imgFile = File('/home/chris/Pictures/test.png');
    imgFile.writeAsBytes(pngBytes);
    return pngBytes;
  }

  @override
  Widget build(BuildContext context) {
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
      child: imageData.imagePath != null
          ? Stack(
              key: UniqueKey(),
              children: [
                Image.file(File(imageData.imagePath!)),
                CustomPaint(
                  key: UniqueKey(),
                  painter: currentPainter,
                ),
                Text(paintMode.toString(),
                    style:
                        TextStyle(background: Paint()..color = Colors.white)),
              ],
            )
          : Container(),
    );
  }
}
