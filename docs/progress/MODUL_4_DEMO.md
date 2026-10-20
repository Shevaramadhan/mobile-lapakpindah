# Demo Modul 4: FR-17 dan FR-18

Fokus Practical Challenge adalah **satu workflow FR-18 yang berjalan penuh**. FR-17 dipakai sebagai layar awal dan layar hasil. Buka tab **Evaluasi** → **Kelola Target** → pilih lokasi dan isi nominal → **Simpan Target** → layar **Target Disimpan!** → **Kembali ke Evaluasi**. Target yang baru disimpan muncul di kartu evaluasi. Pengguna juga bisa mengubah atau menghapus target.

Jalankan dengan `flutter run -d <device-id>`; build debug otomatis menampilkan lokasi dan sesi contoh untuk demonstrasi grafik. Data ini hanya contoh dan tidak berasal dari transaksi asli. Untuk menguji keadaan kosong, jalankan `flutter run -d <device-id> --dart-define=LAPAK_DEMO=false`. Build rilis tetap tanpa data contoh kecuali flag demo diaktifkan secara eksplisit.

| Tahap ujian | Implementasi yang bisa ditunjukkan |
|---|---|
| Input/Event | Tap **Kelola Target**, pilih lokasi, ketik nominal (misalnya `100000` langsung tampil `100.000`) atau tap pilihan cepat, tap **Simpan Target**. |
| State | `ProfitTargetViewModel` menyimpan lokasi terpilih, teks nominal, status memuat/menyimpan, error, dan perubahan yang belum disimpan. `EvaluationViewModel` memuat ulang target setelah form selesai. |
| Validation | Lokasi wajib dipilih; nominal wajib angka rupiah bulat, minimal Rp 100.000 per sesi, maksimal Rp 999.999.999.999. Validasi form dan repository mencegah proses simpan yang salah. |
| Feedback | Error di bawah field, indikator saat menyimpan, pesan jika penyimpanan gagal, dan layar sukses jika berhasil. Menutup form dengan perubahan yang belum disimpan meminta konfirmasi. |
| Navigation/Result | `SavedTarget` dikirim ke layar sukses. Layar sukses mengirim aksi kembali atau atur target lain. Form mengembalikan `ProfitTarget` ke Evaluasi, yang memperbarui daftar target. |

Untuk code review: `validators.dart` memuat aturan input; `profit_target_view_model.dart` memuat state dan event; `profit_target_repository.dart` memuat operasi data sementara; `profit_target_form_screen.dart` memuat validasi, feedback, dan navigasi; `target_result_screen.dart` menampilkan hasil; `evaluation_screen.dart` menampilkan target setelah kembali. Uji penting ada di `test/evaluation_workflow_test.dart` dan `test/evaluation_repository_test.dart`.

**Batasan prototipe:** lokasi, target, dan sesi contoh disimpan dalam memori proses aplikasi. Menutup aplikasi menghapus perubahan. Tidak ada backend atau database untuk fitur ini. Data sesi asli dari Modul 3 belum terhubung; saat integrasi nanti, repository dapat diganti tanpa mengubah alur UI.

Tampilan mengikuti frame Figma FR-17/FR-18 (kartu peringkat, tren laba, form, validasi, umpan balik, dan hasil). Teks **target bulanan/periode bulanan** pada contoh Figma diganti menjadi **target per sesi** agar sesuai PRD revisi yang dipakai kelompok. Angka pada Figma adalah contoh desain; nilai di aplikasi dihitung dari data repository dan target yang benar-benar diisi. Batas minimal Rp 100.000 adalah keputusan tambahan untuk alur ujian; PRD final tidak menetapkan nominal minimum, dan contoh di dokumen peran modul masih memakai Rp 75.000. Jika dokumen kelompok diperbarui, samakan contoh nominal dan aturan validasinya.
