/// Status tampilan layar yang memuat data (M4: State-Driven UI).
///
/// Sengaja ditaruh di file sendiri TANPA import Flutter, supaya ViewModel
/// bisa memakainya tanpa ikut bergantung pada widget UI (M3: MVVM).
///
/// - loading : data sedang diambil  → View menampilkan LoadingView
/// - success : data berhasil diambil → View menampilkan isi layar
/// - error   : data gagal diambil    → View menampilkan ErrorView
enum ViewStatus { loading, success, error }
