import 'package:flutter/material.dart';

/// Interruptor "Compartir en el mapa público".
///
/// `SwitchListTile.adaptive` usa el switch de cada plataforma (Material en
/// Android, Cupertino en iOS) y deja tocar toda la fila, no solo el switch.
class MomentShareField extends StatelessWidget {
  const new({
    required this.isPublic,
    required this.onChanged,
    super.key,
  });

  final bool isPublic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SwitchListTile.adaptive(
      value: isPublic,
      onChanged: onChanged,
      // En iOS el switch es verde por defecto: lo igualamos al de Android.
      activeTrackColor: colors.primary,
      tileColor: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      title: Text(
        'Compartir en el mapa público',
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        'Si lo desactivas, solo lo verás tú.',
        style: textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
