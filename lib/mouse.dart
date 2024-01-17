import 'package:flutter/material.dart';

class ListenerExample extends StatefulWidget {
  const ListenerExample({super.key});

  @override
  State<ListenerExample> createState() => _ListenerExampleState();
}

class _ListenerExampleState extends State<ListenerExample> {
  double x = 0.0;
  double y = 0.0;

  void _updateLocation(PointerEvent details) {
    setState(() {
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(const Size(300.0, 200.0)),
      child: Listener(
        onPointerMove: _updateLocation,
        child: ColoredBox(
          color: Colors.lightBlueAccent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'The cursor is here: (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
