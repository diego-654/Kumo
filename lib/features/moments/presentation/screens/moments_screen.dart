import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kumo/app/router/app_routes.dart';
import 'package:kumo/core/widget/error_view.dart';
import 'package:kumo/features/moments/presentation/providers/moments_providers.dart';
import 'package:kumo/features/moments/presentation/widgets/moment_card.dart';
import 'package:material_ui/material_ui.dart';

class MomentsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Momentos')),
      body: moments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorView(
          message: 'No pudimos cargar tus momentos.',
          onRetry: () => ref.invalidate(momentsProvider),
        ),
        data: (items) => items.isEmpty
            ? const _EmptyMoments()
            : ListView.separated(
                // Con un padding propio, ListView ya no suma el de
                // MediaQuery: lo añadimos a mano para que la última
                // tarjeta no quede detrás de la barra de vidrio.
                padding: EdgeInsets.fromLTRB(
                  8,
                  16,
                  8,
                  16 + MediaQuery.paddingOf(context).bottom,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final moment = items[index];
                  return MomentCard(
                    moment: moment,
                    onTap: () =>
                        context.push(AppRoutes.momentDetail(moment.id)),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyMoments extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_camera_outlined, size: 48),
            const SizedBox(height: 16),
            Text('Aún no hay momentos', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Fotografía un lugar y cuéntanos cómo te hace sentir.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            // Un estado vacío sin acción deja al usuario sin saber qué
            // hacer: siempre le damos el siguiente paso.
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.newMoment),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Registrar mi primer momento'),
            ),
          ],
        ),
      ),
    );
  }
}
