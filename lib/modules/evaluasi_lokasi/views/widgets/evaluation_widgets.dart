import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SVG asli Figma; ukuran intrinsik aset dipertahankan.
class EvaluationAsset extends StatelessWidget {
  const EvaluationAsset(this.name, {super.key});
  final String name;
  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/evaluation/$name.svg');
}
