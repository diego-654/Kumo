import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/features/moments/presentation/providers/moments_providers.dart';
import 'package:kumo/features/moments/presentation/widgets/moment_card.dart';

class MomentsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Momentos')),
      body: moments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (items) => items.isEmpty
            ? const _EmptyMoments()
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 24),
                itemBuilder: (context, index) =>
                    MomentCard(moment: items[index]),
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
          ],
        ),
      ),
    );
  }
}

