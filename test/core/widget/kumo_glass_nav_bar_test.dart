import 'package:flutter_test/flutter_test.dart';
import 'package:kumo/core/theme/app_theme.dart';
import 'package:kumo/core/widget/kumo_glass_nav_bar.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const destinations = [
    KumoNavDestination(
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      label: 'Mapa',
    ),
    KumoNavDestination(
      icon: Icons.photo_library_outlined,
      selectedIcon: Icons.photo_library,
      label: 'Momentos',
    ),
  ];

  Future<void> pumpBar(
    WidgetTester tester, {
    required int selectedIndex,
    ValueChanged<int>? onSelected,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          extendBody: true,
          bottomNavigationBar: KumoGlassNavBar(
            destinations: destinations,
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('el activo muestra su icono relleno', (tester) async {
    await pumpBar(tester, selectedIndex: 0);

    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
  });

  testWidgets('tocar un destino avisa su índice', (tester) async {
    int? tapped;
    await pumpBar(tester, selectedIndex: 0, onSelected: (i) => tapped = i);

    await tester.tap(find.text('Momentos'));

    expect(tapped, 1);
  });

  testWidgets('la acción central va en medio y avisa al tocarla', (
    tester,
  ) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: KumoGlassNavBar(
            destinations: destinations,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            centerAction: KumoNavAction(
              icon: Icons.photo_camera,
              label: 'Registrar un momento',
              onTap: () => pressed = true,
            ),
          ),
        ),
      ),
    );

    final mapX = tester.getCenter(find.text('Mapa')).dx;
    final cameraX = tester.getCenter(find.byIcon(Icons.photo_camera)).dx;
    final momentsX = tester.getCenter(find.text('Momentos')).dx;
    expect(cameraX, greaterThan(mapX));
    expect(cameraX, lessThan(momentsX));

    await tester.tap(find.byIcon(Icons.photo_camera));
    expect(pressed, isTrue);
  });

  testWidgets('oculta, no recibe toques ni se anuncia', (tester) async {
    final semantics = tester.ensureSemantics();
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: KumoGlassNavBar(
            destinations: destinations,
            selectedIndex: 0,
            visible: false,
            onDestinationSelected: (i) => tapped = i,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Momentos'), warnIfMissed: false);

    expect(tapped, isNull);
    expect(find.bySemanticsLabel('Momentos'), findsNothing);
    semantics.dispose();
  });

  testWidgets('el lector de pantalla sabe cuál está seleccionado', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpBar(tester, selectedIndex: 1);

    expect(
      tester.getSemantics(find.bySemanticsLabel('Momentos')),
      matchesSemantics(
        label: 'Momentos',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}
