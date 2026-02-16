import 'screenshot_seed_data.dart';

enum ScreenshotScenario {
  home('home'),
  garage('garage'),
  dashboard('dashboard'),
  bracket('bracket'),
  history('history'),
  champion('champion'),
  standings('standings'),
  settings('settings');

  final String value;
  const ScreenshotScenario(this.value);

  static ScreenshotScenario parse(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return ScreenshotScenario.home;
    }

    final normalized = rawValue.trim().toLowerCase().replaceAll('-', '_');
    return ScreenshotScenario.values.firstWhere(
      (scenario) => scenario.value == normalized,
      orElse: () => ScreenshotScenario.home,
    );
  }

  static String supportedValues() {
    return ScreenshotScenario.values
        .map((scenario) => scenario.value)
        .join(', ');
  }
}

extension ScreenshotScenarioRoute on ScreenshotScenario {
  String toRoute(ScreenshotSeedContext context) {
    switch (this) {
      case ScreenshotScenario.home:
        return '/';
      case ScreenshotScenario.garage:
        return '/garage';
      case ScreenshotScenario.dashboard:
        return '/tournament/${context.activeKnockoutTournamentId}';
      case ScreenshotScenario.bracket:
        return '/tournament/${context.activeKnockoutTournamentId}/bracket';
      case ScreenshotScenario.history:
        return '/tournament/history';
      case ScreenshotScenario.champion:
        return '/tournament/${context.completedKnockoutTournamentId}/champion';
      case ScreenshotScenario.standings:
        return '/tournament/${context.completedRoundRobinTournamentId}/standings';
      case ScreenshotScenario.settings:
        return '/settings';
    }
  }
}
