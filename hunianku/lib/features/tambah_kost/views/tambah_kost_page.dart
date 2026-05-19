import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/tambah_kost/controllers/tambah_kost_controller.dart';
import 'package:hunianku/services/session_service.dart';

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

  String _selectedKategori = 'Campur'; 
  String _selectedStatus = 'Full';
  String _currentIdUser = '';

  // --- 1. UBAH MENJADI LIST UNTUK MENYIMPAN BANYAK FOTO ---
  List<File> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();

  // --- 2. FUNGSI KAMERA (Tetap 1 foto per jepretan, tapi ditambahkan ke list) ---
  Future<void> _pickFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFiles.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka kamera: $e')),
        );
      }
    }
  }

  // --- 3. FUNGSI GALERI (Bisa pilih banyak foto sekaligus) ---
  Future<void> _pickFromGallery() async {
    try {
      // Menggunakan pickMultiImage
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          // Tambahkan semua foto yang dipilih ke dalam list
          for (var xfile in pickedFiles) {
            _imageFiles.add(File(xfile.path));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka galeri: $e')),
        );
      }
    }
  }

  // Fungsi untuk menghapus foto dari list jika user salah pilih
  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color cardColor = const Color(0x80FBFBF9); 
  final Color primaryGreen = const Color(0xFF4A6525);
  final Color primaryRed = const Color(0xFF6B1212); 
  final Color inputBackgroundColor = Colors.white;

  KostModel _buatObjekKost() {
    return KostModel(
      idkost: 'K-${DateTime.now().millisecondsSinceEpoch}', 
      iduser: _currentIdUser,
      namakost: _namaController.text.trim(),
      jenis: _selectedKategori,
      alamat: _alamatController.text.trim(),
      lokasi: _gmapsController.text.trim(),
      harga: _hargaController.text.trim(),
      kontak: _kontakController.text.trim(),
      daftarfasilitas: _fasilitasController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      status: _selectedStatus,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPemilikId();
  }

  Future<void> _loadPemilikId() async {
    final id = await SessionService.getIdUser();
    setState(() {
      _currentIdUser = id ?? '';
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0, right: 10.0),
        child: FloatingActionButton(
          onPressed: _pickFromCamera, // Panggil fungsi kamera
          backgroundColor: primaryGreen,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tambah Kost',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Isi detail untuk menambah kost anda',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // --- AREA UPLOAD GAMBAR (DIUPDATE) ---
                    _buildImageGallery(),
                    
                    const SizedBox(height: 24),

                    // --- FIELD INPUT ---
                    _buildTextField(controller: _namaController, hintText: 'Nama Kost'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _deskripsiController, hintText: 'Deskripsi'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _alamatController, hintText: 'Alamat'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _gmapsController, hintText: 'Link Gmaps'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _fasilitasController, hintText: 'Fasilitas'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _hargaController, hintText: 'Harga per Bulan', isNumeric: true),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _kontakController, hintText: 'Contact Person', isNumeric: true),
                    const SizedBox(height: 24),

                    const Text('Kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSelectionButton('Putra', _selectedKategori, (val) => setState(() => _selectedKategori = val)),
                        const SizedBox(width: 8),
                        _buildSelectionButton('Putri', _selectedKategori, (val) => setState(() => _selectedKategori = val)),
                        const SizedBox(width: 8),
                        _buildSelectionButton('Campur', _selectedKategori, (val) => setState(() => _selectedKategori = val)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSelectionButton('Tersedia', _selectedStatus, (val) => setState(() => _selectedStatus = val)),
                        const SizedBox(width: 12),
                        _buildSelectionButton('Full', _selectedStatus, (val) => setState(() => _selectedStatus = val)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    ValueListenableBuilder<bool>(
                      valueListenable: _controller.isLoading,
                      builder: (context, isLoading, child) {
                        if (isLoading) {
                          return Center(child: CircularProgressIndicator(color: primaryGreen));
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  final kostDraft = _buatObjekKost();
                                  _controller.simpanKeDraf(context, kostDraft, () {
                                    _clearAllFields();
                                  });
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
                                  if (_namaController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Kost wajib diisi!')));
                                    return;
                                  }
                                  final kostBaru = _buatObjekKost();
                                  _controller.simpanKost(context, kostBaru, () {
                                    _clearAllFields();
                                  });
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

  // --- WIDGET UI UNTUK MENAMPILKAN BANYAK GAMBAR ---
  Widget _buildImageGallery() {
    // Jika belum ada foto sama sekali, tampilkan kotak besar seperti desain awal
    if (_imageFiles.isEmpty) {
      return InkWell(
        onTap: _pickFromGallery,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
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

    // Jika sudah ada foto, tampilkan secara horizontal (bisa digeser ke samping)
    return SizedBox(
      height: 120, // Tinggi deretan foto
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageFiles.length + 1, // +1 untuk kotak "Tambah Foto" di paling ujung
        itemBuilder: (context, index) {
          // Jika ini item terakhir, tampilkan kotak untuk tambah foto lagi
          if (index == _imageFiles.length) {
            return GestureDetector(
              onTap: _pickFromGallery,
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
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

          // Tampilkan foto-foto yang sudah dipilih
          return Stack(
            children: [
              Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.file(
                  _imageFiles[index],
                  fit: BoxFit.cover,
                ),
              ),
              // Tombol silang (X) warna merah di pojok kanan atas foto untuk menghapus
              Positioned(
                top: 4,
                right: 16,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
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
    _namaController.clear();
    _deskripsiController.clear();
    _alamatController.clear();
    _gmapsController.clear();
    _fasilitasController.clear();
    _hargaController.clear();
    _kontakController.clear();
    setState(() {
      _imageFiles.clear(); // Kosongkan list gambar setelah disimpan
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isNumeric = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        borderRadius: BorderRadius.circular(16), 
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSelectionButton(String title, String groupValue, Function(String) onSelect) {
    bool isSelected = title == groupValue;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(title),
        child: Container(
          height: 40,
          alignment: Alignment.center,
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