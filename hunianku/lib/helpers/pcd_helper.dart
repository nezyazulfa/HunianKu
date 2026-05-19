import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Kumpulan fungsi Operasi Titik & Spasial untuk Pengolahan Citra Digital (PCD)
/// Fungsi-fungsi ini dibuat top-level agar aman dijalankan di dalam Isolate (compute).

// --- 1. FILTER KECERAHAN (BRIGHTNESS) ---
Future<Uint8List> applyBrightness(Map<String, dynamic> params) async {
  final Uint8List imageBytes = params['bytes'];
  final num brightnessValue = params['brightness']; 

  img.Image? decodedImage = img.decodeImage(imageBytes);
  if (decodedImage == null) return imageBytes;

  img.Image processedImage = img.adjustColor(decodedImage, brightness: brightnessValue);
  return img.encodeJpg(processedImage, quality: 90);
}

// --- 2. FILTER GRAYSCALE (Contoh) ---
Future<Uint8List> applyGrayscale(Map<String, dynamic> params) async {
  final Uint8List imageBytes = params['bytes'];

  img.Image? decodedImage = img.decodeImage(imageBytes);
  if (decodedImage == null) return imageBytes;

  img.Image processedImage = img.grayscale(decodedImage);
  return img.encodeJpg(processedImage, quality: 90);
}

// --- 3. FILTER KETIGA (Bisa diisi nanti) ---
Future<Uint8List> applyFilterTiga(Map<String, dynamic> params) async {
  // Logika filter 3
  return params['bytes'];
}

// --- 4. FILTER KEEMPAT (Bisa diisi nanti) ---
Future<Uint8List> applyFilterEmpat(Map<String, dynamic> params) async {
  // Logika filter 4
  return params['bytes'];
}