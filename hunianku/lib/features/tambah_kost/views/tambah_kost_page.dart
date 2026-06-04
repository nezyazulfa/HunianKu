import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/tambah_kost/controllers/tambah_kost_controller.dart';
import 'package:hunianku/services/session_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunianku/features/tambah_kost/views/map_picker_page.dart';
import 'package:hunianku/helpers/pcd_helper.dart'; 
import 'package:flutter/foundation.dart';
import 'package:hunianku/features/tambah_kost/views/scan_fasilitas_page.dart'; 
import 'package:hunianku/features/auth/model/user_model.dart';

class AddKostPage extends StatefulWidget {
  const AddKostPage({super.key});

  @override
  State<AddKostPage> createState() => _AddKostPageState();
}

class _AddKostPageState extends State<AddKostPage> {
  final TambahKostController _controller = TambahKostController();
  
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _gmapsController = TextEditingController();
  final TextEditingController _fasilitasController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _kontakController = TextEditingController();

  bool _isPutraSelected = false;
  bool _isPutriSelected = false;

  String _selectedPeriode = '/bulan';
  final List<String> _periodeOptions = ['/bulan', '/semester', '/tahun'];

  final String _selectedStatus = 'Tersedia';
  UserModel? _currentUser;

  List<File> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _bukaPemindaiFasilitas() async {
    final List<String>? hasilScan = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanFasilitasPage()),
    );
    if (hasilScan != null && hasilScan.isNotEmpty) {
      setState(() {
        String fasilitasBaru = hasilScan.join(', ');
        if (_fasilitasController.text.isEmpty) {
          _fasilitasController.text = fasilitasBaru;
        } else {
          _fasilitasController.text += ', $fasilitasBaru';
        }
      });
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _imageFiles.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka kamera: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (var xfile in pickedFiles) {
            _imageFiles.add(File(xfile.path));
          }
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka galeri: $e')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> _openImageEditor(int index) async {
    final File imageFile = _imageFiles[index];
    final Uint8List originalBytes = await imageFile.readAsBytes();
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true, 
      builder: (BuildContext context) {
        return _LargePcdEditor(
          originalBytes: originalBytes,
          primaryGreen: primaryGreen,
          primaryRed: primaryRed,
          backgroundColor: backgroundColor,
          onApply: (Uint8List processedBytes) async {
            await imageFile.writeAsBytes(processedBytes);
            setState(() {
              _imageFiles[index] = imageFile; 
            });
          },
        );
      },
    );
  }

  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color cardColor = const Color(0x80FBFBF9); 
  final Color primaryGreen = const Color(0xFF4A6525);
  final Color primaryRed = const Color(0xFF6B1212); 
  final Color inputBackgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadPemilikId();
  }

  Future<void> _loadPemilikId() async {
    final id = await SessionService.getIdUser();
    final nama = await SessionService.getNama();
    final role = await SessionService.getRole();
    if (id != null) {
      setState(() {
        _currentUser = UserModel(
          iduser: id,
          nama: nama ?? 'Pemilik',
          email: '', password: '', role: role ?? 'pemilik'
        );
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _alamatController.dispose();
    _gmapsController.dispose();
    _fasilitasController.dispose();
    _hargaController.dispose();
    _kontakController.dispose();
    super.dispose();
  }

  KostModel _buatObjekKost() {
    List<String> kategoriList = [];
    if (_isPutraSelected) kategoriList.add('Putra');
    if (_isPutriSelected) kategoriList.add('Putri');
    String kategoriFinal = kategoriList.join(', ');
    String hargaFinal = 'Rp${_hargaController.text.trim()}$_selectedPeriode';

    return KostModel(
      idkost: 'K-${DateTime.now().millisecondsSinceEpoch}', 
      user: _currentUser,
      namakost: _namaController.text.trim(),
      jenis: kategoriFinal,
      alamat: _alamatController.text.trim(),
      lokasi: _gmapsController.text.trim(),
      harga: hargaFinal,
      kontak: _kontakController.text.trim(),
      daftarfasilitas: _fasilitasController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      status: _selectedStatus,
    );
  }

  bool _validasiInput() {
    if (_namaController.text.trim().isEmpty ||
        _deskripsiController.text.trim().isEmpty ||
        _alamatController.text.trim().isEmpty ||
        _gmapsController.text.trim().isEmpty ||
        _fasilitasController.text.trim().isEmpty ||
        _hargaController.text.trim().isEmpty ||
        _kontakController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal: Semua kotak isian wajib diisi!'), backgroundColor: Colors.red),
      );
      return false;
    }

    if (!_isPutraSelected && !_isPutriSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal: Pilih minimal satu Kategori (Putra atau Putri)!'), backgroundColor: Colors.red),
      );
      return false;
    }

    return true; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // --- FLOATING ACTION BUTTON (Milik Temanmu) ---
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0), 
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tambah Kost', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87)),
                    const SizedBox(height: 8),
                    const Text('Isi detail untuk menambah kost anda', style: TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    
                    // --- GALERI FOTO (Milik Temanmu) ---
                    _buildImageGallery(),
                    const SizedBox(height: 24),
                    
                    _buildTextField(controller: _namaController, hintText: 'Nama Kost'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _deskripsiController, hintText: 'Deskripsi'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _alamatController, hintText: 'Alamat'),
                    const SizedBox(height: 16),
                    
                    // --- TOMBOL PETA GMAPS (Milikmu) ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: inputBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _gmapsController.text.isEmpty 
                                  ? 'Lokasi Peta Belum Dipilih' 
                                  : 'Titik Lokasi Tersimpan',
                              style: TextStyle(
                                color: _gmapsController.text.isEmpty ? Colors.grey.shade500 : Colors.black87,
                                fontSize: 14,
                                fontWeight: _gmapsController.text.isEmpty ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              LatLng? initial;
                              if (_gmapsController.text.isNotEmpty) {
                                final parts = _gmapsController.text.split(',');
                                if (parts.length == 2) {
                                  try {
                                    initial = LatLng(double.parse(parts[0].trim()), double.parse(parts[1].trim()));
                                  } catch (_) {}
                                }
                              }

                              final LatLng? picked = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MapPickerPage(initialLocation: initial)),
                              );

                              if (picked != null) {
                                setState(() {
                                  _gmapsController.text = '${picked.latitude},${picked.longitude}';
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEFEBE1),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Buka Peta', style: TextStyle(color: Colors.black87)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- ROW FASILITAS & SCANNER ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(controller: _fasilitasController, hintText: 'Fasilitas'),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.document_scanner_rounded),
                            color: primaryGreen,
                            onPressed: _bukaPemindaiFasilitas,
                            tooltip: 'Scan Fasilitas Kamar',
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- INPUT HARGA DENGAN DROPDOWN ---
                    _buildHargaField(),
                    const SizedBox(height: 16),
                    
                    _buildTextField(controller: _kontakController, hintText: 'Contact Person', isNumeric: true),
                    const SizedBox(height: 24),

                    // --- KATEGORI KOST (MULTI-SELECT) ---
                    const Text('Kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMultiSelectButton('Putra', _isPutraSelected, () => setState(() => _isPutraSelected = !_isPutraSelected)),
                        const SizedBox(width: 8),
                        _buildMultiSelectButton('Putri', _isPutriSelected, () => setState(() => _isPutriSelected = !_isPutriSelected)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- STATUS KOST ---
                    const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSingleSelectButton('Tersedia', _selectedStatus, (val) => {}),
                        const SizedBox(width: 12),
                        _buildSingleSelectButton('Full', _selectedStatus, (val) => {}),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- TOMBOL AKSI ---
                    ValueListenableBuilder<bool>(
                      valueListenable: _controller.isLoading,
                      builder: (context, isLoading, child) {
                        if (isLoading) return Center(child: CircularProgressIndicator(color: primaryGreen));
                        
                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  if (!_validasiInput()) return; 
                                  final kostDraft = _buatObjekKost();
                                  _controller.simpanKeDraf(context, kostDraft, _clearAllFields);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: primaryGreen, width: 1.5),
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text('Draf', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryGreen)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!_validasiInput()) return; 
                                  final kostBaru = _buatObjekKost();
                                  // Menggunakan _imageFiles sesuai kode temanmu
                                  _controller.simpanKost(context, kostBaru, _imageFiles, _clearAllFields);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 48),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text('Simpan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60), 
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BANTUAN MILIK TEMANMU ---
  Widget _buildImageGallery() {
    if (_imageFiles.isEmpty) {
      return InkWell(
        onTap: _pickFromGallery,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 160, width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text('Upload Foto Kost', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text('Bisa pilih lebih dari 1 foto', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageFiles.length + 1, 
        itemBuilder: (context, index) {
          if (index == _imageFiles.length) {
            return GestureDetector(
              onTap: _pickFromGallery,
              child: Container(
                width: 100, margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200], borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 1.5, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 32, color: Colors.grey[600]),
                    const SizedBox(height: 4),
                    Text('Tambah', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              GestureDetector(
                onTap: () => _openImageEditor(index), 
                child: Container(
                  width: 120, margin: const EdgeInsets.only(right: 12),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(_imageFiles[index], fit: BoxFit.cover),
                      Positioned(
                        bottom: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.auto_fix_high, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 4, right: 16,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _clearAllFields() {
    _namaController.clear(); _deskripsiController.clear(); _alamatController.clear();
    _gmapsController.clear(); _fasilitasController.clear(); _hargaController.clear(); _kontakController.clear();
    setState(() { 
      _imageFiles.clear(); 
      _isPutraSelected = false;
      _isPutriSelected = false;
      _selectedPeriode = '/bulan';
    });
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, bool isNumeric = false}) {
    return Container(
      decoration: BoxDecoration(color: inputBackgroundColor, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildHargaField() {
    return Container(
      decoration: BoxDecoration(color: inputBackgroundColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                String numericOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (numericOnly.isEmpty) {
                  _hargaController.clear();
                  return;
                }
                
                String formatted = '';
                int count = 0;
                for (int i = numericOnly.length - 1; i >= 0; i--) {
                  if (count != 0 && count % 3 == 0) {
                    formatted = '.$formatted';
                  }
                  formatted = numericOnly[i] + formatted;
                  count++;
                }
                
                _hargaController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              },
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(color: Colors.black87, fontSize: 14),
                hintText: 'Harga',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          Container(height: 24, width: 1, color: Colors.grey.shade300), 
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriode,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                items: _periodeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPeriode = newValue!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectButton(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? primaryRed : Colors.white, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryRed, width: 1.2),
          ),
          child: Text(title, style: TextStyle(color: isSelected ? Colors.white : primaryRed, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildSingleSelectButton(String title, String groupValue, Function(String) onSelect) {
    bool isSelected = title == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(title),
        child: Container(
          height: 40, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? primaryRed : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryRed, width: 1.2),
          ),
          child: Text(
            title,
            style: TextStyle(color: isSelected ? Colors.white : primaryRed, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

// --- WIDGET PCD EDITOR
class _LargePcdEditor extends StatefulWidget {
  final Uint8List originalBytes;
  final Color primaryGreen;
  final Color primaryRed;
  final Color backgroundColor;
  final Function(Uint8List processedBytes) onApply;

  const _LargePcdEditor({
    required this.originalBytes,
    required this.primaryGreen,
    required this.primaryRed,
    required this.backgroundColor,
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

  // Menyimpan hasil filter sementara untuk ditampilkan di layar
  late Uint8List _previewBytes;

  @override
  void initState() {
    super.initState();
    _previewBytes = widget.originalBytes;
  }

  Future<void> _generatePreview() async {
    setState(() => _isProcessing = true);
    try {
      Uint8List resultBytes = widget.originalBytes;

      if (_selectedTab == 'Sharpen') {
        resultBytes = await compute(applySharpening, {
          'bytes': widget.originalBytes,
          'sharpen': _sharpenLevel,
        });
      } else if (_selectedTab == 'Denoise') {
        resultBytes = await compute(applyMedianFilter, {
          'bytes': widget.originalBytes,
          'radius': _medianRadius.toInt(),
        });
      } else if (_selectedTab == 'AutoFix') {
        resultBytes = await compute(applyAutoFix, {
          'bytes': widget.originalBytes,
        });
      }

      setState(() {
        _previewBytes = resultBytes;
      });
    } catch (e) {
      debugPrint('Gagal generate preview: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

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
          leading: IconButton(
            icon: Icon(Icons.close, color: widget.primaryRed),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Edit Foto Kost', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                      margin: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: _isProcessing
                        ? Center(child: CircularProgressIndicator(color: widget.primaryGreen))
                        : _buildLargeImageRender(), // Panggil render UI
                    ),
                    
                    if (_showOriginalOnly)
                      Positioned(
                        top: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                          child: const Text('Melihat Asli (Sebelum)', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),

                    if (!_showOriginalOnly && !_isProcessing)
                      Positioned(
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: widget.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text('Tahan gambar untuk melihat asli', style: TextStyle(color: widget.primaryGreen, fontSize: 11)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[50],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlSlider(),
                  const SizedBox(height: 8),
                  const Divider(),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFilterTab('AutoFix', '✨'),
                      _buildFilterTab('Brightness', '☀️'),
                      _buildFilterTab('Sharpen', '🔍'),
                      _buildFilterTab('Denoise', '🧹'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Terapkan & Simpan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeImageRender() {
    if (_showOriginalOnly) {
      return Image.memory(widget.originalBytes, fit: BoxFit.contain);
    }
    
    if (_selectedTab == 'Brightness') {
      // Tetap gunakan ColorFiltered agar super mulus saat slider digeser
      return ColorFiltered(
        colorFilter: ColorFilter.matrix([
          1, 0, 0, 0, _brightnessLevel, 
          0, 1, 0, 0, _brightnessLevel, 
          0, 0, 1, 0, _brightnessLevel, 
          0, 0, 0, 1, 0,                
        ]),
        child: Image.memory(widget.originalBytes, fit: BoxFit.contain),
      );
    }
    
    return Image.memory(_previewBytes, fit: BoxFit.contain);
  }

  Widget _buildControlSlider() {
    if (_selectedTab == 'Brightness') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Intensitas: ${_brightnessLevel.toInt()}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Slider(
            value: _brightnessLevel,
            min: -255.0, max: 255.0,
            activeColor: widget.primaryGreen,
            onChanged: (val) => setState(() => _brightnessLevel = val),
          ),
        ],
      );
    } else if (_selectedTab == 'Sharpen') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Kekuatan Edge: ${_sharpenLevel.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Slider(
            value: _sharpenLevel,
            min: 0.0, max: 5.0,
            divisions: 4, 
            activeColor: widget.primaryGreen,
            onChanged: (val) => setState(() => _sharpenLevel = val),
            onChangeEnd: (val) => _generatePreview(), 
          ),
        ],
      );
    } else if (_selectedTab == 'Denoise') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Tingkat Kehalusan: ${_medianRadius.toInt()}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Slider(
            value: _medianRadius,
            min: 0.0, max: 3.0,
            divisions: 2, 
            activeColor: widget.primaryGreen,
            onChanged: (val) => setState(() => _medianRadius = val),
            onChangeEnd: (val) => _generatePreview(), 
          ),
        ],
      );
    } else {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('Auto-Fix menyeimbangkan kontras secara otomatis.', style: TextStyle(fontSize: 12, color: Colors.black54))),
      );
    }
  }

  Widget _buildFilterTab(String title, String icon) {
    bool isSelected = _selectedTab == title;
    return ChoiceChip(
      label: Text('$icon $title', style: const TextStyle(fontSize: 11)),
      selected: isSelected,
      selectedColor: widget.primaryGreen.withOpacity(0.2),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: isSelected ? widget.primaryGreen : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      onSelected: (val) {
        if (val) {
          setState(() => _selectedTab = title);
          if (title != 'Brightness') {
             _generatePreview();
          }
        }
      },
    );
  }

  Future<void> _applyAndClose() async {
    setState(() => _isProcessing = true);
    
    try {
      Uint8List finalBytes;
      if (_selectedTab == 'Brightness') {
        finalBytes = await compute(applyBrightness, {
          'bytes': widget.originalBytes,
          'brightness': _brightnessLevel,
        });
      } else {
        finalBytes = _previewBytes;
      }

      widget.onApply(finalBytes);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menerapkan PCD: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}