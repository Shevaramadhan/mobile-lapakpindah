# DOKUMEN USE CASE SCENARIO
**Proyek:** LapakPindah
**Aktor Utama:** Pemilik Usaha (Tunggal)

Dokumen ini membedah skenario interaksi antara pengguna dan sistem berdasarkan Functional Requirements (FR) dari PRD.

---

## UC-01: Membuka Sesi Jualan Baru (Modul 1)
- **Terkait:** FR-01, FR-02, FR-03
- **Aktor:** Pemilik Usaha
- **Pre-Condition (Syarat Awal):** Pengguna sudah pernah mendaftarkan minimal 1 lokasi jualan (misal: "Alun-alun"). Tidak boleh ada sesi jualan lain yang sedang berstatus "Aktif".
- **Normal Flow (Jalur Sukses):**
  1. Pengguna membuka menu "Sesi Jualan".
  2. Sistem menampilkan daftar lokasi tersimpan.
  3. Pengguna memilih lokasi "Alun-alun" dan menekan "Buka Lapak".
  4. Sistem meminta input "Rencana Jam Tutup".
  5. Pengguna memasukkan jam tutup (misal: 22.00) lalu menekan "Konfirmasi".
  6. Sistem menyimpan sesi berstatus 'Aktif' di SQLite.
- **Alternative Flow (Jalur Gagal/Batal):**
  - *Jika pengguna masih punya sesi aktif di "Pasar Kaget":* Sistem menolak permintaan buka lapak baru dan menampilkan pesan "Tutup lapak sebelumnya terlebih dahulu!".
  - *Jika GPS tidak menyala saat menambah lokasi baru:* Sistem menampilkan peringatan "Mohon aktifkan lokasi (GPS) untuk mendata lapak".
- **Post-Condition (Hasil Akhir):** Sistem memiliki 1 ID Sesi aktif yang siap digunakan oleh Modul 2 dan 3. Indikator "Lapak Buka" menyala di layar utama.

---

## UC-02: Mencatat Pengeluaran Harian & Foto Nota (Modul 2)
- **Terkait:** FR-06, FR-07, FR-08, FR-09
- **Aktor:** Pemilik Usaha
- **Pre-Condition (Syarat Awal):** Wajib ada sesi lapak yang sedang "Aktif" (berasal dari UC-01).
- **Normal Flow (Jalur Sukses):**
  1. Saat sesi lapak baru dibuka, sistem otomatis meng-insert "Biaya Tetap" lokasi tersebut (contoh: Sewa Tempat Rp 5.000).
  2. Pengguna menekan tombol "Tambah Pengeluaran".
  3. Pengguna mengisi Form (Nama: "Cup Plastik", Harga: "15000").
  4. Pengguna menekan tombol "Kamera" dan memotret nota pembelian cup.
  5. Pengguna menekan "Simpan".
  6. Sistem memverifikasi limit modal (FR-09). Jika aman, sistem menyimpan ke SQLite.
- **Alternative Flow (Jalur Gagal/Batal):**
  - *Jika memori HP penuh saat jepret kamera:* Sistem menampilkan notifikasi error "Gagal menyimpan foto, penyimpanan penuh".
  - *Jika total pengeluaran melebihi Limit Harian:* Sistem tetap menyimpan, namun menembakkan notifikasi lokal "Peringatan: Pengeluaran melewati batas modal!".
  - *Jika lapak belum dibuka (Sesi belum aktif):* Tombol "Tambah Pengeluaran" terkunci (disabled) dan muncul *SnackBar* "Harap buka lapak di Modul 1 terlebih dahulu".
- **Post-Condition (Hasil Akhir):** Total pengeluaran harian sesi ini bertambah. File foto tersimpan di penyimpanan lokal HP.

---

## UC-03: Transaksi Kasir Penjualan Cepat (Modul 3)
- **Terkait:** FR-11, FR-12, FR-13, FR-14, FR-15
- **Aktor:** Pemilik Usaha
- **Pre-Condition (Syarat Awal):** Sesi lapak sedang "Aktif". Pengguna sudah punya minimal 1 Produk.
- **Normal Flow (Jalur Sukses):**
  1. Pengguna membuka layar Kasir.
  2. Sistem mengecek ID Lokasi saat ini, lalu menampilkan daftar harga khusus untuk lokasi tersebut (jika ada).
  3. Pembeli memesan es teh, pengguna menekan kotak menu "Es Teh (+1)".
  4. Sistem mengakumulasi total tagihan.
  5. Pengguna menekan tombol "Checkout".
  6. Sistem menyimpan data transaksi ke tabel Sale.
  7. Sistem membandingkan angka Penjualan dengan Pengeluaran (dari Modul 2). Jika penjualan lebih besar, sistem menembakkan Notif "Lapak Balik Modal!".
- **Alternative Flow (Jalur Gagal/Batal):**
  - *Jika keranjang kosong (0):* Tombol "Checkout" tidak merespon/terkunci.
  - *Jika produk dihapus permanen oleh pengguna:* Sistem tidak mengizinkan Hard Delete, melainkan mengubah status produk menjadi *non-aktif*, agar tidak muncul di layar kasir tapi riwayat penjualan masa lalunya tidak hancur.
- **Post-Condition (Hasil Akhir):** Total penjualan harian bertambah. Jarak menuju *Break-even Point* (Balik modal) semakin menipis.

---

## UC-04: Meninjau Evaluasi Rapor & Cetak PDF (Modul 4)
- **Terkait:** FR-16, FR-17, FR-18, FR-19
- **Aktor:** Pemilik Usaha
- **Pre-Condition (Syarat Awal):** Aplikasi sudah memiliki riwayat sesi yang ditutup dengan data penjualan/pengeluaran.
- **Normal Flow (Jalur Sukses):**
  1. Pengguna menekan tab "Evaluasi".
  2. Sistem menjalankan *query* JOIN ke SQLite dan menghitung (Total Penjualan - Total Pengeluaran) per lokasi.
  3. Sistem menampilkan Grafik Tren harian berbentuk garis naik-turun.
  4. Sistem menampilkan tabel Peringkat 1, 2, 3 lokasi paling untung.
  5. Pengguna menekan tombol "Ekspor PDF".
  6. Muncul *Loading Indicator* berputar. Sistem me-render *canvas* PDF.
  7. Sistem menyimpan PDF ke direktori HP dan memunculkan notifikasi sukses.
- **Alternative Flow (Jalur Gagal/Batal):**
  - *Jika belum ada riwayat penjualan sama sekali (Pengguna baru instal):* Sistem mendeteksi 
ull dan menampilkan layar Kosong (Empty State) bergambar ilustrasi "Belum ada riwayat jualan". Tidak terjadi *error aplikasi crash*.
- **Post-Condition (Hasil Akhir):** Pengguna memiliki file dokumen fisik (PDF) di HP-nya untuk evaluasi pribadi.
