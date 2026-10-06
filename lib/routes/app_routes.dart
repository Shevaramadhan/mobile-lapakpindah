import 'package:flutter/material.dart';
import '../modules/auth/login_screen.dart';
import '../modules/dashboard/detail_screen.dart';
import '../modules/dashboard/main_navigation_screen.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/not_found_screen.dart';

/// Satu tempat untuk seluruh route aplikasi (M4: Named Routes).
///
/// Dipakai di MaterialApp:
///   initialRoute: AppRoutes.login,
///   routes: AppRoutes.routes,
///   onUnknownRoute: AppRoutes.onUnknownRoute,
class AppRoutes {
  AppRoutes._();

  // ── 1. Nama route disimpan sebagai konstanta (hindari salah ketik) ──
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';

  // ── 2. Daftar route: nama → layar ──
  // Data yang dikirim lewat `arguments` dibaca di layar tujuan
  // dengan ModalRoute.of(context)?.settings.arguments.
  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const MainNavigationScreen(), // Beranda + 5 tab
    detail: (context) => const DetailScreen(), // arguments: Lapak
    catatanForm: (context) => const CatatanFormScreen(), // mengembalikan String
  };

  // ── 3. Halaman cadangan jika nama route tidak terdaftar ──
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
