import 'dart:io';

import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/car_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/tournament_provider.dart';
import '../../services/backup_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _exportBackup() async {
    if (_isExporting || _isImporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final isar = ref.read(databaseProvider).requireValue;
      final backupFile = await BackupService(isar).exportBackup();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(backupFile.path)],
          subject: 'Derby Dash Backup',
          text: 'Derby Dash backup',
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Backup export failed: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _importBackup() async {
    if (_isExporting || _isImporting) return;

    final shouldImport = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Backup?'),
        content: const Text(
          'This will replace all cars, photos, tournaments, and match history on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('IMPORT'),
          ),
        ],
      ),
    );
    if (shouldImport != true) return;

    final pickedFile = await file_selector.openFile(
      acceptedTypeGroups: Platform.isAndroid
          ? const [file_selector.XTypeGroup(label: 'All files')]
          : const [
              file_selector.XTypeGroup(
                label: 'Derby Dash Backup',
                extensions: ['derbydash', 'zip'],
              ),
            ],
      confirmButtonText: 'Import',
    );
    final path = pickedFile?.path;
    if (path == null) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final isar = ref.read(databaseProvider).requireValue;
      final summary = await BackupService(isar).importBackup(File(path));
      _refreshImportedData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${summary.cars} cars, ${summary.tournaments} tournaments, and ${summary.matches} matches.',
          ),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Backup import failed: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  void _refreshImportedData() {
    ref.invalidate(carsProvider);
    ref.invalidate(sortedCarsProvider);
    ref.invalidate(activeTournamentsProvider);
    ref.invalidate(completedTournamentsProvider);
  }

  @override
  Widget build(BuildContext context) {
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
                  activeThumbColor: AppTheme.primaryColor,
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
                  activeThumbColor: AppTheme.primaryColor,
                  secondary: Icon(
                    settings.advancedMode
                        ? Icons.science
                        : Icons.science_outlined,
                    color: settings.advancedMode
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.visibility_off,
                    color: AppTheme.secondaryColor,
                  ),
                  title: const Text('Mystery Race Cars'),
                  subtitle: Text(
                    settings.hiddenMysteryCarIds.isEmpty
                        ? 'All garage cars can be picked'
                        : '${settings.hiddenMysteryCarIds.length} hidden from Mystery Race',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/mystery-race'),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Backup',
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.ios_share,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Export Backup'),
                  subtitle: const Text(
                    'Save cars, photos, tournaments, and match history to a file',
                  ),
                  trailing: _isExporting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  enabled: !_isImporting,
                  onTap: _exportBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.restore,
                    color: AppTheme.secondaryColor,
                  ),
                  title: const Text('Import Backup'),
                  subtitle: const Text(
                    'Replace this device’s local data from a Derby Dash backup',
                  ),
                  trailing: _isImporting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  enabled: !_isExporting,
                  onTap: _importBackup,
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

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
        Card(child: Column(children: children)),
        const SizedBox(height: 16),
      ],
    );
  }
}
