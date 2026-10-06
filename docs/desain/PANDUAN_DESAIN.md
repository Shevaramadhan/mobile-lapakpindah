# PANDUAN DESAIN & DESIGN SYSTEM (LAPAKPINDAH)
**Dokumen Wajib untuk Menjaga Konsistensi Antarmuka (UI/UX) Kelompok**

Dokumen ini adalah pedoman bagi seluruh anggota tim saat menerjemahkan desain (Figma) menjadi kode Flutter. **DILARANG KERAS** melakukan hardcode warna, ukuran font, atau padding di dalam file UI. Selalu panggil variabel dari folder lib/core/theme/.

---

## 1. DESIGN TOKENS (Sistem Tema)

### A. Palet Warna (AppColors)
Setiap warna dalam aplikasi sudah memiliki variabel pasti. Jangan menebak-nebak kode Hex!
- **Primary Color:** Warna utama aplikasi (misal: warna tombol simpan, header AppBar).
- **Secondary Color:** Warna pendukung (misal: ikon aktif).
- **Background Color:** Warna latar belakang halaman (bukan putih bersih, tapi sedikit abu/krem agar tidak menyilaukan saat dipakai jualan di luar ruangan - NFR-03).
- **Surface Color:** Warna latar belakang Kartu (Card) atau Kotak Form.
- **Success & Error:** Warna Hijau (untuk laba/berhasil) dan Merah (untuk rugi/validasi gagal).

**Cara Pakai di Kode:**
color: AppColors.primary *(BUKAN color: Colors.blue atau color: Color(0xFF123456))*

### B. Tipografi (AppTextStyles)
Aplikasi LapakPindah menggunakan standar teks yang mudah dibaca di bawah sinar matahari (NFR-03).
- **Heading 1 / Title:** Untuk Judul Halaman (Besar, Bold).
- **Heading 2 / Subtitle:** Untuk Judul Kartu/Bagian (Sedang, Semi-bold).
- **Body Text:** Untuk teks biasa/paragraf.
- **Caption:** Untuk teks kecil (misal: tanggal transaksi).

**Cara Pakai di Kode:**
style: AppTextStyles.heading1 *(BUKAN style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))*

### C. Jarak, Margin, & Radius (AppSpacing)
Biar tidak ada jarak (padding) yang belang-belang antar halaman yang dikerjakan anggota berbeda.
- AppSpacing.sm (Small): Jarak kecil (misal 8px) antar elemen yang berdekatan.
- AppSpacing.md (Medium): Jarak standar (misal 16px) untuk margin pinggir layar.
- AppSpacing.lg (Large): Jarak besar (misal 24px) untuk pemisah antar bagian (Section).
- AppSpacing.radius: Lekukan sudut kotak (Border Radius), misal 12px agar desain terlihat modern (tidak kaku/kotak tajam).

**Cara Pakai di Kode:**
padding: EdgeInsets.all(AppSpacing.md) *(BUKAN padding: EdgeInsets.all(15.0))*

---

## 2. ATURAN RESPONSIVITAS LAYAR (Tablet & Desktop)
Aplikasi LapakPindah bersifat fleksibel. Jangan biarkan layout terlihat memanjang jelek (stretching) jika dibuka di Tablet/Web.
- **Wajib:** Bungkus konten utama (terutama Form dan Daftar) dengan ConstrainedBox.
  `dart
  Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: childUtamaAnda,
    ),
  )
  `
- **Wajib:** Gunakan widget SafeArea sebagai pembungkus utama di setiap Scaffold agar UI tidak tertabrak poni (notch) kamera HP atau *navigation bar* bawah.

---

## 3. PANDUAN ASET & FIGMA HANDOFF
Jika anggota butuh memindahkan gambar/ikon dari Figma ke Flutter, patuhi aturan ini agar ukuran aplikasi tidak membengkak raksasa (bloated):
1. **Ikon Vektor:** WAJIB diekspor sebagai **SVG**, bukan PNG. Gunakan package lutter_svg untuk menampilkannya. Gambar SVG tidak akan pernah pecah meskipun di-zoom di layar Tablet yang besar.
2. **Gambar Ilustrasi/Foto:** WAJIB diekspor sebagai **WebP** atau kompresi JPG tinggi. Jangan masukkan file PNG mentah berukuran 2MB ke dalam folder ssets/.
3. **Penamaan File:** Gunakan *snake_case* dengan huruf kecil semua. (Benar: icon_kamera_aktif.svg | Salah: Icon Kamera AKTIF.svg).

---

## 4. STANDARISASI WIDGET KOMPONEN
Semua *button* dan *input form* sudah dibuatkan masternya di folder lib/core/widgets/. 
- Jika butuh tombol biasa, pakai CustomButton.
- Jika butuh kotak isian teks, pakai CustomTextField.
- DILARANG membuat widget desain sendiri (seperti membungkus InkWell dengan Container berwarna) di dalam modul masing-masing tanpa menyatukannya ke folder core/widgets/.
