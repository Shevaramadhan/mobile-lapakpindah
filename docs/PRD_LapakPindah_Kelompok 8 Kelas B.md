# **PROJECT PRD** 

## _Product Requirements Document_ 

|**Project Name**|LapakPindah – Aplikasi Mobile Manajemen<br>Operasional, Pemetaan Lokasi Jualan, dan Evaluasi<br>Penjualan bagi UMKM Keliling|
|---|---|
|**Team**|1.Luthfi Harisna Mufti-2411523019<br>2.Sheva Ramadhan-2411523020<br>3.Ihsan Auliya Habiburrohim-2411523022|
||4.Siti Hardini Akhna El Charoz-2411523037|
|**Course**|Mobile Programming|
|**Version**|1.0|
|**Date**|12 September 2026|



## **Tujuan dokumen** 

PRD ini  Kami Rancang digunakan untuk menjelaskan apa yang akan dibangun, untuk siapa, mengapa produk dibutuhkan, dan pembagian modul teknis untuk 4 mahasiswa pada Kelompok 8 Kelas B. Dokumen ini disusun mematuhi Aturan Project Mobile 2026 (4 Modul Mandiri, Pengelolaan CRUD penuh per modul, Fitur Device Fungsional, Notifikasi Lokal Relevan, dan Penyimpanan Data Lokal SQLite tanpa Firebase). 

## **1. Problem & Users** 

Pemilik usaha mikro yang berjualan secara berpindah-pindah (nomaden) seperti food truck, gerobak modern, stan bazar, dan pedagang pasar kaget kesulitan melacak lokasi jualan mana yang menghasilkan keuntungan tertinggi setelah dikurangi biaya sewa dan operasional. Mereka juga tidak memiliki sistem pencatatan kasir dan pengarsipan operasional yang dapat berfungsi maksimal di area terbuka tanpa bergantung pada koneksi internet 

## **1.1 Problem Statement** 

Pemilik usaha mikro yang berjualan secara berpindah-pindah (nomaden) seperti food truck, gerobak modern, stan bazar, dan pedagang pasar kaget kesulitan melacak lokasi jualan mana yang menghasilkan keuntungan tertinggi setelah dikurangi biaya sewa dan operasional. Mereka juga tidak memiliki sistem pencatatan kasir dan pengarsipan operasional yang dapat berfungsi maksimal di area terbuka tanpa bergantung pada koneksi internet. 

## **1.2 Target Users** 

Pemilik atau pengelola usaha mikro / UMKM bergerak (berbasis 1 role pengguna utama: Owner/Operator) yang sering berpindah-pindah lokasi jualan dan membutuhkan efisiensi pencatatan langsung lewat ponsel di tangan (on-the-go). 

Mobile Programming — Project PRD Template 

## **1.3 User Needs / Pain Points** 

- **Kebutuhan 1 (Koneksi & Daya):** Area berjualan di luar ruangan sering kali tidak memiliki sinyal internet yang stabil, membuat aplikasi kasir berbasis cloud menjadi lambat atau tidak bisa digunakan. 

- **Kebutuhan 2 (Riwayat Lokasi):** Pemilik kesulitan mengingat dan membandingkan secara akurat data historis mengenai lokasi jualan mana yang paling ramai pembeli pada waktu tertentu. 

- **Kebutuhan 3 (Bukti Nota & Karcis):** Pengeluaran mendadak di lokasi (beli es batu tambahan, gas, cup plastik, atau bayar karcis retribusi sampah) hanya berupa struk sobekan kertas yang sering hilang atau basah di laci gerobak. 

- **Kebutuhan 4 (Peringatan Stok Habis):** Pedagang sering tidak sadar stok bahan baku tertentu sudah menipis hingga ada pembeli memesan dan terpaksa ditolak karena bahan habis. 

- **Kebutuhan 5 (Rekap Kas Tutup Toko):** Sering kelelahan dan lupa melakukan rekapitulasi hitung uang kas fisik saat menutup lapak di malam hari. 

## **1.4 Project Goal** 

Membangun aplikasi manajemen operasional semi-online (offline-first) khusus UMKM nomaden bernama LapakPindah yang mengintegrasikan pemetaan lokasi via GPS, pencatatan biaya dan foto nota via kamera, kasir cepat dengan pemotongan stok otomatis berbasis resep, serta evaluasi profitabilitas penjualan berbasis lokasi dan ekspor laporan PDF, di mana seluruh operasional inti toko dapat berjalan mandiri secara luring tanpa ketergantungan koneksi internet. 

## **2. Product Requirements** 

**Petunjuk:** Turunkan masalah dan tujuan menjadi kebutuhan produk. Bedakan _functional requirements_ (apa yang sistem lakukan) dan _non-functional requirements_ (bagaimana kualitas/batasan sistem). Pastikan semuanya konsisten dengan _core features_ dan _user flow._ 

## **2.1 Functional Requirements** 

Tuliskan apa saja yang harus dapat dilakukan oleh sistem/aplikasi dari sudut pandang pengguna. Gunakan requirement yang spesifik dan dapat diuji. 

**Modul 1: Pemetaan Lokasi Lapak (Tanggung Jawab: Anggota 1)** 

- **FR-01 (Core - CRUD):** Pengguna dapat mencatat, melihat, mengedit, dan menghapus data lokasi lapak harian (Nama Event/Lokasi, Tanggal, Jam Buka/Tutup, dan Biaya Sewa Lapak). 

- **FR-02 (Core - Device GPS):** Pengguna dapat mengunci titik koordinat presisi letak lapak hari tersebut menggunakan fitur GPS (Location Services) perangkat dengan satu ketukan (Check-in Spot). 

- **FR-03 (Core):** Sistem dapat menampilkan riwayat lokasi yang pernah dikunjungi dalam bentuk daftar kartu spot dan menyediakan tombol navigasi cepat yang langsung membuka titik koordinat tersebut di aplikasi Google Maps bawaan ponsel (url_launcher). 

- **FR-04 (Core):** Pengguna dapat memfilter riwayat lokasi berdasarkan rentang tanggal atau nama event, serta menghasilkan teks promosi otomatis beserta tautan Google Maps yang siap dibagikan ke WhatsApp Story / Status (share_plus). 

Mobile Programming — Project PRD Template 

- **FR-05 (Notifikasi Lokal):** Sistem mengirimkan Notifikasi Lokal pengingat harian (misal: jam 09.00) agar pengguna membagikan rute lokasi lapak hari ini ke media sosial / WhatsApp. 

## **Modul 2: Pencatatan Biaya Lapak & Bukti Nota (Tanggung Jawab: Anggota 2)** 

- **FR-06 (Core - CRUD):** Pengguna dapat mencatat, melihat, memperbarui, dan menghapus pengeluaran biaya operasional harian di lokasi (sewa stan, karcis sampah/kebersihan, listrik, es batu tambahan, atau gas darurat). 

- **FR-07 (Core - Device Kamera):** Pengguna dapat memotret nota fisik, karcis retribusi kertas, atau struk belanja bahan secara langsung menggunakan Kamera Perangkat (image_picker) sebagai bukti transaksi sah yang terikat pada ID lokasi hari tersebut. 

- **FR-08 (Core):** Sistem mengelompokkan pengeluaran ke dalam kategori spesifik (Biaya Sewa Lapak vs Biaya Bahan Tambahan) untuk memudahkan analisis struktur modal. 

- **FR-09 (Core):** Sistem mengalkulasi akumulasi total biaya operasional yang telah dikeluarkan pada lokasi dan tanggal yang sedang aktif secara otomatis. 

- **FR-10 (Notifikasi Lokal):** Sistem memunculkan Notifikasi Lokal di sore hari (misal: jam 17.00) untuk mengingatkan pengguna memotret dan mendata seluruh karcis retribusi atau nota belanja bahan sebelum tercecer/hilang. 

## **Modul 3: Kasir Cepat & Inventaris Resep Bahan (Tanggung Jawab: Anggota 3)** 

- **FR-11 (Core - CRUD):** Pengguna dapat mengelola katalog menu jualan (menambah menu baru, mengisi takaran resep bahan baku per porsi, menentukan harga jual, serta menginput dan mengedit modal stok awal bahan yang dibawa dari rumah). 

- **FR-12 (Core):** Pengguna dapat melakukan pencatatan transaksi penjualan kasir secara cepat (Fast Tap POS), dan sistem menghitung otomatis total belanjaan serta uang kembalian pembeli. 

- **FR-13 (Core):** Setiap transaksi penjualan kasir berhasil, sistem secara otomatis memotong stok bahan baku terkait sesuai takaran resep dan menghitung sisa porsi yang masih dapat dijual. 

- **FR-14 (Core):** Pengguna dapat membatalkan (void) transaksi penjualan kasir jika terjadi salah ketuk sebelum tutup sesi kasir, dan sistem akan mengembalikan stok bahan baku secara otomatis. 

- **FR-15 (Notifikasi Lokal):** Sistem memicu Notifikasi Lokal Otomatis saat bahan baku tertentu mencapai batas kritis (<= 10% atau sisa 5 porsi): 'Peringatan Stok Kritis! Stok Cup Plastik sisa 5 pcs, segera siapkan tambahan sebelum pesanan ramai!'. 

**Modul 4: Evaluasi Performa Lokasi & Ekspor PDF (Tanggung Jawab: Anggota 4)** 

- **FR-16 (Core):** Sistem dapat menggabungkan data dari Modul 1 (Lokasi & Biaya Sewa), Modul 2 (Biaya Operasional & Bahan), dan Modul 3 (Penjualan) untuk menghitung laba bersih riil per titik lokasi spot jualan. 

- **FR-17 (Core):** Sistem menampilkan grafik analitik harian/mingguan yang menyusun peringkat profitabilitas lokasi (Spot ROI Ranking dari yang paling menguntungkan hingga yang paling sepi/merugi). 

- **FR-18 (Core - CRUD):** Pengguna dapat menyetel, melihat, dan memperbarui target omzet bulanan, dan sistem akan mengalkulasi persentase pencapaian berdasarkan data penjualan terkini. 

Mobile Programming — Project PRD Template 

- **FR-19 (Core - Device File Storage):** Pengguna dapat mengekspor laporan rapor performa lokasi dan rekapitulasi laba bersih ke dalam dokumen PDF resmi (pdf & path_provider) yang tersimpan di memori perangkat dan siap dibagikan ke mitra/pemilik modal. 

- **FR-20 (Notifikasi Lokal):** Sistem mengirimkan Notifikasi Lokal setiap akhir pekan (misal: Minggu malam jam 21.00) berisi pengingat untuk meninjau evaluasi lokasi terbaik minggu ini. 

## **2.2 Non-functional Requirements** 

Tuliskan kualitas atau batasan sistem, bukan fitur. Jika memungkinkan, gunakan kriteria yang dapat diukur. 

- **NFR-01 (Offline-First):** Seluruh proses pengelolaan data dilakukan 100% secara lokal menggunakan SQLite (sqflite) tanpa menggunakan layanan Firebase, sesuai aturan proyek. 

- **NFR-02 (Performance):** Proses input barang masuk ke keranjang kasir hingga pemotongan stok bahan baku di balik layar tidak boleh memakan waktu lebih dari 1 detik agar antrean pembeli bazar tidak terhambat. 

- **NFR-03 (Usability):** Antarmuka dibangun khusus dengan Flutter Widget yang menggunakan tombol-tombol berukuran besar (touch-friendly) dan tata letak kontras tinggi agar mudah ditekan oleh pedagang yang bekerja cepat di luar ruangan. 

- **NFR-04 (Reliability):** Fungsi Local Scheduled Notification wajib tereksekusi tepat waktu di latar belakang tanpa bergantung pada ketersediaan koneksi internet. 

- **NFR-05 (Data Integrity):** Relasi data antara titik lokasi, nota pengeluaran operasional, dan transaksi penjualan terjaga secara konsisten di database lokal SQLite (Foreign Key integrity). 

## **2.3 Core Features** 

|**No.**|**Core Feature**|**Purpose / Value**|
|---|---|---|
|1|**GPS Venue Tracker & hatsApp**<br>**Broadcast**|Merekam koordinat lokasi<br>berpindah secara otomatis dan<br>mempermudah berbagi tautan<br>Google Maps lapak terkini ke<br>pelanggan di media sosial.|
|2|**Expense & Receipt Photo**<br>**Tracker**|Mengarsipkan karcis retribusi<br>pasar dan nota belanja bahan<br>mendadak lewat kamera agar<br>modal harian tercatat akurat dan<br>bukti fisik tidak hilang.|
|3|**Recipe-Based Fast POS & Stock**<br>**Alert**|Kasir cepat sekali sentuh yang<br>otomatis memotong stok bahan<br>baku berdasarkan resep porsi serta<br>memberi peringatan saat bahan<br>menipis.|
|4|**Location Profitability Matrix &**<br>**PDF Export**|Memberikan wawasan berbasis<br>data mengenai lokasi jualan mana<br>yang paling menguntungkan<br>(omzet dikurangi sewa dan bahan)|



Mobile Programming — Project PRD Template 

|serta mengekspor dokumen rapor|
|---|
|spot ke format PDF|



## **2.4 User Flow** 

Buka Aplikasi LapakPindah → Tiba di Lokasi (Modul 1: Tag Koordinat GPS & Bagikan Link WhatsApp) → Persiapan Stok Awal & Catat Biaya Nota Lapak (Modul 2 & 3: Input Modal Bahan & Foto Karcis Retribusi) → Operasional Berjalan (Modul 3: Kasir Cepat & Otomatis Potong Bahan Resep) → Jam Tutup (Modul 2: Notifikasi Cek Nota) → Akhir Minggu (Modul 4: Buka Grafik Evaluasi Lokasi, Target Omzet, & Ekspor PDF Rapor Cuan). 

## **2.5 Data Requirements** 

Identifikasi data utama yang perlu digunakan/disimpan oleh aplikasi. 

|**Data / Entity**|**Key Information**|**Purpose**|
|---|---|---|
||id, event_name, latitude,|Menyimpan letak presisi koordinat|
|**LocationLog**|longitude, rent_cost, open_time,<br>close_time, date_recorded|operasional harian lapak dan biaya<br>sewa stan.|
|**ExpenseRecord**|id, location_id, expense_name,<br>category<br>(sewa/bahan/operasional), amount,<br>receipt_photo_path, timestamp|Menyimpan rincian biaya<br>operasional harian dan path file<br>foto bukti nota fisik hasil jepretan<br>kamera.|
||product_id, name, selling_price,|Menyimpan master menu jualan,|
|**ProductRecipe**|recipe_cost (HPP), initial_stock,<br>current_stock, ingredients_json|formula resep per porsi, dan modal<br>stok bahan bawaan.|
||transaction_id, location_id,|Mencatat riwayat transaksi|
|**SalesTransaction**|product_id, qty, total_price,<br>timestamp, is_void|penjualan kasir luring dan status<br>pembatalan void.|



## **2.6 Constraints & Assumptions** 

- **Constraints:** Pengembangan dibatasi hanya menggunakan Flutter dan Dart dengan pola arsitektur MVVM (Model-View-ViewModel). Penyimpanan data dilarang keras menggunakan Firebase dan harus diimplementasikan menggunakan database lokal (SQLite). 

- **Assumptions:** Target pengguna memiliki perangkat smartphone Android dengan RAM memadai untuk menjalankan fitur Kamera, GPS, dan penyimpanan file. Pengguna juga memberikan perizinan (permissions) untuk fitur Kamera, Lokasi, dan Notifikasi di level sistem operasi. 

## **2.7 Success Criteria** 

- Fungsi integrasi keempat modul berjalan tanpa crash pada satu aplikasi utama. 

- Aplikasi dapat memproses transaksi kasir, memotong stok bahan, mengambil foto nota, dan membaca lokasi GPS saat ponsel berada dalam Mode Pesawat (100% Offline-Ready). 

- Masing-masing dari fitur perangkat fisik (GPS, Kamera, dan Penyimpanan File PDF) berhasil berjalan tanpa error pada perangkat nyata. 

- Keempat jenis notifikasi lokal terjadwal tereksekusi tepat waktu sesuai pemicunya di latar belakang. 

Mobile Programming — Project PRD Template 

## **3. Scope** 

## **3.1 In Scope** 

- Pengembangan antarmuka menggunakan Flutter Widget yang responsif dan touch-friendly. 

- Manajemen database lokal mandiri menggunakan SQLite (sqflite) tanpa Firebase. 

- Implementasi 4 modul terpisah: Pemetaan Lokasi Lapak, Pencatatan Biaya & Foto Nota, Kasir Cepat & Resep Bahan, serta Evaluasi Performa Lokasi & Ekspor PDF. 

- Pemanfaatan fitur perangkat keras fungsional: GPS & Location Service (Modul 1), Kamera (Modul 2), dan Ekspor File Storage PDF (Modul 4). 

- Implementasi 4 fitur Local Push Notification sesuai siklus operasional UMKM nomaden. 

## **3.2 Out of Scope** 

- Integrasi pembayaran digital wallet (GoPay, OVO, ShopeePay) atau API perbankan otomatis. 

- Sinkronisasi pencadangan data otomatis ke cloud storage (fokus utama luring murni). 

- Dukungan aplikasi ke platform iOS (fokus utama hanya Android). 

## **4. AI Prompt Context** 

**Petunjuk:** Bagian ini dapat digunakan sebagai konteks ketika meminta bantuan AI. Jangan memasukkan kode atau detail implementasi yang belum diputuskan. 

"Aplikasi LapakPindah adalah sistem manajemen luring berbasis Flutter untuk pemilik UMKM nomaden/keliling (1 role pengguna utama) tanpa menggunakan layanan Firebase (wajib SQLite lokal sqflite). Dibangun oleh 4 pengembang dengan 4 modul utama yang masing-masing berisi 4 fitur inti mencakup fungsi CRUD dan integrasi fitur device, ditambah 1 fitur Notifikasi lokal: (1) Modul Pencatat Lokasi harian via GPS, (2) Modul Pencatatan Biaya Lapak & Bukti Nota via Kamera, (3) Sistem Kasir Cepat & Inventaris Bahan Baku Berbasis Resep, dan (4) Evaluasi Profitabilitas Lokasi & Ekspor Rapor PDF. Seluruh fungsi dirancang untuk bekerja secara offline-first di lapangan." 

## **PRD Checklist** 

- ☐ Problem statement jelas dan berfokus pada pengguna. 

- ☐ Target users spesifik. 

- ☐ Project goal menjawab masalah yang diidentifikasi. 

- ☐ Core features berjumlah sekitar 4–6 dan relevan. 

- ☐ User flow utama sudah dituliskan. 

- ☐ Data utama sudah diidentifikasi. 

- ☐ Constraints dan assumptions sudah dicatat. 

Mobile Programming — Project PRD Template 

- ☐ Success criteria dapat digunakan untuk menilai hasil project. 

- ☐ In Scope dan Out of Scope sudah jelas. 

- ☐ Functional requirements menjelaskan perilaku/fungsi yang harus dilakukan aplikasi. 

- ☐ Non-functional requirements menjelaskan kualitas atau batasan sistem dan, jika memungkinkan, dapat diukur. 

- ☐ Functional requirements konsisten dengan core features. 

- ☐ Non-functional requirements tidak ditulis sebagai fitur baru. 

Mobile Programming — Project PRD Template 

