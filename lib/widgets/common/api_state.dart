import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

part 'api_empty.dart';
part 'api_error_view.dart';

class ApiLoading extends StatelessWidget {
  const ApiLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: CircularProgressIndicator(color: AppColors.primary));
  }
}
