import 'package:flutter/material.dart';

class PhotoPlaceholder extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF1B1C24),
      child: Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white54),
      ),
    );
  }
}
