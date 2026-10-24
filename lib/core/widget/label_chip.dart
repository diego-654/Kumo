import 'package:flutter/material.dart';

class LabelChip extends StatelessWidget {
  const new({
    required this.label,
    required this.color,
    this.labelColor,
    super.key,
  });

  final String label;

  /// Color base: el fondo lo usa con transparencia.
  final Color color;

  /// Color del texto. Si es null usa `onSurface` del tema.
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: labelColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
