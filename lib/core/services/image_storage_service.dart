import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Picks an image from the camera or photo library and copies it into the app's
/// support directory so the stored path stays valid after the picker's temp
/// file is cleaned up. Used for book cover photos.
class ImageStorageService {
  final ImagePicker _picker = ImagePicker();

  /// Returns the absolute path of the stored copy, or null if the user
  /// cancelled / the pick failed.
  Future<String?> pickAndStore({required ImageSource source}) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 80,
      );
      if (picked == null) return null;

      final supportDir = await getApplicationSupportDirectory();
      final coversDir = Directory('${supportDir.path}/book_covers');
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }
      final ext = picked.path.contains('.')
          ? picked.path.split('.').last
          : 'jpg';
      final dest =
          '${coversDir.path}/cover_${DateTime.now().microsecondsSinceEpoch}.$ext';
      await File(picked.path).copy(dest);
      return dest;
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Ignore — a missing cover file is not an error worth surfacing.
    }
  }
}

final imageStorageServiceProvider = Provider<ImageStorageService>(
  (ref) => ImageStorageService(),
);
