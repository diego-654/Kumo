import 'package:flutter/material.dart';

/// Sección "Lugar" del formulario.
///
/// Muestra el lugar elegido (o sugerido por GPS) y un botón para cambiarlo.
/// Solo dibuja y avisa con [onChange]: buscar el lugar es cosa de afuera.
class MomentPlaceField extends StatelessWidget {
  const new({
    required this.placeName,
    required this.onChange,
    this.detail,
    super.key,
  });

  final String placeName;

  /// Línea secundaria, por ejemplo "Restaurante · a 120 m".
  final String? detail;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final hasPlace = placeName.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          'Lugar',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            spacing: 12,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.location_on,
                    size: 22,
                    color: colors.primary,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      hasPlace ? placeName : 'Sin lugar todavía',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      detail ?? 'Elige dónde estás',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onChange,
                child: Text(hasPlace ? 'Cambiar' : 'Elegir'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
