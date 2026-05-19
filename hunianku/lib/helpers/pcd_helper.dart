// Lokasi: lib/helpers/pcd_helper.dart

import 'dart:typed_data';
import 'package:image/image.dart' as img;

// --- 1. FILTER KECERAHAN (BRIGHTNESS) ---
Future<Uint8List> applyBrightness(Map<String, dynamic> params) async {
  final Uint8List imageBytes = params['bytes'];
  final num brightnessValue = params['brightness']; 

  img.Image? decodedImage = img.decodeImage(imageBytes);
  if (decodedImage == null) return imageBytes;

  img.Image processedImage = img.adjustColor(decodedImage, brightness: brightnessValue);
  return img.encodeJpg(processedImage, quality: 90);
}

// --- 2. FILTER PENAJAMAN (SHARPENING / HIGH-PASS FILTER) ---
Future<Uint8List> applySharpening(Map<String, dynamic> params) async {
  final Uint8List imageBytes = params['bytes'];

  // 1. Decode byte ke matriks gambar
  img.Image? decodedImage = img.decodeImage(imageBytes);
  if (decodedImage == null) return imageBytes;

  // 2. Siapkan Kernel High-pass Filter 3x3
  const List<num> sharpenKernel = [
     0, -1,  0,
    -1,  5, -1,
     0, -1,  0
  ];

  // 3. Terapkan konvolusi spasial
  img.Image processedImage = img.convolution(decodedImage, filter: sharpenKernel);
  
  // 4. Encode kembali menjadi file gambar JPG
  return img.encodeJpg(processedImage, quality: 90);
}