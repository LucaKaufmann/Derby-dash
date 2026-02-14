import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/settings_provider.dart';
import 'router/app_router.dart';
import 'screenshot/screenshot_scenario.dart';
import 'screenshot/screenshot_seed_data.dart';
import 'theme/app_theme.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final screenshotSeedContext = await ScreenshotDataSeeder.seed();
  final scenario = ScreenshotScenario.parse(
    _readScenarioFromArgs(args) ?? _readScenarioFromEnvironment(),
  );
  final initialRoute = scenario.toRoute(screenshotSeedContext);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(child: DerbyDashScreenshotApp(initialRoute: initialRoute)),
  );
}

String? _readScenarioFromEnvironment() {
  const scenario = String.fromEnvironment('SCREENSHOT_SCENARIO');
  return scenario.isNotEmpty ? scenario : null;
}

String? _readScenarioFromArgs(List<String> args) {
  if (args.isEmpty) {
    return null;
  }

  for (final arg in args) {
    if (arg.startsWith('scenario=')) {
      return arg.substring('scenario='.length);
    }
    if (arg.startsWith('--scenario=')) {
      return arg.substring('--scenario='.length);
    }
  }

  return args.first;
}

class DerbyDashScreenshotApp extends ConsumerWidget {
  final String initialRoute;

  const DerbyDashScreenshotApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Derby Dash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: buildAppRouter(initialLocation: initialRoute),
    );
  }
}
