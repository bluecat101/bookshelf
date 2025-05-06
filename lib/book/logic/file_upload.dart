import 'dart:io';

import 'package:file_picker/file_picker.dart';

enum FileSelectionState {
  notSelected, // 未選択
  loadSuccess, // 選択済み
  loadFailure, // 選択したが取得失敗
}

class FileUploader {
  FileSelectionState state;
  File? path;
  String? fileName;
  FileUploader({
    this.state = FileSelectionState.notSelected,
    this.path,
    this.fileName,
  });
  Future<FileUploader> pickFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'HEIC'],
    );
    if (filePickerResult != null) {
      final filePath = File(filePickerResult.files.single.path!);
      final fileName = filePickerResult.files.single.name;
      return FileUploader(
        state: FileSelectionState.loadSuccess,
        path: filePath,
        fileName: fileName,
      );
    }
    return FileUploader(state: FileSelectionState.loadFailure);
  }

  String fileSelectionDisplayText() {
    switch (state) {
      case FileSelectionState.notSelected:
        return '';
      case FileSelectionState.loadSuccess:
        return fileName ?? '';
      case FileSelectionState.loadFailure:
        return 'アップロードに失敗しました';
    }
  }
}
