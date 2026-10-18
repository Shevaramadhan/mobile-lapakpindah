import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service notifikasi lokal untuk seluruh aplikasi.
///
/// Menangani semua notifikasi lokal (FR-05, FR-10, FR-15, FR-20 di PRD v2).
/// Untuk Modul 2, dipakai notifikasi FR-10: peringatan saat total pengeluaran
/// mencapai/melewati batas yang ditetapkan (sekali per sesi).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inisialisasi plugin notifikasi (panggil di main()).
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Minta izin notifikasi untuk Android 13+ (API 33+)
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Menampilkan notifikasi peringatan batas pengeluaran (FR-10).
  ///
  /// [sessionId] dipakai sebagai ID notifikasi supaya tidak muncul duplikat
  /// (hanya 1x per sesi).
  Future<void> showExpenseLimitWarning({
    required String sessionId,
    required String locationName,
    required double total,
    required double limit,
  }) async {
    if (!_initialized) await initialize();

    // Gunakan hash sessionId sebagai notification ID agar unik per sesi
    final notificationId = sessionId.hashCode.abs();

    const androidDetails = AndroidNotificationDetails(
      'expense_limit_channel',
      'Peringatan Batas Pengeluaran',
      channelDescription: 'Notifikasi saat pengeluaran mencapai batas harian',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Peringatan Batas Pengeluaran',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      notificationId,
      'Batas pengeluaran tercapai! 🚨',
      'Total pengeluaran di $locationName sudah mencapai Rp ${_formatRupiah(total)} dari batas Rp ${_formatRupiah(limit)}.',
      notificationDetails,
    );
  }

  /// Callback saat notifikasi di-tap (bisa dipakai untuk navigasi ke layar tertentu).
  void _onNotificationTap(NotificationResponse response) {
    // TODO: bisa tambahkan navigasi ke layar pengeluaran saat notifikasi ditap
  }

  /// Format angka ke Rupiah sederhana (mis. 200000 → "200.000").
  String _formatRupiah(double amount) {
    final intAmount = amount.toInt();
    final str = intAmount.toString();
    final buffer = StringBuffer();
    int counter = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      if (counter == 3) {
        buffer.write('.');
        counter = 0;
      }
      buffer.write(str[i]);
      counter++;
    }

    return buffer.toString().split('').reversed.join();
  }
}
