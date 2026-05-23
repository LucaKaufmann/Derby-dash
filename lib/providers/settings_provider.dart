import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'settings_provider.g.dart';

const _keepScreenOnKey = 'keep_screen_on';
const _advancedModeKey = 'advanced_mode';
const _hiddenMysteryCarIdsKey = 'hidden_mystery_car_ids';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final keepScreenOn = prefs.getBool(_keepScreenOnKey) ?? false;
    final advancedMode = prefs.getBool(_advancedModeKey) ?? false;
    final hiddenMysteryCarIds =
        prefs
            .getStringList(_hiddenMysteryCarIdsKey)
            ?.map(int.tryParse)
            .whereType<int>()
            .toSet() ??
        <int>{};

    // Apply wakelock on startup if enabled
    if (keepScreenOn) {
      await WakelockPlus.enable();
    }

    return SettingsState(
      keepScreenOn: keepScreenOn,
      advancedMode: advancedMode,
      hiddenMysteryCarIds: hiddenMysteryCarIds,
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

  Future<void> setMysteryCarHidden(int carId, bool hidden) async {
    final current = state.value;
    if (current == null) return;

    final hiddenMysteryCarIds = {...current.hiddenMysteryCarIds};
    if (hidden) {
      hiddenMysteryCarIds.add(carId);
    } else {
      hiddenMysteryCarIds.remove(carId);
    }

    await _saveHiddenMysteryCarIds(hiddenMysteryCarIds);
    state = AsyncData(
      current.copyWith(hiddenMysteryCarIds: hiddenMysteryCarIds),
    );
  }

  Future<void> showAllMysteryCars() async {
    final current = state.value;
    if (current == null || current.hiddenMysteryCarIds.isEmpty) return;

    await _saveHiddenMysteryCarIds({});
    state = AsyncData(current.copyWith(hiddenMysteryCarIds: {}));
  }

  Future<void> _saveHiddenMysteryCarIds(Set<int> hiddenMysteryCarIds) async {
    final prefs = await SharedPreferences.getInstance();
    final sortedIds = hiddenMysteryCarIds.toList()..sort();
    await prefs.setStringList(
      _hiddenMysteryCarIdsKey,
      sortedIds.map((id) => id.toString()).toList(),
    );
  }
}

class SettingsState {
  final bool keepScreenOn;
  final bool advancedMode;
  final Set<int> hiddenMysteryCarIds;

  SettingsState({
    required this.keepScreenOn,
    required this.advancedMode,
    required this.hiddenMysteryCarIds,
  });

  SettingsState copyWith({
    bool? keepScreenOn,
    bool? advancedMode,
    Set<int>? hiddenMysteryCarIds,
  }) {
    return SettingsState(
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      advancedMode: advancedMode ?? this.advancedMode,
      hiddenMysteryCarIds: hiddenMysteryCarIds ?? this.hiddenMysteryCarIds,
    );
  }
}
