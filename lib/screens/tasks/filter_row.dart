part of 'tasks_screen.dart';

class _FilterRow extends StatelessWidget {
  final String label;
  final List<String> values;
  final String selected;
  final bool dark;
  final ValueChanged<String> onChanged;

  const _FilterRow(
      {required this.label,
      required this.values,
      required this.selected,
      required this.onChanged,
      this.dark = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.slate400,
                  fontWeight: FontWeight.w500)),
          ...values.map((value) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _FilterChip(
                    label: value,
                    selected: selected == value,
                    onTap: () => onChanged(value),
                    isDark: dark),
              )),
        ],
      ),
    );
  }
}
