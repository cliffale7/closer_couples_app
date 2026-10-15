import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/content_pack.dart';
import '../experience/experience_screen.dart';
import '../journal/journal_screen.dart';

void openExperience(BuildContext context, Experience experience) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => ExperienceScreen(experience: experience)),
  );
}

void openJournal(BuildContext context, Experience experience) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => JournalScreen(experience: experience)),
  );
}

class ExperienceTile extends StatelessWidget {
  const ExperienceTile({super.key, required this.experience, this.subtitle});

  final Experience experience;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(experience.title),
        subtitle: Text(
          subtitle ?? '${experience.stableId} · ${app.pack.partName(experience.partId)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => openExperience(context, experience),
      ),
    );
  }
}
