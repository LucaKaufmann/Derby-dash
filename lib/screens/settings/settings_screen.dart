import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SettingsSection(
              title: 'Display',
              children: [
                SwitchListTile(
                  title: const Text('Keep Screen Always On'),
                  subtitle: const Text(
                    'Prevent the screen from turning off while the app is open',
                  ),
                  value: settings.keepScreenOn,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setKeepScreenOn(value);
                  },
                  activeColor: AppTheme.primaryColor,
                  secondary: Icon(
                    settings.keepScreenOn
                        ? Icons.brightness_high
                        : Icons.brightness_low,
                    color: settings.keepScreenOn
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Tournament',
              children: [
                SwitchListTile(
                  title: const Text('Advanced Mode'),
                  subtitle: const Text(
                    'Show additional tournament formats (Round Robin, Group + Knockout)',
                  ),
                  value: settings.advancedMode,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setAdvancedMode(value);
                  },
                  activeColor: AppTheme.primaryColor,
                  secondary: Icon(
                    settings.advancedMode
                        ? Icons.science
                        : Icons.science_outlined,
                    color: settings.advancedMode
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
