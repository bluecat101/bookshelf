import 'dart:io';
import 'package:path_provider/path_provider.dart';
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

  String? get uploadFilePath {
    return (state == FileSelectionState.loadSuccess) ? path?.path : null;
  }

  Future<void> pickFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'HEIC'],
    );
    if (filePickerResult != null) {
      state = FileSelectionState.loadSuccess;
      path = File(filePickerResult.files.single.path!);
      fileName = filePickerResult.files.single.name;
    }

    state = FileSelectionState.loadFailure;
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

  Future<String?> saveImageFromPath() async {
    if (state != FileSelectionState.loadSuccess) {
      return Future.value(null);
    }

    final bytes = await path!.readAsBytes();
    final dir = await getApplicationDocumentsDirectory();
    final newFile = File('${dir.path}/${fileName!}');
    await newFile.writeAsBytes(bytes);
    return newFile.path;
  }
}
