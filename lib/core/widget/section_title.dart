import 'package:material_ui/material_ui.dart';

/// Título de sección de los bocetos: 13 px, negrita, mayúsculas.
class SectionTitle extends StatelessWidget {
  const new(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Color(0xFF3C3F4E),
      ),
    );
  }
}
