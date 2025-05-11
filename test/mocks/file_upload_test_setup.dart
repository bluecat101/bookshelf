import 'dart:io';

import 'package:bookshelf/book/logic/file_upload.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart';

import 'file_upload_test.mocks.dart';

const sampleImageLocalPath = 'test/test_image.png';
const sampleImageStoragePath = 'test/assets/test_image.png';

Future<void> mockPickFile(MockFileUploader mockFileUploader) async {
  when(mockFileUploader.pickFile()).thenAnswer((_) => Future.value());
}

Future<void> mockSaveImageFromPath(
  MockFileUploader mockFileUploader,
  String? resultFilePath,
) async {
  when(
    mockFileUploader.saveImageFromPath(),
  ).thenAnswer((_) => Future.value(resultFilePath));
}

void mockFileSelectionDisplayText(MockFileUploader mockFileUploader) {
  try {
    switch (mockFileUploader.state) {
      case FileSelectionState.notSelected:
        when(mockFileUploader.fileSelectionDisplayText()).thenReturn('');
      case FileSelectionState.loadSuccess:
        when(
          mockFileUploader.fileSelectionDisplayText(),
        ).thenReturn(mockFileUploader.fileName ?? '');
      case FileSelectionState.loadFailure:
        when(
          mockFileUploader.fileSelectionDisplayText(),
        ).thenReturn('アップロードに失敗しました');
    }
  } catch (e) {
    assert(false, 'propertyをスタブしてください');
  }
}

void stubProperty(MockFileUploader mockFileUploader, String? filePath) {
  if (filePath != null) {
    when(mockFileUploader.state).thenReturn(FileSelectionState.loadSuccess);
  } else {
    when(mockFileUploader.state).thenReturn(FileSelectionState.loadFailure);
  }
  when(
    mockFileUploader.path,
  ).thenReturn(filePath != null ? File(filePath) : null);
  when(
    mockFileUploader.fileName,
  ).thenReturn(filePath != null ? basename(filePath) : null);
}

void mockPickFileSuccess(
  MockFileUploader mockFileUploader, {
  String? filePath,
  String? resultFilePath,
}) {
  filePath ??= sampleImageLocalPath;
  resultFilePath ??= sampleImageStoragePath;
  mockPickFile(mockFileUploader);
  stubProperty(mockFileUploader, filePath);
  mockFileSelectionDisplayText(mockFileUploader);
  mockSaveImageFromPath(mockFileUploader, resultFilePath);
}

void mockPickFileFailure(MockFileUploader mockFileUploader) {
  mockPickFile(mockFileUploader);
  stubProperty(mockFileUploader, null);
  mockFileSelectionDisplayText(mockFileUploader);
  mockSaveImageFromPath(mockFileUploader, null);
}

void mockFunctionInit(MockFileUploader mockFileUploader) {
  when(mockFileUploader.state).thenReturn(FileSelectionState.notSelected);
  mockFileSelectionDisplayText(mockFileUploader);
}
