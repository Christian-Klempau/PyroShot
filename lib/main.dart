import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:process_run/shell_run.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_annotation/image_annotation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenflutter/canvas.dart';
import 'package:screenflutter/mouse.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum AnnotationOption { line, rectangle, oval, text }

class _MyHomePageState extends State<MyHomePage> {
  bool _screenshotPermission = false;
  bool _copyToClipboard = true;

  bool showColorPicker = false;
  ValueNotifier<bool> screenshotRequested = ValueNotifier<bool>(false);
  Color currentColor = Color(0xfff44336);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PaintKind annotationOption = PaintKind.line; // Default option.

  CapturedData? _lastCapturedData;
  Uint8List? _imageBytesFromClipboard;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _screenshotPermission = await screenCapturer.isAccessAllowed();
    _fullscreen();

    setState(() {});
  }

  void _minimize() {
    windowManager.minimize();
  }

  void _maximize() {
    windowManager.show();
  }

  void _fullscreen() {
    windowManager.setFullScreen(true);
  }

  void _handleClickCapture(CaptureMode mode) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String imageName =
        'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
    String imagePath = '${directory.path}/$imageName';
    _minimize();
    _lastCapturedData = await screenCapturer.capture(
      mode: mode,
      imagePath: imagePath,
      copyToClipboard: _copyToClipboard,
      silent: true,
    );
    if (_lastCapturedData != null) {
      print('valid screenshot');
    } else {
      // if file in imagePath exists, the screenshot worked
      File file = File(imagePath);
      if (await file.exists()) {
        print('valid screenshot v2');
        _lastCapturedData = CapturedData(
          imagePath: imagePath,
          imageBytes: await file.readAsBytes(),
        );
      } else {
        print('invalid screenshot');
      }
    }
    _maximize();
    setState(() {
      _lastCapturedData = _lastCapturedData;
    });
  }

  void _updateLocation(PointerEvent details) {
    print("${details.position.dx}, ${details.position.dy}");
  }

  Future<void> handleScreenshot(Uint8List pngBytes) async {
    // save to disk
        Directory directory = await getApplicationDocumentsDirectory();
    String imageName =
        'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
    String imagePath = '${directory.path}/$imageName';
    File imgFile = File(imagePath);
    imgFile.writeAsBytes(pngBytes);
    print('save to disk');
    if (_copyToClipboard) {
      // execute shell command
      var shell = Shell();
      shell.run('xclip -selection clipboard -t image/png -i ${imagePath}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color.fromARGB(255, 48, 48, 48),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(children: [
                _lastCapturedData != null
                    ? MyCanvas(
                        key: UniqueKey(),
                        imageData: _lastCapturedData!,
                        saveCallback: handleScreenshot,
                        currentColor: currentColor,
                        paintMode: annotationOption,
                      )
                    : Text(
                        'No image captured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                Visibility(
                    visible: showColorPicker,
                    child: BlockPicker(
                      pickerColor: Colors.red, //default color
                      onColorChanged: (Color color) {
                        //on the color picked
                        setState(() {
                          currentColor = color;
                          showColorPicker = false;
                        });
                      },
                    )),
              ])
            ],
          ),
        ),
        floatingActionButton: Stack(children: [
          Wrap(
            //will break to another line on overflow
            direction: Axis.horizontal, //use vertical to show  on vertical axis
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(10),
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        showColorPicker = !showColorPicker;
                      });
                    },
                    backgroundColor: currentColor,
                    child: Icon(
                      Icons.color_lens,
                      size: 28,
                      color: Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  )),
              Container(
                  margin: EdgeInsets.all(10),
                  child: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: currentColor,
                      child: Icon(Icons.save),
                      shape: RoundedRectangleBorder(
                          side: BorderSide(width: 4, color: currentColor),
                          borderRadius: BorderRadius.circular(100)) //
                      )), //button first
              Container(
                  margin: EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            annotationOption = PaintKind.line;
                          });
                        },
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.brush_outlined,
                          size: 30,
                          color: Colors.white,
                        ),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 4,
                                color: annotationOption == PaintKind.line
                                    ? currentColor
                                    : Colors.black),
                            borderRadius: BorderRadius.circular(100)),
                      ),
                    ],
                  )),
              Container(
                  margin: EdgeInsets.all(10),
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        annotationOption = PaintKind.rect;
                      });
                    },
                    backgroundColor: Colors.black,
                    child: Icon(
                      Icons.square,
                      size: 25,
                      color: Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: 4,
                            color: annotationOption == PaintKind.rect
                                ? currentColor
                                : Colors.black),
                        borderRadius: BorderRadius.circular(100)),
                  )),

              Container(
                  margin: EdgeInsets.all(10),
                  child: FloatingActionButton(
                    onPressed: () {
                      _handleClickCapture(CaptureMode.window);
                    },
                    backgroundColor: currentColor,
                    child: Icon(
                      Icons.camera,
                      size: 30,
                      color: Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(width: 3, color: currentColor),
                        borderRadius: BorderRadius.circular(100)),
                  )),
            ],
          ),
        ]));
  }
}
