# BUKU PEDOMAN UTAMA PROYEK LAPAKPINDAH
**Dokumen Resmi Persiapan Pengembangan & Demo Code Review**

---

## BAGIAN 1: PEMBAGIAN TUGAS & RUANG LINGKUP (SCOPE)

### Anggota 1 - Modul 1: Pondasi Lokasi & Sesi
- **Fokus Utama:** Mengelola profil lokasi dan siklus hidup sesi jualan (Buka/Tutup Lapak).
- **Analogi:** Kunci gembok toko. Tanpa Modul 1 membuka kunci (Buka Sesi), Modul 2 dan 3 sama sekali tidak boleh berjalan.
- **Alur Penggunaan (Flow):** Buka Profil Lokasi -> Tandai Maps -> Klik "Buka Lapak" -> Jualan berjalan -> Selesai -> Klik "Tutup Lapak".
- **Fitur Kritis:** GPS Tracking (geolocator), Integrasi Navigasi Google Maps (url_launcher).
- **Batasan (Boundary):** Modul ini adalah "Kunci Starter". Dilarang mengurus pencatatan uang/barang. Hanya memastikan **ID Sesi Aktif** tersedia untuk digunakan modul lain.

### Anggota 2 - Modul 2: Pintu Pengeluaran & Bukti Nota
- **Fokus Utama:** Mengelola arus kas keluar operasional harian.
- **Analogi:** Laci kasir untuk uang keluar (contoh: beli es batu dadakan, bayar retribusi lapak).
- **Alur Penggunaan (Flow):** Sesi dibuka Modul 1 -> Biaya tetap otomatis tersedot -> User nambah pengeluaran darurat -> Buka Kamera foto nota -> Uang Limit berkurang.
- **Fitur Kritis:** Penggunaan Kamera HP (image_picker) untuk memotret nota/struk pengeluaran.
- **Batasan (Boundary):** Setiap pengeluaran WAJIB terikat pada ID Sesi aktif milik Anggota 1. Form input tidak boleh bisa diklik jika lapak belum dibuka.

### Anggota 3 - Modul 3: Arus Kas Masuk (Penjualan)
- **Fokus Utama:** Sistem kasir (*Point of Sale*) cepat dan sederhana.
- **Analogi:** Mesin Kasir *Fast-Tap* (Satu kali ketuk barang langsung masuk).
- **Alur Penggunaan (Flow):** Sesi dibuka -> Pembeli datang -> User tekan tombol "Kopi +1" -> Sistem hitung total -> Sistem membandingkan dengan pengeluaran dari Modul 2 -> Jika profit, muncul Notif "Balik Modal!".
- **Fitur Kritis:** Harga dinamis berdasarkan lokasi lapak, Algoritma pengecekan Balik Modal (*Break-even Point*).
- **Batasan (Boundary):** Bukan aplikasi inventaris gudang. Tidak mengurus *stock opname* atau kembalian uang fisik. Fokus pada pencatatan uang masuk dan perbandingan dengan modal dari Modul 2.

### Anggota 4 - Modul 4: Otak Analitik & Evaluasi Rapor
- **Fokus Utama:** Menyajikan grafik dan perhitungan peringkat lokasi terbaik.
- **Analogi:** Buku Rapor Keuangan dan Papan Klasemen Akhir Bulan.
- **Alur Penggunaan (Flow):** Lapak sedang libur -> User buka tab Evaluasi -> Lihat Grafik Garis (Naik/Turun) -> Lihat Ranking Lokasi -> Klik Cetak Laporan PDF -> PDF bisa di-share.
- **Fitur Kritis:** Generate Laporan PDF (pdf & path_provider), Visualisasi Grafik Tren Harian/Mingguan.
- **Batasan (Boundary):** Hanya membaca (Read-Only) data dari Modul 1, 2, dan 3. Kritis pada kualitas JOIN Query di SQLite agar tidak terjadi *Division by Zero*.

---

## BAGIAN 2: ATURAN MUTLAK KELOMPOK (Golden Rules)
1. **Tidak Ada Fake UI:** Semua angka dan status harus merupakan respon sah dari State Provider. DILARANG KERAS menanam data mati (*hardcode string*) di file UI.
2. **Kepatuhan Rute:** Semua perpindahan antar halaman WAJIB menggunakan konstanta nama rute di lib/routes/app_routes.dart (Navigator.pushNamed).
3. **Kepatuhan Multi-Platform (Responsif):** Layout wajib rapi di HP, Tablet, Desktop. Gunakan ConstrainedBox(maxWidth: 600) untuk mencegah form/tombol melar (stretching) secara ekstrem di layar besar.

---

## BAGIAN 3: DETAIL FR (FUNCTIONAL REQUIREMENTS) & EDGE CASES

### Modul 1 (Anggota 1)
- **FR-01 (CRUD Lokasi):** Jangan lakukan *Hard Delete* jika lokasi sudah ada histori penjualan. Gunakan status non-aktif.
- **FR-02 (GPS):** Tangani error jika user mematikan izin lokasi (*Permission Denied*).
- **FR-03 (Buka/Tutup Sesi):** HANYA BOLEH ADA 1 SESI AKTIF. Tolak jika user mau buka lapak di tempat baru padahal lapak lama belum ditutup.
- **FR-04 (Maps):** Kirim Lat/Long dari FR-02 ke aplikasi Google Maps.
- **FR-05 (Notif Lokal):** Ingatkan user jika jam HP sudah melebihi rencana jam tutup lapak.

### Modul 2 (Anggota 2)
- **FR-06 (CRUD Pengeluaran):** Form WAJIB MATI jika tidak ada Sesi Aktif dari Modul 1.
- **FR-07 (Kamera):** Gunakan 	ry-catch jika user *cancel* kamera tanpa memotret atau memori HP penuh.
- **FR-08 (Biaya Tetap):** Trigger otomatis dari Modul 1. Begitu lapak dibuka, langsung insert biaya kebersihan/sewa ke pengeluaran.
- **FR-09 (Limit Pengeluaran):** Sediakan UI sisa batas modal hari ini.
- **FR-10 (Notif Lokal):** Peringatkan user jika total pengeluaran mendekati/melebihi limit FR-09.

### Modul 3 (Anggota 3)
- **FR-11 (CRUD Produk):** Jangan *Hard Delete* produk yang pernah terjual.
- **FR-12 (Kasir Penjualan):** UI kasir wajib sentuh (Tap-friendly). Tidak perlu ketik jumlah pesanan pakai keyboard.
- **FR-13 (Harga Khusus):** Saat kasir berjalan, sistem wajib ngecek lapak mana yang sedang buka, lalu gunakan harga khusus lokasi tersebut (jika ada).
- **FR-14 (Selisih Modal):** Ambil Total Pengeluaran dari Modul 2, lalu tampilkan sisa kekurangannya secara real-time di layar kasir.
- **FR-15 (Notif Lokal):** Kabari user jika total penjualan pertama kali mengalahkan modal (Lapak Balik Modal!).

### Modul 4 (Anggota 4)
- **FR-16 (Kalkulasi Peringkat):** Tangani dengan rapi jika ada lokasi yang belum punya riwayat jualan sama sekali (Empty State).
- **FR-17 (Grafik Tren):** Visualisasikan garis laba naik/turun yang rapi.
- **FR-18 (Target Laba):** Sediakan progress bar persentase target.
- **FR-19 (Ekspor PDF):** Wajib tampilkan *Loading Indicator* selama HP men-generate PDF agar layar tidak freeze.
- **FR-20 (Notif Lokal):** Alarm mingguan untuk mengingatkan mengecek laporan.

---

## BAGIAN 4: PERSIAPAN UJIAN DEMO & CODE REVIEW (Practical Challenge)

Tugas individu mensyaratkan 1 Workflow Lengkap (Event -> State -> Validation -> Feedback -> Navigation) yang harus bisa didemokan berjalan di device.

### 4.1. Blueprint Workflow Demo per Anggota
Pilih 1 fitur andalan untuk didemokan agar kelima kriteria terpenuhi:

* **Anggota 1: Buka Lapak (Sesi)**
  - *Event:* Mengisi rencana jam tutup dan klik "Buka Lapak".
  - *State:* Aplikasi berubah dari idle ke loading.
  - *Validation:* Cek apakah ada sesi lain yang masih aktif.
  - *Feedback:* Muncul Loading, lalu SnackBar "Lapak Berhasil Dibuka!".
  - *Navigation:* Kembali ke halaman utama, indikator "Toko Buka" menyala hijau.

* **Anggota 2: Input Pengeluaran + Nota**
  - *Event:* Isi nominal biaya, jepret foto nota pakai Kamera, lalu klik "Simpan".
  - *State:* Menyimpan file gambar dan data ke SQLite (isLoading = true).
  - *Validation:* Cegah jika nominal diisi huruf atau foto dibiarkan kosong.
  - *Feedback:* Menampilkan indikator loading putar, disusul SnackBar Sukses.
  - *Navigation:* Navigator.pop(context) ke daftar pengeluaran, daftar otomatis *refresh* memunculkan item baru.

* **Anggota 3: Transaksi Kasir**
  - *Event:* Mengetuk (Tap) menu makanan, lalu klik "Checkout".
  - *State:* Menyimpan total pesanan dan mengurangi sisa selisih balik modal.
  - *Validation:* Cek apakah Sesi masih aktif. Cegah checkout jika keranjang 0.
  - *Feedback:* SnackBar "Transaksi Berhasil" (dan mungkin notif Balik Modal).
  - *Navigation:* Kembali ke layar daftar pesanan, keranjang di-reset jadi kosong.

* **Anggota 4: Ekspor PDF**
  - *Event:* Memilih lokasi dan menekan tombol "Cetak Laporan PDF".
  - *State:* Proses *rendering* dokumen di latar belakang (isGeneratingPDF = true).
  - *Validation:* Cek apakah data penjualan kosong. Jika kosong, tolak pencetakan.
  - *Feedback:* Tampilkan CircularProgressIndicator berputar cukup lama, lalu SnackBar "PDF tersimpan di folder Document".
  - *Navigation:* Buka aplikasi *File Viewer* bawaan HP untuk melihat hasil PDF.

### 4.2. Persiapan Hadapi "Ujian Coba Ubah & AI Prompting"
Saat dosen menguji langsung di tempat (Live Coding):
1. **Kenali Widget Tree Anda:** Dosen akan menyuruh *"Coba ganti warna tombol simpannya jadi merah"*. Pastikan Anda tahu file *Screen* Anda dan di baris mana ElevatedButton itu berada.
2. **Pahami Logika ViewModel:** Jika dosen meminta *"Ubah pesan error validasinya"*, Anda harus bisa langsung membuka file lib/utils/validators.dart atau ViewModel terkait.
3. **Ujian AI Prompt:** Jika terjadi error saat *live demo* atau disuruh menggunakan AI, berikan prompt seperti ini: 
   *"Saya mengerjakan Modul 2. Saat klik Kamera, terjadi Exception X di Android 14. Tolong berikan solusi spesifik untuk kode ini tanpa menggunakan package pihak ketiga baru."*


