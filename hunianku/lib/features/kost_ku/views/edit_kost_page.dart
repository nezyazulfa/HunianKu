import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/kost_ku/controllers/kost_ku_controller.dart';

class EditKostPage extends StatefulWidget {
  final KostModel kostData; 
  final bool isDraft;

  const EditKostPage({super.key, required this.kostData, this.isDraft = false, required Map<String, String> initialData});

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

  String _selectedKategori = 'Campur';
  String _selectedStatus = 'Full';

  final Color backgroundColor = const Color(0xFFEFEBE1);
  final Color cardColor = const Color(0xFFFBFBF9);
  final Color primaryGreen = const Color(0xFF4A6525);
  final Color primaryRed = const Color(0xFF6B1212);

  @override
  void initState() {
    super.initState();
    // Isi field dengan data dari MongoDB
    _namaController = TextEditingController(text: widget.kostData.namakost);
    _deskripsiController = TextEditingController(text: widget.kostData.deskripsi);
    _alamatController = TextEditingController(text: widget.kostData.alamat);
    _gmapsController = TextEditingController(text: widget.kostData.lokasi);
    _fasilitasController = TextEditingController(text: widget.kostData.daftarfasilitas);
    _hargaController = TextEditingController(text: widget.kostData.harga);
    _kontakController = TextEditingController(text: widget.kostData.kontak);
    
    _selectedKategori = widget.kostData.jenis.isNotEmpty ? widget.kostData.jenis : 'Campur';
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

  // Fungsi untuk mengompilasi data form ke dalam objek KostModel baru (untuk Update)
  KostModel _buatObjekUpdate() {
    return KostModel(
      id: widget.kostData.id, 
      idkost: widget.kostData.idkost, 
      iduser: widget.kostData.iduser, 
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Text('Edit Kost', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
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
              _buildTextField(controller: _hargaController, hintText: 'Harga per Bulan'),
              const SizedBox(height: 16),
              _buildTextField(controller: _kontakController, hintText: 'Contact Person'),
              const SizedBox(height: 24),

              // --- KATEGORI KOST ---
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

              // --- STATUS KOST ---
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
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: primaryGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(0, 48),
                          ),
                          child: Text('Batal', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_namaController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama kost tidak boleh kosong!")));
                              return;
                            }
                            final kostUpdate = _buatObjekUpdate();
                            _controller.simpanEditKost(context, kostUpdate, widget.isDraft);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(0, 48),
                          ),
                          child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField({required TextEditingController controller, required String hintText}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
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
            style: TextStyle(
              color: isSelected ? Colors.white : primaryRed,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}