part of 'reports_screen.dart';

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _Legend(this.color, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.slate600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(width: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
      ],
    );
  }
}
