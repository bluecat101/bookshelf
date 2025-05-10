import 'dart:io';

import 'package:bookshelf/book/logic/file_upload.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart';

import 'file_upload_test.mocks.dart';

Future<FileUploader> mockPickFileSuccess(String filePath) async {
  final fileName = basename(filePath);
  return FileUploader(
    state: FileSelectionState.loadSuccess,
    path: File(filePath),
    fileName: fileName,
  );
}

Future<FileUploader> mockPickFileFailure() async {
  return FileUploader(state: FileSelectionState.loadFailure);
}

Future<void> mockPickFile(
  MockFileUploader mockFileUploader,
  Future<FileUploader> mockPickFile,
) async {
  when(mockFileUploader.pickFile()).thenAnswer((_) => mockPickFile);
}
