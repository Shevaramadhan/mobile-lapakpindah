# Pembagian Tugas Ekstra Detail & Kontrak Teknis Anggota
**Proyek:** LapakPindah (Aplikasi Evaluasi Keuntungan Lokasi Jualan UMKM Keliling)
**Arsitektur:** MVVM + Provider
**Database:** SQLite Lokal (Offline-first)

> **Tujuan Dokumen:** Mencegah tumpang tindih pengerjaan, menghindari cacat logika (logic flaws) lintas modul, memastikan konsistensi penggunaan Widget UI, dan menangani Edge Cases.

---

## 1. Anggota 1 - Modul 1: Pondasi Lokasi & Sesi
**A. Ruang Lingkup File (Scope)**
- **Views:** location_list_screen.dart, location_form_screen.dart, session_manager_screen.dart.
- **ViewModels:** LocationViewModel, SessionViewModel.
- **Database (Tabel):** Location, SalesSession.

**B. Detail Logika & Edge Cases (Wajib Ditangani):**
- **Logika Sesi (Kritis):** HANYA BOLEH ADA 1 Sesi Aktif! Di SessionViewModel.startSession(), periksa ke SQLite: SELECT * FROM SalesSession WHERE status = 'aktif'. Jika ada, tolak/blokir pembuatan sesi baru dan tampilkan peringatan.
- **Logika GPS:** Saat menandai lokasi, tangani kondisi jika GPS mati atau *Permission Denied*. Munculkan peringatan agar user menyalakan GPS, jangan biarkan aplikasi *crash*.
- **Relasi Data:** Jika user menghapus (Delete) Location yang sudah punya riwayat sesi, CEGAH penghapusan tersebut secara *hard delete*. Beri peringatan atau ubah statusnya menjadi *Inactive* agar laporan keuangan masa lalu tidak korup (NFR-05).

**C. Standar UI / Widget:**
- Semua form *input* wajib menggunakan CustomTextField dari folder core/widgets.
- Tombol navigasi Maps wajib memakai FilledButton.icon dengan logo petunjuk arah agar selaras.

---

## 2. Anggota 2 - Modul 2: Pintu Pengeluaran & Nota
**A. Ruang Lingkup File (Scope)**
- **Views:** expense_list_screen.dart, expense_form_screen.dart, expense_camera_screen.dart.
- **ViewModels:** ExpenseViewModel.
- **Database (Tabel):** Expense, LocationFixedCost, ExpenseLimit.

**B. Detail Logika & Edge Cases (Wajib Ditangani):**
- **Ketergantungan Sesi (Kritis):** Sebelum mengizinkan input pengeluaran baru, WAJIB mengecek session_id aktif dari Modul 1. Jika session_id == null (lapak belum buka), tombol "Catat Pengeluaran" wajib dinonaktifkan (Disabled) atau memunculkan alert: *"Buka lapak/sesi jualan terlebih dahulu!"*.
- **Logika Kamera:** Tangani error asinkron pada image_picker. Gunakan 	ry-catch jika user *cancel* kamera tanpa memotret, atau jika memori penuh.
- **Otomatisasi Biaya Sewa:** Harus ada fungsi yang mendengarkan (listen) ketika Sesi di Modul 1 dibuka, lalu otomatis menyisipkan data LocationFixedCost (biaya lapak tempat itu) ke dalam riwayat pengeluaran sesi tersebut.

**C. Standar UI / Widget:**
- Form nominal harga wajib memakai TextInputType.number agar *keyboard* angka yang muncul.
- Foto bukti struk/nota harus ditampilkan dalam bingkai berarsir dengan BoxDecoration dan bisa di-klik untuk *Preview* membesar.

---

## 3. Anggota 3 - Modul 3: Arus Kas Masuk (Penjualan)
**A. Ruang Lingkup File (Scope)**
- **Views:** product_catalog_screen.dart, pos_cashier_screen.dart.
- **ViewModels:** ProductViewModel, PosViewModel.
- **Database (Tabel):** Product, LocationPrice, Sale.

**B. Detail Logika & Edge Cases (Wajib Ditangani):**
- **Validasi Sesi Aktif (Kritis):** Layar Kasir tidak boleh bisa dipakai jika session_id aktif belum ada. (Sama batasannya dengan Modul 2).
- **Harga Dinamis Per Lokasi:** PosViewModel harus selalu mengecek location_id sesi saat ini. Query ke tabel LocationPrice: Apakah barang A punya harga beda di lokasi ini? Jika ya, pakaikan harga tersebut saat kasir berjalan.
- **Kalkulasi Balik Modal (Break-even):** PosViewModel harus menarik nilai TOTAL EXPENSE dari tabel milik Modul 2 untuk sesi aktif. Tiap kali ada pesanan kasir masuk, bandingkan dengan Total Penjualan. Jika melampaui, picu *Local Notification* "Lapak sudah balik modal".

**C. Standar UI / Widget:**
- Desain Kasir (POS) wajib memakai Grid tombol besar yang *Touch-Friendly* (NFR-03).
- Dilarang keras memakai keyboard (ngetik angka) saat jualan kasir berjalan. Cukup ketuk (tap) produk untuk menambah jumlah (Quantity +1).

---

## 4. Anggota 4 - Modul 4: Otak Analitik & Evaluasi
**A. Ruang Lingkup File (Scope)**
- **Views:** evaluation_dashboard_screen.dart, 	arget_profit_screen.dart.
- **ViewModels:** AnalyticsViewModel.
- **Database (Tabel):** ProfitTarget. (Modul ini bertugas menggabungkan/JOIN tabel Modul 1, 2, dan 3).

**B. Detail Logika & Edge Cases (Wajib Ditangani):**
- **Integritas Perhitungan (Kritis):** Algoritma utamanya: Rata-rata Laba = (Total Penjualan Sesi X - Total Pengeluaran Sesi X) / Jumlah Sesi di Lokasi X. Pastikan query JOIN akurat agar laba tidak tertukar lokasi.
- **Kasus Data Kosong (Null-Safety):** Jangan sampai terjadi "Division by Zero" (pembagian dengan angka nol) jika belum ada riwayat penjualan. Tampilkan layar *Empty State* ("Belum ada riwayat lapak untuk dievaluasi").
- **Proses Cetak PDF:** Penyusunan dokumen PDF berjalan asinkron dan butuh waktu. Wajib menahan UI dengan tampilan Loading (CircularProgressIndicator) agar tombol PDF tidak ditekan beruntun dan membuat HP lag.

**C. Standar UI / Widget:**
- Menggunakan skema warna yang sinkron (AppColors.success untuk untung, AppColors.error untuk rugi) di dalam grafik (chart).
- Klasemen/Ranking Lokasi harus punya *highlight* visual (misal: medali atau piala untuk ranking 1).

---

## ATURAN MUTLAK KELOMPOK (Golden Rules)
1. **Tidak Ada Fake UI:** Angka "Rp 0" atau teks "Kosong" harus merupakan respon sah dari State Provider. DILARANG KERAS menanam data mati (*hardcode string*) di file UI (*Screen*).
2. **Kepatuhan Rute:** Semua perpindahan antar halaman WAJIB menggunakan konstanta nama rute di lib/routes/app_routes.dart (pakai Navigator.pushNamed). DILARANG Navigator.push(MaterialPageRoute(...)) sembarangan.
3. **Standar Penanganan Error:** Jangan hanya pakai print(e). Gunakan ScaffoldMessenger.of(context).showSnackBar() atau buat file lib/core/widgets/error_dialog.dart jika terjadi error input agar *user experience* tetap baik.

4. **Kepatuhan Multi-Platform (Responsif):** Layout aplikasi WAJIB tampil rapi di HP, Tablet, dan Desktop. Gunakan ConstrainedBox(maxWidth: 600) untuk mencegah form/tombol melar (stretching) secara ekstrem di layar besar, atau gunakan LayoutBuilder untuk membuat Grid secara dinamis.

