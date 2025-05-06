import 'dart:io';

import 'package:file_picker/file_picker.dart';

abstract class IFileUploader {
  Future<UploadedFileStatus> pickFile();
}

enum FileSelectionState {
  notSelected, // 未選択
  loadSuccess, // 選択済み
  loadFailure, // 選択したが取得失敗
}

class UploadedFileStatus implements IFileUploader {
  final FileSelectionState state;
  final File? path;
  final String? fileName;
  const UploadedFileStatus({
    this.state = FileSelectionState.notSelected,
    this.path,
    this.fileName,
  });
  @override
  Future<UploadedFileStatus> pickFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'HEIC'],
    );
    if (filePickerResult != null) {
      final filePath = File(filePickerResult.files.single.path!);
      final fileName = filePickerResult.files.single.name;
      return UploadedFileStatus(
        state: FileSelectionState.loadSuccess,
        path: filePath,
        fileName: fileName,
      );
    }
    return UploadedFileStatus(state: FileSelectionState.loadFailure);
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
