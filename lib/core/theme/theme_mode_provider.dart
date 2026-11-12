import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Dónde se guarda la preferencia de tema (Sistema / Claro / Oscuro).
///
/// Es una interfaz a propósito: hoy usamos [InMemoryThemeModeStore] y,
/// cuando llegue la pantalla de Ajustes, se cambia por una implementación
/// que persista (p. ej. con `shared_preferences`) sin tocar el notifier
/// ni la UI. Solo se sobreescribe [themeModeStoreProvider].
abstract interface class ThemeModeStore {
  /// La preferencia guardada, o `null` si el usuario nunca eligió.
  ThemeMode? read();

  Future<void> write(ThemeMode mode);
}

/// Guarda en memoria: se pierde al cerrar la app. Suficiente mientras no
/// exista la opción en Ajustes.
class InMemoryThemeModeStore implements ThemeModeStore {
  ThemeMode? _mode;

  @override
  ThemeMode? read() => _mode;

  @override
  Future<void> write(ThemeMode mode) async => _mode = mode;
}

final themeModeStoreProvider = Provider<ThemeModeStore>(
  (ref) => InMemoryThemeModeStore(),
);

/// Tema activo de la app. Por defecto, claro: es el diseño original de
/// Kumo. El usuario podrá cambiarlo a Sistema u Oscuro desde Ajustes.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const ThemeMode defaultMode = ThemeMode.light;

  @override
  ThemeMode build() => ref.watch(themeModeStoreProvider).read() ?? defaultMode;

  ThemeMode get mode => state;

  /// Uso desde Ajustes: `ref.read(themeModeProvider.notifier).mode = x`.
  set mode(ThemeMode mode) {
    state = mode;
    // Sin await: la UI cambia al instante y el guardado va en segundo plano.
    ref.read(themeModeStoreProvider).write(mode).ignore();
  }
}
