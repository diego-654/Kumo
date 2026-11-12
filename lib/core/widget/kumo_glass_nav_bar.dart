import 'dart:async' show unawaited;
import 'dart:ui' show ImageFilter;

import 'package:flutter/services.dart' show HapticFeedback;
import 'package:material_ui/material_ui.dart';

/// Un destino de [KumoGlassNavBar]: icono normal, icono activo y texto.
@immutable
class KumoNavDestination {
  const new({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// La acción principal de la app, en el centro de la barra (en Kumo,
/// registrar un momento). No es un destino: no se queda "seleccionada",
/// abre una pantalla encima.
@immutable
class KumoNavAction {
  const new({required this.icon, required this.label, required this.onTap});

  final IconData icon;

  /// No se ve: es lo que anuncia el lector de pantalla y el tooltip.
  final String label;
  final VoidCallback onTap;
}

/// Barra de navegación inferior de Kumo, flotante y con efecto vidrio.
///
/// Cómo se logra el "vidrio", de abajo hacia arriba:
/// 1. `ClipRRect` recorta todo a una píldora. Sin el recorte, el desenfoque
///    se aplicaría a un rectángulo (o a toda la pantalla).
/// 2. `BackdropFilter` desenfoca lo que ya está pintado DETRÁS (el mapa).
/// 3. Un color de superficie semitransparente encima da el tinte y el
///    contraste para que iconos y textos se lean.
/// 4. Un borde fino simula el canto del vidrio.
///
/// Para que el mapa se vea detrás, el `Scaffold` que la usa necesita
/// `extendBody: true`. Así el body ocupa toda la pantalla y recibe la altura
/// de la barra en `MediaQuery.paddingOf(context).bottom`, que las pantallas
/// usan para que su contenido no quede tapado.
///
/// Los colores salen de `colorScheme`, así funciona igual en claro y oscuro.
class KumoGlassNavBar extends StatelessWidget {
  const new({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.centerAction,
    this.visible = true,
    super.key,
  });

  /// Botón destacado en medio de los destinos. Opcional.
  final KumoNavAction? centerAction;

  final List<KumoNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// En `false` la barra baja y sale de la pantalla, para dejar sitio a
  /// una hoja inferior (como hace Apple Maps).
  final bool visible;

  /// Alto de la píldora, sin contar el margen inferior.
  static const double height = 64;

  static const _radius = BorderRadius.all(Radius.circular(height / 2));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    // Accesibilidad: con "Aumentar contraste" activo quitamos la
    // transparencia, porque el texto sobre un fondo que cambia (el mapa)
    // es más difícil de leer.
    final highContrast = MediaQuery.highContrastOf(context);
    final base = isLight
        ? scheme.surfaceContainerLowest
        : scheme.surfaceContainerHigh;
    final glass = highContrast
        ? base
        : base.withValues(alpha: isLight ? 0.72 : 0.64);

    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);

    // AnimatedSlide mueve la barra sin cambiar su tamaño, así el Scaffold
    // no recalcula el layout del body en cada frame. El offset se mide en
    // alturas de la propia barra: 1.0 = justo fuera de la pantalla.
    // IgnorePointer evita tocar una barra que ya no se ve, y ExcludeSemantics
    // que el lector de pantalla la anuncie.
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 1),
          duration: duration,
          curve: visible ? Curves.easeOutCubic : Curves.easeInCubic,
          child: _buildBar(scheme, isLight, glass),
        ),
      ),
    );
  }

  Widget _buildBar(ColorScheme scheme, bool isLight, Color glass) {
    // SafeArea respeta el home indicator de iOS y la barra de gestos de
    // Android; `minimum` deja aire si el equipo no tiene ninguno.
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        // La sombra va FUERA del ClipRRect: si estuviera dentro, el recorte
        // la cortaría y no se vería.
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: _radius,
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: isLight ? 0.10 : 0.30),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: _radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: glass,
                  borderRadius: _radius,
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: SizedBox(
                  height: height,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(children: _buildItems()),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Los destinos, con la acción central (si hay) justo a la mitad.
  List<Widget> _buildItems() {
    final items = <Widget>[
      for (final (i, destination) in destinations.indexed)
        Expanded(
          child: _GlassNavItem(
            destination: destination,
            selected: i == selectedIndex,
            onTap: () => onDestinationSelected(i),
          ),
        ),
    ];
    final action = centerAction;
    if (action != null) {
      items.insert(destinations.length ~/ 2, _GlassNavCenterButton(action));
    }
    return items;
  }
}

/// El botón central: un círculo lleno con el color primario, para que la
/// acción más importante sea la más fácil de encontrar.
class _GlassNavCenterButton extends StatelessWidget {
  const new(this.action);

  final KumoNavAction action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Tooltip(
        message: action.label,
        child: Semantics(
          button: true,
          label: action.label,
          onTap: action.onTap,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: () {
              unawaited(HapticFeedback.lightImpact());
              action.onTap();
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox.square(
                dimension: 52,
                child: Icon(action.icon, color: scheme.onPrimary, size: 26),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Un botón de la barra. El activo lleva una "gota" de color detrás.
class _GlassNavItem extends StatelessWidget {
  const new({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final KumoNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Si el usuario pidió reducir movimiento, los cambios son instantáneos.
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 250);

    final foreground = selected ? scheme.primary : scheme.onSurfaceVariant;

    void handleTap() {
      // El "tic" sutil que da iOS al cambiar de tab.
      unawaited(HapticFeedback.selectionClick());
      onTap();
    }

    // Semantics: el lector de pantalla anuncia "Mapa, botón, seleccionado".
    // excludeSemantics evita que lea también el Icon y el Text sueltos, pero
    // también borra la acción de toque del GestureDetector de abajo; por
    // eso se la volvemos a dar con `onTap`.
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      onTap: handleTap,
      excludeSemantics: true,
      child: GestureDetector(
        // opaque: el toque cuenta en todo el rectángulo, no solo sobre el
        // icono o el texto.
        behavior: HitTestBehavior.opaque,
        onTap: handleTap,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.12)
                : scheme.primary.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                color: foreground,
                size: 24,
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: duration,
                style: theme.textTheme.labelSmall!.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
