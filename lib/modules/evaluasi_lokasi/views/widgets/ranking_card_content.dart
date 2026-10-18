import 'package:flutter/material.dart';

import '../../../../core/utils/format_rupiah.dart';
import '../../view_models/evaluation_view_model.dart';

/// Isi visual kartu peringkat; bingkai kartu tetap dibuat layar Evaluasi.
class RankingCardContent extends StatelessWidget {
  const RankingCardContent({super.key, required this.vm});
  final EvaluationViewModel vm;

  static const _ink = Color(0xFF1E293B);
  static const _muted = Color(0xFF9CA3AF);
  static const _orange = Color(0xFFB45309);
  static const _green = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    final ranked =
        vm.locations.where((l) => vm.averageFor(l.id) != null).toList()..sort(
          (a, b) => vm.averageFor(b.id)!.compareTo(vm.averageFor(a.id)!),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Peringkat Lokasi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              Text(
                'LABA RATA-RATA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .5,
                  color: _muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (ranked.isEmpty)
            const SizedBox(
              height: 98,
              child: Center(
                child: Text(
                  'Belum ada sesi selesai untuk dibandingkan.',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
              ),
            )
          else
            for (var i = 0; i < ranked.length && i < 2; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF9FAFB)),
                ),
              InkWell(
                onTap: () => vm.selectLocation(ranked[i].id),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? const Color(0xFFFFF7ED)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: i == 0 ? _orange : _muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ranked[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          Text(
                            '${vm.sessionsFor(ranked[i].id).length} sesi selesai',
                            style: const TextStyle(fontSize: 10, color: _muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCompactRupiah(vm.averageFor(ranked[i].id)!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: i == 0 ? _green : _ink,
                          ),
                        ),
                        Text(
                          i == 0 ? 'TERTINGGI' : 'PER SESI',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: i == 0 ? _green : _muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}
