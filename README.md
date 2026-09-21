# LapakPindah

Aplikasi Mobile Manajemen Operasional, Pemetaan Lokasi Jualan, dan Evaluasi Penjualan bagi UMKM Keliling. 
Dibangun menggunakan Flutter dengan arsitektur MVVM dan penyimpanan lokal SQLite (Offline-first).

## 🔐 Akun Demo (Login)

Aplikasi ini menggunakan database SQLite lokal. Saat pertama kali dijalankan, sistem akan otomatis membuat satu akun demo yang bisa langsung digunakan:

- **No. WhatsApp / Email:** `0812345678`
- **Kata Sandi / PIN:** `123456`

## 🚀 Cara Menjalankan Aplikasi

1. Pastikan dependensi sudah terunduh:
   ```bash
   flutter pub get
   ```
2. Jalankan aplikasi di emulator atau perangkat fisik (Android):
   ```bash
   flutter run
   ```

> **Catatan Windows:** Jika terjadi error kompilasi *Kotlin incremental* di Windows, build project ini sudah dikonfigurasi dengan `kotlin.incremental=false` di `android/gradle.properties` sebagai *workaround*.

## 📂 Struktur Folder (MVVM)

- `lib/core/`: Berisi konfigurasi tema (warna, font), helper database SQLite, dan widget UI yang dapat digunakan kembali (*reusable*).
- `lib/modules/`: Berisi fitur utama aplikasi yang dipisah per modul (Auth, Dashboard, dll) dengan masing-masing memiliki View (`*_screen.dart`) dan ViewModel (`*_view_model.dart`).
