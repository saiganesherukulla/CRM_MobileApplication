part of 'reports_screen.dart';

class _TableCard extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;

  const _TableCard(
      {required this.title, required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const Text('No rows yet.',
                style: TextStyle(color: AppColors.slate400))
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final minWidth =
                    math.max(constraints.maxWidth, headers.length * 92.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minWidth),
                    child: Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: AppColors.slate100))),
                          children: headers
                              .map((header) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8, right: 10),
                                  child: Text(header,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.slate500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)))
                              .toList(),
                        ),
                        ...rows.map((row) => TableRow(
                            children: row
                                .map((cell) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 7)
                                            .copyWith(right: 10),
                                    child: Text(cell,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.slate700),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)))
                                .toList())),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
