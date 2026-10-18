import 'package:flutter/material.dart';
import 'package:lapakpindah/core/widgets/not_found_screen.dart';
import 'package:lapakpindah/modules/auth/views/login_screen.dart';
import 'package:lapakpindah/modules/auth/views/register_placeholder_screen.dart';
import 'package:lapakpindah/modules/home/views/main_navigation_screen.dart';
import 'package:lapakpindah/modules/sesi_lokasi/views/location_form_screen.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/models/profit_target.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/views/profit_target_form_screen.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/views/target_result_screen.dart';

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
  static const String locationForm = '/lokasi/tambah'; // Modul 1
  static const String targetForm = '/evaluasi/target';
  static const String targetResult = '/evaluasi/target/hasil';

  /// Generic route harus sama dengan tipe result `pushNamed<T>` pemanggil.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == targetForm) {
      return MaterialPageRoute<ProfitTarget>(
        settings: settings,
        builder: (_) => const ProfitTargetFormScreen(),
      );
    }
    if (settings.name == targetResult) {
      final args = settings.arguments;
      return MaterialPageRoute<TargetResultAction>(
        settings: settings,
        builder: (_) => args is SavedTarget
            ? TargetResultScreen(saved: args)
            : NotFoundScreen(routeName: settings.name),
      );
    }
    return null;
  }

  // ── 2. Daftar route: nama → layar ──
  // Jika sebuah layar butuh data, kirim lewat `arguments` lalu baca di
  // layar tujuan dengan ModalRoute.of(context)?.settings.arguments.
  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterPlaceholderScreen(),
    home: (context) => const MainNavigationScreen(), // Beranda + 5 tab
    locationForm: (context) => const LocationFormScreen(), // form tambah lokasi
  };

  // ── 3. Halaman cadangan jika nama route tidak terdaftar ──
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
