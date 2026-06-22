import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/connection/native_database_connection.dart';
import 'package:Ok/product/utility/constants/settings_messages.dart';
import 'package:path/path.dart' as p;

/// Handles local SQLite database backup and restore operations.
final class DatabaseBackupService {
  DatabaseBackupService(this._database);

  final AppDatabase _database;

  static const _backupFilePrefix = 'ok_teknik_metal_crm_backup_';
  static const _sqliteTypeGroup = XTypeGroup(
    label: 'SQLite',
    extensions: ['sqlite'],
  );

  /// Copies the current database file to a user-selected folder.
  /// Returns `true` when a backup file was created, `false` when cancelled.
  Future<bool> backupDatabase() async {
    final selectedDirectory = await getDirectoryPath(
      confirmButtonText: 'Seç',
    );
    if (selectedDirectory == null) {
      return false;
    }

    await _database.customStatement('PRAGMA wal_checkpoint(FULL)');

    final sourcePath = await resolveDatabaseFilePath();
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception(SettingsMessages.backupError);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupName = '${_backupFilePrefix}$timestamp.sqlite';
    final destinationPath = p.join(selectedDirectory, backupName);

    try {
      await sourceFile.copy(destinationPath);
      return true;
    } on IOException {
      throw Exception(SettingsMessages.backupError);
    }
  }

  /// Prompts the user to select a backup file. Returns null when cancelled.
  Future<String?> pickRestoreFile() async {
    final file = await openFile(
      acceptedTypeGroups: [_sqliteTypeGroup],
      confirmButtonText: 'Seç',
    );

    final path = file?.path;
    if (path == null || path.isEmpty) {
      return null;
    }

    return path;
  }

  /// Replaces the current database file with the selected backup.
  Future<void> restoreDatabase(String backupFilePath) async {
    final backupFile = File(backupFilePath);
    if (!await backupFile.exists()) {
      throw Exception(SettingsMessages.restoreError);
    }

    final databasePath = await resolveDatabaseFilePath();
    final databaseFile = File(databasePath);
    final safetyBackupPath = '$databasePath.pre_restore_backup';

    await _database.close();

    try {
      if (await databaseFile.exists()) {
        await databaseFile.copy(safetyBackupPath);
      }

      await backupFile.copy(databasePath);
      await _deleteSidecarFiles(databasePath);

      final safetyBackup = File(safetyBackupPath);
      if (await safetyBackup.exists()) {
        await safetyBackup.delete();
      }
    } on IOException {
      await _rollbackRestore(databasePath, safetyBackupPath);
      throw Exception(SettingsMessages.restoreError);
    }
  }

  Future<void> _rollbackRestore(
    String databasePath,
    String safetyBackupPath,
  ) async {
    final safetyBackup = File(safetyBackupPath);
    if (!await safetyBackup.exists()) {
      return;
    }

    try {
      await safetyBackup.copy(databasePath);
      await safetyBackup.delete();
    } on IOException {
      // Keep the safety backup if rollback fails.
    }
  }

  Future<void> _deleteSidecarFiles(String databasePath) async {
    final walFile = File('$databasePath-wal');
    final shmFile = File('$databasePath-shm');

    if (await walFile.exists()) {
      await walFile.delete();
    }
    if (await shmFile.exists()) {
      await shmFile.delete();
    }
  }
}
