import 'package:flutter/material.dart';

class KumoSheetSurface extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F1B1C24), // 12 % del texto
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class KumoSheetHandle extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 8),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFFC9CCDB),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
