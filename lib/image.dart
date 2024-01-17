import 'package:flutter/material.dart';

class Image extends StatefulWidget {
  final String imagePath;
  const Image({
    super.key,
    required this.imagePath,
  });

  @override
  State<Image> createState() => _ImageState();
}

class _ImageState extends State<Image> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
