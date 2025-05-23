// Mocks generated by Mockito 5.4.5 from annotations
// in bookshelf/test/book/logic/file_upload_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:io' as _i3;

import 'package:bookshelf/book/logic/file_upload.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [FileUploader].
///
/// See the documentation for Mockito's code generation for more information.
class MockFileUploader extends _i1.Mock implements _i2.FileUploader {
  MockFileUploader() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FileSelectionState get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _i2.FileSelectionState.notSelected,
      ) as _i2.FileSelectionState);

  @override
  set state(_i2.FileSelectionState? _state) => super.noSuchMethod(
        Invocation.setter(
          #state,
          _state,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set path(_i3.File? _path) => super.noSuchMethod(
        Invocation.setter(
          #path,
          _path,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set fileName(String? _fileName) => super.noSuchMethod(
        Invocation.setter(
          #fileName,
          _fileName,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<void> pickFile() => (super.noSuchMethod(
        Invocation.method(
          #pickFile,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  String fileSelectionDisplayText() => (super.noSuchMethod(
        Invocation.method(
          #fileSelectionDisplayText,
          [],
        ),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.method(
            #fileSelectionDisplayText,
            [],
          ),
        ),
      ) as String);

  @override
  _i4.Future<String?> saveImageFromPath() => (super.noSuchMethod(
        Invocation.method(
          #saveImageFromPath,
          [],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);
}
