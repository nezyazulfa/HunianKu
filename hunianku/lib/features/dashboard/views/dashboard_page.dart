import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hunianku/features/auth/views/profil_page.dart';
import 'package:hunianku/features/review/views/review_kost_page.dart';
import 'package:hunianku/features/note/views/note_page.dart';
import 'package:hunianku/features/note/views/tambah_note_page.dart'; 
import 'package:hunianku/services/session_service.dart'; 
import 'package:hunianku/features/dashboard/views/detail_kost_page.dart'; 
import 'package:hunianku/features/dashboard/controllers/dashboard_controller.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/tambah_kost/views/tambah_kost_page.dart';
import 'package:hunianku/features/kost_ku/views/kost_ku_page.dart';
import 'package:hunianku/features/draft/views/draft_page.dart';
import 'package:hunianku/features/bookmark/views/bookmark_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController _controller = DashboardController();
  int _selectedIndex = 0;
  
  String _userRole = '';

  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color cardColor = const Color(0xFFFBFBF9); 
  final Color primaryGreen = const Color(0xFF4A6525); 
  final Color buttonYellow = const Color(0xFFEBC144); 
  final Color buttonRed = const Color(0xFF6B1212);

  @override
  void initState() {
    super.initState();
    _controller.fetchKosts();
    _loadUserSession(); 
  }

  Future<void> _loadUserSession() async {
    final role = await SessionService.getRole() ?? 'penghuni'; 
    setState(() {
      _userRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildMainDashboard(), // Index 0 (Home)

      // Index 1 (Kost Ku untuk Pemilik, Daftar Catatan untuk Penghuni)
      _userRole == 'pemilik' ? const KostKuPage() : const NotePage(), 

      // Index 2 (Tambah Kost untuk Pemilik, Tambah Note untuk Penghuni)
      _userRole == 'pemilik' ? const AddKostPage() : const TambahNotePage(), 

      // Index 3 (Draft untuk Pemilik, Pin untuk Penghuni)
      _userRole == 'pemilik' ? DraftPage() : const BookmarkPage(),   
      
      const ProfilePage(),   // Index 4 (Profil)
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            pages[_selectedIndex],

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _userRole == 'pemilik' 
                  ? [
                      _buildNavItem(Icons.home, Icons.home_outlined, 0),
                      _buildNavItem(Icons.vpn_key, Icons.vpn_key_outlined, 1),
                      _buildNavItem(Icons.add_circle, Icons.add, 2),
                      _buildNavItem(Icons.edit, Icons.edit_outlined, 3), 
                      _buildNavItem(Icons.person, Icons.person_outline, 4),
                    ]
                  : [
                      _buildNavItem(Icons.home, Icons.home_outlined, 0),
                      _buildNavItem(Icons.article, Icons.article_outlined, 1),
                      _buildNavItem(Icons.add_circle, Icons.add, 2),
                      _buildNavItem(Icons.push_pin, Icons.push_pin_outlined, 3), 
                      _buildNavItem(Icons.person, Icons.person_outline, 4),
                    ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Cari kost impianmu di sini!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Image.asset(
                'assets/logo_hunianku.png',
                height: 36,
                width: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      // Fitur pencarian dari temanmu
                      _controller.searchKost(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari Kost (Nama / Lokasi / Fasilitas)',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.black87),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.black87), 
                        onPressed: () => _showFilterModal(context), // Panggil pop-up
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: _controller.isLoading,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ValueListenableBuilder<List<KostModel>>(
                valueListenable: _controller.kostList,
                builder: (context, kostList, child) {
                  if (kostList.isEmpty) {
                    return const Center(child: Text("Belum ada data kost tersedia."));
                  }

                  return RefreshIndicator(
                    color: primaryGreen, // Warna animasi loading putar
                    onRefresh: () async {
                      // Fungsi yang dipanggil saat user menarik layar ke bawah
                      await _controller.fetchKosts();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 24.0, 
                        right: 24.0, 
                        bottom: 100.0, 
                      ),
                      itemCount: kostList.length,
                      itemBuilder: (context, index) {
                        final kost = kostList[index];
                        return _buildKostCard(kost); 
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // MODAL BOTTOM SHEET UNTUK FILTER
  void _showFilterModal(BuildContext context) {
    // Controller lokal untuk menampung inputan di dalam modal
    TextEditingController minPriceCtrl = TextEditingController(text: _controller.minPrice?.toString() ?? '');
    TextEditingController maxPriceCtrl = TextEditingController(text: _controller.maxPrice?.toString() ?? '');
    
    String tempKategori = _controller.selectedKategori;
    String tempStatus = _controller.selectedStatus;
    String tempPeriode = _controller.selectedPeriode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, 
                left: 24, right: 24, top: 24
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle Bar
                    Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 20),
                    
                    // --- PERBAIKAN: JUDUL DENGAN TOMBOL RESET ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filter Pencarian', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
                        TextButton(
                          onPressed: () {
                            // 1. Kosongkan nilai di layar modal
                            minPriceCtrl.clear();
                            maxPriceCtrl.clear();
                            setModalState(() {
                              tempKategori = 'Semua';
                              tempStatus = 'Semua';
                              tempPeriode = 'Per Bulan';
                            });
                            // 2. Perintahkan controller mengembalikan data ke semula
                            _controller.resetFilters();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Reset', style: TextStyle(color: Color(0xFF6B1212), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- FILTER HARGA & PERIODE ---
                    const Text('Rentang Harga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildPriceInput(minPriceCtrl, 'Minimum (Rp)')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPriceInput(maxPriceCtrl, 'Maksimum (Rp)')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ['Per Bulan', 'Per Semester', 'Per Tahun'].map((periode) {
                        return ChoiceChip(
                          label: Text(periode, style: TextStyle(color: tempPeriode == periode ? Colors.white : Colors.black87)),
                          selected: tempPeriode == periode,
                          selectedColor: primaryGreen,
                          backgroundColor: backgroundColor,
                          onSelected: (bool selected) {
                            setModalState(() => tempPeriode = periode);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // --- FILTER KATEGORI ---
                    const Text('Kategori Kost', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ['Semua', 'Putra', 'Putri', 'Putra Putri'].map((kategori) {
                        return ChoiceChip(
                          label: Text(kategori, style: TextStyle(color: tempKategori == kategori ? Colors.white : Colors.black87)),
                          selected: tempKategori == kategori,
                          selectedColor: primaryGreen,
                          backgroundColor: backgroundColor,
                          onSelected: (bool selected) {
                            setModalState(() => tempKategori = selected ? kategori : 'Semua');
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // --- FILTER STATUS ---
                    const Text('Status Kost', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ['Semua', 'Tersedia', 'Full'].map((status) {
                        return ChoiceChip(
                          label: Text(status, style: TextStyle(color: tempStatus == status ? Colors.white : Colors.black87)),
                          selected: tempStatus == status,
                          selectedColor: primaryGreen,
                          backgroundColor: backgroundColor,
                          onSelected: (bool selected) {
                            setModalState(() => tempStatus = selected ? status : 'Semua');
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // --- TOMBOL TERAPKAN ---
                    ElevatedButton(
                      onPressed: () {
                        int? min = minPriceCtrl.text.isNotEmpty ? int.parse(minPriceCtrl.text) : null;
                        int? max = maxPriceCtrl.text.isNotEmpty ? int.parse(maxPriceCtrl.text) : null;
                        
                        _controller.setFilters(
                          min: min,
                          max: max,
                          kategori: tempKategori,
                          status: tempStatus,
                          periode: tempPeriode,
                        );
                        Navigator.pop(context); // Tutup modal
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Terapkan Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24), // Spacing ekstra di bawah
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget bantuan untuk input harga di dalam Modal
  Widget _buildPriceInput(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildKostCard(KostModel kost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
              image: kost.daftarFoto.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(kost.daftarFoto[0]), // Ambil foto urutan pertama
                      fit: BoxFit.cover, // Biar fotonya memenuhi kotak tanpa gepeng
                    )
                  : null,
            ),
            child: kost.daftarFoto.isEmpty 
                ? const Icon(Icons.image, size: 40, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kost.namakost,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  kost.alamat,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    kost.jenis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kost.harga,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigasi ke fitur Review Kost milik temanmu
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewKostPage(kost: kost),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonYellow,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          minimumSize: const Size(0, 32),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Lihat Ulasan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailKostPage(kost: kost), // Menggunakan format baru dari temanmu
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          minimumSize: const Size(0, 32),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Lihat Detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        // Jika user menekan ikon Beranda (Index 0), otomatis tarik data terbaru!
        if (index == 0) {
          _controller.fetchKosts();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          size: 28,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.6), 
        ),
      ),
    );
  }
}