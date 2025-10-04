// A simple placeholder image for missing service images
import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  final double width;
  final double height;
  const ImagePlaceholder({this.width = 120, this.height = 120, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Icon(Icons.image, size: width * 0.5, color: Colors.grey.shade400),
      ),
    );
  }
}
