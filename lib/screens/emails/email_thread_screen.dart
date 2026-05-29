part of 'emails_screen.dart';

class _EmailThreadScreen extends StatefulWidget {
  final EmailMessage email;
  final VoidCallback onSent;

  const _EmailThreadScreen({required this.email, required this.onSent});

  @override
  State<_EmailThreadScreen> createState() => _EmailThreadScreenState();
}
