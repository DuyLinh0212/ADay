import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Picks a photo from the device library and owns a durable private copy.
/// Saving a copy avoids retaining a transient gallery/cache URI in settings.
class AvatarService {
  AvatarService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> chooseAndStore() async {
    final selected = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (selected == null) return null;
    final directory = await getApplicationDocumentsDirectory();
    final extension = selected.path.contains('.')
        ? selected.path.split('.').last.toLowerCase()
        : 'jpg';
    final destination = File('${directory.path}/aday-avatar.$extension');
    await selected.saveTo(destination.path);
    return destination.path;
  }
}
