import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'settings_provider.g.dart';

const _keepScreenOnKey = 'keep_screen_on';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final keepScreenOn = prefs.getBool(_keepScreenOnKey) ?? false;

    // Apply wakelock on startup if enabled
    if (keepScreenOn) {
      await WakelockPlus.enable();
    }

    return SettingsState(keepScreenOn: keepScreenOn);
  }

  Future<void> setKeepScreenOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keepScreenOnKey, value);

    // Apply or disable wakelock
    if (value) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }

    state = AsyncData(SettingsState(keepScreenOn: value));
  }
}

class SettingsState {
  final bool keepScreenOn;

  SettingsState({
    required this.keepScreenOn,
  });

  SettingsState copyWith({
    bool? keepScreenOn,
  }) {
    return SettingsState(
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }
}
