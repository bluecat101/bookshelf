import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

import 'image_helper_test.mocks.dart';

Future<void> mockExistUrl(
  MockImageHelperImpl mockImageHelper,
  bool existUrl,
) async {
  when(mockImageHelper.existUrl(any)).thenAnswer((_) async => existUrl);
}

Future<void> mockCreateNetworkImage(
  MockImageHelperImpl mockImageHelper,
  String displayImage,
) async {
  when(
    mockImageHelper.createNetworkImage(any),
  ).thenReturn(FileImage(File(displayImage)));
}
