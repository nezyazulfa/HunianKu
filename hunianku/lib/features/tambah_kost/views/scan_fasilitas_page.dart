import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hunianku/features/tambah_kost/controllers/scan_fasilitas_controller.dart';

class ScanFasilitasPage extends StatefulWidget {
  const ScanFasilitasPage({super.key});

  @override
  State<ScanFasilitasPage> createState() => _ScanFasilitasPageState();
}

class _ScanFasilitasPageState extends State<ScanFasilitasPage>
    with WidgetsBindingObserver {
  final ScanFasilitasController _controller = ScanFasilitasController();
  final Color primaryGreen = const Color(0xFF4A6525);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.initApp();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller.cameraController == null ||
        !_controller.cameraController!.value.isInitialized)
      return;
    if (state == AppLifecycleState.paused) {
      _controller.pauseCamera();
    } else if (state == AppLifecycleState.resumed) {
      _controller.resumeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Cek status loading dari Controller
        if (!_controller.isLoaded ||
            _controller.cameraController == null ||
            !_controller.cameraController!.value.isInitialized) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: primaryGreen)),
          );
        }
        return Scaffold(
          body: Stack(
            children: [
              Positioned(
                top: 0, left: 0, right: 0,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    color: Colors.black,
                    child: ClipRect(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.cameraController!.value.previewSize!.height,
                            height: _controller.cameraController!.value.previewSize!.width,
                            child: CameraPreview(_controller.cameraController!),
                          ),
                        ),
                      ),
                    ),
                ),
              ),
              ..._buildBoundingBoxes(size),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: const BoxDecoration(color: Colors.white,borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fasilitas Terdeteksi:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 8,children: _controller.targetClasses.values.map((fasilitas,) 
                      {
                          bool isFound = _controller.fasilitasTerdeteksi
                              .contains(fasilitas);
                          return Chip(
                            label: Text(fasilitas, style: TextStyle(color: isFound ? Colors.white : Colors.black87)),
                            backgroundColor: isFound ? primaryGreen : Colors.grey[200],
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, _controller.fasilitasTerdeteksi.toList());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
                        ),
                        child: const Text('Simpan Hasil Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildBoundingBoxes(Size screenSize) {
    if (_controller.yoloResults.isEmpty) return [];
    double previewWidth = screenSize.width;
    double previewHeight = screenSize.width * (4 / 3);
    double factorX = previewWidth / _controller.cameraController!.value.previewSize!.height;
    double factorY = previewHeight / _controller.cameraController!.value.previewSize!.width;
    return _controller.yoloResults
        .where((res) => _controller.targetClasses.containsKey(res['tag']))
        .map((res) {
          return Positioned(
            left: res['box'][0] * factorX,
            top: res['box'][1] * factorY,
            width: (res['box'][2] - res['box'][0]) * factorX,
            height: (res['box'][3] - res['box'][1]) * factorY,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: primaryGreen, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  color: primaryGreen,
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    "${_controller.targetClasses[res['tag']]} ${(res['box'][4] * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        })
    .toList();
  }
}
