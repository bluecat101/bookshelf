import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

abstract class ImageHelper {
  Future<bool> existUrl(String url);
  ImageProvider createNetworkImage(String url);
}

class ImageHelperImpl implements ImageHelper {
  @override
  Future<bool> existUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  ImageProvider createNetworkImage(String url) {
    return NetworkImage(url);
  }
}
