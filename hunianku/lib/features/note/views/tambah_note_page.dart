import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hunianku/features/note/controllers/note_controller.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/auth/model/user_model.dart';
import 'package:hunianku/features/note/model/note_model.dart';
import 'package:hunianku/services/kost_service.dart';
import 'package:hunianku/services/session_service.dart';
import 'package:hunianku/helpers/pcd_helper.dart';
import 'package:hunianku/features/tambah_kost/views/scan_fasilitas_page.dart'; 

class TambahNotePage extends StatefulWidget {
  const TambahNotePage({super.key});

  @override
  State<TambahNotePage> createState() => _TambahNotePageState();
}

class _TambahNotePageState extends State<TambahNotePage> {
  final TextEditingController _noteController = TextEditingController();
  final NoteController _controller = NoteController();

  List<KostModel> _kumpulanKost = [];
  KostModel? _selectedKost;
  UserModel? _currentUser;

  // --- VARIABEL UNTUK FOTO & PCD ---
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final Color containerColor = const Color(0xFFFBFBF9);
  final Color cardColor = Colors.white;
  final Color primaryGreen = const Color(0xFF4A6525);
  final Color primaryRed = const Color(0xFF6B1212);

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final listKost = await KostService().getAllKost();
      setState(() {
        _kumpulanKost = listKost;
      });
    } catch (e) {
      debugPrint('Gagal load kost: $e');
    }
    final id = await SessionService.getUserId();
    final nama = await SessionService.getNama();
    final role = await SessionService.getRole();
    if (id != null) {
      _currentUser = UserModel(
        iduser: id,
        nama: nama ?? 'User',
        email: '', password: '', role: role ?? 'penghuni',
      );
    }
  }

  // --- FUNGSI AMBIL GAMBAR ---
  Future<void> _pickFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka kamera: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka galeri: $e')));
    }
  }

  // --- FUNGSI MEMBUKA EDITOR PCD ---
  Future<void> _openImageEditor() async {
    if (_imageFile == null) return;
    final Uint8List originalBytes = await _imageFile!.readAsBytes();
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true, 
      builder: (BuildContext context) {
        return _LargePcdEditor(
          originalBytes: originalBytes,
          primaryGreen: primaryGreen,
          primaryRed: primaryRed,
          onApply: (Uint8List processedBytes) async {
            await _imageFile!.writeAsBytes(processedBytes);
            setState(() {});
          },
        );
      },
    );
  }

  void _showKostDropdown() {
    List<KostModel> filteredList = List.from(_kumpulanKost);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Pilih Kost', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 300, 
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          filteredList = _kumpulanKost.where((k) => k.namakost.toLowerCase().contains(value.toLowerCase())).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filteredList[index].namakost),
                            onTap: () {
                              setState(() => _selectedKost = filteredList[index]);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _bukaPemindaiFasilitas() async {
    final List<String>? hasilScan = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanFasilitasPage()),
    );
    
    if (hasilScan != null && hasilScan.isNotEmpty) {
      setState(() {
        String fasilitasBaru = hasilScan.join(', ');
        String teksFormat = "Daftar fasilitas : $fasilitasBaru";
        if (_noteController.text.isEmpty) {
          _noteController.text = teksFormat;
        } else {
          _noteController.text += '\n\n$teksFormat';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFEFEBE1),
      // --- TOMBOL KAMERA MELAYANG ---
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0, right: 10.0),
        child: FloatingActionButton(
          onPressed: _pickFromCamera,
          backgroundColor: primaryGreen,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('Tambah Notes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87)),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _showKostDropdown, 
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedKost?.namakost ?? 'Pilih Nama Kost',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: _selectedKost != null ? FontWeight.w800 : FontWeight.normal,
                                        color: _selectedKost != null ? Colors.black87 : Colors.grey,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: Colors.black87),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            _buildImageSection(),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Scan Fasilitas Kost',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.document_scanner_rounded, size: 20),
                                    color: primaryGreen,
                                    onPressed: _bukaPemindaiFasilitas,
                                    tooltip: 'Scan Fasilitas Kost',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),

                            TextField(
                              controller: _noteController,
                              maxLines: null,
                              minLines: 3,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(hintText: 'Tulis catatanmu di sini...', border: InputBorder.none),
                              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- TOMBOL SIMPAN ---
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 24.0 : 100.0, 
                      top: 8.0
                    ), 
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _controller.isLoading,
                      builder: (context, isLoading, child) {
                        return ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            if (_selectedKost == null || _noteController.text.isEmpty || _currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kost dan isi catatan terlebih dahulu!')));
                              return;
                            }

                            final now = DateTime.now();
                            final tanggalFormat = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
                            
                            final noteBaru = NoteModel(
                              idnote: 'NOTE-${now.millisecondsSinceEpoch}',
                              user: _currentUser,
                              kost: _selectedKost,
                              catatan: _noteController.text.trim(),
                              tanggal: tanggalFormat,
                            );
                            
                            bool success = await _controller.tambahNote(noteBaru);

                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catatan berhasil disimpan!')));
                              setState(() {
                                _selectedKost = null;
                                _noteController.clear();
                                _imageFile = null;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Simpan',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BAGIAN GAMBAR
  Widget _buildImageSection() {
    if (_imageFile == null) {
      return InkWell(
        onTap: _pickFromGallery,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 100, width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1.5, style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 32, color: Colors.grey[500]),
              const SizedBox(height: 4),
              Text('Lampirkan Foto (Opsional)', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 150, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(_imageFile!, fit: BoxFit.cover),
          
          Positioned(
            bottom: 8, right: 8,
            child: GestureDetector(
              onTap: _openImageEditor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.auto_fix_high, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Edit Foto', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          
          // Tombol Hapus Gambar
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _imageFile = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// --- WIDGET PCD EDITOR (Sama persis dengan yang di Tambah Kost) ---
// =============================================================================
class _LargePcdEditor extends StatefulWidget {
  final Uint8List originalBytes;
  final Color primaryGreen;
  final Color primaryRed;
  final Function(Uint8List processedBytes) onApply;

  const _LargePcdEditor({
    required this.originalBytes,
    required this.primaryGreen,
    required this.primaryRed,
    required this.onApply,
  });

  @override
  State<_LargePcdEditor> createState() => _LargePcdEditorState();
}

class _LargePcdEditorState extends State<_LargePcdEditor> {
  String _selectedTab = 'Brightness'; 
  double _brightnessLevel = 0.0;
  double _sharpenLevel = 1.0;
  double _medianRadius = 1.0;
  bool _isProcessing = false;
  bool _showOriginalOnly = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      clipBehavior: Clip.hardEdge,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.close, color: widget.primaryRed), onPressed: () => Navigator.pop(context)),
          title: const Text('Edit Foto Catatan', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onLongPressStart: (_) => setState(() => _showOriginalOnly = true),
                onLongPressEnd: (_) => setState(() => _showOriginalOnly = false),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10), width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                      clipBehavior: Clip.hardEdge,
                      child: _isProcessing ? Center(child: CircularProgressIndicator(color: widget.primaryGreen)) : _buildLargeImageRender(),
                    ),
                    if (_showOriginalOnly)
                      Positioned(top: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)), child: const Text('Melihat Asli (Sebelum)', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
                    if (!_showOriginalOnly && !_isProcessing)
                      Positioned(bottom: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: widget.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text('Tahan gambar untuk melihat asli', style: TextStyle(color: widget.primaryGreen, fontSize: 11)))),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: Colors.grey[50],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlSlider(),
                  const SizedBox(height: 8), const Divider(),
                  Wrap(
                    spacing: 8, alignment: WrapAlignment.center,
                    children: [
                      _buildFilterTab('AutoFix', '✨'), _buildFilterTab('Brightness', '☀️'),
                      _buildFilterTab('Sharpen', '🔍'), _buildFilterTab('Denoise', '🧹'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _applyAndClose,
            style: ElevatedButton.styleFrom(backgroundColor: widget.primaryGreen, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 48), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Terapkan & Simpan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeImageRender() {
    if (_showOriginalOnly) return Image.memory(widget.originalBytes, fit: BoxFit.contain);
    if (_selectedTab == 'Brightness') {
      return ColorFiltered(
        colorFilter: ColorFilter.matrix([
          1, 0, 0, 0, _brightnessLevel, 0, 1, 0, 0, _brightnessLevel, 0, 0, 1, 0, _brightnessLevel, 0, 0, 0, 1, 0,                
        ]),
        child: Image.memory(widget.originalBytes, fit: BoxFit.contain),
      );
    }
    return Image.memory(widget.originalBytes, fit: BoxFit.contain);
  }

  Widget _buildControlSlider() {
    if (_selectedTab == 'Brightness') {
      return Column(mainAxisSize: MainAxisSize.min, children: [Text('Intensitas: ${_brightnessLevel.toInt()}', style: const TextStyle(fontSize: 12, color: Colors.black54)), Slider(value: _brightnessLevel, min: -255.0, max: 255.0, activeColor: widget.primaryGreen, onChanged: (val) => setState(() => _brightnessLevel = val))]);
    } else if (_selectedTab == 'Sharpen') {
      return Column(mainAxisSize: MainAxisSize.min, children: [Text('Kekuatan Edge: ${_sharpenLevel.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, color: Colors.black54)), Slider(value: _sharpenLevel, min: 1.0, max: 5.0, divisions: 4, activeColor: widget.primaryGreen, onChanged: (val) => setState(() => _sharpenLevel = val))]);
    } else if (_selectedTab == 'Denoise') {
      return Column(mainAxisSize: MainAxisSize.min, children: [Text('Tingkat Kehalusan: ${_medianRadius.toInt()}', style: const TextStyle(fontSize: 12, color: Colors.black54)), Slider(value: _medianRadius, min: 1.0, max: 3.0, divisions: 2, activeColor: widget.primaryGreen, onChanged: (val) => setState(() => _medianRadius = val))]);
    } else {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Center(child: Text('Auto-Fix menyeimbangkan kontras secara otomatis.', style: TextStyle(fontSize: 12, color: Colors.black54))));
    }
  }

  Widget _buildFilterTab(String title, String icon) {
    bool isSelected = _selectedTab == title;
    return ChoiceChip(
      label: Text('$icon $title', style: const TextStyle(fontSize: 11)), selected: isSelected,
      selectedColor: widget.primaryGreen.withOpacity(0.2), backgroundColor: Colors.white,
      labelStyle: TextStyle(color: isSelected ? widget.primaryGreen : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      onSelected: (val) { if (val) setState(() => _selectedTab = title); },
    );
  }

  Future<void> _applyAndClose() async {
    setState(() => _isProcessing = true);
    try {
      Uint8List finalBytes;
      if (_selectedTab == 'Brightness') finalBytes = await compute(applyBrightness, {'bytes': widget.originalBytes, 'brightness': _brightnessLevel});
      else if (_selectedTab == 'Sharpen') finalBytes = await compute(applySharpening, {'bytes': widget.originalBytes, 'sharpen': _sharpenLevel});
      else if (_selectedTab == 'Denoise') finalBytes = await compute(applyMedianFilter, {'bytes': widget.originalBytes, 'radius': _medianRadius.toInt()});
      else finalBytes = await compute(applyAutoFix, {'bytes': widget.originalBytes});
      widget.onApply(finalBytes);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}