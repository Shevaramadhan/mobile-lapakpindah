import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';

/// Peta sebuah lokasi memakai OpenStreetMap (gratis, tanpa API key).
///
/// Widget BERSAMA: dipakai Beranda dan bisa dipakai modul lain.
/// Widget ini hanya MENAMPILKAN koordinat yang diberikan lewat parameter;
/// tidak mengakses GPS sendiri.
///
/// Butuh koneksi internet untuk memuat gambar peta (tile).
/// Tombol di kanan atas mengembalikan tampilan ke titik lokasi.
class LocationMap extends StatefulWidget {
  const LocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  // ── Pengaturan peta ──
  static const double _initialZoom = 16;

  /// Controller untuk menggerakkan peta dari kode (tombol "kembali ke lapak").
  final _mapController = MapController();

  LatLng get _lapakPoint => LatLng(widget.latitude, widget.longitude);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Menggeser peta kembali ke titik lapak.
  void _recenter() => _mapController.move(_lapakPoint, _initialZoom);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Peta ──
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _lapakPoint,
            initialZoom: _initialZoom,
          ),
          children: [
            // 1. Gambar peta dari server OpenStreetMap
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              // Wajib menurut kebijakan OSM: identitas aplikasi
              userAgentPackageName: 'com.example.lapakpindah',
            ),

            // 2. Lingkaran area di sekitar lapak (radius 60 meter)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: _lapakPoint,
                  radius: 60,
                  useRadiusInMeter: true,
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderColor: AppColors.primary.withValues(alpha: 0.4),
                  borderStrokeWidth: 1,
                ),
              ],
            ),

            // 3. Pin lapak (ujung bawah pin tepat di titik koordinat)
            MarkerLayer(
              markers: [
                Marker(
                  point: _lapakPoint,
                  width: 40,
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ],
            ),

            // 4. Atribusi sumber peta (wajib menurut lisensi OSM).
            //    Dibuat sendiri agar terpotong rapi di layar sempit,
            //    karena SimpleAttributionWidget bawaan bisa overflow.
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                color: AppColors.surfaceCard.withValues(alpha: 0.8),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: const Text(
                  '© OpenStreetMap contributors',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),

        // ── Tombol kembali ke titik lapak (kanan atas) ──
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: AppColors.surfaceCard,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.inputBorder),
            ),
            child: IconButton(
              tooltip: 'Kembali ke titik lapak',
              onPressed: _recenter,
              icon: const Icon(Icons.my_location, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
