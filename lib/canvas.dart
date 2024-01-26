import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:screen_capturer/screen_capturer.dart';
import 'package:screenflutter/painters/basePainter.dart';
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
  final Function saveCallback;

  const MyCanvas({
    super.key,
    required this.imageData,
    required this.currentColor,
    required this.paintMode,
    required this.saveCallback,
  });

  @override
  _MyCanvasState createState() => _MyCanvasState(
        imageData: imageData,
        currentColor: currentColor,
        paintMode: paintMode,
        saveCallback: saveCallback,
      );
}

class _MyCanvasState extends State<MyCanvas> {
  CapturedData imageData;
  Color currentColor;
  PaintKind paintMode;
  late BasePainter currentPainter;
  Function saveCallback;
  bool canUndo = true;

  final _notifier = ValueNotifier<MouseEvent>(MouseEvent(
    offset: Offset.zero,
    kind: MouseKind.dummy,
  ));

  _MyCanvasState({
    required this.imageData,
    required this.currentColor,
    required this.paintMode,
    required this.saveCallback,
  });
  static GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    RawKeyboard.instance.addListener(onKeyEvent);

    switch (paintMode) {
      case PaintKind.line:
        currentPainter = PointPainter(notifier: _notifier, color: currentColor);
        break;
      case PaintKind.rect:
        currentPainter = RectPainter(notifier: _notifier, color: currentColor);
        break;
    }
  }

  void onKeyEvent(RawKeyEvent event) {
    // Here you have access to the state of CTRL+ALT+SHIFT keys
    bool ctrlPressed = event.isControlPressed;
    bool zPressed = event.isKeyPressed(LogicalKeyboardKey.keyZ);

    if (ctrlPressed && zPressed && canUndo) {
      canUndo = false;
      currentPainter.undo();
      _notifier.value = MouseEvent(
        offset: Offset.infinite,
        kind: MouseKind.dummy,
      );
      resetCanUndo();
    }
  }

  void resetCanUndo() {
    Future.delayed(const Duration(milliseconds: 200), () {
      canUndo = true;
    });
  }

  Future<Uint8List> captureImage() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 20));
      return captureImage();
    }
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return Uint8List(0);
    }
    Uint8List pngBytes = byteData.buffer.asUint8List();
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
                RepaintBoundary(
                  key: globalKey,
                  child: Stack(
                    children: [
                      Image.file(File(imageData.imagePath!)),
                      CustomPaint(
                        key: UniqueKey(),
                        painter: currentPainter,
                      ),
                    ],
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Uint8List pngBytes = await captureImage();
                        saveCallback(pngBytes);
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(currentColor)),
                      child: Text('Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            )
          : Container(),
    );
  }
}
