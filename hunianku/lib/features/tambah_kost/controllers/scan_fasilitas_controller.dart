import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vibration/vibration.dart';

class ScanFasilitasController extends ChangeNotifier {
  CameraController? cameraController;
  late FlutterVision vision;
  List<Map<String, dynamic>> yoloResults = [];
  Set<String> fasilitasTerdeteksi = {};
  bool isLoaded = false;
  bool isDetecting = false;

  final Map<String, String> targetClasses = {
    'bed': 'Kasur',
    'chair': 'Kursi',
    'dining table': 'Meja Belajar',
    'tv': 'Televisi',
    'refrigerator': 'Kulkas',
    'toilet': 'Kamar Mandi Dalam',
    'sink': 'Wastafel',
    'couch': 'Sofa',
    'laptop': 'Laptop',
    'book': 'Buku',
    'clock': 'Jam Dinding',
  };

  // Fungsi Inisialisasi Utama
  Future<void> initApp() async {
    try {
      vision = FlutterVision();
      await _initModel();
      await _initCamera();
    } catch (e) {
      print("🚨 GAGAL MEMUAT KAMERA / AI: $e");
    }
  }

  Future<void> _initModel() async {
    await vision.loadYoloModel(
      labels: dotenv.env['LABEL_PATH'] ?? 'assets/models/labels.txt',
      modelPath: dotenv.env['MODEL_PATH'] ?? 'assets/models/yolov8n.tflite',
      modelVersion: "yolov8",
      numThreads: 2,
      useGpu: true,
    );
    isLoaded = true;
    notifyListeners();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(cameras.first, ResolutionPreset.medium);
    await cameraController!.initialize();
    startDetection();
  }

  // Fungsi Deteksi
  void startDetection() {
    cameraController?.startImageStream((CameraImage image) async {
      if (isDetecting) return;
      isDetecting = true;

      final confThreshold = double.parse(dotenv.env['CONFIDENCE_THRESHOLD'] ?? '0.5');
      final iouThreshold = double.parse(dotenv.env['IOU_THRESHOLD'] ?? '0.45');

      final result = await vision.yoloOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        iouThreshold: iouThreshold,
        confThreshold: confThreshold,
      );

      if (result.isNotEmpty) {
        yoloResults = result;
        _processResults(result);
      } else {
        yoloResults = []; // Kosongkan kotak jika tidak ada objek
      }

      isDetecting = false;
      notifyListeners(); // Menyuruh UI menggambar ulang kotak hijau
    });
  }

  void _processResults(List<Map<String, dynamic>> results) {
    bool foundNew = false;

    for (var res in results) {
      String tag = res['tag'];
      if (targetClasses.containsKey(tag)) {
        String namaFasilitas = targetClasses[tag]!;
        if (!fasilitasTerdeteksi.contains(namaFasilitas)) {
          fasilitasTerdeteksi.add(namaFasilitas);
          foundNew = true;
        }
      }
    }

    if (foundNew) {
      Vibration.vibrate(duration: 50);
      notifyListeners(); // Update daftar teks di bawah layar
    }
  }

  // Fungsi Lifecycle (dipanggil dari Page)
  void pauseCamera() {
    cameraController?.stopImageStream();
  }

  void resumeCamera() {
    startDetection();
  }

  // Fungsi Pembersihan
  void disposeController() {
    isDetecting = true;
    if (cameraController != null && cameraController!.value.isStreamingImages) {
      cameraController!.stopImageStream();
    }
    cameraController?.dispose();
    //vision.closeYoloModel();
    dispose();
  }
}