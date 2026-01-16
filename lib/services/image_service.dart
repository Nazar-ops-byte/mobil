import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85, // 🔒 stabil
    );
    if (file == null) return null;
    return _saveImage(File(file.path));
  }

  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // 🔒 stabil
    );
    if (file == null) return null;
    return _saveImage(File(file.path));
  }

  Future<String> _saveImage(File image) async {
    final dir = await getApplicationDocumentsDirectory();

    final ext = extension(image.path);
    final uniqueName =
        'dump_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}$ext';

    final saved = await image.copy('${dir.path}/$uniqueName');
    return saved.path;
  }
}
