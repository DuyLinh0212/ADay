import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/aday_snapshot.dart';
import '../../domain/repositories/aday_repository.dart';

class SharedPreferencesADayRepository implements ADayRepository {
  SharedPreferencesADayRepository(this._preferences);

  static const _primaryKey = 'aday.snapshot.v1';
  static const _backupKey = 'aday.snapshot.backup.v1';

  final SharedPreferences _preferences;

  @override
  Future<ADaySnapshot> load() async {
    final primary = _preferences.getString(_primaryKey);
    if (primary == null || primary.isEmpty) return const ADaySnapshot();
    try {
      return _decode(primary);
    } on FormatException {
      final backup = _preferences.getString(_backupKey);
      if (backup == null || backup.isEmpty) rethrow;
      return _decode(backup);
    }
  }

  @override
  Future<void> save(ADaySnapshot snapshot) async {
    final previous = _preferences.getString(_primaryKey);
    if (previous != null) {
      final backedUp = await _preferences.setString(_backupKey, previous);
      if (!backedUp) {
        throw StateError('Không thể tạo bản sao lưu dữ liệu cục bộ.');
      }
    }
    final encoded = jsonEncode(snapshot.toJson());
    final saved = await _preferences.setString(_primaryKey, encoded);
    if (!saved) {
      throw StateError('Thiết bị từ chối ghi dữ liệu ADay.');
    }
  }

  ADaySnapshot _decode(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map) {
      throw const FormatException('Dữ liệu ADay không đúng định dạng.');
    }
    return ADaySnapshot.fromJson(Map<String, Object?>.from(decoded));
  }
}
