import 'package:flutter/material.dart';

import '../../../core/utils/format_rupiah.dart';
import '../models/profit_target.dart';
import 'widgets/evaluation_widgets.dart';

/// Feedback sukses FR-18; semua nilai berasal dari SavedTarget yang dikirim form.
class TargetResultScreen extends StatelessWidget {
  const TargetResultScreen({super.key, required this.saved});
  final SavedTarget saved;

  static const _ink = Color(0xFF111C2D);
  static const _muted = Color(0xFF565E74);
  static const _brown = Color(0xFF8D4B00);
  static const _border = Color(0x66DBC2B0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const EvaluationAsset('result_store'),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'LapakPindah',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F3FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDBE3FF)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 3,
                              backgroundColor: Color(0xFF006948),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tersimpan',
                              style: TextStyle(fontSize: 11, color: _muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDFBF0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF006948),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const EvaluationAsset('result_check'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Target Disimpan!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Target laba tersimpan sementara selama aplikasi terbuka.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.5, color: _muted),
                  ),
                  const SizedBox(height: 24),
                  _panel(
                    Column(
                      children: [
                        const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'RINGKASAN DATA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .4,
                                  color: Color(0xFF887364),
                                ),
                              ),
                            ),
                            EvaluationAsset('result_receipt'),
                          ],
                        ),
                        const Divider(height: 14, color: Color(0xFFE4E8F5)),
                        _row('Lokasi', saved.locationName),
                        const Divider(height: 16, color: Color(0xFFE4E8F5)),
                        _row(
                          'Target Baru',
                          formatRupiah(saved.target.amount.toDouble()),
                          emphasis: true,
                        ),
                        const Divider(height: 16, color: Color(0xFFE4E8F5)),
                        _row('Berlaku untuk', 'Setiap sesi'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _panel(
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDCC2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const EvaluationAsset('result_arrow'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Target Laba per Sesi',
                                style: TextStyle(fontSize: 11, color: _muted),
                              ),
                              Text(
                                formatRupiah(saved.target.amount.toDouble()),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _border),
                          ),
                          child: const Text(
                            '1 Sesi',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF006948),
                            ),
                          ),
                        ),
                      ],
                    ),
                    background: const Color(0xFFF0F3FF),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      // Result dashboard menutup halaman hasil menuju form.
                      onPressed: () =>
                          Navigator.pop(context, TargetResultAction.dashboard),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Kembali ke Evaluasi',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 8),
                          EvaluationAsset('result_edit'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      // Result another meminta form dibersihkan untuk target lain.
                      onPressed: () =>
                          Navigator.pop(context, TargetResultAction.another),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xCCDBC2B0)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          EvaluationAsset('result_trend'),
                          SizedBox(width: 8),
                          Text(
                            'Atur Target Lain',
                            style: TextStyle(color: _ink),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Bingkai ringkasan agar dua kelompok data punya gaya yang sama.
  Widget _panel(Widget child, {Color background = Colors.white}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: child,
  );

  /// Label dan nilai target yang dibaca dari SavedTarget.
  Widget _row(String label, String value, {bool emphasis = false}) => Row(
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(fontSize: 13, color: _muted)),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: emphasis ? 18 : 14,
            fontWeight: FontWeight.w700,
            color: emphasis ? _brown : _ink,
          ),
        ),
      ),
    ],
  );
}
