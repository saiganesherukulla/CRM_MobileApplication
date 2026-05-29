part of 'settings_screen.dart';

class _RolesSection extends StatelessWidget {
  final List<RoleInfo> roles;
  final VoidCallback onChanged;

  const _RolesSection({required this.roles, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final permissionSet =
        roles.expand((role) => role.permissions).toSet().toList()..sort();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Roles & Permissions',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800)),
            ),
            ElevatedButton.icon(
              onPressed: () => _openRoleSheet(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (roles.isEmpty)
          const ApiEmpty('No roles configured.')
        else
          ...roles.map((role) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder)),
                child: Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                            color: AppColors.info, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(role.name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(role.description,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.slate400),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    TextButton(
                        onPressed: () => _openRoleSheet(context, role: role),
                        child: const Text('Edit')),
                  ],
                ),
              )),
        const SizedBox(height: 10),
        const Text('Permission Matrix',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder)),
          child: permissionSet.isEmpty
              ? const Text('No permissions have been assigned.',
                  style: TextStyle(color: AppColors.slate400))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: permissionSet
                      .map((permission) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(permission,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.slate700),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                                const Icon(Icons.check_rounded,
                                    size: 16, color: AppColors.success),
                              ],
                            ),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }

  void _openRoleSheet(BuildContext context, {RoleInfo? role}) {
    final nameCtrl = TextEditingController(text: role?.name ?? '');
    final descriptionCtrl = TextEditingController(text: role?.description ?? '');
    final permissionsCtrl =
        TextEditingController(text: role?.permissions.join(', ') ?? '');
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
              setSheetState(() => error = 'Role name is required.');
              return;
            }
            setSheetState(() {
              saving = true;
              error = null;
            });
            try {
              await CrmApi.instance.saveRole({
                if (role != null) 'id': role.id,
                'name': nameCtrl.text.trim(),
                'description': descriptionCtrl.text.trim(),
                'permissions': permissionsCtrl.text
                    .split(',')
                    .map((item) => item.trim())
                    .where((item) => item.isNotEmpty)
                    .toList(),
              });
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              onChanged();
              if (context.mounted) _showInfo(context, 'Role saved.');
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
                  Text(role == null ? 'Add Role' : 'Edit Role',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate800)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Role Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: permissionsCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'Permissions',
                        hintText: 'clients, tasks, projects'),
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
                      child: Text(saving ? 'Saving...' : 'Save Role'),
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
      descriptionCtrl.dispose();
      permissionsCtrl.dispose();
    });
  }
}
