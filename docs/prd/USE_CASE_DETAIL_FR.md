# DOKUMEN USE CASE DETAIL (PER-FR)
**Proyek:** LapakPindah
**Aktor Utama:** Pemilik Usaha

Dokumen ini membedah skenario interaksi secara spesifik satu per satu untuk ke-20 Functional Requirements (FR).

---

## 🏗 MODUL 1: LOKASI & SESI JUALAN (Anggota 1)

**UC-01: Mengelola Data Lokasi (Mewakili FR-01)**
- **Pre-Condition:** Aplikasi berjalan normal.
- **Normal Flow:** User menambah lokasi "Alun-alun", mengisi catatan, dan menekan simpan. Sistem menyimpan ke SQLite.
- **Alternative Flow:** Jika user mencoba menghapus lokasi yang sudah memiliki riwayat sesi, sistem menolak *Hard Delete* dan mengubah statusnya menjadi non-aktif.

**UC-02: Mendapatkan Koordinat GPS (Mewakili FR-02)**
- **Pre-Condition:** User sedang berada di halaman Form Tambah Lokasi.
- **Normal Flow:** User menekan tombol "Ambil Koodinat". Sistem menyalakan sensor GPS dan mendapatkan angka Lat/Long, lalu menampilkannya di form.
- **Alternative Flow:** Jika izin lokasi ditolak, sistem memunculkan pesan peringatan "Mohon izinkan akses lokasi di Pengaturan HP".

**UC-03: Membuka dan Menutup Sesi Jualan (Mewakili FR-03)**
- **Pre-Condition:** Minimal ada 1 lokasi tersimpan.
- **Normal Flow:** User memilih lokasi, mengatur rencana jam tutup, lalu klik "Buka Lapak". Selesai jualan, user menekan "Tutup Lapak".
- **Alternative Flow:** Jika user memencet "Buka Lapak" di Pasar Kaget, padahal sesi di Alun-alun belum ditutup, sistem memunculkan pop-up error "Selesaikan sesi sebelumnya terlebih dahulu!".

**UC-04: Mendapatkan Petunjuk Arah (Mewakili FR-04)**
- **Pre-Condition:** HP memiliki koneksi internet dan aplikasi Google Maps.
- **Normal Flow:** User menekan tombol "Arahkan" pada detail lokasi. Sistem mengarahkan user keluar dari aplikasi menuju Google Maps.
- **Alternative Flow:** Jika aplikasi Maps tidak ada, muncul pesan "Aplikasi peta tidak ditemukan".

**UC-05: Notifikasi Tutup Lapak (Mewakili FR-05)**
- **Pre-Condition:** Sesi sedang aktif dan rencana jam tutup telah diatur.
- **Normal Flow:** Ketika waktu HP melewati jam tutup, aplikasi menembakkan notifikasi lokal.

---

## 📸 MODUL 2: PENGELUARAN & BUKTI NOTA (Anggota 2)

**UC-06: Mencatat Pengeluaran Sesi (Mewakili FR-06)**
- **Pre-Condition:** Sesi lapak sedang aktif di Modul 1.
- **Normal Flow:** User membuka form, memasukkan nama barang dan harga, lalu simpan.
- **Alternative Flow:** Jika tidak ada sesi aktif, tombol pengeluaran mati (disabled) atau muncul pesan "Buka sesi jualan terlebih dahulu". Jika harga diisi huruf, form tervalidasi error.

**UC-07: Melampirkan Bukti Nota dengan Kamera (Mewakili FR-07)**
- **Pre-Condition:** Memori HP mencukupi dan izin kamera diberikan.
- **Normal Flow:** User memencet ikon Kamera, mengambil gambar nota, gambar muncul di *preview*, lalu sistem menyimpan file ke storage lokal.
- **Alternative Flow:** Jika user memencet *back* saat kamera terbuka (batal memotret), sistem kembali ke form tanpa error.

**UC-08: Pencatatan Biaya Tetap Otomatis (Mewakili FR-08)**
- **Pre-Condition:** Lokasi memiliki "Biaya Tetap" tersimpan. Sesi baru dibuka.
- **Normal Flow:** Modul 2 otomatis membuat *record* pengeluaran di SQLite tanpa intervensi user.
- **Alternative Flow:** -

**UC-09: Memantau Batas Pengeluaran Sesi (Mewakili FR-09)**
- **Pre-Condition:** User menetapkan Batas Modal harian.
- **Normal Flow:** Setiap user input pengeluaran baru (UC-06), indikator sisa saldo di layar berkurang secara *real-time*.
- **Alternative Flow:** Jika pengeluaran > limit, bar sisa saldo bisa berubah warna (misal: merah).

**UC-10: Notifikasi Peringatan Modal Habis (Mewakili FR-10)**
- **Pre-Condition:** Sisa batas pengeluaran menyentuh Rp0 atau kurang.
- **Normal Flow:** Sistem mengirim notifikasi lokal "Awas, modal jualanmu sudah melebih batas hari ini!".

---

## 🛒 MODUL 3: PENCATATAN PENJUALAN (Anggota 3)

**UC-11: Mengelola Katalog Produk (Mewakili FR-11)**
- **Pre-Condition:** -
- **Normal Flow:** User menambah produk "Nasi Goreng" dan harganya.
- **Alternative Flow:** Penghapusan produk yang sudah pernah terjual akan dicegah secara *Hard Delete* (mirip UC-01).

**UC-12: Mencatat Penjualan (Mewakili FR-12)**
- **Pre-Condition:** Sesi sedang aktif.
- **Normal Flow:** User di layar kasir, melakukan *tap* pada kotak produk. Keranjang terisi, sistem menghitung total uang. Klik Checkout, simpan ke database.
- **Alternative Flow:** Sama seperti UC-06, tidak bisa transaksi jika lapak belum buka. Jika keranjang kosong, tombol Checkout mati.

**UC-13: Menyesuaikan Harga Per Lokasi (Mewakili FR-13)**
- **Pre-Condition:** Sesi aktif di lokasi tertentu (misal: Pantai).
- **Normal Flow:** Sistem mendeteksi location_id Pantai. Sistem mengecek SQLite, jika Pantai punya harga khusus, layar Kasir akan menampilkan harga tersebut.

**UC-14: Memantau Selisih Balik Modal (Mewakili FR-14)**
- **Pre-Condition:** Ada pengeluaran tercatat di Modul 2.
- **Normal Flow:** Teks di layar kasir otomatis menampilkan: Total Jual - Total Keluar. Muncul teks "Kurang Rp X untuk balik modal".

**UC-15: Notifikasi Balik Modal (Mewakili FR-15)**
- **Pre-Condition:** Angka UC-14 berbalik menjadi surplus (Total Jual > Total Keluar).
- **Normal Flow:** Sistem mengirimkan notif gembira "Selamat, lapakmu sudah balik modal!".

---

## 📊 MODUL 4: EVALUASI LOKASI (Anggota 4)

**UC-16: Melihat Peringkat & Laba Bersih (Mewakili FR-16)**
- **Pre-Condition:** Data transaksi tersedia.
- **Normal Flow:** Sistem melakukan JOIN tabel penjualan dan pengeluaran per lokasi. Sistem merender urutan ranking 1, 2, 3 di layar.
- **Alternative Flow:** Jika tabel transaksi benar-benar kosong, tangani *Division by Zero* dan tampilkan UI "Belum ada riwayat".

**UC-17: Melihat Grafik Tren Laba (Mewakili FR-17)**
- **Pre-Condition:** -
- **Normal Flow:** Sistem merender grafik garis berdsarkan waktu (hari/minggu).

**UC-18: Mengelola Target Laba (Mewakili FR-18)**
- **Pre-Condition:** User menginput target untung Rp X.
- **Normal Flow:** Bar indikator menunjukkan persentase progres harian dibandingkan target.

**UC-19: Mengekspor Laporan PDF (Mewakili FR-19)**
- **Pre-Condition:** Memori HP cukup.
- **Normal Flow:** User klik "Cetak PDF". Muncul Loading. Setelah selesai render, PDF tersimpan dan bisa di-share.
- **Alternative Flow:** Jika diklik berkali-kali secara cepat, *Loading Indicator* mengunci layar agar HP tidak nge-lag atau memproses *render* ganda.

**UC-20: Notifikasi Rapor Mingguan (Mewakili FR-20)**
- **Pre-Condition:** -
- **Normal Flow:** Terjadwal pada *cron time* tertentu (misal: Minggu 20.00) untuk memberikan notifikasi evaluasi.
