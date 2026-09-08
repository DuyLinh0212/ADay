import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Installs the SQLite FFI implementation for desktop platforms.
/// Android and iOS keep sqflite's platform implementation.
void configureLocalDatabase() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
