import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SelectedFile {
  final PlatformFile file;
  final String type;
  SelectedFile(this.file, this.type);
}

class FileProvider with ChangeNotifier {
  SelectedFile? resumeFile;
  SelectedFile? idFrontFile;
  SelectedFile? idBackFile;

  Future<void> pickFile(String type) async {
    FileType allowedType = FileType.any;
    List<String>? allowedExtensions;

    if (type == "resume") {
      allowedType = FileType.custom;
      allowedExtensions = ["pdf"];
    } else {
      allowedType = FileType.custom;
      allowedExtensions = ["jpg", "jpeg", "png"];
    }

    final result = await FilePicker.platform.pickFiles(
      type: allowedType,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      final file = result.files.first;

      // size check (only for resume)
      if (type == "resume" && file.size > 2 * 1024 * 1024) {
        // greater than 2MB
        notifyListeners();
        return;
      }

      if (type == "resume") {
        resumeFile = SelectedFile(file, type);
      } else if (type == "idFront") {
        idFrontFile = SelectedFile(file, type);
      } else if (type == "idBack") {
        idBackFile = SelectedFile(file, type);
      }

      notifyListeners();
    }
  }

  void removeFile(String type) {
    if (type == "resume") resumeFile = null;
    if (type == "idFront") idFrontFile = null;
    if (type == "idBack") idBackFile = null;
    notifyListeners();
  }

  void clearAll() {
    resumeFile = null;
    idFrontFile = null;
    idBackFile = null;
    notifyListeners();
  }
}
