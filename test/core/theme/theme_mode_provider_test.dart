import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kumo/core/theme/theme_mode_provider.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('arranca en claro si el usuario nunca eligió', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('cambiar el modo actualiza el estado y lo guarda', () {
    final store = InMemoryThemeModeStore();
    final container = ProviderContainer(
      overrides: [themeModeStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    container.read(themeModeProvider.notifier).mode = ThemeMode.dark;

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(store.read(), ThemeMode.dark);
  });

  test('respeta la preferencia guardada al arrancar', () async {
    final store = InMemoryThemeModeStore();
    await store.write(ThemeMode.system);
    final container = ProviderContainer(
      overrides: [themeModeStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);
  });
}
