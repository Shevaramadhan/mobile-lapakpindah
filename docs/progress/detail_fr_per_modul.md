# Pedoman Ekstra Detail Functional Requirements (FR-01 s.d. FR-20)
**Tujuan:** Panduan teknis mutlak bagi setiap anggota kelompok agar memahami persis apa yang harus dibuat (Fitur, Logika, Batasan) untuk masing-masing FR sesuai PRD. Mencegah cacat logika (logic flaw) dan inkonsistensi.

---

## 🏗 MODUL 1: Lokasi & Sesi Jualan (PIC: Anggota 1)
*Modul ini adalah "Kunci Starter" dari aplikasi. Jika Modul 1 rusak/salah logika, Modul 2, 3, dan 4 tidak akan bisa beroperasi.*

- **FR-01 (CRUD Lokasi):**
  - **Instruksi:** Buat antarmuka (Form) untuk menambah, mengedit, dan menghapus nama tempat (misal: "Pasar Kaget Minggu") beserta catatannya.
  - **Batasan/Logika Kritis:** Saat user menghapus lokasi, **CEK DULU** apakah lokasi ini sudah punya histori Sesi Jualan. Jika sudah, JANGAN DIHAPUS (bisa merusak data keuangan masa lalu). Cukup *hide* atau ubah statusnya jadi *inactive*.
- **FR-02 (Device GPS):**
  - **Instruksi:** Di dalam Form Lokasi, sediakan satu tombol "Ambil Koordinat Saat Ini". Gunakan geolocator untuk mendapatkan Latitude & Longitude.
  - **Batasan/Logika Kritis:** Tangani error jika user menolak izin lokasi (*Location Permission Denied*) atau GPS HP sedang mati. Munculkan pesan peringatan ramah, jangan biarkan aplikasi *crash*.
- **FR-03 (Manajemen Sesi):**
  - **Instruksi:** User bisa menekan tombol "Buka Lapak". Sistem membuat *record* baru di tabel SalesSession dengan mencatat Jam Buka dan Rencana Jam Tutup.
  - **Batasan/Logika Kritis:** **ATURAN EMAS:** Hanya boleh ada **SATU** sesi berstatus "Aktif" di seluruh aplikasi. Jika user coba buka lapak di "Alun-alun" padahal lapak "Pasar Kaget" belum ditutup, sistem WAJIB menolak.
- **FR-04 (Navigasi Maps):**
  - **Instruksi:** Di daftar riwayat lokasi, buat tombol ikon Maps. Gunakan url_launcher untuk membuka aplikasi Google Maps bawaan HP berdasarkan titik koodinat (Lat/Long) dari FR-02.
- **FR-05 (Notifikasi Lokal):**
  - **Instruksi:** Baca "Rencana Jam Tutup" dari FR-03. Pasang *trigger* lutter_local_notifications. Jika jam di HP sudah melewati jam tersebut tapi sesi masih berstatus "Aktif", munculkan notif: *"Waktunya tutup lapak! Jangan lupa akhiri sesi jualanmu."*

---

## 📸 MODUL 2: Pengeluaran & Bukti Nota (PIC: Anggota 2)
*Modul ini mengatur arus uang keluar. Selalu bergantung (menempel) pada Sesi Aktif milik Modul 1.*

- **FR-06 (CRUD Pengeluaran):**
  - **Instruksi:** Buat daftar riwayat pengeluaran dan form input biaya (nama pengeluaran & nominal rupiah).
  - **Batasan/Logika Kritis:** Semua biaya wajib punya session_id. **Jika Modul 1 belum membuka sesi (tidak ada sesi aktif), non-aktifkan (disable) tombol Tambah Pengeluaran** dan beri peringatan *"Buka lapak dulu!"*.
- **FR-07 (Device Kamera):**
  - **Instruksi:** Di dalam Form FR-06, wajibkan fitur memotret nota/struk pakai kamera (image_picker). Simpan *path* foto ke database SQLite.
  - **Batasan/Logika Kritis:** Beri penanganan *error* (try-catch) jika user buka kamera tapi batal memotret, atau jika penyimpanan HP penuh.
- **FR-08 (Biaya Tetap / Otomatisasi):**
  - **Instruksi:** User bisa mendaftarkan "Biaya Tetap" untuk suatu lokasi (contoh: Uang Kebersihan Rp5.000 di Alun-alun). 
  - **Batasan/Logika Kritis:** Saat Modul 1 memanggil fungsi "Buka Lapak" di Alun-alun, Modul 2 harus secara gaib (otomatis) meng-insert "Uang Kebersihan Rp5.000" ke daftar pengeluaran sesi tersebut tanpa perlu user ketik ulang.
- **FR-09 (Batas Pengeluaran):**
  - **Instruksi:** Beri fitur agar user bisa mengatur "Batas Modal Harian" (Limit) di sesi yang sedang berjalan. Tampilkan sisa kuota modal (Limit - Total Pengeluaran) secara *real-time*.
- **FR-10 (Notifikasi Lokal):**
  - **Instruksi:** Jika Total Pengeluaran (FR-06 + FR-08) nilainya menyentuh atau melampaui Batas Modal (FR-09), langsung bunyikan notifikasi sistem: *"Awas! Pengeluaran lapakmu sudah melewati batas modal harian!"*

---

## 🛒 MODUL 3: Pencatatan Penjualan (PIC: Anggota 3)
*Modul pencetak uang masuk. Berjalan seiringan dengan Modul 2.*

- **FR-11 (CRUD Produk):**
  - **Instruksi:** Buat master katalog Menu/Barang (Nama & Harga Standar).
  - **Batasan/Logika Kritis:** Jangan izinkan penghapusan permanen (DELETE SQL) pada produk yang sudah pernah laku terjual di sesi lalu. Cukup beri status is_active = false agar histori keuangan lama tidak error (NFR-05).
- **FR-12 (Catat Penjualan):**
  - **Instruksi:** Buat UI Kasir cepat (Kotak-kotak menu). User ketuk (tap) menu, otomatis mencatat penjualan (+1) di Sesi Aktif.
  - **Batasan/Logika Kritis:** Sama seperti Modul 2, UI Kasir ini **wajib mati/terkunci** jika Sesi Jualan di Modul 1 belum dibuka.
- **FR-13 (Harga Khusus per Lokasi):**
  - **Instruksi:** Harga es teh standar Rp5.000. Tapi user bisa menyetel harga es teh di "Pantai" jadi Rp8.000.
  - **Batasan/Logika Kritis:** Di halaman Kasir (FR-12), sistem wajib melihat location_id dari sesi saat ini. Jika lokasinya di "Pantai", paksa sistem memakai harga Rp8.000. Jika tidak, pakai harga standar.
- **FR-14 (Selisih Balik Modal):**
  - **Instruksi:** Tarik "Total Pengeluaran Sesi Aktif" dari Modul 2. Kurangi dengan "Total Penjualan Sesi Aktif" dari Modul 3. Tampilkan angka selisihnya di layar Kasir secara *real-time* ("Kurang Rp 20.000 untuk balik modal").
- **FR-15 (Notifikasi Lokal):**
  - **Instruksi:** Berdasarkan angka dari FR-14, ketika Total Penjualan akhirnya mengalahkan (>) Total Pengeluaran untuk pertama kalinya hari itu, tembak notifikasi: *"Selamat! Lapakmu hari ini sudah balik modal!"*

---

## 📊 MODUL 4: Evaluasi Lokasi (PIC: Anggota 4)
*Modul penutup dan paling kompleks di sisi algoritma/SQL Query. Hanya nge-Read data, dilarang mengubah/menambah data transaksi Modul 1, 2, 3.*

- **FR-16 (Kalkulasi & Peringkat Lokasi):**
  - **Instruksi:** Hitung Laba Bersih = (Penjualan Modul 3) - (Pengeluaran Modul 2). Kelompokkan berdasarkan Lokasi (Modul 1). Susun tabel/list dari Laba Rata-rata tertinggi (Peringkat 1) ke terendah.
  - **Batasan/Logika Kritis:** Hati-hati dengan *Division by Zero*. Jika ada lokasi yang baru didaftarkan tapi belum pernah dipakai jualan, pastikan labanya Rp 0, bukan aplikasi menjadi *Crash* atau me-return *Null/NaN*.
- **FR-17 (Grafik Tren Laba):**
  - **Instruksi:** Gunakan *package* (misal: l_chart) untuk menggambar garis naik-turun keuntungan sebuah lokasi dari hari ke hari atau minggu ke minggu.
- **FR-18 (Target Laba per Lokasi):**
  - **Instruksi:** User bisa memasukkan teks "Target untung di Alun-alun: Rp 500.000/minggu". Bandingkan dengan hasil FR-16, lalu buat bar indikator (Tercapai / Belum Tercapai).
- **FR-19 (Ekspor PDF):**
  - **Instruksi:** Ambil layar ranking (FR-16), ubah menjadi file PDF, simpan ke memori HP menggunakan package pdf dan path_provider.
  - **Batasan/Logika Kritis:** Proses ini berat. Tampilkan *Loading Indicator* (berputar) agar layar tidak *freeze* dan user tidak memencet tombol berkali-kali.
- **FR-20 (Notifikasi Lokal Mingguan):**
  - **Instruksi:** Bikin jadwal notifikasi (Scheduled Notification) otomatis setiap hari Minggu jam 20:00. Pesan: *"Saatnya meninjau Rapor Keuntungan! Cek lokasi mana yang paling cuan minggu ini."*

