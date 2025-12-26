import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'settings_provider.g.dart';

const _keepScreenOnKey = 'keep_screen_on';
const _advancedModeKey = 'advanced_mode';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final keepScreenOn = prefs.getBool(_keepScreenOnKey) ?? false;
    final advancedMode = prefs.getBool(_advancedModeKey) ?? false;

    // Apply wakelock on startup if enabled
    if (keepScreenOn) {
      await WakelockPlus.enable();
    }

    return SettingsState(
      keepScreenOn: keepScreenOn,
      advancedMode: advancedMode,
    );
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

    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(keepScreenOn: value));
    }
  }

  Future<void> setAdvancedMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_advancedModeKey, value);

    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(advancedMode: value));
    }
  }
}

class SettingsState {
  final bool keepScreenOn;
  final bool advancedMode;

  SettingsState({
    required this.keepScreenOn,
    required this.advancedMode,
  });

  SettingsState copyWith({
    bool? keepScreenOn,
    bool? advancedMode,
  }) {
    return SettingsState(
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      advancedMode: advancedMode ?? this.advancedMode,
    );
  }
}
