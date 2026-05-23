import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/kost_ku/controllers/kost_ku_controller.dart';
// --- IMPORT GABUNGAN MILIKMU & TEMANMU ---
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunianku/features/tambah_kost/views/map_picker_page.dart';
import 'package:hunianku/features/tambah_kost/views/scan_fasilitas_page.dart';

class EditKostPage extends StatefulWidget {
  final KostModel kostData; 
  final bool isDraft;
  final Map<String, String> initialData;

  const EditKostPage({super.key, required this.kostData, this.isDraft = false, required this.initialData});

  @override
  State<EditKostPage> createState() => _EditKostPageState();
}

class _EditKostPageState extends State<EditKostPage> {
  final KostKuController _controller = KostKuController();

  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _alamatController;
  late TextEditingController _gmapsController;
  late TextEditingController _fasilitasController;
  late TextEditingController _hargaController;
  late TextEditingController _kontakController;

  bool _isPutraSelected = false;
  bool _isPutriSelected = false;

  String _selectedPeriode = '/bulan';
  final List<String> _periodeOptions = ['/bulan', '/semester', '/tahun'];

  String _selectedStatus = 'Tersedia';

  final Color backgroundColor = const Color(0xFFEFEBE1);
  final Color cardColor = const Color(0xFFFBFBF9);
  final Color primaryGreen = const Color(0xFF4A6525);
  final Color primaryRed = const Color(0xFF6B1212);
  final Color inputBackgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    
    // --- PARSING DATA DARI DATABASE (Logika Temanmu) ---
    // 1. Parsing Kategori
    String jenis = widget.kostData.jenis;
    _isPutraSelected = jenis.contains('Putra') || jenis == 'Campur';
    _isPutriSelected = jenis.contains('Putri') || jenis == 'Campur';

    // 2. Parsing Harga
    String hargaRaw = widget.kostData.harga;
    if (hargaRaw.contains('/semester')) {
      _selectedPeriode = '/semester';
    } else if (hargaRaw.contains('/tahun')) {
      _selectedPeriode = '/tahun';
    } else {
      _selectedPeriode = '/bulan';
    }
    String priceNumber = hargaRaw.replaceAll('Rp', '').replaceAll(_selectedPeriode, '').trim();

    _namaController = TextEditingController(text: widget.kostData.namakost);
    _deskripsiController = TextEditingController(text: widget.kostData.deskripsi);
    _alamatController = TextEditingController(text: widget.kostData.alamat);
    _gmapsController = TextEditingController(text: widget.kostData.lokasi);
    _fasilitasController = TextEditingController(text: widget.kostData.daftarfasilitas);
    _hargaController = TextEditingController(text: priceNumber);
    _kontakController = TextEditingController(text: widget.kostData.kontak);
    
    _selectedStatus = widget.kostData.status.isNotEmpty ? widget.kostData.status : 'Tersedia';
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

  // --- LOGIKA SCAN FASILITAS (Milik Temanmu) ---
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

  // --- LOGIKA MENGGABUNGKAN DATA (Milik Temanmu) ---
  KostModel _buatObjekUpdate() {
    List<String> kategoriList = [];
    if (_isPutraSelected) kategoriList.add('Putra');
    if (_isPutriSelected) kategoriList.add('Putri');
    String kategoriFinal = kategoriList.join(', ');

    String hargaFinal = 'Rp${_hargaController.text.trim()}$_selectedPeriode';

    return KostModel(
      id: widget.kostData.id, 
      idkost: widget.kostData.idkost, 
      user: widget.kostData.user, 
      namakost: _namaController.text.trim(),
      jenis: kategoriFinal,
      alamat: _alamatController.text.trim(),
      lokasi: _gmapsController.text.trim(), // Koordinat Gmaps
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
        const SnackBar(content: Text('Gagal: Pilih minimal satu Kategori!'), backgroundColor: Colors.red),
      );
      return false;
    }

    return true; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              const Text('Edit Kost', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87)),
              const SizedBox(height: 8),
              const Text('Perbarui informasi kost anda', style: TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
              const SizedBox(height: 24),

              // --- KOTAK UPLOAD GAMBAR ---
              _buildImageUploadBox(),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _gmapsController.text.isEmpty ? 'Lokasi Peta Belum Dipilih' : 'Titik Lokasi Tersimpan',
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

              // --- ROW FASILITAS & SCANNER (Milik Temanmu) ---
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
              
              _buildHargaField(), // Dari Temanmu
              const SizedBox(height: 16),
              _buildTextField(controller: _kontakController, hintText: 'Contact Person', isNumeric: true),
              const SizedBox(height: 24),

              // --- KATEGORI KOST MULTI-SELECT ---
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

              // --- STATUS KOST SINGLE-SELECT ---
              const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSingleSelectButton('Tersedia', _selectedStatus, (val) => setState(() => _selectedStatus = val)),
                  const SizedBox(width: 12),
                  _buildSingleSelectButton('Full', _selectedStatus, (val) => setState(() => _selectedStatus = val)),
                ],
              ),
              const SizedBox(height: 32),
              
              ValueListenableBuilder<bool>(
                valueListenable: _controller.isLoading,
                builder: (context, isLoading, child) {
                  if (isLoading) return Center(child: CircularProgressIndicator(color: primaryGreen));
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: primaryGreen, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            minimumSize: const Size(0, 48),
                          ),
                          child: Text('Batal', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_validasiInput()) return;
                            final kostUpdate = _buatObjekUpdate();
                            _controller.simpanEditKost(context, kostUpdate, widget.isDraft);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            minimumSize: const Size(0, 48),
                          ),
                          child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  );
                }
              )
            ],
          ),
        ),
      ),
    );
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