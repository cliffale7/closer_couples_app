import 'package:flutter/material.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/shell/app_shell.dart';
import 'app_controller.dart';
import 'app_scope.dart';
import 'closer_theme.dart';

class CloserApp extends StatelessWidget {
  const CloserApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return MaterialApp(
            title: 'The Closer Project',
            theme: closerLightTheme(),
            darkTheme: closerDarkTheme(),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              final system = MediaQuery.textScalerOf(context);
              final scale = system.scale(1) * controller.fontScale;
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: controller.onboardingComplete ? const AppShell() : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
