import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/app/router/app_router.dart';
import 'package:kumo/core/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

class KumoApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Kumo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
