import 'package:flutter/material.dart';

import 'app/app_controller.dart';
import 'app/closer_app.dart';
import 'data/content/content_repository.dart';
import 'data/private/journal_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pack = await const ContentRepository().loadActive();
  final journal = await JournalRepository.openDefault();
  final controller = AppController(pack: pack, journal: journal);
  await controller.restore();
  runApp(CloserApp(controller: controller));
}
