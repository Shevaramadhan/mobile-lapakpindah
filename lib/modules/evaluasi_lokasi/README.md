# Modul 4 — Evaluasi Lokasi

**Penanggung jawab:** Anggota 4
**Acuan:** PRD v2 (`Materi/PRD_Mobile_Programming_Kelompok_8_Kelas_B_Revisi.docx`)

## Tujuan
Menghitung laba tiap lokasi dari data Modul 1–3, lalu menampilkan **peringkat**, **tren laba**,
**target laba**, dan **laporan PDF**, agar pedagang tahu lokasi mana yang paling menguntungkan.
Catatan PRD v2: aplikasi hanya menampilkan hasil perhitungan dan peringkat, **tidak** memberi rekomendasi keputusan.

## Functional Requirements
| FR | Ringkasan |
|---|---|
| **FR-16** | Menghitung laba tiap sesi (penjualan − pengeluaran), mengelompokkan per lokasi, dan menampilkan peringkat lokasi berdasarkan **rata-rata laba per sesi** pada periode yang dipilih. |
| **FR-17** | Grafik tren laba sebuah lokasi dari waktu ke waktu (harian atau mingguan). |
| **FR-18** (CRUD) | Tambah, lihat, ubah, hapus target laba per sesi untuk tiap lokasi; tampilkan status tercapai/belum berdasarkan rata-rata laba per sesi. |
| **FR-19** (Device File/PDF) | Ekspor laporan peringkat dan laba lokasi pada periode tertentu ke PDF yang tersimpan di perangkat dan dapat dibagikan. |
| **FR-20** (Notifikasi) | Notifikasi lokal terjadwal **seminggu sekali** untuk meninjau rekap dan peringkat lokasi. |

## Data (Model)
| Entitas | Atribut |
|---|---|
| `ProfitTarget` | id, location_id, target_amount |

Selain itu modul ini **membaca** data `Location`, `SalesSession` (Modul 1), `Expense` (Modul 2), dan `Sale` (Modul 3).

## Rencana file (MVVM)
```
evaluasi_lokasi/
 ┣ models/
 ┃ ┣ profit_target.dart
 ┃ ┗ location_ranking.dart        (hasil hitung: lokasi + rata-rata laba)
 ┣ repositories/
 ┃ ┣ evaluation_repository.dart   (menggabungkan data Modul 1–3)
 ┃ ┗ profit_target_repository.dart
 ┣ view_models/
 ┃ ┣ evaluation_view_model.dart
 ┃ ┗ profit_target_view_model.dart
 ┗ views/
   ┣ evaluation_screen.dart
   ┣ profit_target_form_screen.dart
   ┗ widgets/
     ┣ (misal: profit_trend_chart.dart)
     ┗ (misal: location_ranking_list.dart)
```
Nama file di atas hanya usulan; silakan disesuaikan pemilik modul, asalkan tetap mengikuti lapisan MVVM.

## Hubungan dengan modul lain
- **Membutuhkan Modul 1, 2, dan 3** (lokasi, sesi, pengeluaran, penjualan) melalui `repositories/` mereka.
- Perhatikan kasus data kosong (belum ada sesi) agar tidak terjadi pembagian dengan nol saat menghitung rata-rata.

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
