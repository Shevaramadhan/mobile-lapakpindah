# Modul 3 — Pencatatan Penjualan

**Penanggung jawab:** Anggota 3
**Acuan:** PRD v2 (`Materi/PRD_Mobile_Programming_Kelompok_8_Kelas_B_Revisi.docx`)

## Tujuan
Mencatat produk yang terjual di setiap **sesi jualan**, dengan harga yang berlaku di lokasi itu,
dan menunjukkan kapan sesi sudah **balik modal**.
Catatan PRD v2: aplikasi **bukan kasir** (tanpa pembayaran/kembalian) dan **tidak mengelola stok**.

## Functional Requirements
| FR | Ringkasan |
|---|---|
| **FR-11** (CRUD) | Tambah, lihat, ubah, hapus produk (nama & harga jual). Produk yang sudah punya catatan penjualan tidak dihapus, melainkan **dinonaktifkan**. |
| **FR-12** | Mencatat penjualan pada sesi aktif (pilih produk & jumlah). Sistem menghitung nilai penjualan, menyimpan harga satuan, dan menampilkan total penjualan sesi. Catatan bisa diubah/dihapus. |
| **FR-13** | Harga khusus produk untuk lokasi tertentu; di lokasi lain memakai harga normal. |
| **FR-14** | Membandingkan total penjualan dengan total pengeluaran sesi aktif dan menampilkan selisihnya (kekurangan untuk balik modal atau keuntungan). |
| **FR-15** (Notifikasi) | Notifikasi lokal **satu kali per sesi** saat total penjualan pertama kali melewati total pengeluaran (balik modal). |

## Data (Model)
| Entitas | Atribut |
|---|---|
| `Product` | id, name, selling_price, is_active |
| `LocationPrice` | id, product_id, location_id, price |
| `Sale` | id, session_id, product_id, quantity, unit_price, recorded_at |

## Rencana file (MVVM)
```
penjualan/
 ┣ models/
 ┃ ┣ product.dart
 ┃ ┣ location_price.dart
 ┃ ┗ sale.dart
 ┣ repositories/
 ┃ ┣ product_repository.dart
 ┃ ┗ sale_repository.dart
 ┣ view_models/
 ┃ ┣ product_view_model.dart
 ┃ ┗ sale_view_model.dart
 ┗ views/
   ┣ product_list_screen.dart
   ┣ product_form_screen.dart
   ┣ sale_screen.dart
   ┗ widgets/
     ┗ (misal: break_even_card.dart)
```
Nama file di atas hanya usulan; silakan disesuaikan pemilik modul, asalkan tetap mengikuti lapisan MVVM.

## Hubungan dengan modul lain
- **Membutuhkan Modul 1:** sesi aktif (`session_id`) dan lokasinya (`location_id`, untuk harga khusus).
  Jika belum ada sesi aktif, pencatatan penjualan dinonaktifkan.
- **Membutuhkan Modul 2:** total pengeluaran sesi untuk FR-14 dan FR-15.
- **Dipakai oleh** Modul 4 (laba per lokasi) dan Beranda (total penjualan, status balik modal).

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
