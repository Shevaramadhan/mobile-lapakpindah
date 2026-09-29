import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class NotFoundScreen extends StatelessWidget {
  final String? routeName;

  const NotFoundScreen({super.key, this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 64),
              const SizedBox(height: 12),
              const Text('404', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              const Text(
                'Halaman yang kamu tuju belum tersedia.',
                textAlign: TextAlign.center,
              ),
              if (routeName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Route: $routeName',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
