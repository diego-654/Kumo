import 'package:material_ui/material_ui.dart';

/// Título de sección de los bocetos: etiqueta pequeña, negrita, mayúsculas.
/// Parte de `labelMedium` del tema para que crezca con el tamaño de letra
/// que el usuario eligió en el sistema.
class SectionTitle extends StatelessWidget {
  const new(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
