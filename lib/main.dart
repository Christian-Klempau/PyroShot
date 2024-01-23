import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        // asdasdasd
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum AnnotationOption { line, rectangle, oval, text }

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;

  bool _screenshotPermission = false;
  bool _copyToClipboard = true;

  bool showColorPicker = false;
  Color currentColor = Color(0xfff44336);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AnnotationOption selectedOption = AnnotationOption.line; // Default option.

  CapturedData? _lastCapturedData;
  Uint8List? _imageBytesFromClipboard;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _screenshotPermission = await screenCapturer.isAccessAllowed();

    setState(() {});
  }

  String chooseAnnotationType(AnnotationOption option) {
    switch (option) {
      case AnnotationOption.line:
        return 'line';
      case AnnotationOption.rectangle:
        return 'rectangle';
      case AnnotationOption.oval:
        return 'oval';
      case AnnotationOption.text:
        return 'text';
    }
  }

  // Function to handle tapping on the drawer options and update the selected option.
  void _handleDrawerOptionTap(AnnotationOption option) {
    setState(() {
      selectedOption = option;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _openDrawer() {
    print(_scaffoldKey.currentState);
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _minimize() {
    windowManager.minimize();
  }

  void _maximize() {
    windowManager.show();
  }

  void _handleClickCapture(CaptureMode mode) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String imageName =
        'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
    String imagePath = '${directory.path}/$imageName';
    // minimize flutter
    _minimize();
    _lastCapturedData = await screenCapturer.capture(
      mode: mode,
      imagePath: imagePath,
      copyToClipboard: _copyToClipboard,
      silent: true,
    );
    if (_lastCapturedData != null) {
      // ignore: avoid_print
      print('valid screenshot');
    } else {
      // ignore: avoid_print
      // if file in imagePath exists, the screenshot worked
      File file = File(imagePath);
      if (await file.exists()) {
        // ignore: avoid_print
        print('valid screenshot v2');
        _lastCapturedData = CapturedData(
          imagePath: imagePath,
          imageBytes: await file.readAsBytes(),
        );
      } else {
        // ignore: avoid_print
        print('invalid screenshot');
      }
    }
    // mazimize flutter
    _maximize();
    setState(() {
      _lastCapturedData = _lastCapturedData;
    });
  }

  void _updateLocation(PointerEvent details) {
    print("${details.position.dx}, ${details.position.dy}");
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
        // appBar: AppBar(
        //   // TRY THIS: Try changing the color here to a specific color (to
        //   // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        //   // change color while the other colors stay the same.
        //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        //   // Here we take the value from the MyHomePage object that was created by
        //   // the App.build method, and use it to set our appbar title.
        //   title: Text(widget.title),
        // ),
        key: _scaffoldKey,
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(children: [
                _lastCapturedData != null
                    ? MyCanvas(
                        key:UniqueKey(),
                        imageData: _lastCapturedData!,
                        currentColor: currentColor,
                      )
                    : Text('No image captured'),
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
              // ElevatedButton(
              //   onPressed: _openDrawer,
              //   child: const Text('Open End Drawer'),
              // ),
              // ImageAnnotation(
              //   imagePath: '/home/chris/Documents/file.png',
              //   annotationType: chooseAnnotationType(selectedOption),
              // ),
              // Text(_lastCapturedData?.imagePath ?? 'No image captured yet'),
              // _lastCapturedData?.imagePath != null
              //     ? CustomPaint(
              //         painter: PointPainter(),
              //         child: Image.file(File(_lastCapturedData!.imagePath!)),
              //       ) //Image.file(File(_lastCapturedData!.imagePath!))
              //     : CustomPaint(size: Size(1980, 1920), painter: PointPainter()),
              // child: CustomPaint(size: Size(1980, 1920), painter: MyPainter())
            ],
          ),
        ),
        endDrawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.green),
                  accountName: Text('Image Annotation Types'),
                  accountEmail: Text('choose one option'),
                ),
              ),
              ListTile(
                title: Text('Line'),
                onTap: () => _handleDrawerOptionTap(AnnotationOption.line),
                selected: selectedOption == AnnotationOption.line,
              ),
              ListTile(
                title: Text('Rectangular'),
                onTap: () => _handleDrawerOptionTap(AnnotationOption.rectangle),
                selected: selectedOption == AnnotationOption.rectangle,
              ),
              ListTile(
                title: Text('Oval'),
                onTap: () => _handleDrawerOptionTap(AnnotationOption.oval),
                selected: selectedOption == AnnotationOption.oval,
              ),
              ListTile(
                title: Text('Text'),
                onTap: () => _handleDrawerOptionTap(AnnotationOption.text),
                selected: selectedOption == AnnotationOption.text,
              ),
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
                      //action code for button 1
                    },
                    backgroundColor: currentColor,
                    child: Icon(Icons.color_lens), //
                  )), //button first

              Container(
                  margin: EdgeInsets.all(10),
                  child: FloatingActionButton(
                    onPressed: () {
                      //action code for button 2
                    },
                    backgroundColor: Colors.deepPurpleAccent,
                    child: Icon(Icons.brush_outlined),
                  )), // button second

              Container(
                  margin: EdgeInsets.all(10),
                  child: FloatingActionButton(
                    onPressed: () {
                      _handleClickCapture(CaptureMode.window);
                    },
                    backgroundColor: Colors.deepOrangeAccent,
                    child: Icon(Icons.camera),
                  )), // button third

              // Add more buttons here
            ],
          ),
        ]));
  }
}
