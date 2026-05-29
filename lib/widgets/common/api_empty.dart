part of 'api_state.dart';

class ApiEmpty extends StatelessWidget {
  final String message;

  const ApiEmpty(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.slate400)),
      ),
    );
  }
}
