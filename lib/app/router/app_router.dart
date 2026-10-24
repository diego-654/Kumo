import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kumo/app/router/app_routes.dart';
import 'package:kumo/app/router/home_shell.dart';
import 'package:kumo/features/heat_map/presentation/screens/heat_map_screen.dart';
import 'package:kumo/features/moments/presentation/screens/moment_detail_screen.dart';
import 'package:kumo/features/moments/presentation/screens/moment_form_screen.dart';
import 'package:kumo/features/moments/presentation/screens/moments_screen.dart';

/// El router vive en un provider para que más adelante pueda leer otros
/// providers (por ejemplo, el estado de autenticación para redirigir).
final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.heatMap,
    routes: [
      // Fuera del shell: se abre encima de todo (sin navbar) y se puede
      // llegar desde cualquier tab.
      GoRoute(
        path: AppRoutes.newMoment,
        builder: (context, state) => const MomentFormScreen(),
      ),
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
                routes: [
                  GoRoute(
                    path: ':id', // queda /moments/:id
                    parentNavigatorKey:
                        rootNavigatorKey, // se abre encima del navbar
                    builder: (context, state) => MomentDetailScreen(
                      momentId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit', // /moments/:id/edit
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => MomentFormScreen(
                          momentId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
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
