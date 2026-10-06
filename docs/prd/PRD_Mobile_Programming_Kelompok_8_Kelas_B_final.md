# **PROJECT PRD** 

_Product Requirements Document_ 

|**Project Name**|LapakPindah â€“ Aplikasi Mobile Evaluasi<br>Keuntungan Lokasi Jualan bagi UMKM Keliling|
|---|---|
||1. Anggota 1 Mufti - 2411523019|
|**Team**|2. Anggota 2 - 2411523020<br>3. Anggota 3 Habiburrohim - 2411523022|
||4. Anggota 4 Akhna El Charoz - 2411523037|
|**Course**|Mobile Programming|
|**Version**|2.0|
|**Date**|2 Oktober 2026|



## **Tujuan dokumen** 

PRD ini digunakan untuk menjelaskan apa yang akan dibangun, untuk siapa, mengapa produk dibutuhkan, dan pembagian modul untuk 4 mahasiswa pada Kelompok 8 Kelas B. Dokumen ini merupakan revisi dari versi 1.0 yang memfokuskan aplikasi pada satu masalah, dan disusun mengikuti Aturan Project Mobile 2026: setiap anggota memegang satu modul berisi 4 fungsionalitas utama (minimal satu CRUD) dan satu notifikasi, data disimpan di database lokal SQLite tanpa Firebase, dan aplikasi memakai fitur perangkat (GPS dan kamera). 

## **1. Problem & Users** 

## **1.1 Problem Statement** 

Pemilik usaha mikro yang berjualan berpindah-pindah, seperti gerobak, food truck, stan bazar, dan pedagang pasar kaget, tidak mengetahui lokasi jualan mana yang paling menguntungkan. Penjualan dan pengeluaran di tiap lokasi tidak tercatat terpisah, sehingga mereka tidak dapat membandingkan hasil penjualan setelah dikurangi biaya di masing-masing tempat. 

## **1.2 Target Users** 

Pemilik atau pengelola usaha mikro keliling yang berjualan di lebih dari satu lokasi dan mencatat usahanya sendiri lewat ponsel Android. Aplikasi hanya memiliki satu peran pengguna, yaitu pemilik usaha (owner/operator). 

## **1.3 User Needs / Pain Points** 

- **Kebutuhan 1 (Catatan per Lokasi):** Penjualan dan pengeluaran selama ini tidak dipisahkan per tempat jualan, sehingga pedagang hanya mengetahui hasil usahanya secara keseluruhan, bukan hasil di tiap lokasi. 

Mobile Programming â€” Project PRD Template 

- **Kebutuhan 2 (Biaya di Lokasi):** Biaya yang muncul di lokasi, seperti sewa tempat, retribusi, dan belanja mendadak, sering tidak tercatat dan notanya hilang, sehingga keuntungan sebuah lokasi terlihat lebih besar dari kenyataannya. 

- **Kebutuhan 3 (Perbandingan Lokasi):** Pedagang mengandalkan ingatan untuk menilai lokasi mana yang menguntungkan, dan tidak memiliki data untuk membandingkan satu lokasi dengan lokasi lain dari waktu ke waktu. 

## **1.4 Project Goal** 

Membangun aplikasi mobile **LapakPindah** yang membantu pedagang keliling mengetahui lokasi jualan yang paling menguntungkan, dengan cara mencatat penjualan dan pengeluaran pada setiap sesi jualan di sebuah lokasi, lalu menghitung dan membandingkan laba tiap lokasi. 

## **2. Product Requirements** 

## **2.1 Functional Requirements** 

Dua istilah dipakai di seluruh requirement. **Lokasi** adalah tempat jualan yang disimpan satu kali. **Sesi jualan** adalah satu kali berjualan di sebuah lokasi, dari lapak dibuka sampai ditutup. Sesi yang sedang berlangsung disebut sesi aktif, dan hanya boleh ada satu sesi aktif dalam satu waktu. Penjualan dan pengeluaran selalu dicatat ke sebuah sesi. 

## **Modul 1: Lokasi & Sesi Jualan (Tanggung Jawab: Anggota 1)** 

- **FR-01 (Core - CRUD):** Pengguna dapat menambah, melihat, mengubah, dan menghapus lokasi jualan (nama tempat dan catatan). Lokasi yang sudah memiliki sesi jualan tidak dapat dihapus. 

- **FR-02 (Core - Device GPS):** Pengguna dapat menandai koordinat sebuah lokasi dengan GPS perangkat saat berada di tempat tersebut, dan koordinatnya tersimpan pada data lokasi. 

- **FR-03 (Core):** Pengguna dapat membuka sesi jualan di sebuah lokasi dengan mengisi rencana jam tutup, lalu menutupnya saat selesai. Sistem mencatat tanggal, jam buka, dan jam tutup secara otomatis, dan pengguna dapat mengoreksi jam tersebut secara manual. 

- **FR-04 (Core):** Pengguna dapat membuka petunjuk arah menuju lokasi tersimpan di aplikasi Google Maps berdasarkan koordinat lokasi tersebut. 

- **FR-05 (Notifikasi Lokal):** Sistem menampilkan notifikasi lokal pada rencana jam tutup apabila sesi jualan belum ditutup, untuk mengingatkan pengguna menutup sesi. 

## **Modul 2: Pengeluaran & Bukti Nota (Tanggung Jawab: Anggota 2)** 

- **FR-06 (Core - CRUD):** Pengguna dapat menambah, melihat, mengubah, dan menghapus pengeluaran pada sebuah sesi jualan, berupa keterangan dan jumlah biaya. Sistem menampilkan total pengeluaran sesi tersebut. 

- **FR-07 (Core - Device Kamera):** Pengguna dapat memotret nota atau karcis dengan kamera perangkat sebagai bukti sebuah pengeluaran, lalu melihat, mengganti, atau menghapus foto tersebut. 

- **FR-08 (Core):** Pengguna dapat menyimpan daftar biaya tetap sebuah lokasi (keterangan dan jumlah). Saat sesi jualan dibuka di lokasi itu, sistem otomatis mencatat biaya tetap tersebut sebagai pengeluaran sesi. 

Mobile Programming â€” Project PRD Template 

- **FR-09 (Core):** Pengguna dapat menetapkan batas pengeluaran untuk sesi aktif, dan sistem menampilkan sisa batas yang dihitung ulang setiap kali pengeluaran berubah. 

- **FR-10 (Notifikasi Lokal):** Sistem menampilkan notifikasi lokal satu kali per sesi saat total pengeluaran sesi mencapai atau melewati batas yang ditetapkan. 

## **Modul 3: Pencatatan Penjualan (Tanggung Jawab: Anggota 3)** 

- **FR-11 (Core - CRUD):** Pengguna dapat menambah, melihat, mengubah, dan menghapus produk (nama dan harga jual). Produk yang sudah memiliki catatan penjualan tidak dihapus, melainkan dinonaktifkan. 

- **FR-12 (Core):** Pengguna dapat mencatat penjualan pada sesi aktif dengan memilih produk dan mengisi jumlah terjual. Sistem menghitung nilai penjualan, menyimpan harga satuan pada catatan tersebut, dan menampilkan total penjualan sesi. Catatan penjualan dapat diubah atau dihapus. 

- **FR-13 (Core):** Pengguna dapat menetapkan harga khusus sebuah produk untuk lokasi tertentu. Saat mencatat penjualan di lokasi itu sistem memakai harga khusus, dan di lokasi lain memakai harga normal. 

- **FR-14 (Core):** Sistem membandingkan total penjualan dengan total pengeluaran sesi aktif dan menampilkan selisihnya, yaitu kekurangan untuk balik modal atau jumlah keuntungan. 

- **FR-15 (Notifikasi Lokal):** Sistem menampilkan notifikasi lokal satu kali per sesi saat total penjualan sesi pertama kali melewati total pengeluarannya (balik modal). 

## **Modul 4: Evaluasi Lokasi (Tanggung Jawab: Anggota 4)** 

- **FR-16 (Core):** Sistem menghitung laba tiap sesi (total penjualan dikurangi total pengeluaran), mengelompokkannya per lokasi, dan menampilkan peringkat lokasi berdasarkan rata-rata laba per sesi pada periode yang dipilih pengguna. 

- **FR-17 (Core):** Pengguna dapat melihat grafik tren laba sebuah lokasi dari waktu ke waktu dalam tampilan harian atau mingguan. 

- **FR-18 (Core - CRUD):** Pengguna dapat menambah, melihat, mengubah, dan menghapus target laba per sesi untuk tiap lokasi, dan sistem menampilkan status tercapai atau belum berdasarkan rata-rata laba per sesi lokasi tersebut. 

- **FR-19 (Core):** Pengguna dapat mengekspor laporan peringkat dan laba lokasi pada periode tertentu ke dokumen PDF yang tersimpan di perangkat dan dapat dibagikan. 

- **FR-20 (Notifikasi Lokal):** Sistem menampilkan notifikasi lokal terjadwal seminggu sekali yang mengingatkan pengguna meninjau rekap dan peringkat lokasi minggu itu. 

- **2.2 Non-functional Requirements** 

- **NFR-01 (Offline):** Seluruh pencatatan dan perhitungan berjalan tanpa koneksi internet dengan data tersimpan di database lokal SQLite (sqflite), tanpa layanan Firebase. Hanya petunjuk arah (FR-04) yang memerlukan internet dan aplikasi Google Maps. 

- **NFR-02 (Performance):** Penyimpanan satu catatan penjualan atau pengeluaran, termasuk pembaruan total sesi, selesai dalam â‰¤ 1 detik. 

- **NFR-03 (Usability):** Antarmuka memakai tombol berukuran minimal 48 Ã— 48 dp dan teks berkontras tinggi agar mudah dipakai di luar ruangan saat melayani pembeli. 

Mobile Programming â€” Project PRD Template 

- **NFR-04 (Reliability):** Notifikasi lokal muncul tanpa koneksi internet. Notifikasi terjadwal (FR-05 dan FR-20) muncul dalam rentang 5 menit dari waktu yang dijadwalkan, dan notifikasi berbasis kejadian (FR-10 dan FR-15) muncul segera setelah data disimpan. 

- **NFR-05 (Data Integrity):** Setiap penjualan dan pengeluaran selalu terhubung ke satu sesi, dan setiap sesi ke satu lokasi, melalui relasi foreign key di SQLite. Hanya ada satu sesi aktif dalam satu waktu. 

## **2.3 Core Features** 

|**No.**|**Core Feature**|**Purpose / Value**|
|---|---|---|
|1|**Pencatatan Lokasi & Sesi**<br>**Jualan**|Menyimpan tempat jualan beserta koordinat GPS dan mencatat<br>setiap kali berjualan di sana, sehingga semua data terikat pada<br>lokasi yang jelas.|
|2|**Pencatatan Pengeluaran &**<br>**Bukti Nota**|Mencatat biaya di tiap sesi beserta foto nota, termasuk biaya<br>tetap lokasi, agar biaya setiap lokasi tercatat lengkap.|
|3|**Pencatatan Penjualan per**<br>**Lokasi**|Mencatat produk yang terjual di tiap sesi dengan harga yang<br>berlaku di lokasi itu, dan menunjukkan kapan sesi sudah balik<br>modal.|
|4|**Evaluasi & Peringkat Lokasi**|Menghitung laba tiap lokasi, menampilkan peringkat dan<br>trennya, serta mengekspor laporan PDF, agar pedagang<br>mengetahui lokasi yang paling menguntungkan.|



## **2.4 User Flow** 

Buka aplikasi â†’ Pilih atau tambah lokasi dan tandai koordinat GPS (Modul 1) â†’ Buka lapak untuk memulai sesi jualan, biaya tetap lokasi tercatat otomatis (Modul 1 dan 2) â†’ Catat pengeluaran dan foto nota (Modul 2) â†’ Catat penjualan dan pantau balik modal (Modul 3) â†’ Tutup lapak (Modul 1) â†’ Lihat peringkat dan tren laba lokasi, lalu ekspor laporan PDF (Modul 4). 

## **2.5 Data Requirements** 

|**Data / Entity**|**Key Information**|**Purpose**|
|---|---|---|
|**Location**|id, name, note, latitude, longitude|Menyimpan tempat jualan dan<br>koordinatnya (Modul 1).|
||id, location_id, date, open_time,|Mencatat satu kali berjualan di sebuah|
|**SalesSession**|planned_close_time, close_time, status<br>(aktif/selesai)|lokasi, tempat penjualan dan<br>pengeluaran menempel (Modul 1).|
|**Expense**|id, session_id, description, amount,<br>receipt_photo_path, recorded_at|Menyimpan pengeluaran sebuah sesi<br>dan alamat file foto notanya (Modul<br>2).|
|||Menyimpan biaya tetap lokasi yang|
|**LocationFixedCost**|id, location_id, description, amount|dicatat otomatis saat sesi dibuka<br>(Modul 2).|
|**ExpenseLimit**|session_id, limit_amount|Menyimpan batas pengeluaran sebuah<br>sesi (Modul 2).|
|**Product**|id, name, selling_price, is_active|Menyimpan daftar produk dan harga|



Mobile Programming â€” Project PRD Template 

|||normalnya (Modul 3).|
|---|---|---|
|**LocationPrice**|id, product_id, location_id, price|Menyimpan harga khusus produk di<br>lokasi tertentu (Modul 3).|
|**Sale**|id, session_id, product_id, quantity,<br>unit_price, recorded_at|Mencatat penjualan pada sebuah sesi<br>beserta harga satuan saat itu (Modul<br>3).|
|**ProfitTarget**|id, location_id, target_amount|Menyimpan target laba per sesi untuk<br>tiap lokasi (Modul 4).|



## **2.6 Constraints & Assumptions** 

- **Constraints:** Aplikasi dikembangkan dengan Flutter dan Dart untuk Android dengan pola arsitektur MVVM. Data disimpan di database lokal SQLite (sqflite) dan tidak menggunakan Firebase. Petunjuk arah bergantung pada aplikasi Google Maps dan koneksi internet. 

- **Assumptions:** Pengguna memiliki ponsel Android dengan GPS dan kamera, serta memberi izin lokasi, kamera, dan notifikasi. Pengguna membuka dan menutup sesi setiap kali berjualan dan mencatat penjualan serta pengeluarannya, karena ketepatan peringkat lokasi bergantung pada kelengkapan catatan tersebut. Satu perangkat dipakai oleh satu usaha. 

## **2.7 Success Criteria** 

- Pengguna dapat menyelesaikan alur utama, dari membuka sesi, mencatat pengeluaran dan penjualan, menutup sesi, sampai melihat peringkat lokasi, dalam satu aplikasi tanpa crash. 

- Laba dan peringkat lokasi yang ditampilkan sama dengan hasil hitung manual (penjualan dikurangi pengeluaran) pada data uji. 

- Pencatatan penjualan dan pengeluaran, penandaan GPS, dan foto nota tetap berfungsi saat perangkat tidak terhubung ke internet. 

- Keempat notifikasi lokal muncul sesuai pemicunya, dan fitur GPS serta kamera berjalan pada perangkat nyata. 

## **3. Scope** 

## **3.1 In Scope** 

- Empat modul: Lokasi & Sesi Jualan, Pengeluaran & Bukti Nota, Pencatatan Penjualan, dan Evaluasi Lokasi, masing-masing dengan 4 fungsionalitas utama dan 1 notifikasi lokal. 

- Antarmuka dengan Flutter Widget dan penyimpanan data lokal SQLite (sqflite) tanpa Firebase. 

- Pemakaian fitur perangkat: GPS (Modul 1) dan kamera (Modul 2). 

- Halaman pendukung riwayat sesi dengan filter tanggal dan lokasi. 

- Ekspor laporan evaluasi lokasi ke dokumen PDF. 

## **3.2 Out of Scope** 

- Fungsi kasir: pembayaran, perhitungan kembalian, dan dompet digital. 

- Manajemen stok dan resep bahan baku. 

- Promosi atau berbagi lokasi ke media sosial. 

- Rekomendasi atau pengambilan keputusan otomatis (sistem penunjang keputusan). Aplikasi hanya menampilkan hasil perhitungan dan peringkat. 

- Sinkronisasi atau pencadangan data ke cloud, dan akun multi-pengguna. 

- Dukungan platform iOS. 

Mobile Programming â€” Project PRD Template 

## **4. AI Prompt Context** 

"LapakPindah adalah aplikasi mobile Flutter (Dart, arsitektur MVVM, Android) untuk pemilik usaha mikro keliling dengan satu peran pengguna. Tujuannya membantu pengguna mengetahui lokasi jualan yang paling menguntungkan dengan mencatat penjualan dan pengeluaran per sesi jualan di sebuah lokasi, lalu membandingkan laba antar lokasi. Data disimpan di SQLite lokal (sqflite) tanpa Firebase, dan aplikasi bekerja tanpa internet kecuali petunjuk arah ke Google Maps. Aplikasi terdiri dari 4 modul yang dikerjakan 4 pengembang, masing-masing berisi 4 fungsionalitas utama dan 1 notifikasi lokal: (1) Lokasi & Sesi Jualan dengan GPS, (2) Pengeluaran & Bukti Nota dengan kamera, (3) Pencatatan Penjualan dengan harga khusus per lokasi dan pantauan balik modal, dan (4) Evaluasi Lokasi berisi peringkat, tren laba, target laba, dan ekspor PDF. Aplikasi bukan kasir, tidak mengelola stok, dan tidak memberi rekomendasi keputusan. Saat meminta bantuan AI, sebutkan modul dan nomor FR yang dikerjakan, dan minta penjelasan kode agar dapat dipahami dan dijelaskan saat code review." 

## **PRD Checklist** 

- â˜‘ Problem statement jelas dan berfokus pada pengguna. 

- â˜‘ Target users spesifik. 

- â˜‘ Project goal menjawab masalah yang diidentifikasi. 

â˜‘ Core features berjumlah sekitar 4â€“6 dan relevan. 

- â˜‘ User flow utama sudah dituliskan. 

- â˜‘ Data utama sudah diidentifikasi. 

- â˜‘ Constraints dan assumptions sudah dicatat. 

- â˜‘ Success criteria dapat digunakan untuk menilai hasil project. 

- â˜‘ In Scope dan Out of Scope sudah jelas. 

- â˜‘ Functional requirements menjelaskan perilaku/fungsi yang harus dilakukan aplikasi. 

- â˜‘ Non-functional requirements menjelaskan kualitas atau batasan sistem dan, jika memungkinkan, dapat diukur. 

- â˜‘ Functional requirements konsisten dengan core features. 

- â˜‘ Non-functional requirements tidak ditulis sebagai fitur baru. 

Mobile Programming â€” Project PRD Template 


