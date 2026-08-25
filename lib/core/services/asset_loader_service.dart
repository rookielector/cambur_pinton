import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AssetLoaderService {

  static Future<String> loadJsonString(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading primary asset path "$path": $e');
      }

      final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
      try {
        return await rootBundle.loadString(normalizedPath);
      } catch (fallbackErr) {
        if (kDebugMode) {
          print('Fallback asset loading failed for "$normalizedPath": $fallbackErr');
        }
        rethrow;
      }
    }
  }
}
