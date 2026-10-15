import 'package:flutter/services.dart';

import '../../domain/content_pack.dart';

class ContentRepository {
  const ContentRepository();

  static const baselineAsset = 'content/canonical/baseline-v0.1/content_pack.json';
  static const activeAsset = 'content/canonical/v1-draft/content_pack.json';

  Future<ContentPack> loadBaseline() async {
    final source = await rootBundle.loadString(baselineAsset);
    return contentPackFromJsonString(source);
  }

  Future<ContentPack> loadActive() async {
    final source = await rootBundle.loadString(activeAsset);
    return contentPackFromJsonString(source);
  }
}
