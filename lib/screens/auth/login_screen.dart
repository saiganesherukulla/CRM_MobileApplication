import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';

part 'login_screen_state.dart';

// ============================================================
// LoginScreen — Glassmorphism-style login
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
