import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_service.dart';
import 'file_replacement.dart';

class RecurringBackupService {
  static const retentionCount = 14;
  static const enabledKey = 'recurring_backups_enabled';
  static const lastBackupDateKey = 'recurring_backups_last_date';
  static const lastBackupAtKey = 'recurring_backups_last_at';
  static const lastBackupPathKey = 'recurring_backups_last_path';
  static const lastBackupSummaryKey = 'recurring_backups_last_summary';

  static Future<RecurringBackupStatus> readStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return RecurringBackupStatus(
      enabled: prefs.getBool(enabledKey) ?? false,
      lastBackupAt: DateTime.tryParse(prefs.getString(lastBackupAtKey) ?? ''),
      lastBackupPath: prefs.getString(lastBackupPathKey),
      lastSummary: BackupSummary.fromJsonString(
        prefs.getString(lastBackupSummaryKey),
      ),
    );
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(enabledKey, enabled);
  }

  static Future<RecurringBackupResult> runIfDue(
    Isar isar, {
    bool ignoreEnabled = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(enabledKey) ?? false;
    final backupDate = _dateKey(DateTime.now());

    if (!enabled && !ignoreEnabled) {
      return RecurringBackupResult.skipped(reason: 'Automatic backups off.');
    }

    final lastBackupPath = prefs.getString(lastBackupPathKey);
    final lastBackupExists =
        lastBackupPath != null && await File(lastBackupPath).exists();
    if (prefs.getString(lastBackupDateKey) == backupDate && lastBackupExists) {
      return RecurringBackupResult.skipped(
        reason: 'Today’s automatic backup already exists.',
        backupFile: File(lastBackupPath),
        summary: BackupSummary.fromJsonString(
          prefs.getString(lastBackupSummaryKey),
        ),
      );
    }

    final backupService = BackupService(isar);
    final currentSummary = await backupService.summarize();
    if (currentSummary.score == 0) {
      return RecurringBackupResult.skipped(
        reason: 'Current database is empty.',
        summary: currentSummary,
      );
    }

    final backupDir = await _backupDirectory();
    await backupDir.create(recursive: true);
    final backupFile = File(
      p.join(backupDir.path, 'DerbyDash-auto-$backupDate.derbydash'),
    );
    await FileReplacement.recover(backupFile);
    final tempBackupFile = File('${backupFile.path}.tmp');

    final exportedSummary = await backupService.exportBackupToFile(
      tempBackupFile,
    );
    await FileReplacement.replace(tempBackupFile, backupFile);
    await _pruneOldBackups(backupDir);

    final backedUpAt = DateTime.now().toUtc().toIso8601String();
    await prefs.setString(lastBackupDateKey, backupDate);
    await prefs.setString(lastBackupAtKey, backedUpAt);
    await prefs.setString(lastBackupPathKey, backupFile.path);
    await prefs.setString(lastBackupSummaryKey, exportedSummary.toJsonString());

    return RecurringBackupResult.written(
      backupFile: backupFile,
      summary: exportedSummary,
      backedUpAt: DateTime.parse(backedUpAt),
    );
  }

  static Future<Directory> _backupDirectory() async {
    Directory? baseDir;
    if (Platform.isAndroid) {
      baseDir = await getExternalStorageDirectory();
    }
    baseDir ??= await getApplicationDocumentsDirectory();
    return Directory(p.join(baseDir.path, 'backups'));
  }

  static String _dateKey(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  static Future<void> _pruneOldBackups(Directory backupDir) async {
    final backups = await backupDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.derbydash'))
        .cast<File>()
        .toList();
    backups.sort((a, b) => b.path.compareTo(a.path));

    for (final backup in backups.skip(retentionCount)) {
      try {
        await backup.delete();
      } catch (_) {
        // Best-effort cleanup only.
      }
    }
  }
}

class RecurringBackupStatus {
  final bool enabled;
  final DateTime? lastBackupAt;
  final String? lastBackupPath;
  final BackupSummary? lastSummary;

  const RecurringBackupStatus({
    required this.enabled,
    required this.lastBackupAt,
    required this.lastBackupPath,
    required this.lastSummary,
  });
}

class RecurringBackupResult {
  final bool didWrite;
  final String reason;
  final File? backupFile;
  final BackupSummary? summary;
  final DateTime? backedUpAt;

  const RecurringBackupResult._({
    required this.didWrite,
    required this.reason,
    required this.backupFile,
    required this.summary,
    required this.backedUpAt,
  });

  factory RecurringBackupResult.written({
    required File backupFile,
    required BackupSummary summary,
    required DateTime backedUpAt,
  }) {
    return RecurringBackupResult._(
      didWrite: true,
      reason: 'Automatic backup created.',
      backupFile: backupFile,
      summary: summary,
      backedUpAt: backedUpAt,
    );
  }

  factory RecurringBackupResult.skipped({
    required String reason,
    File? backupFile,
    BackupSummary? summary,
  }) {
    return RecurringBackupResult._(
      didWrite: false,
      reason: reason,
      backupFile: backupFile,
      summary: summary,
      backedUpAt: null,
    );
  }
}
