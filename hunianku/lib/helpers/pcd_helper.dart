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

// --- 3. FILTER HISTOGRAM EQUALIZATION (PERBAIKAN KONTRAS) ---
Future<Uint8List> applyHistogramEqualization(Map<String, dynamic> params) async {
  final Uint8List imageBytes = params['bytes'];

  img.Image? decodedImage = img.decodeImage(imageBytes);
  if (decodedImage == null) return imageBytes;

  // Kita buat histogram terpisah untuk channel Red, Green, dan Blue
  List<int> histR = List.filled(256, 0);
  List<int> histG = List.filled(256, 0);
  List<int> histB = List.filled(256, 0);

  // Tahap 1: Hitung frekuensi kemunculan intensitas (Histogram)
  for (final p in decodedImage) {
    histR[p.r.toInt()]++;
    histG[p.g.toInt()]++;
    histB[p.b.toInt()]++;
  }

  int totalPixels = decodedImage.width * decodedImage.height;

  // Tahap 2: Hitung Cumulative Distribution Function (CDF)
  List<int> cdfR = List.filled(256, 0);
  List<int> cdfG = List.filled(256, 0);
  List<int> cdfB = List.filled(256, 0);

  cdfR[0] = histR[0];
  cdfG[0] = histG[0];
  cdfB[0] = histB[0];

  for (int i = 1; i < 256; i++) {
    cdfR[i] = cdfR[i - 1] + histR[i];
    cdfG[i] = cdfG[i - 1] + histG[i];
    cdfB[i] = cdfB[i - 1] + histB[i];
  }

  // Cari nilai CDF minimum yang bukan nol untuk rumus normalisasi
  int minCdfR = cdfR.firstWhere((val) => val > 0, orElse: () => 1);
  int minCdfG = cdfG.firstWhere((val) => val > 0, orElse: () => 1);
  int minCdfB = cdfB.firstWhere((val) => val > 0, orElse: () => 1);

  // Tahap 3: Normalisasi (Pemetaan nilai piksel lama ke baru)
  List<int> mapR = List.filled(256, 0);
  List<int> mapG = List.filled(256, 0);
  List<int> mapB = List.filled(256, 0);

  for (int i = 0; i < 256; i++) {
    mapR[i] = (((cdfR[i] - minCdfR) / (totalPixels - minCdfR)) * 255).round().clamp(0, 255);
    mapG[i] = (((cdfG[i] - minCdfG) / (totalPixels - minCdfG)) * 255).round().clamp(0, 255);
    mapB[i] = (((cdfB[i] - minCdfB) / (totalPixels - minCdfB)) * 255).round().clamp(0, 255);
  }

  // Tahap 4: Terapkan pemetaan ke seluruh piksel gambar
  for (final p in decodedImage) {
    p.r = mapR[p.r.toInt()];
    p.g = mapG[p.g.toInt()];
    p.b = mapB[p.b.toInt()];
  }

  return img.encodeJpg(decodedImage, quality: 90);
}