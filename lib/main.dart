import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_theme.dart';
import 'package:lapakpindah/modules/auth/auth_view_model.dart';
import 'package:lapakpindah/modules/dashboard/dashboard_view_model.dart';
import 'package:lapakpindah/routes/app_routes.dart'; // named routes

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LapakPindahApp());
}

/// Root widget LapakPindah — setup Provider, Theme, dan Named Routes.
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
        initialRoute: AppRoutes.login, // mulai dari layar Login
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );
  }
}
