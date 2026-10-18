import 'package:flutter/material.dart';
import 'package:lapakpindah/core/widgets/not_found_screen.dart';
import 'package:lapakpindah/modules/auth/views/login_screen.dart';
import 'package:lapakpindah/modules/auth/views/register_placeholder_screen.dart';
import 'package:lapakpindah/modules/home/views/main_navigation_screen.dart';

/// Satu tempat untuk seluruh route aplikasi (M4: Named Routes).
///
/// Semua perpindahan layar memakai nama route dari kelas ini, sehingga
/// alur navigasi terpusat dan mudah dibaca (M4: Navigation Architecture).
///
/// Dipakai di MaterialApp:
///   initialRoute: AppRoutes.login,
///   routes: AppRoutes.routes,
///   onUnknownRoute: AppRoutes.onUnknownRoute,
class AppRoutes {
  AppRoutes._();

  // ── 1. Nama route disimpan sebagai konstanta (hindari salah ketik) ──
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  // ── 2. Daftar route: nama → layar ──
  // Jika sebuah layar butuh data, kirim lewat `arguments` lalu baca di
  // layar tujuan dengan ModalRoute.of(context)?.settings.arguments.
  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterPlaceholderScreen(),
    home: (context) => const MainNavigationScreen(), // Beranda + 5 tab
  };

  // ── 3. Halaman cadangan jika nama route tidak terdaftar ──
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
