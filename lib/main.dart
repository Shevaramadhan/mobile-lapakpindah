import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_theme.dart';
import 'package:lapakpindah/modules/auth/view_models/auth_view_model.dart';
import 'package:lapakpindah/modules/home/view_models/home_view_model.dart';
import 'package:lapakpindah/modules/sesi_lokasi/view_models/location_view_model.dart';
import 'package:lapakpindah/routes/app_routes.dart';
import 'package:lapakpindah/modules/sesi_lokasi/models/location.dart';
import 'package:lapakpindah/modules/sesi_lokasi/repositories/location_repository.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/repositories/evaluation_repository.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/repositories/profit_target_repository.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/view_models/evaluation_view_model.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/view_models/profit_target_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LapakPindahApp());
}

/// Root widget LapakPindah — setup Provider & Theme & Routing.
class LapakPindahApp extends StatefulWidget {
  const LapakPindahApp({super.key, this.locationRepository});
  final LocationRepository? locationRepository;

  @override
  State<LapakPindahApp> createState() => _LapakPindahAppState();
}

class _LapakPindahAppState extends State<LapakPindahApp> {
  // flutter run memakai data contoh; build rilis tetap mulai tanpa data contoh.
  // --dart-define=LAPAK_DEMO=false dapat dipakai untuk menguji keadaan kosong.
  static const _demo = bool.fromEnvironment(
    'LAPAK_DEMO',
    defaultValue: kDebugMode,
  );
  late final _locations =
      widget.locationRepository ??
      LocationRepository(
        initialLocations: _demo
            ? [
                const Location(id: 'demo-cfd', name: 'CFD Jam Gadang'),
                const Location(id: 'demo-office', name: 'Area Perkantoran'),
              ]
            : [],
      );
  late final _targets = ProfitTargetRepository();
  late final _evaluation = EvaluationRepository(demo: _demo);

  @override
  Widget build(BuildContext context) {
    // Provider: menyediakan ViewModel ke semua layar di bawahnya (M3: MVVM).
    // Tiap modul mendaftarkan ViewModel-nya di sini.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ), // sesi login (global)
        ChangeNotifierProvider(create: (_) => HomeViewModel()), // Beranda
        ChangeNotifierProvider(
          create: (_) => LocationViewModel(repository: _locations),
        ),
        ChangeNotifierProvider(
          create: (_) => EvaluationViewModel(
            locationsRepository: _locations,
            repository: _evaluation,
            targetsRepository: _targets,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfitTargetViewModel(
            repository: _targets,
            locationsRepository: _locations,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'LapakPindah',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // M4: Named routes. Jika memakai initialRoute, properti `home` tidak dipakai.
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );
  }
}
