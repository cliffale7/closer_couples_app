import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExperienceArt extends StatelessWidget {
  const ExperienceArt({super.key, required this.asset, this.height = 180});

  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      semanticsLabel: 'Chapter artwork',
    );
  }
}
