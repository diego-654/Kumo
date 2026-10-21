import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kumo/app/router/app_routes.dart';
import 'package:kumo/app/router/home_shell.dart';
import 'package:kumo/features/heat_map/presentation/screens/heat_map_screen.dart';
import 'package:kumo/features/moments/presentation/screens/moments_screen.dart';

/// El router vive en un provider para que más adelante pueda leer otros
/// providers (por ejemplo, el estado de autenticación para redirigir).
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.heatMap,
    routes: [
      // Cada rama conserva su propio stack de navegación al cambiar de tab.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.heatMap,
                builder: (context, state) => const HeatMapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.moments,
                builder: (context, state) => const MomentsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Ruta no encontrada: ${state.uri}'))),
  );
  ref.onDispose(router.dispose);
  return router;
});
