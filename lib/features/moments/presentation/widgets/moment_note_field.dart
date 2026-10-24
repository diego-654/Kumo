import 'package:flutter/material.dart';

/// Sección "¿Cómo te sientes aquí?" del formulario.
///
/// El estilo del campo viene de `inputDecorationTheme` en `AppTheme`.
class MomentNoteField extends StatelessWidget {
  const new({
    required this.initialValue,
    required this.minLength,
    required this.onChanged,
    super.key,
  });

  /// Texto inicial (al editar). Solo se lee al crear el campo.
  final String initialValue;
  final int minLength;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          '¿Cómo te sientes aquí?',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          minLines: 4,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          style: textTheme.bodyLarge,
          decoration: const InputDecoration(
            hintText:
                'Cuéntalo con tus palabras: qué ves, qué te recuerda, '
                'cómo te hace sentir',
          ),
        ),
        Text(
          'La IA leerá este texto para detectar la emoción. '
          'Mínimo $minLength caracteres.',
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
