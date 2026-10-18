
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_theme.dart';
import 'package:lapakpindah/modules/auth/view_models/auth_view_model.dart';
import 'package:lapakpindah/modules/home/view_models/home_view_model.dart';
import 'package:lapakpindah/modules/penjualan/view_models/sale_view_model.dart';
import 'package:lapakpindah/routes/app_routes.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale Indonesia sebelum aplikasi dijalankan.
  await initializeDateFormatting('id_ID');

  runApp(const LapakPindahApp());
}
/// Root widget LapakPindah — setup Provider & Theme & Routing.
class LapakPindahApp extends StatelessWidget {
  const LapakPindahApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider: menyediakan ViewModel ke semua layar di bawahnya (M3: MVVM).
    // Tiap modul mendaftarkan ViewModel-nya di sini.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()), // sesi login (global)
        ChangeNotifierProvider(create: (_) => HomeViewModel()), // Beranda
        ChangeNotifierProvider(create: (_) => SaleViewModel()), // Penjualan
      ],
      child: MaterialApp(
        title: 'LapakPindah',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // M4: Named routes. Jika memakai initialRoute, properti `home` tidak dipakai.
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );
  }
}
