import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_theme.dart';
import 'package:lapakpindah/modules/auth/auth_view_model.dart';
import 'package:lapakpindah/modules/auth/login_screen.dart';
import 'package:lapakpindah/modules/dashboard/dashboard_view_model.dart';
import 'package:lapakpindah/modules/dashboard/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LapakPindahApp());
}

/// Root widget LapakPindah — setup Provider & Theme.
class LapakPindahApp extends StatelessWidget {
  const LapakPindahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: MaterialApp(
        title: 'LapakPindah',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Gate yang menentukan initial screen berdasarkan session.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authVM = context.read<AuthViewModel>();
    final hasSession = await authVM.checkSavedSession();

    if (!mounted) return;

    if (hasSession) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const LoginScreen();
  }
}
