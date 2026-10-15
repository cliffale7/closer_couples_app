import 'package:flutter/material.dart';

import '../data/private/journal_repository.dart';
import '../domain/content_pack.dart';

class AppController extends ChangeNotifier {
  AppController({required this.pack, required this.journal});

  final ContentPack pack;
  final JournalRepository journal;

  List<Profile> profiles = const [];
  Profile? activeProfile;
  bool onboardingComplete = false;
  double fontScale = 1;
  String readerTheme = 'parchment';
  bool reduceMotion = false;
  Set<String> favoriteIds = const {};
  List<SessionRecord> inProgress = const [];

  Future<void> restore() async {
    profiles = await journal.profiles();
    final activeId = await journal.preference('active_profile_id');
    activeProfile = profiles.cast<Profile?>().firstWhere(
          (profile) => profile!.id == activeId,
          orElse: () => profiles.isEmpty ? null : profiles.first,
        );
    onboardingComplete = (await journal.preference('onboarding_complete')) == 'true';
    fontScale = double.tryParse(await journal.preference('font_scale') ?? '') ?? 1;
    readerTheme = await journal.preference('reader_theme') ?? 'parchment';
    reduceMotion = (await journal.preference('reduce_motion')) == 'true';
    favoriteIds = await journal.favoriteIds();
    inProgress = await journal.inProgressSessions();
    notifyListeners();
  }

  Future<void> completeOnboarding(String partnerA, String partnerB) async {
    final first = profiles.firstWhere((profile) => profile.slot == 'partner_a');
    final second = profiles.firstWhere((profile) => profile.slot == 'partner_b');
    await journal.renameProfile(first.id, partnerA.trim().isEmpty ? 'Partner A' : partnerA);
    await journal.renameProfile(second.id, partnerB.trim().isEmpty ? 'Partner B' : partnerB);
    profiles = await journal.profiles();
    activeProfile = profiles.firstWhere((profile) => profile.slot == 'partner_a');
    await journal.setPreference('active_profile_id', activeProfile!.id);
    await journal.setPreference('onboarding_complete', 'true');
    onboardingComplete = true;
    notifyListeners();
  }

  Future<void> setActiveProfile(String id) async {
    activeProfile = profiles.firstWhere((profile) => profile.id == id);
    await journal.setPreference('active_profile_id', id);
    notifyListeners();
  }

  Future<void> setFontScale(double value) async {
    fontScale = value;
    await journal.setPreference('font_scale', value.toString());
    notifyListeners();
  }

  Future<void> setReaderTheme(String value) async {
    readerTheme = value;
    await journal.setPreference('reader_theme', value);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    reduceMotion = value;
    await journal.setPreference('reduce_motion', value.toString());
    notifyListeners();
  }

  Future<void> toggleFavorite(String experienceId) async {
    final next = !favoriteIds.contains(experienceId);
    await journal.setFavorite(experienceId, favorite: next);
    favoriteIds = await journal.favoriteIds();
    notifyListeners();
  }

  Future<void> refreshSessions() async {
    inProgress = await journal.inProgressSessions();
    notifyListeners();
  }
}
