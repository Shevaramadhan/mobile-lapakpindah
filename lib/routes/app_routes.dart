import 'package:flutter/material.dart';
import 'package:lapakpindah/models/item.dart';
import 'package:lapakpindah/modules/auth/login_screen.dart';
import 'package:lapakpindah/screens/catatan_form_screen.dart';
import 'package:lapakpindah/screens/detail_screen.dart';
import 'package:lapakpindah/screens/home_screen.dart';
import 'package:lapakpindah/screens/not_found_screen.dart';

/// Konstanta nama route dan generator route terpusat.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case detail:
        final args = settings.arguments;
        if (args is Item) {
          // periksa tipe argument dengan 'is'
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(item: args),
            settings: settings,
          );
        }
        return null; // data salah/kosong -> onUnknownRoute dipanggil
      case catatanForm:
        // <String> karena layar ini mengembalikan teks saat ditutup
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null; // route tidak terdaftar -> onUnknownRoute dipanggil
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
