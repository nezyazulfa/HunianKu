import 'package:flutter/material.dart';
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

  bool _isPutraSelected = false;
  bool _isPutriSelected = false;

  String _selectedPeriode = '/bulan';
  final List<String> _periodeOptions = ['/bulan', '/semester', '/tahun'];

  final String _selectedStatus = 'Tersedia';
  String _currentIdUser = '';

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

  // --- LOGIKA MENGGABUNGKAN DATA KOST ---
  KostModel _buatObjekKost() {
    List<String> kategoriList = [];
    if (_isPutraSelected) kategoriList.add('Putra');
    if (_isPutriSelected) kategoriList.add('Putri');
    String kategoriFinal = kategoriList.join(', ');
    String hargaFinal = 'Rp${_hargaController.text.trim()}$_selectedPeriode';

    return KostModel(
      idkost: 'K-${DateTime.now().millisecondsSinceEpoch}', 
      iduser: _currentIdUser,
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

  // --- LOGIKA VALIDASI SEMUA FIELD ---
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

                    // --- KOTAK UPLOAD GAMBAR ---
                    _buildImageUploadBox(),
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
                    const SizedBox(height: 32),

                    // --- TOMBOL AKSI ---
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
                                  _controller.simpanKost(context, kostBaru, _clearAllFields);
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

  void _clearAllFields() {
    _namaController.clear();
    _deskripsiController.clear();
    _alamatController.clear();
    _gmapsController.clear();
    _fasilitasController.clear();
    _hargaController.clear();
    _kontakController.clear();
    setState(() {
      _isPutraSelected = false;
      _isPutriSelected = false;
      _selectedPeriode = '/bulan';
    });
  }

  Widget _buildImageUploadBox() {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur upload foto segera hadir!')));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160, width: double.infinity,
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
            Text('Format: JPG, PNG', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, bool isNumeric = false}) {
    return Container(
      decoration: BoxDecoration(color: inputBackgroundColor, borderRadius: BorderRadius.circular(16)),
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