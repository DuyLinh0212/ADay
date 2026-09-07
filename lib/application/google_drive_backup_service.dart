import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../domain/models/aday_snapshot.dart';

class DriveBackupResult {
  const DriveBackupResult({required this.email, required this.backedUpAt});
  final String email;
  final DateTime backedUpAt;
}

/// Uploads a private JSON copy to the Google account chosen by the user.
/// The app-data scope means ADay cannot browse the user's ordinary Drive files.
class GoogleDriveBackupService {
  GoogleDriveBackupService({GoogleSignIn? signIn})
    : _signIn =
          signIn ??
          GoogleSignIn(scopes: const [drive.DriveApi.driveAppdataScope]);

  static const _fileName = 'aday-backup.json';
  final GoogleSignIn _signIn;

  Future<DriveBackupResult> backup(ADaySnapshot snapshot) async {
    final account = await _signIn.signIn();
    if (account == null) {
      throw StateError('Bạn đã hủy chọn tài khoản Google.');
    }
    final headers = await account.authHeaders;
    final client = _GoogleAuthClient(headers);
    try {
      final api = drive.DriveApi(client);
      final bytes = utf8.encode(jsonEncode(snapshot.toJson()));
      final existing = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_fileName' and trashed = false",
        $fields: 'files(id)',
      );
      final target = drive.File()
        ..name = _fileName
        ..parents = ['appDataFolder']
        ..mimeType = 'application/json';
      final media = drive.Media(Stream<List<int>>.value(bytes), bytes.length);
      if (existing.files?.isNotEmpty ?? false) {
        await api.files.update(
          target,
          existing.files!.first.id!,
          uploadMedia: media,
        );
      } else {
        await api.files.create(target, uploadMedia: media);
      }
      return DriveBackupResult(
        email: account.email,
        backedUpAt: DateTime.now(),
      );
    } finally {
      client.close();
    }
  }
}

class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() => _client.close();
}
