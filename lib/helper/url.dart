import 'package:http/http.dart' as http;

abstract class UrlHelper {
  Future<bool> existUrl(String url);
}

class UrlHelperImpl implements UrlHelper {
  @override
  Future<bool> existUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
