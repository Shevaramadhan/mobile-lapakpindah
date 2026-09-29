# LapakPindah — Latihan Praktikum Pertemuan 02

Project ini sudah dilengkapi mengikuti alur Latihan 2:

1. Login + validasi Form
2. Home dengan loading / empty / error state
3. Named Routes
4. Home → Detail dengan pengiriman data dummy
5. Detail → Form Catatan
6. Form Catatan → kembali ke Detail dengan teks catatan
7. Route tidak dikenal → halaman 404

## Cara menjalankan di VS Code

Buka folder project `mobile-lapakpindah-main`, lalu terminal:

```bash
flutter pub get
flutter run
```

Jika memakai HP Android:

```bash
flutter devices
flutter run
```

## Login demo

Nomor: `0812345678`  
Password/PIN: `123456`

## Pengujian Latihan 2

- Login kosong → muncul validasi.
- Password kurang dari 6 karakter → muncul validasi.
- Login benar → masuk Home.
- Home menampilkan daftar lapak setelah loading.
- Tap salah satu lapak → Detail.
- Tap `Tulis Catatan` → Form Catatan.
- Simpan teks minimal 5 karakter → kembali ke Detail dan catatan tampil.
- Route yang tidak dikenal → halaman 404.

Catatan: tampilan dasar Praktikum 1 tetap dipertahankan. Tambahan utama untuk Latihan 2 adalah logika, state, navigasi, data passing, dan halaman yang diperlukan.
