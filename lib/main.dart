import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/migration_bridge_service.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database while this release still uses the old Isar runtime.
  final isar = await DatabaseService.instance;

  // Keep phones portrait-first, but allow iPad/tablet orientations.
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
  final isTablet = shortestSide >= 600;

  await SystemChrome.setPreferredOrientations(
    isTablet
        ? const [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : const [DeviceOrientation.portraitUp],
  );

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: DerbyDashApp()));
  Timer(const Duration(seconds: 2), () => _startMigrationBridgeBackup(isar));
}

void _startMigrationBridgeBackup(Isar isar) {
  unawaited(() async {
    try {
      debugPrint('Migration bridge starting.');
      final result = await MigrationBridgeService.ensureBackup(
        isar,
      ).timeout(const Duration(minutes: 3));
      debugPrint(
        'Migration bridge ${result.didWrite ? 'wrote' : 'skipped'} '
        '${result.currentSummary.toJson()}: '
        '${result.reason ?? result.backupFile.path}',
      );
    } catch (error, stackTrace) {
      debugPrint('Migration bridge backup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }());
}

class DerbyDashApp extends ConsumerWidget {
  const DerbyDashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize settings on app startup (this applies wakelock if enabled)
    ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Derby Dash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
