import 'package:flutter/material.dart';

import '../../domain/discovery.dart';

class DiscoveryFilterPanel extends StatelessWidget {
  const DiscoveryFilterPanel({
    super.key,
    required this.time,
    required this.outcomes,
    required this.energy,
    required this.depth,
    required this.formats,
    required this.onToggle,
  });

  final Set<String> time;
  final Set<String> outcomes;
  final Set<String> energy;
  final Set<String> depth;
  final Set<String> formats;
  final void Function(String group, String id) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _group(context, 'Time', 'time', timeBuckets, time, initiallyExpanded: true),
        _group(context, 'Desired feeling', 'outcome', outcomeOptions, outcomes),
        _group(context, 'Energy', 'energy', energyOptions, energy),
        _group(context, 'Emotional depth', 'depth', depthOptions, depth),
        _group(context, 'Format', 'format', formatOptions, formats),
      ],
    );
  }

  Widget _group(
    BuildContext context,
    String title,
    String group,
    List<FacetOption> options,
    Set<String> selected, {
    bool initiallyExpanded = false,
  }) {
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      title: Text(title),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                FilterChip(
                  label: Text(option.detail.isEmpty ? option.label : '${option.label}\n${option.detail}'),
                  selected: selected.contains(option.id),
                  onSelected: (_) => onToggle(group, option.id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
