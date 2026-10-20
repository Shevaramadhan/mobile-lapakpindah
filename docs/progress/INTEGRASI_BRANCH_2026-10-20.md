# Integrasi branch modul — 20 Oktober 2026

## Keputusan

Kode dari `modul1-lokasi-sesijualan`, `modul-2-pengeluaran`, dan
`modul4-evaluasi-lokasi` digabungkan ke basis `main` dengan merge commit agar
riwayat perubahan tiap anggota tetap tercatat.

Branch `modul3-pencatatan-penjualan` dibuat dengan riwayat Git terpisah dan
berisi salinan seluruh proyek yang lebih lama. Riwayatnya dicatat dengan merge
`ours`, lalu kode Modul 3 (`lib/modules/penjualan/`) dan token tipografi yang
dibutuhkannya diambil dari branch tersebut. `SaleViewModel` didaftarkan di
`main.dart`, dan tab Penjualan diarahkan ke `SaleScreen`. Cara ini menjaga
implementasi terbaru Modul 1, 2, dan 4 yang sudah ada di basis integrasi.

Konflik Modul 2/4 pada Provider, tab, route, repository lokasi, dan lockfile
diselesaikan dengan mempertahankan kedua fitur. `LocationRepository` dipakai
bersama oleh ViewModel Lokasi dan Evaluasi. Lockfile dibuat ulang lewat
`flutter pub get` dari gabungan dependensi di `pubspec.yaml`.

## Batasan yang masih ada

Penggabungan branch menyatukan layar dan kode dalam satu aplikasi, tetapi
repository penjualan, pengeluaran, dan evaluasi masih memakai data sementara
atau contoh masing-masing. Integrasi transaksi nyata antar modul dan
penyimpanan permanen belum termasuk dalam penggabungan ini.

## Pemeriksaan

- `flutter analyze`: lulus tanpa isu.
- `flutter test test/location_workflow_test.dart`: lulus setelah tes menyuntikkan
  repository lokasi kosong secara eksplisit; build debug tetap memakai data
  contoh untuk demo Modul 4.
- `flutter test test/module_tabs_integration_test.dart`: lulus; login dan tab
  Lokasi, Biaya, Penjualan, serta Evaluasi dapat dibuka.
- `flutter test --reporter compact`: seluruh 36 tes lulus.
- `flutter build apk --debug`: lulus; APK debug berhasil dibuat.
