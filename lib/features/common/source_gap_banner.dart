import 'package:flutter/material.dart';

import '../../app/closer_theme.dart';

class SourceGapBanner extends StatelessWidget {
  const SourceGapBanner({super.key, this.compact = false, this.completeness = 'inventory_not_full_chapters'});

  final bool compact;
  final String completeness;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CloserColors.burgundy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CloserColors.burgundy.withValues(alpha: 0.35)),
      ),
      child: Text(
        _message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  String get _message {
    if (completeness == 'copyedited_draft') {
      return compact
          ? 'Copyedited draft. Not the owner-approved release.'
          : 'These are the copyedited v1 draft chapters. The publication gate stays closed until the owner marks the edition approved.';
    }
    return compact
        ? 'Inventory only. The finished chapter is not in this edition.'
        : 'This build is using the v0.1 inventory. Finished chapters, signature sessions, durations, and artwork arrive with an approved book. Nothing here is filled in as if it were that book.';
  }
}
