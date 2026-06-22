import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String kDatabaseFileName = 'okteknikmetal_auth.sqlite';

/// Resolves the on-disk path for the SQLite database file.
Future<String> resolveDatabaseFilePath({String fileName = kDatabaseFileName}) async {
  final directory = await getApplicationSupportDirectory();
  return p.join(directory.path, fileName);
}

/// Opens a background SQLite connection for desktop (macOS / Windows / Linux).
LazyDatabase openNativeConnection({String fileName = kDatabaseFileName}) {
  return LazyDatabase(() async {
    final file = File(await resolveDatabaseFilePath(fileName: fileName));
    return NativeDatabase.createInBackground(file);
  });
}
