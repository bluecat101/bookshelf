import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/apis/national_diet_library_api.dart';

void main() {
  group('[正常系]fetchBookInfoThroughNationalDietLibraryのテスト', () {
    test('サイズを取得後の型が正しい', () async {
      final isbn = 023737539;
      final size = await fetchBookInfoThroughNationalDietLibrary(isbn);
      expect(size.width, isA<double>());
      expect(size.height, isA<double>());
    });
  });
}
