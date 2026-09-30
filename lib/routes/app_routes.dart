import 'package:flutter/material.dart';
import '../modules/dashboard/home_screen.dart'; 
import '../modules/auth/login_screen.dart';
import '../screens/not_found_screen.dart'; // Sesuaikan path jika diletakkan di /screens atau /core/widgets
import '../models/lapak.dart';
import '../modules/dashboard/detail_screen.dart';
import '../modules/dashboard/catatan_form_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Nama route disimpan sebagai konstanta
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
        final args = settings.arguments; // Tangkap data yang dikirim
        if (args is Lapak) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(item: args),
            settings: settings,
          );
        }
        return null;

        case catatanForm:
        // Gunakan <String> karena layar ini akan mengembalikan data bertipe teks (String)
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null; // Route tidak terdaftar -> akan diteruskan ke onUnknownRoute
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}