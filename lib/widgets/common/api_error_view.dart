part of 'api_state.dart';

class ApiErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const ApiErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.slate400, size: 32),
            const SizedBox(height: 10),
            Text(
              error?.toString() ?? 'Unable to load data.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.slate500, fontSize: 13),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
