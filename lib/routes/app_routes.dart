import 'package:flutter/material.dart';
import 'package:lapakpindah/models/item.dart'; // TUGAS
import 'package:lapakpindah/modules/auth/login_screen.dart';
import 'package:lapakpindah/modules/dashboard/main_navigation_screen.dart';
import 'package:lapakpindah/screens/not_found_screen.dart';
import 'package:lapakpindah/screens/detail_screen.dart'; // TUGAS
import 'package:lapakpindah/screens/catatan_form_screen.dart'; // TUGAS

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail'; // TUGAS
  static const String catatanForm = '/catatan-form'; // TUGAS

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const MainNavigationScreen(),
          settings: settings,
        );
      case detail:
        // TUGAS: Membaca argument yang dilempar dari pushNamed
        final args = settings.arguments;
        if (args is Item) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(item: args),
            settings: settings,
          );
        }
        return null; // data salah/kosong -> halaman 404
      case catatanForm:
        // TUGAS: Menggunakan <String> karena layar ini akan mengembalikan data teks saat di-pop
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
