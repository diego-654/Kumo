import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kumo/app/router/app_routes.dart';
import 'package:kumo/core/widget/kumo_glass_nav_bar.dart';
import 'package:kumo/features/heat_map/presentation/providers/heat_map_providers.dart';
import 'package:material_ui/material_ui.dart';

/// Contenedor con la barra de navegación inferior compartida por los tabs.
class HomeShell extends ConsumerWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// Índice de la rama del mapa en el router.
  static const _mapBranch = 0;

  static const _destinations = [
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;

    // Con la hoja de una zona abierta, la barra se esconde para que no la
    // tape. Se cierra tocando fuera de la zona y la barra vuelve sola.
    // Vive aquí (capa app) porque es quien junta las features: el mapa no
    // sabe que existe una barra, y la barra no sabe qué es una zona.
    final zoneSheetOpen =
        currentIndex == _mapBranch && ref.watch(selectedZoneProvider) != null;

    return Scaffold(
      // El body se dibuja también detrás de la barra (el mapa se ve a través
      // del vidrio). Las pantallas leen la altura de la barra en
      // `MediaQuery.paddingOf(context).bottom`.
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: KumoGlassNavBar(
        destinations: _destinations,
        selectedIndex: currentIndex,
        visible: !zoneSheetOpen,
        // La acción central de Kumo, a un toque desde cualquier pestaña.
        centerAction: KumoNavAction(
          icon: Icons.photo_camera,
          label: 'Registrar un momento',
          onTap: () => context.push(AppRoutes.newMoment),
        ),
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tocar el tab activo vuelve a su pantalla inicial.
          initialLocation: index == currentIndex,
        ),
      ),
    );
  }
}
