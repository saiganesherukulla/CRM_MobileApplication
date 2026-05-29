part of 'settings_screen.dart';

class _DepartmentsSection extends StatelessWidget {
  final List<DepartmentInfo> departments;
  final VoidCallback onChanged;

  const _DepartmentsSection({
    required this.departments,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text('Departments',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _openDepartmentSheet(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (departments.isEmpty)
          const ApiEmpty('No departments configured.')
        else
          ...departments.map((department) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder)),
                child: Row(
                  children: [
                    Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.business_outlined,
                            color: AppColors.primary, size: 20)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(department.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(
                              '${department.members} members - Head: ${department.head}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.slate400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.slate400),
                      onPressed: () =>
                          _openDepartmentSheet(context, department: department),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  void _openDepartmentSheet(BuildContext context, {DepartmentInfo? department}) {
    final nameCtrl = TextEditingController(text: department?.name ?? '');
    final headCtrl = TextEditingController(text: department?.head ?? '');
    final membersCtrl =
        TextEditingController(text: (department?.members ?? 0).toString());
    bool saving = false;
    String? error;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(builder: (context, setSheetState) {
          Future<void> save() async {
            if (nameCtrl.text.trim().isEmpty) {
              setSheetState(() => error = 'Department name is required.');
              return;
            }
            setSheetState(() {
              saving = true;
              error = null;
            });
            try {
              await CrmApi.instance.saveDepartment({
                if (department != null) 'id': department.id,
                'name': nameCtrl.text.trim(),
                'head': headCtrl.text.trim(),
                'members': int.tryParse(membersCtrl.text.trim()) ?? 0,
              });
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              onChanged();
              if (context.mounted) _showInfo(context, 'Department saved.');
            } catch (err) {
              setSheetState(() => error = err.toString());
            } finally {
              if (context.mounted) {
                setSheetState(() => saving = false);
              }
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 18,
              bottom: MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(department == null ? 'Add Department' : 'Edit Department',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate800)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Department Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: headCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Department Head'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: membersCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Member Count'),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving ? null : save,
                      child: Text(saving ? 'Saving...' : 'Save Department'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    ).whenComplete(() {
      nameCtrl.dispose();
      headCtrl.dispose();
      membersCtrl.dispose();
    });
  }
}
