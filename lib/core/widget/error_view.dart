import 'package:material_ui/material_ui.dart';

/// Estado de error para una pantalla o sección: un mensaje que una persona
/// entiende y, si se puede, un botón para reintentar.
///
/// El detalle técnico del error no se muestra: al usuario no le sirve
/// "SocketException: Failed host lookup", y puede filtrar información
/// interna. Ese detalle va a los logs (o a Crashlytics, más adelante).
class ErrorView extends StatelessWidget {
  const new({
    this.title = 'Algo salió mal',
    this.message = 'Revisa tu conexión e intenta de nuevo.',
    this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onRetry = this.onRetry;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
