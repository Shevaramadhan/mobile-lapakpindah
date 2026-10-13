# Modul 1 — Lokasi & Sesi Jualan

**Penanggung jawab:** Anggota 1 (Ihsan Auliya Habiburrohim)
**Acuan:** PRD v2 (`Materi/PRD_Mobile_Programming_Kelompok_8_Kelas_B_Revisi.docx`) dan desain Figma layar `M1 · …`

## Tujuan
Menjawab pertanyaan *"di mana dan kapan pedagang berjualan"*. Modul ini menyimpan daftar **lokasi** jualan
dan mencatat setiap **sesi jualan** (satu kali berjualan dari lapak dibuka sampai ditutup).
Penjualan (Modul 3) dan pengeluaran (Modul 2) selalu menempel ke sebuah sesi.

## Functional Requirements
| FR | Ringkasan |
|---|---|
| **FR-01** (CRUD) | Tambah, lihat, ubah, hapus lokasi (nama tempat & catatan). Lokasi yang sudah punya sesi **tidak dapat dihapus**. |
| **FR-02** (Device GPS) | Menandai koordinat lokasi dengan GPS perangkat; koordinat tersimpan pada data lokasi. |
| **FR-03** | Buka sesi (isi rencana jam tutup) lalu tutup sesi. Tanggal, jam buka, jam tutup tercatat otomatis dan bisa dikoreksi manual. **Hanya boleh ada satu sesi aktif.** |
| **FR-04** | Membuka petunjuk arah ke lokasi di aplikasi Google Maps berdasarkan koordinat. |
| **FR-05** (Notifikasi) | Notifikasi lokal pada rencana jam tutup jika sesi belum ditutup. |

Halaman pendukung (In Scope PRD): **riwayat sesi** dengan filter tanggal dan lokasi.

## Data (Model)
| Entitas | Atribut |
|---|---|
| `Location` | id, name, note, latitude, longitude |
| `SalesSession` | id, location_id, date, open_time, planned_close_time, close_time, status (aktif/selesai) |

## Rencana file (MVVM)
```
sesi_lokasi/
 ┣ models/
 ┃ ┣ location.dart
 ┃ ┗ sales_session.dart
 ┣ repositories/
 ┃ ┣ location_repository.dart
 ┃ ┗ session_repository.dart
 ┣ view_models/
 ┃ ┣ location_view_model.dart
 ┃ ┗ session_view_model.dart
 ┗ views/
   ┣ location_list_screen.dart      (Figma M1·1, 1a, 1b)
   ┣ location_form_screen.dart      (M1·2 — tambah & ubah)
   ┣ location_detail_screen.dart    (M1·3, 3b)
   ┣ session_history_screen.dart    (M1·6)
   ┗ widgets/
     ┣ location_card.dart
     ┣ open_session_sheet.dart      (M1·4 Buka lapak)
     ┗ close_session_sheet.dart     (M1·5 Tutup lapak)
```

## Hubungan dengan modul lain
- **Dipakai oleh** Modul 2, Modul 3, Modul 4, dan Beranda (sesi aktif, lokasi).
  Karena itu `Location` dan `SalesSession` sebaiknya diselesaikan lebih dulu.
- Saat sesi dibuka, biaya tetap lokasi dicatat otomatis sebagai pengeluaran (FR-08 Modul 2) —
  cara penyambungannya disepakati dengan Anggota 2.

---

## Aturan MVVM bersama (berlaku untuk semua modul)
1. **Arah ketergantungan:** View → ViewModel → Repository → Model.
   View **tidak** meng-import repository secara langsung.
2. **ViewModel tanpa UI:** import `package:flutter/foundation.dart` (bukan `material.dart`) dan
   `core/utils/view_status.dart` untuk status loading/success/error.
3. **Lintas modul:** boleh memakai `models/` dan `repositories/` modul lain.
   ViewModel modul lain yang boleh dipakai hanya `AuthViewModel` (sesi login global).
4. **Pendaftaran:** ViewModel didaftarkan di `MultiProvider` pada `lib/main.dart`;
   route didaftarkan di `lib/routes/app_routes.dart` dan dipanggil dengan `Navigator.pushNamed`.
5. **Pakai ulang dari `core/`:** `LapakTextField`, `LapakPrimaryButton`, `state_views.dart`
   (LoadingView/ErrorView/EmptyView), `validators.dart`, `format_rupiah.dart`, `location_map.dart`.
6. File `.gitkeep` hanya penanda folder kosong untuk Git; boleh dihapus setelah folder berisi file Dart.
