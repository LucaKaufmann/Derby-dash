import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_service.dart';

class MigrationBridgeService {
  static const version = 1;
  static const _prefsPrefix = 'migration_bridge_v1';
  static const _backupFileName = 'isar_v1_bridge.derbydash';
  static const _manifestFileName = 'isar_v1_bridge_manifest.json';
  static const _rawSnapshotFileName = 'default.isar.snapshot';

  static Future<MigrationBridgeResult> ensureBackup(Isar isar) async {
    final appDir = await getApplicationDocumentsDirectory();
    final migrationDir = Directory(p.join(appDir.path, 'migration'));
    await migrationDir.create(recursive: true);

    final backupFile = File(p.join(migrationDir.path, _backupFileName));
    final manifestFile = File(p.join(migrationDir.path, _manifestFileName));
    final sourceDatabaseFile = File(p.join(appDir.path, 'default.isar'));
    final rawSnapshotFile = File(
      p.join(migrationDir.path, _rawSnapshotFileName),
    );

    final backupService = BackupService(isar);
    final currentSummary = await backupService.summarize();
    final sourceDatabaseModifiedAt = await _lastModified(sourceDatabaseFile);
    final sourceDatabaseSha256 = await _sha256(sourceDatabaseFile);
    final existingManifest = await _readManifest(manifestFile);
    final existingSummary = BackupSummary.fromJson(
      existingManifest?['summary'],
    );
    final existingSourceDatabaseSha256 =
        existingManifest?['sourceDatabaseSha256'] as String?;
    final hasExistingBackup =
        existingSummary != null && await backupFile.exists();

    if (currentSummary.score == 0) {
      return MigrationBridgeResult.skipped(
        backupFile: backupFile,
        manifestFile: manifestFile,
        currentSummary: currentSummary,
        existingSummary: existingSummary,
        reason: 'Current database is empty.',
      );
    }

    if (hasExistingBackup && existingSummary.score > currentSummary.score) {
      return MigrationBridgeResult.skipped(
        backupFile: backupFile,
        manifestFile: manifestFile,
        currentSummary: currentSummary,
        existingSummary: existingSummary,
        reason: 'Existing bridge backup has more records.',
      );
    }

    if (hasExistingBackup &&
        existingSummary.score == currentSummary.score &&
        sourceDatabaseSha256 != null &&
        sourceDatabaseSha256 == existingSourceDatabaseSha256) {
      return MigrationBridgeResult.skipped(
        backupFile: backupFile,
        manifestFile: manifestFile,
        currentSummary: currentSummary,
        existingSummary: existingSummary,
        reason: 'Existing bridge backup is current.',
      );
    }

    final tempBackupFile = File('${backupFile.path}.tmp');
    final tempManifestFile = File('${manifestFile.path}.tmp');

    final exportedSummary = await backupService.exportBackupToFile(
      tempBackupFile,
    );
    final backupBytes = await tempBackupFile.readAsBytes();
    final backupSha256 = sha256.convert(backupBytes).toString();

    String? rawSnapshotError;
    try {
      final tempRawSnapshotFile = File('${rawSnapshotFile.path}.tmp');
      if (await tempRawSnapshotFile.exists()) {
        await tempRawSnapshotFile.delete();
      }
      await isar.copyToFile(tempRawSnapshotFile.path);
      await _replaceFile(tempRawSnapshotFile, rawSnapshotFile);
    } catch (error) {
      rawSnapshotError = error.toString();
    }

    final exportedAt = DateTime.now().toUtc().toIso8601String();
    final manifest = {
      'format': 'derby_dash_isar_v1_bridge',
      'version': version,
      'exportedAt': exportedAt,
      'summary': exportedSummary.toJson(),
      'sourceDatabasePath': sourceDatabaseFile.path,
      if (sourceDatabaseModifiedAt != null)
        'sourceDatabaseModifiedAt': sourceDatabaseModifiedAt
            .toUtc()
            .toIso8601String(),
      if (sourceDatabaseSha256 != null)
        'sourceDatabaseSha256': sourceDatabaseSha256,
      'backupPath': backupFile.path,
      'backupSha256': backupSha256,
      'backupBytes': backupBytes.length,
      'rawSnapshotPath': rawSnapshotFile.path,
      if (rawSnapshotError != null) 'rawSnapshotError': rawSnapshotError,
    };

    await tempManifestFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(manifest),
      flush: true,
    );
    await _replaceFile(tempBackupFile, backupFile);
    await _replaceFile(tempManifestFile, manifestFile);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefsPrefix.version', version);
    await prefs.setString('$_prefsPrefix.exported_at', exportedAt);
    await prefs.setString('$_prefsPrefix.backup_path', backupFile.path);
    await prefs.setString('$_prefsPrefix.backup_sha256', backupSha256);
    await prefs.setString(
      '$_prefsPrefix.summary',
      jsonEncode(exportedSummary.toJson()),
    );

    return MigrationBridgeResult.written(
      backupFile: backupFile,
      manifestFile: manifestFile,
      currentSummary: exportedSummary,
      existingSummary: existingSummary,
      backupSha256: backupSha256,
      rawSnapshotError: rawSnapshotError,
    );
  }

  static Future<Map<String, dynamic>?> _readManifest(File file) async {
    if (!await file.exists()) return null;
    try {
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static Future<DateTime?> _lastModified(File file) async {
    try {
      if (!await file.exists()) return null;
      return await file.lastModified();
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _sha256(File file) async {
    try {
      if (!await file.exists()) return null;
      return sha256.convert(await file.readAsBytes()).toString();
    } catch (_) {
      return null;
    }
  }

  static Future<void> _replaceFile(File source, File destination) async {
    if (await destination.exists()) {
      await destination.delete();
    }
    await source.rename(destination.path);
  }
}

class MigrationBridgeResult {
  final bool didWrite;
  final File backupFile;
  final File manifestFile;
  final BackupSummary currentSummary;
  final BackupSummary? existingSummary;
  final String? reason;
  final String? backupSha256;
  final String? rawSnapshotError;

  const MigrationBridgeResult._({
    required this.didWrite,
    required this.backupFile,
    required this.manifestFile,
    required this.currentSummary,
    required this.existingSummary,
    this.reason,
    this.backupSha256,
    this.rawSnapshotError,
  });

  factory MigrationBridgeResult.written({
    required File backupFile,
    required File manifestFile,
    required BackupSummary currentSummary,
    required BackupSummary? existingSummary,
    required String backupSha256,
    required String? rawSnapshotError,
  }) {
    return MigrationBridgeResult._(
      didWrite: true,
      backupFile: backupFile,
      manifestFile: manifestFile,
      currentSummary: currentSummary,
      existingSummary: existingSummary,
      backupSha256: backupSha256,
      rawSnapshotError: rawSnapshotError,
    );
  }

  factory MigrationBridgeResult.skipped({
    required File backupFile,
    required File manifestFile,
    required BackupSummary currentSummary,
    required BackupSummary? existingSummary,
    required String reason,
  }) {
    return MigrationBridgeResult._(
      didWrite: false,
      backupFile: backupFile,
      manifestFile: manifestFile,
      currentSummary: currentSummary,
      existingSummary: existingSummary,
      reason: reason,
    );
  }
}
