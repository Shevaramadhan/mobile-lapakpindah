# Modul 2 — Pengeluaran & Bukti Nota

**Penanggung jawab:** Anggota 2
**Acuan:** PRD v2 (`Materi/PRD_Mobile_Programming_Kelompok_8_Kelas_B_Revisi.docx`)

## Tujuan
Menjawab pertanyaan *"berapa biaya yang keluar di lokasi ini"*. Semua pengeluaran dicatat ke **sesi jualan**
dari Modul 1, beserta foto nota sebagai bukti, sehingga biaya tiap lokasi tercatat lengkap.

## Functional Requirements
| FR | Ringkasan |
|---|---|
| **FR-06** (CRUD) | Tambah, lihat, ubah, hapus pengeluaran pada sebuah sesi (keterangan & jumlah). Tampilkan total pengeluaran sesi. |
| **FR-07** (Device Kamera) | Memotret nota/karcis dengan kamera sebagai bukti pengeluaran, lalu melihat, mengganti, atau menghapus foto. |
| **FR-08** | Menyimpan daftar biaya tetap sebuah lokasi. Saat sesi dibuka di lokasi itu, biaya tetap otomatis dicatat sebagai pengeluaran sesi. |
| **FR-09** | Menetapkan batas pengeluaran sesi aktif; sisa batas dihitung ulang setiap kali pengeluaran berubah. |
| **FR-10** (Notifikasi) | Notifikasi lokal **satu kali per sesi** saat total pengeluaran mencapai/melewati batas. |

## Data (Model)
| Entitas | Atribut |
|---|---|
| `Expense` | id, session_id, description, amount, receipt_photo_path, recorded_at |
| `LocationFixedCost` | id, location_id, description, amount |
| `ExpenseLimit` | session_id, limit_amount |

## Rencana file (MVVM)
```
pengeluaran/
 ┣ models/
 ┃ ┣ expense.dart
 ┃ ┣ location_fixed_cost.dart
 ┃ ┗ expense_limit.dart
 ┣ repositories/
 ┃ ┗ expense_repository.dart
 ┣ view_models/
 ┃ ┗ expense_view_model.dart
 ┗ views/
   ┣ expense_list_screen.dart
   ┣ expense_form_screen.dart
   ┗ widgets/
     ┗ (misal: receipt_photo_preview.dart)
```
Nama file di atas hanya usulan; silakan disesuaikan pemilik modul, asalkan tetap mengikuti lapisan MVVM.

## Hubungan dengan modul lain
- **Membutuhkan Modul 1:** `session_id` sesi aktif (pengeluaran selalu menempel ke sesi) dan `location_id`
  (biaya tetap lokasi). Jika belum ada sesi aktif, pencatatan pengeluaran dinonaktifkan.
- **Dipakai oleh** Modul 3 (total pengeluaran untuk balik modal), Modul 4 (laba per lokasi), dan Beranda.

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
