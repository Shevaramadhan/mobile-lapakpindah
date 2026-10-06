**Peran Modul 1**

Modul 1 menjawab pertanyaan "di mana dan kapan pedagang berjualan". Ia menyimpan dua hal: daftar tempat jualan, dan catatan setiap kali pedagang berjualan di salah satu tempat itu (disebut sesi). Penjualan (Modul 3\) dan pengeluaran (Modul 2\) menempel ke sesi, lalu Modul 4 menghitung laba per lokasi dari situ.

**Fitur 1: Kelola lokasi (CRUD)**

Pedagang menyimpan tempat-tempat jualannya, masing-masing sekali saja.

* **Tambah:** mengisi nama tempat (misalnya "CFD Jam Gadang") dan catatan (misalnya "dekat pintu masuk, ramai pagi").

* **Lihat:** daftar semua lokasi tersimpan, dan halaman detail tiap lokasi.

* **Ubah:** memperbaiki nama, catatan, atau koordinat.

* **Hapus:** menghapus lokasi yang tidak dipakai lagi.

Saran saya, lokasi yang sudah punya sesi tidak boleh dihapus, supaya riwayat laba di Modul 4 tidak ikut hilang.

**Fitur 2: Tandai koordinat dengan GPS**

Saat menambah atau mengubah lokasi, pedagang menekan "Ambil lokasi saat ini" ketika sedang berada di tempat itu. Aplikasi membaca GPS ponsel dan menyimpan latitude dan longitude ke data lokasi.

* Butuh izin lokasi dari pengguna.

* GPS bisa bekerja tanpa internet, hanya biasanya lebih lambat mendapat titik.

* Ini fitur device untuk Modul 1\.

**Fitur 3: Buka dan tutup sesi jualan**

Mencatat satu kali berjualan di sebuah lokasi.

1. Pedagang memilih lokasi dari daftar lalu menekan "Buka lapak".

2. Aplikasi membuat sesi baru dengan tanggal dan jam buka dari jam perangkat. Pedagang mengisi rencana jam tutup.

3. Selama sesi aktif, penjualan dan pengeluaran yang dicatat otomatis masuk ke sesi itu.

4. Pedagang menekan "Tutup lapak", dan jam tutup tercatat.

Aturannya: hanya satu sesi aktif dalam satu waktu, dan jam buka-tutup bisa dikoreksi manual kalau lupa menekan tombol.

**Fitur 4: Rute ke lokasi tersimpan**

Di halaman detail lokasi ada tombol "Rute". Saat ditekan, aplikasi mengirim koordinat lokasi ke Google Maps di ponsel, dan Google Maps yang menampilkan petunjuk arah.

* Bergantung pada fitur 2, karena koordinatnya dari sana.

* Butuh internet dan aplikasi Google Maps. Ini satu-satunya bagian Modul 1 yang tidak offline.

**Notifikasi: sesi belum ditutup**

Saat sesi dibuka, aplikasi menjadwalkan notifikasi lokal pada rencana jam tutup. Kalau sesi ditutup lebih dulu, jadwalnya dibatalkan. Kalau belum, muncul pengingat seperti: "Lapak di CFD Jam Gadang masih tercatat buka. Sudah selesai berjualan?"

Notifikasi ini penting karena sesi yang lupa ditutup membuat jam jualan dan data hari berikutnya kacau.

**Halaman pendukung: riwayat sesi**

Daftar semua sesi yang pernah dilakukan, bisa difilter berdasarkan tanggal atau lokasi. Halaman ini tetap dibuat, tapi tidak dihitung sebagai salah satu dari 4 fitur.

**Data yang disimpan**

| Data | Isi |
| :---- | :---- |
| Lokasi | id, nama, catatan, latitude, longitude |
| Sesi jualan | id, id lokasi, tanggal, jam buka, rencana jam tutup, jam tutup, status (aktif/selesai) |

**Contoh pemakaian satu hari**

1. Minggu pagi pedagang tiba di tempat baru, menambah lokasi "CFD Jam Gadang", dan menandai koordinatnya (fitur 1 dan 2).

2. Ia menekan "Buka lapak" pukul 06.10 dengan rencana tutup 10.30 (fitur 3).

3. Sepanjang pagi ia mencatat penjualan dan pengeluaran, yang semuanya masuk ke sesi itu.

4. Pukul 10.30 notifikasi muncul karena sesi belum ditutup, lalu ia menekan "Tutup lapak".

5. Minggu depannya ia ingin kembali ke sana, membuka detail lokasi, dan menekan "Rute" (fitur 4). Ia tidak perlu menambah lokasi lagi, cukup membuka sesi baru.

Kalau Modul 1 sudah jelas, kita lanjut ke Modul 2\.

**Peran Modul 2**

Modul 2 menjawab pertanyaan "berapa biaya yang keluar di lokasi ini hari ini". Semua pengeluaran dicatat ke sesi jualan dari Modul 1, lalu totalnya dipakai Modul 3 untuk pantauan balik modal dan Modul 4 untuk menghitung laba.

**Fitur 1: Kelola pengeluaran per sesi (CRUD)**

* **Tambah:** pedagang mengisi keterangan dan jumlah biaya, misalnya "beli es batu, Rp10.000". Sesi dan waktu pencatatan terisi otomatis.

* **Lihat:** daftar pengeluaran pada sesi itu beserta totalnya.

* **Ubah:** memperbaiki keterangan atau jumlah yang salah.

* **Hapus:** membuang pengeluaran yang salah catat.

Pengeluaran selalu menempel ke sebuah sesi. Kalau ada yang lupa dicatat, pedagang bisa menambahkannya ke sesi yang sudah selesai lewat halaman riwayat sesi.

**Fitur 2: Foto nota dengan kamera**

1. Di form pengeluaran ada tombol kamera.

2. Pedagang memotret nota atau karcis.

3. Foto disimpan di penyimpanan aplikasi, dan database hanya menyimpan alamat filenya.

4. Foto bisa dilihat lagi dari detail pengeluaran, diganti, atau dihapus.

Fitur ini tidak wajib diisi, butuh izin kamera, dan bekerja tanpa internet.

**Fitur 3: Biaya tetap lokasi**

Untuk biaya yang selalu sama setiap kali berjualan di suatu tempat.

1. Di detail lokasi, pedagang menambahkan daftar biaya tetap, masing-masing berupa keterangan dan jumlah. Contohnya "sewa tempat, Rp50.000" dan "retribusi kebersihan, Rp5.000".

2. Daftar ini bisa ditambah, diubah, dan dihapus kapan saja.

3. Saat sesi dibuka di lokasi itu, aplikasi otomatis memasukkan biaya-biaya tersebut sebagai pengeluaran sesi.

4. Kalau hari itu jumlahnya berbeda, pedagang cukup mengubah pengeluaran di sesi tersebut. Daftar biaya tetapnya tidak ikut berubah.

Fitur ini adalah titik sambung dengan Modul 1, karena pemicunya adalah tombol "Buka lapak". Anggota 1 dan anggota 2 perlu menyepakati cara penyambungannya.

**Fitur 4: Batas pengeluaran per sesi**

1. Pedagang menetapkan batas untuk sesi yang aktif, misalnya Rp150.000. Batas ini tidak wajib diisi.

2. Di halaman pengeluaran, aplikasi menampilkan total pengeluaran dan sisa batasnya.

3. Setiap kali pengeluaran ditambah atau diubah, sisa batas dihitung ulang.

**Notifikasi: batas terlewati**

Begitu total pengeluaran sesi mencapai atau melewati batas, notifikasi muncul saat itu juga: "Pengeluaran di CFD Jam Gadang sudah melewati batas Rp150.000". Notifikasi ini cukup muncul sekali per sesi supaya tidak mengganggu.

**Data yang disimpan**

| Data | Isi |
| :---- | :---- |
| Pengeluaran | id, id sesi, keterangan, jumlah, alamat file foto nota, waktu catat |
| Biaya tetap lokasi | id, id lokasi, keterangan, jumlah |
| Batas pengeluaran | id sesi, jumlah batas |

**Contoh pemakaian satu hari**

1. Sebelumnya pedagang sudah menyimpan biaya tetap untuk "CFD Jam Gadang": sewa Rp50.000 dan retribusi Rp5.000 (fitur 3).

2. Minggu pagi ia membuka lapak di sana. Dua biaya itu langsung tercatat, total Rp55.000.

3. Ia menetapkan batas Rp100.000 (fitur 4). Sisa batas Rp45.000.

4. Pukul 08.00 ia membeli es batu Rp10.000, mencatatnya, dan memotret notanya (fitur 1 dan 2). Total Rp65.000.

5. Pukul 09.00 ia membeli cup plastik Rp40.000. Total menjadi Rp105.000, melewati batas, dan notifikasi muncul.

**Hubungan dengan modul lain**

* **Modul 1:** menyediakan sesi dan lokasi, dan memicu biaya tetap saat sesi dibuka.

* **Modul 3:** memakai total pengeluaran sesi untuk menghitung balik modal.

* **Modul 4:** memakai total pengeluaran untuk menghitung laba per lokasi.

Kalau Modul 2 sudah jelas, kita lanjut ke Modul 3\.

ALASAN MODUL 2 ada yang di ubah

Sebenarnya separuh Modul 2 tidak berubah. Dua fitur lama tetap dipakai, dan yang diganti adalah dua fitur yang menurut saya rawan tidak dihitung dosen, ditambah notifikasinya.

Perbandingan lama dan baru

| PRD lama | Sekarang | Alasan |
| ----- | ----- | ----- |
| FR-06: CRUD pengeluaran | Tetap (fitur 1\) | Isiannya disederhanakan jadi keterangan dan jumlah, sesuai permintaan kalian |
| FR-07: Foto nota dengan kamera | Tetap (fitur 2\) | Tidak ada perubahan |
| FR-08: Pengelompokan kategori | Dihapus, diganti biaya tetap lokasi | Kategori hanya satu isian di form, bukan kemampuan baru. Kalian juga sudah memutuskan pengeluaran cukup keterangan dan jumlah |
| FR-09: Total biaya otomatis | Tidak dihitung sebagai fitur, diganti batas pengeluaran | Totalnya tetap tampil di halaman pengeluaran, tapi penjumlahan saja sulit dibela sebagai fungsi utama |
| FR-10: Pengingat foto nota jam 17.00 | Diganti notifikasi batas terlewati | Lihat penjelasan di bawah |

Alasan di balik penggantian

**FR-08 dan FR-09.** Aturan 3a menyebut fungsionalitas yang dihitung harus memberi kemampuan berbeda ke pengguna, bukan variasi tampilan. Memilih kategori dan melihat angka total adalah bagian dari mencatat pengeluaran itu sendiri. Kalau dosen menilainya begitu, Modul 2 hanya punya 2 fitur: CRUD dan kamera. Biaya tetap lokasi dan batas pengeluaran saya usulkan karena keduanya memberi kemampuan yang memang berbeda.

**FR-10.** Jam 17.00 tidak cocok untuk semua pedagang. Yang berjualan di CFD pagi sudah tutup pukul 10.30, jadi pengingat sore tidak relevan. Notifikasi batas terikat langsung ke kejadian di modul dan lebih mudah ditunjukkan saat review.

Yang perlu kalian tahu

* Dosen kalian tidak mengkritik Modul 2 secara langsung. Penggantian FR-08 dan FR-09 adalah penilaian saya atas aturan 3a, bukan permintaan dosen.  
* Kalau kalian lebih suka fitur lama, itu bisa dipertahankan dengan risiko tadi. Cara paling aman adalah menanyakan ke dosen apakah kategori dan total otomatis dihitung sebagai fitur.  
* Notifikasi lama juga bisa dipakai lagi kalau kalian mau, asal jamnya mengikuti jam sesi, bukan tetap pukul 17.00.

Mau tetap dengan susunan baru, atau kembali ke sebagian fitur lama?

Peran Modul 3

Modul 3 menjawab pertanyaan "berapa pemasukan di lokasi ini hari ini". Ia mencatat apa saja yang terjual pada sesi yang sedang aktif. Ini bukan kasir: tidak ada pembayaran, kembalian, atau stok, hanya pencatatan jumlah terjual dan nilainya.

Fitur 1: Kelola produk (CRUD)

* **Tambah:** pedagang mengisi nama produk dan harga jual, misalnya "Es teh, Rp5.000".  
* **Lihat:** daftar semua produk.  
* **Ubah:** mengganti nama atau harga.  
* **Hapus:** membuang produk yang tidak dijual lagi.

Saran saya, produk yang sudah punya catatan penjualan tidak dihapus, cukup dinonaktifkan supaya tidak muncul di halaman pencatatan. Dengan begitu riwayat penjualannya tetap utuh untuk Modul 4\.

Fitur 2: Catat penjualan pada sesi aktif

1. Halaman pencatatan menampilkan daftar produk.  
2. Pedagang mengetuk produk dan mengisi jumlah terjual, misalnya es teh 3\.  
3. Aplikasi menghitung nilainya (3 × Rp5.000 \= Rp15.000) dan menyimpannya ke sesi aktif.  
4. Total penjualan sesi tampil di halaman itu dan bertambah setiap ada catatan baru.  
5. Catatan yang salah bisa diubah atau dihapus.

Harga satuan ikut disimpan di setiap catatan penjualan. Jadi kalau harga produk diubah bulan depan, nilai penjualan yang sudah lewat tidak ikut berubah.

Fitur 3: Harga khusus per lokasi

Untuk produk yang dijual dengan harga berbeda di tempat tertentu.

1. Di detail produk, pedagang menambahkan harga khusus untuk sebuah lokasi, misalnya es teh di CFD Jam Gadang Rp6.000.  
2. Saat mencatat penjualan pada sesi di lokasi itu, aplikasi otomatis memakai harga khusus.  
3. Di lokasi lain yang tidak punya harga khusus, harga normal yang dipakai.  
4. Harga khusus bisa diubah atau dihapus.

Fitur 4: Pantau balik modal sesi

1. Aplikasi mengambil total penjualan sesi (dari modul ini) dan total pengeluaran sesi (dari Modul 2).  
2. Selama penjualan masih di bawah pengeluaran, tampil "kurang Rp… lagi untuk balik modal".  
3. Setelah terlewati, tampil "sudah untung Rp…".  
4. Angkanya dihitung ulang setiap ada penjualan atau pengeluaran baru.

Pantauan ini hanya seakurat pengeluaran yang sudah dicatat. Kalau pedagang belum mencatat pengeluaran sama sekali, tidak ada modal yang bisa dibandingkan, jadi status balik modal tidak ditampilkan.

Notifikasi: balik modal tercapai

Saat total penjualan sesi pertama kali melewati total pengeluarannya, notifikasi muncul: "Lapak di CFD Jam Gadang sudah balik modal". Cukup sekali per sesi.

Data yang disimpan

| Data | Isi |
| ----- | ----- |
| Produk | id, nama, harga jual, status aktif |
| Harga khusus | id, id produk, id lokasi, harga |
| Penjualan | id, id sesi, id produk, jumlah, harga satuan, waktu catat |

Contoh pemakaian satu hari

Melanjutkan contoh Modul 2, pengeluaran sesi di CFD Jam Gadang sudah Rp105.000.

1. Pedagang sudah punya produk "Es teh" Rp5.000 dengan harga khusus Rp6.000 di CFD Jam Gadang (fitur 1 dan 3).  
2. Sampai pukul 08.00 ia mencatat 10 es teh terjual. Nilainya Rp60.000 karena harga khusus dipakai (fitur 2).  
3. Pantauan menampilkan "kurang Rp45.000 lagi untuk balik modal" (fitur 4).  
4. Pukul 09.30 ia mencatat 8 es teh lagi. Total penjualan menjadi Rp108.000, melewati pengeluaran Rp105.000.  
5. Notifikasi balik modal muncul, dan pantauan berubah menjadi "sudah untung Rp3.000".

Hubungan dengan modul lain

* **Modul 1:** menyediakan sesi aktif dan data lokasi untuk harga khusus.  
* **Modul 2:** menyediakan total pengeluaran sesi untuk pantauan balik modal.  
* **Modul 4:** memakai data penjualan untuk menghitung laba per lokasi.

Karena fitur 4 membaca data Modul 2, anggota 2 dan anggota 3 perlu menyepakati cara mengambil total pengeluaran sesi.

Kalau Modul 3 sudah jelas, kita lanjut ke Modul 4\.

MASALAH HARGA KHUSUS MODUL 3

Harga khusus per lokasi berarti satu produk bisa punya harga berbeda di tempat tertentu, dan aplikasi memilih harga yang benar secara otomatis saat penjualan dicatat.

## **Contoh**

Produk "Es teh" dengan harga normal Rp5.000:

| Lokasi | Harga khusus | Harga yang dipakai |
| ----- | ----- | ----- |
| CFD Jam Gadang | Rp6.000 | Rp6.000 |
| Event kampus | Rp7.000 | Rp7.000 |
| Pasar kaget | Tidak ada | Rp5.000 (harga normal) |

## **Tampilan di aplikasi**

**Halaman detail produk.** Di bawah nama dan harga normal ada bagian "Harga khusus per lokasi", berisi daftar lokasi dan harganya. Tombol tambah membuka form kecil: pilih lokasi dari daftar lokasi Modul 1, isi harga, simpan. Tiap baris bisa diubah atau dihapus.

**Halaman catat penjualan.** Daftar produk menampilkan harga yang berlaku untuk lokasi sesi yang sedang aktif. Kalau harganya harga khusus, ada tanda kecil di sampingnya supaya pedagang tahu.

## **Cara kerja saat mencatat penjualan**

1. Pedagang membuka lapak di CFD Jam Gadang, jadi sesi aktif berada di lokasi itu.  
2. Ia mengetuk "Es teh" dengan jumlah 3\.  
3. Aplikasi memeriksa apakah es teh punya harga khusus untuk CFD Jam Gadang.  
4. Ada, yaitu Rp6.000, jadi nilainya 3 × Rp6.000 \= Rp18.000.  
5. Harga Rp6.000 itu ikut disimpan di catatan penjualan.

Kalau tidak ada harga khusus untuk lokasi itu, langkah 4 memakai harga normal.

## **Aturan**

* Satu produk hanya punya satu harga khusus untuk satu lokasi.  
* Harga khusus boleh lebih tinggi atau lebih rendah dari harga normal.  
* Mengubah harga khusus tidak mengubah penjualan yang sudah tercatat, karena tiap catatan menyimpan harganya sendiri.  
* Kalau harga khusus dihapus, lokasi itu kembali memakai harga normal.

## **Hubungannya dengan masalah inti**

Lokasi dengan harga lebih tinggi bisa lebih untung walaupun jumlah terjualnya lebih sedikit. Karena nilai penjualan sudah dihitung dengan harga yang benar, Modul 4 otomatis menangkap perbedaan itu tanpa perhitungan tambahan.

## **Sisi teknis**

* Satu tabel kecil: id, id produk, id lokasi, harga.  
* Satu pengecekan saat mencatat penjualan: cari harga khusus untuk produk dan lokasi sesi aktif, kalau tidak ada pakai harga normal.  
* Butuh daftar lokasi dari Modul 1, jadi anggota 3 perlu tahu cara mengambil data lokasi dari anggota 1\.

Kalau ini sudah jelas, kita lanjut ke Modul 4\.

boleh 

## **Peran Modul 4**

Modul 4 menjawab pertanyaan inti aplikasi: "lokasi mana yang paling menguntungkan". Ia hampir tidak punya data sendiri, karena tugasnya mengolah data sesi (Modul 1), pengeluaran (Modul 2), dan penjualan (Modul 3). Modul ini hanya menghitung dan menampilkan, dan tidak memberi saran atau keputusan.

## **Fitur 1: Laba dan peringkat lokasi**

1. Untuk tiap sesi yang sudah selesai, aplikasi menghitung laba \= total penjualan − total pengeluaran.  
2. Sesi-sesi itu dikelompokkan per lokasi, lalu dihitung jumlah sesi, total penjualan, total pengeluaran, total laba, dan rata-rata laba per sesi.  
3. Lokasi diurutkan dari rata-rata laba per sesi tertinggi sampai terendah, termasuk yang merugi.  
4. Pedagang bisa memilih periode (minggu ini, bulan ini, atau semua) dan mengetuk sebuah lokasi untuk melihat rincian per sesinya.

Peringkat memakai rata-rata per sesi, bukan total, supaya lokasi yang sering dikunjungi tidak otomatis menang hanya karena jumlah sesinya lebih banyak.

## **Fitur 2: Tren laba lokasi**

1. Pedagang memilih satu lokasi.  
2. Aplikasi menampilkan grafik laba lokasi itu dari waktu ke waktu.  
3. Tampilannya bisa harian (satu titik per sesi) atau mingguan (laba dijumlah per minggu).

Dari grafik ini pedagang melihat apakah sebuah lokasi sedang naik, turun, atau stabil.

## **Fitur 3: Target laba per lokasi (CRUD)**

* **Tambah:** pedagang memilih lokasi dan mengisi target laba per sesi, misalnya CFD Jam Gadang Rp75.000.  
* **Lihat:** daftar target dengan status "tercapai" atau "belum", berdasarkan rata-rata laba per sesi lokasi itu.  
* **Ubah:** mengganti angka target.  
* **Hapus:** membuang target yang tidak dipakai lagi.

Satu lokasi hanya punya satu target. Aplikasi hanya menampilkan statusnya, tanpa saran apa pun.

## **Fitur 4: Ekspor laporan PDF**

1. Pedagang memilih periode laporan.  
2. Aplikasi menyusun PDF berisi peringkat lokasi, angka penjualan, pengeluaran, dan laba tiap lokasi, serta status targetnya.  
3. File disimpan di penyimpanan ponsel dan bisa dibuka atau dibagikan.

## **Notifikasi: rekap mingguan**

Notifikasi terjadwal seminggu sekali, misalnya Minggu pukul 21.00: "Rekap minggu ini sudah siap. Lihat peringkat lokasi Anda." Saran saya isi pesannya dibuat umum seperti ini. Menyebut nama lokasi terbaik di dalam notifikasi bisa dilakukan, tapi lebih rumit karena isinya harus dihitung ulang setiap kali data berubah.

## **Data yang disimpan**

| Data | Isi |
| ----- | ----- |
| Target laba | id, id lokasi, jumlah target |

Selebihnya modul ini hanya membaca data dari tiga modul lain.

## **Contoh**

Setelah sebulan, data pedagang seperti ini:

| Lokasi | Jumlah sesi | Total laba | Rata-rata per sesi | Peringkat |
| ----- | ----- | ----- | ----- | ----- |
| Event kampus | 2 | Rp190.000 | Rp95.000 | 1 |
| CFD Jam Gadang | 4 | Rp320.000 | Rp80.000 | 2 |
| Pasar kaget | 5 | Rp150.000 | Rp30.000 | 3 |

1. Halaman peringkat menempatkan event kampus di urutan pertama, walaupun total laba CFD lebih besar (fitur 1).  
2. Pedagang membuka tren CFD Jam Gadang dan melihat labanya naik dari minggu ke minggu (fitur 2).  
3. Target CFD Rp75.000 berstatus tercapai, sedangkan target pasar kaget Rp50.000 belum (fitur 3).  
4. Ia mengekspor laporan bulan itu ke PDF (fitur 4).

## **Yang perlu diperhatikan anggota 4**

* **Butuh data contoh.** Modul ini baru bisa diuji kalau sudah ada sesi, pengeluaran, dan penjualan. Supaya tidak menunggu tiga modul lain selesai, siapkan data contoh sejak awal.  
* **Fitur 1 dan 2 bisa dianggap mirip.** Pembedanya: fitur 1 membandingkan antar lokasi, fitur 2 melihat satu lokasi sepanjang waktu.  
* **Perhitungannya bergantung pada struktur tabel modul lain**, jadi anggota 4 paling berkepentingan agar struktur database disepakati di awal.

Keempat modul sekarang sudah dibahas. Mau saya tuangkan semuanya ke PRD versi revisi?

