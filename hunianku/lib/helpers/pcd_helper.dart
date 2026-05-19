import 'dart:typed_data';
import 'package:image/image.dart' as img;

// --- 1. PENCERAH CERDAS (GLOBAL HISTOGRAM EQUALIZATION) ---
Future<Uint8List> applyAutoFix(Map<String, dynamic> params) async {
  final Uint8List imageBytes = params['bytes'];
  img.Image? decodedImage = img.decodeImage(imageBytes);
  if (decodedImage == null) return imageBytes;

  List<int> histR = List.filled(256, 0);
  List<int> histG = List.filled(256, 0);
  List<int> histB = List.filled(256, 0);

  for (final p in decodedImage) {
    histR[p.r.toInt()]++;
    histG[p.g.toInt()]++;
    histB[p.b.toInt()]++;
  }

  int totalPixels = decodedImage.width * decodedImage.height;
  List<int> cdfR = List.filled(256, 0);
  List<int> cdfG = List.filled(256, 0);
  List<int> cdfB = List.filled(256, 0);

  cdfR[0] = histR[0]; cdfG[0] = histG[0]; cdfB[0] = histB[0];
  for (int i = 1; i < 256; i++) {
    cdfR[i] = cdfR[i - 1] + histR[i];
    cdfG[i] = cdfG[i - 1] + histG[i];
    cdfB[i] = cdfB[i - 1] + histB[i];
  }

  int minCdfR = cdfR.firstWhere((val) => val > 0, orElse: () => 1);
  int minCdfG = cdfG.firstWhere((val) => val > 0, orElse: () => 1);
  int minCdfB = cdfB.firstWhere((val) => val > 0, orElse: () => 1);

  List<int> mapR = List.filled(256, 0);
  List<int> mapG = List.filled(256, 0);
  List<int> mapB = List.filled(256, 0);

  for (int i = 0; i < 256; i++) {
    mapR[i] = (((cdfR[i] - minCdfR) / (totalPixels - minCdfR)) * 255).round().clamp(0, 255);
    mapG[i] = (((cdfG[i] - minCdfG) / (totalPixels - minCdfG)) * 255).round().clamp(0, 255);
    mapB[i] = (((cdfB[i] - minCdfB) / (totalPixels - minCdfB)) * 255).round().clamp(0, 255);
  }

  for (final p in decodedImage) {
    p.r = mapR[p.r.toInt()];
    p.g = mapG[p.g.toInt()];
    p.b = mapB[p.b.toInt()];
  }

  return img.encodeJpg(decodedImage, quality: 90);
}

// --- 2. KECERAHAN (BRIGHTNESS POINT OPERATION) ---
Future<Uint8List> applyBrightness(Map<String, dynamic> params) async {
  final Uint8List imageBytes = params['bytes'];
  final num brightnessValue = params['brightness']; 

  img.Image? decodedImage = img.decodeImage(imageBytes);
  if (decodedImage == null) return imageBytes;

  img.Image processedImage = img.adjustColor(decodedImage, brightness: brightnessValue);
  return img.encodeJpg(processedImage, quality: 90);
}

// --- 3. PERTAJAM DETAIL (DYNAMIC HIGH-PASS FILTER) ---
Future<Uint8List> applySharpening(Map<String, dynamic> params) async {
  final Uint8List imageBytes = params['bytes'];
  final double intensity = params['intensity']; // Nilai dari slider

  img.Image? decodedImage = img.decodeImage(imageBytes);
  if (decodedImage == null) return imageBytes;

  // Kernel High-pass konvolusi yang bobotnya diatur oleh intensitas
  List<num> sharpenKernel = [
     0,          -intensity,           0,
    -intensity, 1 + (4 * intensity), -intensity,
     0,          -intensity,           0
  ];

  img.Image processedImage = img.convolution(decodedImage, filter: sharpenKernel);
  return img.encodeJpg(processedImage, quality: 90);
}

// --- 4. BERSIHKAN BINTIK (MEDIAN FILTER - NON-LINEAR SPATIAL) ---
Future<Uint8List> applyMedianFilter(Map<String, dynamic> params) async {
  final Uint8List imageBytes = params['bytes'];
  final int radius = params['radius']; // 1 = 3x3, 2 = 5x5, 3 = 7x7

  img.Image? src = img.decodeImage(imageBytes);
  if (src == null) return imageBytes;

  // Clone gambar untuk menampung hasil piksel baru
  img.Image dst = src.clone();
  int width = src.width;
  int height = src.height;

  // Looping seluruh piksel
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      List<num> rList = [];
      List<num> gList = [];
      List<num> bList = [];

      // Mengambil piksel tetangga berdasarkan ukuran jendela (kernel)
      for (int dy = -radius; dy <= radius; dy++) {
        for (int dx = -radius; dx <= radius; dx++) {
          int nx = (x + dx).clamp(0, width - 1);
          int ny = (y + dy).clamp(0, height - 1);
          
          final p = src.getPixel(nx, ny);
          rList.add(p.r);
          gList.add(p.g);
          bList.add(p.b);
        }
      }

      // Mengurutkan nilai intensitas untuk mencari nilai tengah (Median)
      rList.sort();
      gList.sort();
      bList.sort();
      
      int midIndex = rList.length ~/ 2;

      // Menetapkan nilai median ke piksel target
      final targetPixel = dst.getPixel(x, y);
      targetPixel.r = rList[midIndex];
      targetPixel.g = gList[midIndex];
      targetPixel.b = bList[midIndex];
    }
  }

  return img.encodeJpg(dst, quality: 90);
}