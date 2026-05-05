import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/tambah_kost/controllers/tambah_kost_controller.dart';

class AddKostPage extends StatefulWidget {
  const AddKostPage({super.key});

  @override
  State<AddKostPage> createState() => _AddKostPageState();
}

class _AddKostPageState extends State<AddKostPage> {
  final TambahKostController _controller = TambahKostController();
  // Controllers untuk text input
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _gmapsController = TextEditingController();
  final TextEditingController _fasilitasController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _kontakController = TextEditingController();

  // State untuk radio/toggle button
  String _selectedKategori = 'Campur'; // Default terpilih
  String _selectedStatus = 'Full'; // Default terpilih

  // Warna sesuai palet desain
  final Color backgroundColor = const Color(0xFFEFEBE1); // Krem terang
  final Color cardColor = const Color(0x80FBFBF9); 
  final Color primaryGreen = const Color(0xFF4A6525); // Hijau olive
  final Color primaryRed = const Color(0xFF6B1212); // Merah marun
  final Color inputBackgroundColor = Colors.white;

  KostModel _buatObjekKost() {
  return KostModel(
    // Buat ID sementara yang unik menggunakan timestamp (waktu saat ini)
    idkost: 'K-${DateTime.now().millisecondsSinceEpoch}', 
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
      // SafeArea agar aman dari notch/status bar
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          // Tambahkan bottom padding ekstra jika halaman ini akan digabung dengan Bottom Navigation Bar
          child: Column(
            children: [
              // Card Container utama
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
                    // Judul Form
                    const Text(
                      'Tambah Kost',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Sub-judul
                    const Text(
                      'Isi detail untuk menambah kost anda',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
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

                    // --- KATEGORI KOST ---
                    const Text(
                      'Kategori',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
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
                    const Text(
                      'Status',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSelectionButton('Tersedia', _selectedStatus, (val) => setState(() => _selectedStatus = val)),
                        const SizedBox(width: 12),
                        _buildSelectionButton('Full', _selectedStatus, (val) => setState(() => _selectedStatus = val)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- TOMBOL AKSI (Draf & Simpan) ---
                    ValueListenableBuilder<bool>(
                      valueListenable: _controller.isLoading,
                      builder: (context, isLoading, child) {
                        if (isLoading) {
                          return Center(
                            child: CircularProgressIndicator(color: primaryGreen),
                          );
                        }
                    return Row(
                      children: [
                        // Tombol Draf (Outline)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              final kostDraft = _buatObjekKost();
                              _controller.simpanKeDraf(context, kostDraft, () {
                                // Fungsi ini akan dipanggil otomatis oleh controller saat sukses
                                _namaController.clear();
                                _deskripsiController.clear();
                                _alamatController.clear();
                                _gmapsController.clear();
                                _fasilitasController.clear();
                                _hargaController.clear();
                                _kontakController.clear();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryGreen, width: 1.5),
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Draf',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Tombol Simpan (Filled)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_namaController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Nama Kost wajib diisi!')),
                                );
                                return;
                              }
                              final kostBaru = _buatObjekKost();
                              _controller.simpanKost(context, kostBaru, () {
                                // Fungsi ini akan dipanggil otomatis oleh controller saat sukses
                                _namaController.clear();
                                _deskripsiController.clear();
                                _alamatController.clear();
                                _gmapsController.clear();
                                _fasilitasController.clear();
                                _hargaController.clear();
                                _kontakController.clear();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 48),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                    },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60), // Spasi bawah ekstra agar tidak mentok
            ],
          ),
        ),
      ),
    );
  }

  // Widget bantuan untuk membuat Text Field yang seragam
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isNumeric = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        borderRadius: BorderRadius.circular(16), // Rounded pill
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

  // Widget bantuan untuk membuat tombol Kategori & Status (Bisa Outline / Filled)
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
            border: Border.all(
              color: primaryRed,
              width: 1.2,
            ),
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