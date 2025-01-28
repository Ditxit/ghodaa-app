import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MarkerBitmapService {
  // Cache for bitmap descriptors
  static final Map<String, BitmapDescriptor> _bitmapCache = {};

  // Load image from assets and convert it to BitmapDescriptor
  static Future<BitmapDescriptor> loadAssetBitmap(String assetPath) async {
    // Check if the bitmap is already cached
    if (_bitmapCache.containsKey(assetPath)) {
      return _bitmapCache[assetPath]!;
    }

    // Load the bitmap from assets
    ByteData byteData = await rootBundle.load(assetPath);
    Uint8List imageData = byteData.buffer.asUint8List();
    BitmapDescriptor bitmapDescriptor = BitmapDescriptor.bytes(imageData);

    // Cache the bitmap descriptor
    _bitmapCache[assetPath] = bitmapDescriptor;

    return bitmapDescriptor;
  }

  // Load image from network and convert it to BitmapDescriptor
  static Future<BitmapDescriptor> loadNetworkBitmap(String url) async {
    // Check if the bitmap is already cached
    if (_bitmapCache.containsKey(url)) {
      return _bitmapCache[url]!;
    }

    // Load the bitmap from the network
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Uint8List imageData = response.bodyBytes;
      BitmapDescriptor bitmapDescriptor = BitmapDescriptor.bytes(imageData);

      // Cache the bitmap descriptor
      _bitmapCache[url] = bitmapDescriptor;

      return bitmapDescriptor;
    } else {
      throw Exception('Failed to load image from network');
    }
  }
}
