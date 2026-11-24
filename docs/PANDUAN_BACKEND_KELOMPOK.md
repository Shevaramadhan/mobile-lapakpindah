# Panduan Backend & Integrasi Kelompok 8

Panduan ini untuk semua anggota. Bacalah sampai habis sebelum mulai
mengerjakan backend modul Anda.

Tujuannya: kita bekerja di branch masing-masing, tetapi **strukturnya sudah
sama sejak awal**, sehingga saat digabung ke `main` tidak bentrok dan modul
langsung saling terhubung.

Dokumen terkait (berada di repo backend `lapakpindah-backend`):
- [Kontrak API](../../lapakpindah-backend/docs/api/kontrak-api.md) (`lapakpindah-backend/docs/api/kontrak-api.md`): daftar endpoint dan bentuk JSON. **Wajib dibaca.**
- [README Backend](../../lapakpindah-backend/README.md) (`lapakpindah-backend/README.md`): cara menjalankan server di laptop.

### Susunan repository (2 repo terpisah)

Backend dan aplikasi mobile dipisah ke dua repository dan folder sejajar:

```text
lapak-pindah/
├── lapakpindah/           ← Repo Mobile (Flutter): mobile-lapakpindah
└── lapakpindah-backend/   ← Repo Backend (Express + MySQL + Kontrak API)
```

---

## 1. Gambaran sistem

```text
HP (Flutter — lapakpindah)                      Server (Express — lapakpindah-backend)  MySQL
View → ViewModel → Repository ─┬─ RemoteXxxRepository → ApiClient ─HTTP─▶ route → controller → repository ─▶ tabel
                               └─ LocalXxxRepository (data contoh, untuk tes & tanpa server)
```

- Aplikasi memakai server jika dijalankan dengan `--dart-define=API_BASE_URL=...`.
  Tanpa itu, aplikasi tetap memakai data contoh seperti sekarang, jadi tes
  dan demo lama tidak rusak.
- Semua modul memakai **satu database** dan **satu server**. Hubungan antar
  modul dijaga oleh foreign key di MySQL, bukan disalin antar repository.

---

## 2. Pembagian folder: siapa mengubah apa

**Aturan utama: ubah hanya folder milik Anda.** Dua orang yang mengubah file
yang sama adalah satu-satunya penyebab bentrok (conflict) saat merge.

| Pemilik | Repo Backend (`lapakpindah-backend/`) | Repo Mobile (`lapakpindah/`) |
|---|---|---|
| Anggota 1 — Modul 1 Lokasi & Sesi | `src/modules/sesi_lokasi/`<br>`database/schema/01_sesi_lokasi.sql`<br>`test/sesi_lokasi/` | `lib/modules/sesi_lokasi/` |
| Anggota 2 — Modul 2 Pengeluaran | `src/modules/pengeluaran/`<br>`database/schema/02_pengeluaran.sql`<br>`test/pengeluaran/` | `lib/modules/pengeluaran/` |
| Anggota 3 — Modul 3 Penjualan | `src/modules/penjualan/`<br>`database/schema/03_penjualan.sql`<br>`test/penjualan/` | `lib/modules/penjualan/` |
| Anggota 4 — Modul 4 Evaluasi | `src/modules/evaluasi_lokasi/`<br>`database/schema/04_evaluasi_lokasi.sql`<br>`test/evaluasi_lokasi/` | `lib/modules/evaluasi_lokasi/` |
| **Koordinator** (file bersama) | `src/app.js`, `src/shared/`, `src/middleware/`, `src/config/`, `src/modules/auth/`, `database/schema/00_auth.sql`, `database/seeds/`, `package.json`, `package-lock.json` | `lib/core/`, `lib/main.dart`, `lib/routes/`, `lib/modules/auth/`, `lib/modules/home/`, `pubspec.yaml`, `pubspec.lock`, `android/` |
| Semua (lewat Koordinator) | `docs/api/kontrak-api.md` | `docs/PANDUAN_BACKEND_KELOMPOK.md` |

### Kalau butuh mengubah file bersama

Contohnya: perlu paket npm atau Flutter baru, menambah route di
`app_routes.dart`, menambah data demo, atau mengubah kontrak.

1. Kabari Koordinator di grup: apa yang perlu diubah dan alasannya.
2. Koordinator mengubahnya di `main` (di repo yang bersangkutan).
3. Semua anggota menarik `main` ke branch masing-masing (langkah 4).

**Jangan** menjalankan `npm install <paket>` atau `flutter pub add <paket>`
di branch Anda. Itu mengubah lockfile, dan lockfile yang diubah dua orang
hampir pasti bentrok.

### Yang sudah disiapkan di `main` agar Anda tidak perlu menyentuh file bersama

- `src/app.js` di repo backend **sudah mendaftarkan keempat modul**. Anda cukup
  mengisi `src/modules/<modul>/index.js`.
- Tiap modul punya file schema sendiri (`database/schema/0X_<modul>.sql`),
  dan semua tabel sudah dibuat sesuai PRD.
- Paket yang dibutuhkan semua modul sudah terpasang: `bcryptjs` dan
  `jsonwebtoken` (login), `multer` (upload foto nota), `mysql2`, serta
  `http` di Flutter.
- Data demo (`database/seeds/demo.sql`) sudah berisi lokasi, satu sesi
  selesai, satu sesi aktif, produk, penjualan, dan pengeluaran. Setiap
  anggota bisa langsung menguji modulnya tanpa menunggu modul lain.
- `GET /sessions/active` sudah jadi, karena Modul 2 dan 3 membutuhkannya.
- Login (JWT) sudah jadi, termasuk login dari aplikasi Flutter.

---

## 3. Langkah pertama (sekali saja)

### A. Update repo Mobile (`lapakpindah/`)

Kondisi branch mobile per 17 November 2026: branch Modul 1, 3, dan 4 **tidak punya
commit baru** setelah integrasi 20 Oktober, jadi tinggal disamakan dengan
`main`. Branch Modul 2 punya satu commit dokumentasi, dan sudah dicek bisa
digabung dengan `main` tanpa bentrok.

```bash
cd lapakpindah
git status                     # pastikan bersih; jika ada perubahan, commit dulu
git fetch origin
git checkout <branch-anda>     # contoh: modul1-lokasi-sesijualan
git merge origin/main          # Modul 1, 3, 4: langsung sama dengan main
                               # Modul 2: membuat merge commit, tanpa bentrok
git push origin <branch-anda>
```

### B. Clone & siapkan repo Backend (`lapakpindah-backend/`)

Clone repo backend **sejajar** dengan folder `lapakpindah/` (bukan di dalamnya),
lalu gunakan nama branch modul yang sama:

```bash
# Jalankan di folder induk (sejajar dengan folder lapakpindah/)
git clone https://github.com/Shevaramadhan/backend-lapakpindah.git lapakpindah-backend
cd lapakpindah-backend
git checkout -b <branch-anda>  # atau git checkout <branch-anda> jika sudah ada di origin
npm install
copy .env.example .env         # Mac/Linux: cp .env.example .env
# isi DB_USER / DB_PASSWORD / DB_PORT di .env
npm run db:fresh               # buat semua tabel + data demo
npm run dev
```

| Anggota | Nama Branch (sama di kedua repo) |
|---|---|
| Anggota 1 | `modul1-lokasi-sesijualan` |
| Anggota 2 | `modul-2-pengeluaran` |
| Anggota 3 | `modul3-pencatatan-penjualan` |
| Anggota 4 | `modul4-evaluasi-lokasi` |

Buka `http://localhost:3000/api/health`. Harus tampil `"database": "connected"`.

---

## 4. Alur kerja harian (git)

Alur di bawah ini berlaku sama di **kedua repo** (`lapakpindah-backend/` untuk
backend, dan `lapakpindah/` untuk Flutter):

```text
            main  ●──────────●───────────────●──────────▶
                   \          \ (tarik main)  ▲ (Pull Request)
 branch-anda        ●──●──●────●──●──●────────┘
```

1. **Sebelum mulai kerja**, tarik perubahan terbaru dari `main` di kedua repo:
   ```bash
   git fetch origin
   git merge origin/main
   ```
   Di `lapakpindah-backend`, jika ada file schema teman yang berubah, jalankan `npm run db:fresh`.
2. Kerjakan **hanya** di folder milik Anda. Commit kecil-kecil di masing-masing repo:
   ```bash
   # Di repo backend (lapakpindah-backend/)
   git add src/modules/pengeluaran test/pengeluaran
   git commit -m "feat(pengeluaran): endpoint tambah pengeluaran"
   git push origin <branch-anda>

   # Di repo mobile (lapakpindah/)
   git add lib/modules/pengeluaran
   git commit -m "feat(pengeluaran): sambungkan pengeluaran ke API"
   git push origin <branch-anda>
   ```
   Pakai `git add <folder-anda>`, **bukan** `git add .`, agar file lain
   tidak ikut tanpa sengaja.
3. Jika satu fitur sudah selesai dan lulus checklist (bagian 8), buat
   **Pull Request** ke `main` di GitHub (PR backend di repo backend, PR Flutter
   di repo mobile). Koordinator memeriksa lalu menggabungkannya.
4. Setelah PR digabung, anggota lain menarik `main` lagi (langkah 1).

Format pesan commit: `feat(<modul>): ...`, `fix(<modul>): ...`, atau
`docs(<modul>): ...`. Contoh: `fix(penjualan): harga khusus tidak terpakai`.

**Jangan format seluruh proyek.** `dart format .` atau fitur "format semua
file" di editor akan mengubah ribuan baris milik orang lain. Format folder
Anda saja: `dart format lib/modules/<modul-anda>`.

---

## 5. Mengerjakan endpoint backend modul Anda

Semua langkah di bagian ini dilakukan di dalam folder repo **`lapakpindah-backend/`**.
Contoh lengkap yang bisa ditiru: Modul 1 lokasi di `src/modules/sesi_lokasi/locations/`.

```text
lapakpindah-backend/
  src/modules/<modul>/
    index.js                    ← daftar URL modul (sudah ada, isi TODO-nya)
    <resource>/
      <resource>.validator.js   ← cek isian dari aplikasi (422 jika salah)
      <resource>.repository.js  ← query SQL saja
      <resource>.controller.js  ← terima request → validasi → repository → jawab JSON
```

Langkah:

1. Baca bagian modul Anda di `lapakpindah-backend/docs/api/kontrak-api.md`.
2. Salin folder `src/modules/sesi_lokasi/locations/` ke folder modul Anda, misalnya
   `src/modules/pengeluaran/expenses/`, lalu ganti isinya.
3. Daftarkan URL di `src/modules/<modul>/index.js`:
   ```js
   import * as expenses from './expenses/expense.controller.js';
   pengeluaranRoutes.get('/expenses', expenses.list);
   pengeluaranRoutes.post('/expenses', expenses.create);
   ```
4. Buat tes validator di `test/<modul>/`, lalu jalankan `npm test`.
5. Coba endpoint dengan token (lihat `lapakpindah-backend/README.md` bagian "Mencoba endpoint").

Aturan yang wajib diikuti:

- **Selalu batasi data dengan `req.userId`.** Jangan menerima `userId` dari body.
- Pakai pembantu di `src/shared/validate.js`: `readText`, `readRupiah`,
  `readPositiveInt`, `readDateTime`, `throwIfInvalid`, `parseId`.
- Lempar `new HttpError(404, 'Pengeluaran tidak ditemukan')` untuk error.
  Tidak perlu try-catch, karena error otomatis diubah ke format kontrak.
- Pesan error berbahasa Indonesia dan bisa langsung ditampilkan ke pengguna.
- Selalu pakai `?` di query (`db.query('... WHERE id = ?', [id])`). Jangan
  menyambung teks SQL dengan input pengguna.
- Mengubah kolom tabel Anda: ubah file schema Anda, lalu `npm run db:fresh`.
  Jika kolom itu dipakai modul lain, kabari pemakainya dulu.

---

## 6. Menyambungkan modul Flutter ke server

Pola untuk setiap modul: **satu kontrak abstrak, dua implementasi.** ViewModel
dan View tidak berubah, karena yang diganti hanya sumber datanya.

### Langkah 1 — Jadikan repository yang ada sebagai kontrak + versi lokal

```dart
// lib/modules/pengeluaran/repositories/pengeluaran_repository.dart
abstract class PengeluaranRepository {
  Future<List<Expense>> getExpenses();
  Future<Expense> addExpense({required String description, required double amount, required ExpenseCategory category});
  // ... method lain yang sudah dipakai ViewModel
}

/// Isi kelas lama dipindah ke sini, tanpa diubah (data contoh di memori).
class LocalPengeluaranRepository implements PengeluaranRepository { ... }
```

### Langkah 2 — Buat versi server

```dart
// lib/modules/pengeluaran/repositories/remote_pengeluaran_repository.dart
import 'package:lapakpindah/core/network/api_client.dart';

class RemotePengeluaranRepository implements PengeluaranRepository {
  RemotePengeluaranRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<Expense>> getExpenses() async {
    final json = await _api.get('expenses') as List<dynamic>;
    return json.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Expense> addExpense({...}) async {
    final json = await _api.post('expenses', body: {
      'description': description,
      'amount': amount.round(),          // uang dikirim sebagai bilangan bulat
      'category': category.name,         // bahanBaku, operasional, ...
    });
    return _fromJson(json as Map<String, dynamic>);
  }

  // Ubah JSON kontrak menjadi model yang sudah ada.
  Expense _fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'].toString(),           // model lama memakai String
    sessionId: json['sessionId'].toString(),
    description: json['description'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: ExpenseCategory.fromString(json['category'] as String?),
    receiptPhotoPath: json['receiptPhotoUrl'] as String?,
    recordedAt: DateTime.parse(json['recordedAt'] as String).toLocal(),
    isFixedCost: json['isFixedCost'] as bool,
  );
}
```

Jangan menangkap error di repository. Biarkan `ApiException` naik ke ViewModel.

### Langkah 3 — Pilih versi di dalam modul Anda sendiri

Agar tidak perlu mengubah `main.dart`, pilih repository di konstruktor
ViewModel modul Anda:

```dart
class PengeluaranViewModel extends ChangeNotifier {
  PengeluaranViewModel({PengeluaranRepository? repository})
    : _repository = repository ??
          (ApiClient.shared != null
              ? RemotePengeluaranRepository(ApiClient.shared!)
              : LocalPengeluaranRepository());
```

Tes tetap memakai versi lokal karena tes berjalan tanpa `API_BASE_URL`.

### Langkah 4 — Tampilkan error server di ViewModel

```dart
} on ApiException catch (e) {
  _errorMessage = e.message;                      // pesan umum
  _fieldErrors = e.fieldErrors;                   // e.fieldErrors['amount'] untuk form
  if (e.isNetworkError) { /* tampilkan tombol "Coba lagi" */ }
}
```

### Langkah 5 — Tes repository server tanpa server sungguhan

Tiru `test/core/api_client_test.dart`. `MockClient` dari `package:http/testing.dart`
berpura-pura menjadi backend. Buat minimal satu tes JSON benar dan satu tes
error 422.

### Kapan pakai server lokal vs server VPS?

- **Saat sedang membuat/menguji endpoint baru di branch Anda:** jalankan backend di **laptop sendiri** (`http://localhost:3000/api/v1` — bisa lewat Docker `docker compose up -d db && npm run dev` atau XAMPP/Laragon), karena endpoint baru tersebut belum ada di VPS.
- **Setelah PR digabung ke `main` (tes integrasi lintas modul / demo):** arahkan Flutter ke **server VPS bersama**:
  `https://lapakpindah.43-157-229-215.sslip.io/api/v1`
  Koordinator cukup menjalankan `cd /opt/lapakpindah-backend && ./deploy.sh --host-db` di VPS setiap ada PR yang masuk ke `main`.

### Menjalankan aplikasi dengan server

| Perangkat | Perintah |
|---|---|
| Chrome (lokal) | `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1` |
| HP lewat kabel USB (lokal) | `adb reverse tcp:3000 tcp:3000` lalu `flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1` |
| Emulator Android (lokal) | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1` |
| Server VPS (integrasi & demo) | `flutter run --dart-define=API_BASE_URL=https://lapakpindah.43-157-229-215.sslip.io/api/v1` |

Login demo: `081234567890` / PIN `123456`. Tanpa `API_BASE_URL`, aplikasi
memakai data contoh seperti biasa.

---

## 7. Hubungan antar modul

```text
          Auth (Koordinator) ── semua endpoint butuh token
                 │
        Modul 1 Lokasi & Sesi
        ├── locations ─────────────┬──────────────┬──────────────┐
        └── sales_sessions ────────┤              │              │
                 │  applyFixedCosts│(FR-08)       │              │
                 ▼                 ▼              ▼              ▼
          Modul 2 Pengeluaran   Modul 3 Penjualan        Modul 4 Evaluasi
          expenses ──────────▶  break-even (FR-14)  ◀─── baca semua (JOIN)
```

| Yang dibutuhkan | Penyedia | Pemakai | Cara memakai |
|---|---|---|---|
| Sesi aktif | Modul 1 | Modul 2, 3 | Backend: `requireActiveSession(req.userId)` dari `src/shared/active-session.js`. Flutter: `GET /sessions/active` |
| Daftar lokasi | Modul 1 | Modul 2 (biaya tetap), 3 (harga khusus), 4 | `GET /locations` |
| Biaya tetap otomatis saat buka sesi | Modul 2 | Modul 1 | `applyFixedCosts()` di `pengeluaran/fixed_costs/apply-fixed-costs.js` |
| Total pengeluaran sesi | Modul 2 (tabel `expenses`) | Modul 3 (balik modal) | `SELECT SUM(amount) FROM expenses WHERE session_id = ?` |
| Penjualan & pengeluaran per sesi | Modul 2 dan 3 | Modul 4 | JOIN ke `sales` dan `expenses`, **hanya membaca** |

Aturan membaca tabel modul lain: boleh `SELECT`, tetapi `INSERT`, `UPDATE`,
dan `DELETE` hanya lewat endpoint atau fungsi milik pemilik tabel.
Pengecualian: kolom `limit_notified` (Modul 2) dan `break_even_notified`
(Modul 3) di `sales_sessions` boleh diubah oleh modul yang disebut.

### Urutan pengerjaan yang disarankan

Semua anggota bisa mulai bersamaan karena data demo sudah tersedia.
Prioritaskan yang ditunggu orang lain:

1. **Anggota 1:** `POST /sessions` dan `POST /sessions/:id/close`, karena tanpa
   ini sesi baru belum bisa dibuat dari aplikasi.
2. **Anggota 2:** isi `applyFixedCosts()` dan `POST /expenses`.
3. **Anggota 3:** `POST /sales` dan `GET /sales/break-even`.
4. **Anggota 4:** `GET /evaluation/ranking`, yang bisa diuji langsung dengan data demo.

---

## 8. Checklist sebelum Pull Request

### Repo Backend (`lapakpindah-backend/`)
- [ ] Sudah `git merge origin/main` dan tidak ada conflict.
- [ ] Hanya file di folder milik saya yang berubah (cek di tab "Files changed" PR).
- [ ] `npm test` lulus.
- [ ] `npm run db:fresh` berhasil (schema saya tidak rusak).
- [ ] Endpoint sudah dicoba dengan token dan sesuai `docs/api/kontrak-api.md`.
- [ ] Status endpoint di `docs/api/kontrak-api.md` saya ubah dari ⏳ menjadi ✅ (minta Koordinator jika ragu).

### Repo Mobile (`lapakpindah/`)
- [ ] Sudah `git merge origin/main` dan tidak ada conflict.
- [ ] Hanya file di folder milik saya yang berubah (cek di tab "Files changed" PR).
- [ ] `flutter analyze` tidak ada isu.
- [ ] `flutter test` lulus.

---

## 9. Jika terjadi conflict

1. Jangan panik dan jangan `git push --force`.
2. `git status` menunjukkan file yang bentrok. Jika file itu **bukan milik
   Anda**, ambil versi `main`:
   ```bash
   git checkout --theirs <file>    # saat merge origin/main: "theirs" = main
   git add <file>
   ```
3. Jika file milik Anda, buka file, pilih bagian yang benar, hapus tanda
   `<<<<<<<`, `=======`, dan `>>>>>>>`, lalu `git add <file>`.
4. `git commit` untuk menyelesaikan merge, lalu jalankan tes.
5. Masih bingung? Jalankan `git merge --abort` (kembali seperti sebelum
   merge), lalu tanyakan di grup.
