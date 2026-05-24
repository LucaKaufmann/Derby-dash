import 'dart:io';

class FileReplacement {
  static Future<void> recover(File destination) async {
    final rollbackFile = _rollbackFile(destination);
    if (!await destination.exists() && await rollbackFile.exists()) {
      await rollbackFile.rename(destination.path);
    }
  }

  static Future<void> replace(File source, File destination) async {
    await recover(destination);

    final rollbackFile = _rollbackFile(destination);
    await _deleteIfExists(rollbackFile);

    if (await destination.exists()) {
      await destination.rename(rollbackFile.path);
    }

    try {
      await source.rename(destination.path);
    } catch (_) {
      await recover(destination);
      rethrow;
    }

    await _deleteIfExists(rollbackFile);
  }

  static File _rollbackFile(File destination) {
    return File('${destination.path}.previous');
  }

  static Future<void> _deleteIfExists(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // A stale rollback file is harmless while the destination exists.
    }
  }
}
