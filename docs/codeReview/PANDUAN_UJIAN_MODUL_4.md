# Panduan ujian Modul 4 — FR-17 dan FR-18

Dokumen ini menjelaskan **kode yang benar-benar ada di branch `modul4-evaluasi-lokasi`**. Fokus demo Practical Challenge adalah satu workflow FR-18: `Evaluasi → Kelola Target → isi dan validasi → simpan → hasil → kembali ke Evaluasi`. FR-17 adalah layar awal dan tempat melihat hasil. Ketentuan tugas ada di `docs/codeReview/PRACTICAL CHALLENGE - Tugas Individu (2).md`; code review meminta mahasiswa memahami kode, menunjukkan perubahan kecil, dan membuat prompt AI yang tepat.

## Peta folder project dari luar ke dalam

| Folder/file | Fungsi di project ini |
|---|---|
| `lib/` | Semua source code utama aplikasi Flutter. Mulai membaca dari sini. |
| `lib/main.dart` | Titik mulai aplikasi; membuat repository, mendaftarkan ViewModel melalui Provider, memasang tema dan route. |
| `lib/routes/` | Nama dan tujuan navigasi antarhalaman. `app_routes.dart` mendaftarkan form dan layar hasil target. |
| `lib/core/` | Kode bersama lintas modul: `theme/` untuk gaya, `utils/` untuk validator/format Rupiah/status, `widgets/` untuk komponen UI bersama. `database/` belum dipakai Modul 4 ini. |
| `lib/modules/` | Fitur dikelompokkan menurut tanggung jawab: `auth`, `home`, `sesi_lokasi`, `pengeluaran`, `penjualan`, `evaluasi_lokasi`. Modul 4 ada di `evaluasi_lokasi/`. |
| `lib/modules/evaluasi_lokasi/models/` | Bentuk data dan hasil perhitungan: `ProfitTarget`, `SavedTarget`, `SessionProfit`, `ProfitPoint`, enum periode. Model bukan database. |
| `lib/modules/evaluasi_lokasi/repositories/` | Sumber dan operasi data. `profit_target_repository.dart` menyimpan target dalam Map memori; `evaluation_repository.dart` menyediakan sesi sementara/contoh. |
| `lib/modules/evaluasi_lokasi/view_models/` | State dan logika yang menghubungkan data ke UI. Form target memakai `ProfitTargetViewModel`; halaman Evaluasi memakai `EvaluationViewModel`. |
| `lib/modules/evaluasi_lokasi/views/` | Layar yang dilihat dan disentuh pengguna: Evaluasi, form target, dan hasil simpan. |
| `lib/modules/evaluasi_lokasi/views/widgets/` | Bagian UI yang dipakai layar, seperti aset SVG dan grafik kustom. |
| `assets/evaluation/` | File SVG yang dipakai tampilan Modul 4; didaftarkan melalui `pubspec.yaml`. |
| `test/` | Tes aturan data, format Rupiah, dan alur widget; membantu membuktikan workflow tetap berjalan setelah perubahan. |
| `docs/` | PRD, Practical Challenge, code review, desain, dan panduan ini. Dokumen acuan, bukan kode yang dijalankan. |
| `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` | Konfigurasi platform Flutter. Ujian Android terutama memakai `android/`; layar aplikasi tetap ditulis di `lib/`. |
| `pubspec.yaml` | Daftar package dan aset. `build/` serta `.dart_tool/` adalah hasil proses tooling, bukan tempat menulis fitur. |

**Alur hubungan folder:** `main.dart` menyediakan repository dan ViewModel → `routes/` membuka `views/` → event dari View masuk ke `view_models/` → ViewModel memvalidasi atau meminta data ke `repositories/` → repository mengembalikan `models/` → ViewModel memanggil `notifyListeners()` → View menggambar ulang. Pada prototipe ini, repository target memakai memori; tidak ada penulisan target ke `core/database/`.

## Jawaban pembuka 30–45 detik

> “Saya mengerjakan Modul 4, terutama FR-17 grafik evaluasi lokasi dan FR-18 CRUD target laba per sesi per lokasi. Workflow ujian saya adalah mengatur target. Dari halaman Evaluasi, pengguna membuka form, memilih lokasi, memasukkan nominal, lalu menekan Simpan. Form memvalidasi lokasi dan nominal minimal Rp100.000. ViewModel mengubah state menjadi menyimpan, repository menyimpan sementara di memori, lalu layar hasil menampilkan target yang benar-benar disimpan. Saat kembali, Evaluasi memuat ulang target dan menampilkan status tercapai berdasarkan rata-rata laba per sesi di lokasi itu. Saya menggunakan MVVM dan Provider; belum ada database atau backend pada prototipe ujian ini.”

**Catatan kejujuran:** PRD final menetapkan target *per sesi per lokasi* dan status berdasarkan *rata-rata laba per sesi*, tetapi tidak menetapkan minimum. Minimum Rp100.000 adalah keputusan tambahan untuk validasi ujian. Dokumen peran modul masih memberi contoh Rp75.000, sehingga contoh dokumen dan implementasi belum sama. Build debug (`flutter run`) memakai data contoh secara otomatis; data transaksi Modul 2/3 belum terhubung. Build rilis tidak memakai data contoh secara default. Target juga hilang saat proses aplikasi ditutup karena repository masih memori.

## Peta lima tahap Practical Challenge

| Tahap | Tunjukkan di aplikasi | Tunjukkan di kode |
|---|---|---|
| Input/Event | Tap **Kelola Target**, pilih lokasi, ketik `100000` hingga tampil `100.000`, tap **Simpan Target**. | `evaluation_screen.dart` `_manageCard`/`_openTarget`; `profit_target_form_screen.dart` `TextFormField`, `onChanged`, `_submit`; `rupiah_input_formatter.dart`. |
| State | Lokasi dan nominal berubah; tombol masuk kondisi menyimpan. | `profit_target_view_model.dart`: `locationId`, `amountText`, `dirty`, `isSaving`, `saveError`, `notifyListeners()`; View membaca lewat `context.watch`. |
| Validation | Coba kosong dan `99999`: error; `100000`: lolos. | `validators.dart` `profitTarget`; form memanggil `_formKey.currentState?.validate()`; repository mengecek minimum lagi. |
| Feedback | Error di bawah field; loading saat simpan; pesan gagal atau layar sukses. | Form `validator`, `_attempted`, `vm.isSaving`, `vm.saveError`, `_showSuccess`; `target_result_screen.dart`. |
| Navigation/Result | Hasil menampilkan lokasi dan nominal; kembali ke Evaluasi, target muncul. | `AppRoutes.targetForm` dan `targetResult`; `SavedTarget` sebagai `arguments`; `TargetResultAction` sebagai hasil layar sukses; `ProfitTarget` dikembalikan ke Evaluasi; `vm.load()`. |

## Letak kode dan fungsi tiap bagian

### 1. Titik awal dan dependensi

`lib/main.dart`: `main()` memanggil `runApp`; `LapakPindahApp` membuat **satu instance** `LocationRepository`, `ProfitTargetRepository`, dan `EvaluationRepository`. `_demo` aktif secara default pada build debug dan dapat ditimpa lewat `LAPAK_DEMO`; jika benar, lokasi dan sesi contoh diisi. `MultiProvider` membuat `EvaluationViewModel` dan `ProfitTargetViewModel` dengan instance repository yang sama. Karena repository target sama, form dan halaman Evaluasi melihat target yang sama selama aplikasi berjalan. `MaterialApp` memasang tema dan daftar route.

`lib/routes/app_routes.dart`: `targetForm` adalah alamat form; `targetResult` adalah alamat hasil. `onGenerateRoute` membuat route bertipe `ProfitTarget` untuk form dan `TargetResultAction` untuk layar hasil. Tipe generik ini mengikuti data yang dikirim saat `Navigator.pop`.

### 2. Model dan repository

`models/profit_target.dart`: `ProfitTarget(id, locationId, amount)` adalah data target. `SavedTarget(target, locationName)` adalah paket data untuk layar hasil, karena layar hasil butuh nominal dan nama lokasi. `TargetResultAction.dashboard/another` adalah jawaban dari layar hasil: kembali ke Evaluasi atau atur target lain.

`repositories/profit_target_repository.dart`:

1. `_targets` adalah `Map<String, ProfitTarget>`; kuncinya ID lokasi. Ini membuat satu lokasi mempunyai satu target aktif.
2. `fetchAll()` mengembalikan daftar target tanpa mengizinkan pemanggil mengubah list langsung.
3. `save(locationId, amount)` menolak ID kosong, nominal di bawah Rp100.000, dan nominal di atas batas.
4. `Future.delayed(250 ms)` memberi simulasi waktu proses; ini bukan penyimpanan permanen.
5. Saat target lokasi sudah ada, ID lama dipakai untuk **ubah**; jika belum ada, `_nextId++` membuat ID untuk **tambah**.
6. `_targets[locationId] = target` menaruh hasil di memori. `delete(id)` menghapus target dengan ID itu. Semua data hilang saat aplikasi ditutup.

`models/profit_series.dart`: `SessionProfit.profit` menghitung `revenue - expense`. `groupProfits` menjumlahkan laba sesi pada tanggal yang sama atau minggu yang sama untuk grafik; hari tanpa sesi tidak diberi laba nol. `repositories/evaluation_repository.dart` menyediakan daftar sesi. Saat flag demo aktif, sesi contoh dibuat; tanpa itu, daftar sesi kosong sampai integrasi Modul 2/3.

### 3. ViewModel form: penjelasan per pernyataan penting

`view_models/profit_target_view_model.dart`:

| Pernyataan | Artinya saat demo |
|---|---|
| `extends ChangeNotifier` | ViewModel dapat memberi tahu widget saat state berubah. |
| `status = ViewStatus.loading` | Form punya kondisi loading/success/error saat mengambil lokasi dan target. |
| `locationId`, `amountText` | Nilai input yang sedang dikerjakan pengguna. |
| `dirty`, `isSaving`, `saveError` | Ada perubahan belum tersimpan; proses sedang berjalan; pesan jika simpan gagal. |
| `isValid` | Benar hanya jika lokasi dipilih dan validator nominal mengembalikan `null`. |
| `begin(initialLocationId)` | Reset form, ambil lokasi dan target, lalu isi nominal lama jika pengguna sedang mengubah target. |
| `++_request` lalu `request != _request` | Hasil pemuatan lama tidak boleh menimpa hasil pemuatan yang lebih baru. |
| `_existingAmount(id)` | Mengambil target lama untuk lokasi dan memformatnya menjadi `100.000` di form. |
| `selectLocation(id)` | Ganti lokasi dan isi nominal sesuai target lokasi itu; tandai form berubah. |
| `changeAmount(text)` | Simpan ketikan terbaru ke state, hapus error lama, lalu beri tahu View. |
| `notifyListeners()` | Meminta widget yang memakai `context.watch` membangun tampilan ulang. |
| `save()` | Tolak jika sedang menyimpan atau tidak valid; ubah teks Rupiah ke integer; panggil repository; kembalikan `SavedTarget`. |
| `try/catch/finally` | Berhasil: bersihkan `dirty`; gagal: isi `saveError`; akhirnya: kembalikan `isSaving=false`. |
| `if (!_disposed)` | Jangan memberi tahu widget setelah ViewModel dibuang. |

`context.read<T>()` dipakai untuk **memanggil aksi** tanpa mendengarkan perubahan. `context.watch<T>()` dipakai di `build()` agar UI dibangun ulang saat `notifyListeners()` dipanggil. `setState()` di form hanya untuk state UI lokal seperti `_attempted` dan `_showSuccess`; data target utama ada di ViewModel.

### 4. Validasi dan format input

`core/utils/validators.dart`: `parseRupiah` menerima digit mentah atau format titik ribuan, lalu menghapus titik dan mengubahnya menjadi integer. `profitTarget` mengembalikan pesan untuk kosong, format salah, di bawah Rp100.000, atau terlalu besar. **`null` berarti valid** dalam validator Flutter. Lokasi memakai validator `id == null` pada dropdown. Repository memeriksa batas minimum lagi supaya pemanggilan langsung ke repository juga aman.

`core/utils/rupiah_input_formatter.dart`: `formatEditUpdate` dipanggil Flutter saat teks berubah. `formatDigits` membuang karakter selain digit dan menyisipkan titik setiap tiga digit. Perhitungan `digitsBeforeCursor` dan `offset` menjaga kursor dekat digit yang sedang diedit. Formatter mengubah **tampilan teks**, sedangkan `parseRupiah` mengubahnya kembali menjadi **nilai integer** untuk disimpan. `50000` menjadi `50.000`, bukan `5.000`.

### 5. View: bagian yang menggambar desain dan menangani event

`views/evaluation_screen.dart`: `build()` membuat `Scaffold`, `AppBar`, dan `ListView`. `_rankingCard`, `_chartCard`, `_targetCard`, `_manageCard` adalah bagian visual FR-17 dan pintu masuk FR-18. `TextStyle`, `Color`, `Padding`, `SizedBox`, `Container`, `BoxDecoration`, dan `EvaluationAsset` mengatur **desain**. `onTap` di `_manageCard` memanggil `_openTarget`. `_openTarget` membawa ID lokasi ke form dan menerima `ProfitTarget` ketika form ditutup; `vm.load()` membaca ulang hasil dari repository. `_targetCard` membandingkan `average >= target.amount` untuk status tercapai, dan menyediakan tombol ubah/hapus.

`views/profit_target_form_screen.dart`:

1. `_formKey` adalah pegangan `Form` untuk menjalankan semua validator. `_amount` adalah controller teks. `_attempted` menandai percobaan simpan; `_showSuccess` untuk feedback singkat.
2. `initState()` memasang listener controller: setiap perubahan teks memanggil `vm.changeAmount`. `didChangeDependencies()` membaca argumen lokasi dari route, sekali saja. `_load()` memanggil `vm.begin()` dan menaruh target lama ke controller.
3. `build()` memakai `context.watch<ProfitTargetViewModel>()`. `Scaffold` dan seluruh widget di dalamnya **menggambar desain**. `switch(vm.status)` memilih loading, error, form, atau keadaan belum ada lokasi.
4. `DropdownButtonFormField` memilih lokasi; `onChanged` memanggil `vm.selectLocation`; `validator` menolak lokasi kosong.
5. `TextFormField` menerima nominal; `inputFormatters` memasang format Rupiah otomatis; `validator: Validators.profitTarget` menampilkan pesan di bawah field. Pilihan cepat mengisi nominal terformat.
6. Tombol `Simpan Target` memakai `onPressed: _submit`. `_submit()` memanggil `validate()`; jika valid, memanggil `vm.save()`; jika berhasil, mengirim `SavedTarget` ke layar hasil.
7. `_leave()` dan `PopScope` meminta konfirmasi bila `dirty == true`; `_submit()` menampilkan pesan gagal lewat `vm.saveError` atau navigasi ke layar sukses. `mounted` diperiksa setelah `await` karena pengguna mungkin sudah meninggalkan layar.

`views/target_result_screen.dart`: `build()` menggambar ikon centang, ringkasan lokasi/target, dan tombol. Nilai diambil dari `saved`, bukan angka yang ditulis tetap di UI. **Kembali ke Evaluasi** melakukan `Navigator.pop(context, TargetResultAction.dashboard)`; **Atur Target Lain** mengembalikan `TargetResultAction.another`.

`view_models/evaluation_view_model.dart`: `load()` memuat lokasi, sesi, target. `sessionsFor` memfilter sesi berdasarkan lokasi dan periode tampilan (7 hari terakhir, bulan berjalan, atau semua). **Periode tampilan grafik bukan periode target**: target tetap per sesi. `averageFor` menghitung jumlah laba sesi dibagi jumlah sesi; jika tidak ada sesi, hasilnya `null`, bukan nol. `deleteTarget` menghapus target lalu memperbarui state. `models/profit_series.dart` mengelompokkan titik grafik harian/mingguan.

### Bacaan baris demi baris untuk alur inti `_submit`

Ini fungsi paling tepat dibuka jika dosen meminta kamu menjelaskan seluruh workflow. Nomor di bawah mengikuti urutan pernyataan dalam `profit_target_form_screen.dart`, bukan nomor baris fisik yang bisa berubah ketika kode diformat.

| Urutan | Kode | Penjelasan |
|---|---|---|
| 1 | `final vm = context.read<ProfitTargetViewModel>();` | Ambil ViewModel untuk menjalankan aksi; `read` tidak mendaftar pembaruan tampilan. |
| 2 | `if (vm.isSaving) return;` | Abaikan tap ganda saat simpan sedang berlangsung. |
| 3 | `setState(() => _attempted = true);` | Tandai pengguna sudah mencoba simpan agar petunjuk error UI dapat muncul. |
| 4 | `if (!(_formKey.currentState?.validate() ?? false)) return;` | Jalankan validator dropdown dan nominal; jika gagal, tetap di form. `?? false` menjaga kasus form belum tersedia. |
| 5 | `FocusScope.of(context).unfocus();` | Tutup keyboard agar feedback terlihat. |
| 6 | `final saved = await vm.save();` | Serahkan penyimpanan ke ViewModel dan tunggu hasilnya. |
| 7 | `if (!mounted || saved == null) return;` | Hentikan bila layar sudah ditutup atau simpan gagal; pesan gagal ditampilkan dari `vm.saveError`. |
| 8 | `_savedDuringVisit = saved.target;` | Ingat target yang telah tersimpan untuk hasil saat pengguna meninggalkan form. |
| 9 | `setState(() => _showSuccess = true);` | Tampilkan feedback sukses singkat pada form. |
| 10 | `await Future.delayed(...)` | Beri waktu sekitar 650 ms agar pengguna melihat feedback tersebut. |
| 11 | `if (!mounted) return;` | Jangan navigasi bila layar sudah tidak aktif sesudah penundaan. |
| 12 | `Navigator.pushNamed<TargetResultAction>(..., arguments: saved)` | Buka layar sukses dengan data tersimpan; tunggu pilihan dari layar itu. |
| 13 | `if (!mounted) return;` | Pastikan form masih aktif ketika layar sukses ditutup. |
| 14 | `if (action == TargetResultAction.another)` | Jika pengguna memilih target lain, reset `Form` dan muat form kosong. |
| 15 | `else Navigator.pop(context, saved.target);` | Jika kembali ke Evaluasi, tutup form sambil mengirim target yang tersimpan. |

Untuk membaca baris UI yang berulang, gunakan aturan sederhana: `Widget(...)` membuat elemen tampilan; `child/children` menentukan isi; `padding/height/width/alignment` mengatur posisi; `decoration/style/color` mengatur tampilan; `onTap/onPressed/onChanged` adalah event; `validator` adalah aturan input. Dengan aturan ini, kamu bisa menjelaskan baris UI yang ditunjuk dosen tanpa menghafal ribuan baris widget.

## Urutan demo yang aman

1. Sebelum giliran, buka VS Code dan jalankan `flutter devices`. Pastikan HP Android muncul. Jalankan dari folder `lapakpindah`: `flutter run -d <device-id>`. Build debug otomatis menyediakan lokasi dan sesi contoh; gunakan `--dart-define=LAPAK_DEMO=false` hanya jika ingin menguji keadaan kosong.
2. Buka tab **Evaluasi**. Jelaskan bahwa grafik FR-17 memakai sesi contoh; FR-18 adalah workflow yang akan didemokan.
3. Tap **Kelola Target**. Biarkan nominal kosong, tap **Simpan Target**, tunjukkan pesan wajib diisi. Isi `99999`, tunjukkan batas minimum. Isi `100000`, tunjukkan format otomatis `100.000`.
4. Tap **Simpan Target**. Tunjukkan proses menyimpan dan layar **Target Disimpan!**; sebutkan `SavedTarget` dikirim sebagai argumen route.
5. Tap **Kembali ke Evaluasi**. Tunjukkan target dan status. Tap **Ubah Target** untuk menunjukkan nilai lama dimuat. Jika waktu cukup, tunjukkan hapus dengan dialog konfirmasi.
6. Saat dosen meminta source code, buka file melalui `Ctrl+P` dan nama file; cari fungsi dengan `Ctrl+F`. Demonstrasikan perubahan kecil di tempat yang tepat, jalankan hot reload (`r` di terminal Flutter), lalu jelaskan hasilnya.

Sebelum ujian, pastikan HP muncul di `flutter devices`. Jika tidak muncul, periksa kabel, USB debugging, dan dialog otorisasi di HP. Jangan mengandalkan APK saja: dosen meminta project dan environment yang bisa dijalankan serta diubah.

## Pertanyaan yang mungkin muncul

| Pertanyaan dosen | Jawaban singkat yang sesuai kode |
|---|---|
| “Mana event, state, validasi, feedback, navigasi?” | Tunjukkan tabel lima tahap di atas dan fungsi `_submit`. |
| “Kenapa `notifyListeners`?” | Agar `context.watch` membangun ulang UI setelah ViewModel berubah. |
| “Apa beda `read` dan `watch`?” | `read` memanggil aksi tanpa berlangganan; `watch` membuat widget mengikuti perubahan. |
| “Kenapa validator mengembalikan `null`?” | Kontrak Flutter: `null` valid, string adalah pesan error. |
| “Kenapa simpan dicek dua kali?” | Form memberi pesan yang jelas, repository menjaga aturan jika dipanggil langsung. |
| “Target mingguan/bulanan?” | Belum ada; pilihan week/month pada Evaluasi hanya memfilter data yang ditampilkan. Unit target selalu laba per sesi sesuai PRD final. |
| “Apa arti tercapai?” | Rata-rata laba per sesi dari sesi pada lokasi/periode tampilan lebih besar atau sama dengan target per sesi. Tanpa sesi, status belum dapat dihitung. |
| “Data tersimpan di mana?” | `Map` dalam `ProfitTargetRepository`, hanya selama proses aplikasi berjalan. Belum SQLite/backend. |
| “Dari mana angka grafik?” | Dari `EvaluationRepository`; pada build debug berasal dari data contoh yang aktif secara default, bukan transaksi nyata. Flag `LAPAK_DEMO` dapat mengubah pengaturan itu. |
| “Mengapa batas Rp100.000?” | Keputusan tambahan untuk validasi ujian; PRD final tidak memberi minimum dan contoh dokumen lama perlu diselaraskan. |
| “Bagaimana tambah dan ubah bisa satu fungsi?” | `save` memakai ID target lama bila lokasi sudah punya target, atau ID baru bila belum. |

## Jika diminta “coba ubah…”

| Permintaan | Lokasi edit yang tepat | Pemeriksaan |
|---|---|---|
| Ubah teks judul/warna/jarak/ukuran | `build()` pada `evaluation_screen.dart`, `profit_target_form_screen.dart`, atau `target_result_screen.dart` | Hot reload, lihat UI. |
| Ubah batas minimum | `Validators.minProfitTargetAmount`, pesan di `profitTarget`, hint/info di form; repository memakai konstanta yang sama | Coba satu nilai di bawah dan tepat di batas. |
| Ubah tombol pilihan cepat | Map nominal pada `profit_target_form_screen.dart` | Tap chip, lihat teks dan nilai yang tersimpan. |
| Ubah pesan gagal/sukses | `ProfitTargetViewModel.saveError`, form, atau layar hasil | Uji state yang relevan. |
| Ubah aturan status tercapai | Perhitungan `averageFor` dan perbandingan di `_targetCard` | Uji dengan sesi/target contoh; jangan ubah tanpa menjelaskan aturan PRD. |
| Ubah route/hasil kembali | `app_routes.dart`, `_submit`, `_openTarget`, `target_result_screen.dart` | Jalankan alur dari awal sampai kartu target diperbarui. |

Contoh prompt AI yang baik saat diminta dosen: “Di aplikasi Flutter `lapakpindah` branch `modul4-evaluasi-lokasi`, ubah batas minimum target laba FR-18 dari Rp100.000 menjadi Rp150.000. Pertahankan target per sesi, format Rupiah, arsitektur MVVM/Provider, validasi form dan repository, serta pesan UI. Tunjukkan file yang diubah, jelaskan alasannya, lalu jalankan `flutter analyze` dan tes yang terkait. Jangan mengubah fitur modul lain.” Setelah AI mengubah kode, baca diff dan jelaskan dengan kata-katamu sendiri.

## Pemeriksaan sebelum giliran

- Laptop menyala, VS Code terbuka pada folder `lapakpindah`, branch `modul4-evaluasi-lokasi`.
- `flutter devices` menampilkan Android yang akan dipakai, lalu aplikasi sudah berjalan di sana.
- `flutter analyze` dan `flutter test` selesai tanpa kegagalan.
- Alur kosong → gagal validasi → berhasil simpan → hasil → kembali bisa dilakukan tanpa membaca skrip.
- Bisa membuka enam file inti: `evaluation_screen`, `profit_target_form_screen`, `profit_target_view_model`, `validators`, `profit_target_repository`, `target_result_screen`.
- Jika HP tidak terdeteksi, cek USB debugging/otorisasi/kabel. Siapkan emulator Android sebagai cadangan bila tersedia.
