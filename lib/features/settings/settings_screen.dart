import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/version.dart';
import '../../domain/session_engine.dart';
import '../session/session_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final edition = app.pack.edition;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text('Edition', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('${edition.editionId} · ${edition.approvalState}'),
        const SizedBox(height: 4),
        Text(edition.provenance),
        const SizedBox(height: 4),
        Text('Publication gate: ${app.pack.isFinishedBook ? 'READY_FOR_FULL_CONTENT_QA' : AppVersion.publicationGate}'),
        const SizedBox(height: 4),
        Text('App ${AppVersion.app} · content schema ${AppVersion.contentSchema} · journal schema ${AppVersion.journalSchema}'),
        const SizedBox(height: 4),
        Text('Content checksum ${edition.checksum}'),
        const SizedBox(height: 20),
        Text('Reading size', style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: app.fontScale.clamp(0.9, 1.6).toDouble(),
          min: 0.9,
          max: 1.6,
          divisions: 7,
          label: app.fontScale.toStringAsFixed(1),
          onChanged: (value) {
            app.setFontScale(value);
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reduce motion'),
          subtitle: const Text('Keeps the mark still. Nothing in a session depends on animation.'),
          value: app.reduceMotion,
          onChanged: (value) {
            app.setReduceMotion(value);
          },
        ),
        const SizedBox(height: 12),
        Text('Privacy', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
          'Notes stay in a private database on this phone, separate from the book. There is no account, analytics, or required network. Switching profiles organizes notes. It is not a lock. Android auto-backup of the journal is turned off. An export file is a plain copy of the notes. It is not encrypted, so keep it somewhere private.',
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () async {
            final archive = await app.journal.exportArchive();
            final bytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(archive));
            await FilePicker.platform.saveFile(
              dialogTitle: 'Export notes',
              fileName: 'closer-journal.json',
              bytes: bytes,
            );
          },
          child: const Text('Export notes'),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () async {
            final picked = await FilePicker.platform.pickFiles(withData: true, type: FileType.custom, allowedExtensions: const ['json']);
            if (!context.mounted || picked == null) {
              return;
            }
            final bytes = picked.files.single.bytes;
            if (bytes == null) {
              return;
            }
            final messenger = ScaffoldMessenger.maybeOf(context);
            try {
              final decoded = jsonDecode(utf8.decode(bytes));
              if (decoded is! Map) {
                throw const FormatException('This file is not a Closer Project journal export.');
              }
              final result = await app.journal.restoreArchive(decoded.map((key, value) => MapEntry(key.toString(), value)));
              messenger?.showSnackBar(
                SnackBar(content: Text('Restored ${result.entriesAdded} notes. ${result.entriesSkipped} were already here.')),
              );
            } on FormatException catch (error) {
              messenger?.showSnackBar(SnackBar(content: Text(error.message)));
            }
          },
          child: const Text('Restore notes'),
        ),
        const SizedBox(height: 20),
        FilledButton.tonal(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SessionScreen(
                  definition: InteractionDefinition.fromJson(sessionEnginePreview),
                ),
              ),
            );
          },
          child: const Text('Preview the session engine'),
        ),
        const SizedBox(height: 8),
        const Text('The preview is a labeled fixture. It is not a chapter, and it does not save notes. A real visit starts from the chapter.'),
      ],
    );
  }
}
