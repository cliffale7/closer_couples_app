import 'package:flutter/material.dart';

import '../../app/app_scope.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _partnerA = TextEditingController();
  final _partnerB = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _partnerA.dispose();
    _partnerB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Text('The Closer Project', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'A private place for two adults who already enjoy each other and want to keep discovering, playing, and remembering. This is not a repair program, and it does not ask you to create an account.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'On a shared phone, two names keep notes organized. Switching names is not a lock. Either person who can open the app can switch profiles.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _partnerA,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'First name or nickname',
                hintText: 'Partner A',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _partnerB,
              decoration: const InputDecoration(
                labelText: 'Second name or nickname',
                hintText: 'Partner B',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : () => _finish(context),
              child: const Text('Continue'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _saving ? null : () => _finish(context, skipNames: true),
              child: const Text('Skip names for now'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish(BuildContext context, {bool skipNames = false}) async {
    setState(() => _saving = true);
    await AppScope.of(context).completeOnboarding(
      skipNames ? '' : _partnerA.text,
      skipNames ? '' : _partnerB.text,
    );
  }
}
