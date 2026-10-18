import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../models/profit_series.dart';

/// Grafik dinamis: skala mencakup rugi, nol, nilai sama, dan satu titik.
/// Grafik tetap dapat dibaca pembaca layar.
class ProfitTrendChart extends StatelessWidget {
  const ProfitTrendChart({
    super.key,
    required this.points,
    required this.grouping,
  });
  final List<ProfitPoint> points;
  final TrendGrouping grouping;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Semantics memberi deskripsi grafik untuk pembaca layar.
    return Semantics(
      label: 'Grafik tren laba ${points.length} periode',
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: CustomPaint(
          painter: _TrendPainter(
            points,
            grouping,
            colors.primary,
            colors.outlineVariant,
            Theme.of(context).textTheme.labelSmall!,
            Directionality.of(context),
          ),
        ),
      ),
    );
  }
}

/// Menggambar grid, garis, area, titik, dan label tanggal pada Canvas.
class _TrendPainter extends CustomPainter {
  _TrendPainter(
    this.points,
    this.grouping,
    this.color,
    this.gridColor,
    this.textStyle,
    this.direction,
  );
  final List<ProfitPoint> points;
  final TrendGrouping grouping;
  final Color color;
  final Color gridColor;
  final TextStyle textStyle;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    // Skala selalu mencakup nol dan tetap aman untuk rugi atau satu nilai saja.
    final minValue = math
        .min(0, points.map((p) => p.profit).reduce(math.min))
        .toDouble();
    final maxValue = math
        .max(0, points.map((p) => p.profit).reduce(math.max))
        .toDouble();
    final range = maxValue - minValue;
    final padding = range == 0 ? 1.0 : range * .12;
    final low = minValue >= 0 ? 0.0 : minValue - padding;
    final high = maxValue + padding;
    // Sisakan ruang kiri untuk label Rupiah dan bawah untuk label tanggal.
    final area = Rect.fromLTWH(
      58,
      12,
      math.max(1, size.width - 68),
      size.height - 38,
    );
    double y(double value) =>
        area.bottom - (value - low) / (high - low) * area.height;
    void label(String text, Offset position, {bool centered = false}) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: direction,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          centered
              ? (position.dx - painter.width / 2).clamp(
                  0,
                  size.width - painter.width,
                )
              : position.dx,
          position.dy,
        ),
      );
    }

    // Empat interval grid membantu membaca besaran laba pada sumbu Y.
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final value = low + (high - low) * i / 4;
      final row = y(value);
      canvas.drawLine(Offset(area.left, row), Offset(area.right, row), grid);
      final number = 'Rp ${(value / 1000).round()}k';
      label(number, Offset(0, row - 7));
    }
    canvas.drawLine(
      Offset(area.left, y(0)),
      Offset(area.right, y(0)),
      Paint()
        ..color = color.withValues(alpha: .4)
        ..strokeWidth = 1,
    );
    // Ubah tanggal menjadi posisi horizontal; satu titik ditempatkan di tengah.
    final first = points.first.date.millisecondsSinceEpoch;
    final duration = points.last.date.millisecondsSinceEpoch - first;
    final offsets = points
        .map(
          (p) => Offset(
            duration == 0
                ? area.center.dx
                : area.left +
                      (p.date.millisecondsSinceEpoch - first) /
                          duration *
                          area.width,
            y(p.profit.toDouble()),
          ),
        )
        .toList();
    // Hubungkan titik laba dari tanggal paling lama ke paling baru.
    final line = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      line.lineTo(offset.dx, offset.dy);
    }
    if (offsets.length > 1) {
      // Isi area tipis di bawah garis hanya jika ada lebih dari satu titik.
      final fill = Path.from(line)
        ..lineTo(offsets.last.dx, y(0))
        ..lineTo(offsets.first.dx, y(0))
        ..close();
      canvas.drawPath(fill, Paint()..color = color.withValues(alpha: .07));
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
    // Batasi jumlah label agar tanggal tidak saling bertumpuk di layar kecil.
    final step = math.max(1, (points.length / 7).ceil());
    for (var i = 0; i < offsets.length; i++) {
      canvas.drawCircle(offsets[i], 3, Paint()..color = color);
      if (i % step == 0 || i == offsets.length - 1 && i % step > 1) {
        label(
          grouping == TrendGrouping.daily
              ? const [
                  'Sen',
                  'Sel',
                  'Rab',
                  'Kam',
                  'Jum',
                  'Sab',
                  'Min',
                ][points[i].date.weekday - 1]
              : DateFormat('dd/MM').format(points[i].date),
          Offset(offsets[i].dx, area.bottom + 12),
          centered: true,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.points != points ||
      old.grouping != grouping ||
      old.color != color ||
      old.gridColor != gridColor ||
      old.textStyle != textStyle;
}
