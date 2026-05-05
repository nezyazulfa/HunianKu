import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/controllers/dashboard_controller.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/services/session_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController _controller = DashboardController();
  // Indeks aktif untuk Bottom Navigation Bar
  int _selectedIndex = 0;
  String _userRole = '';
  String _userName = '';

  // Warna-warna yang digunakan (sesuai desain)
  final Color backgroundColor = const Color(0xFFEFEBE1); // Krem terang
  final Color cardColor = const Color(0xFFFBFBF9); // Putih tulang
  final Color primaryGreen = const Color(0xFF4A6525); // Hijau olive
  final Color buttonYellow = const Color(0xFFEBC144); // Kuning mustard
  final Color buttonRed = const Color(0xFF6B1212); // Merah marun

  @override
  void initState() {
    super.initState();
    // Ambil data kost secara otomatis saat halaman pertama kali dimuat
    _controller.fetchKosts();
    _loadUserSession(); 
  }

  // Mengambil data dari session
  Future<void> _loadUserSession() async {
    final role = await SessionService.getRole() ?? 'penghuni'; 
    final nama = await SessionService.getNama() ?? 'User';
    
    setState(() {
      _userRole = role;
      _userName = nama;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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

                // SEARCH BAR & LOGO (Tetap Sama)
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
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari Kost',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                              prefixIcon: Icon(Icons.search, color: Colors.black87),
                              suffixIcon: Icon(Icons.menu, color: Colors.black87),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // LIST KOST (Dihubungkan dengan ValueListenableBuilder)
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

                          return ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 24.0, 
                              right: 24.0, 
                              bottom: 100.0, 
                            ),
                            itemCount: kostList.length,
                            itemBuilder: (context, index) {
                              final kost = kostList[index];
                              return _buildKostCard(kost); // Kirim KostModel ke widget
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // BOTTOM NAVIGATION BAR (Tetap Sama)
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
                      ? _buildPemilikMenu() 
                      : _buildPenghuniMenu(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI MENU UNTUK PEMILIK ---
  List<Widget> _buildPemilikMenu() {
    return [
      _buildNavItem(Icons.home, 0),             // Beranda Kost-nya
      _buildNavItem(Icons.add_business, 1),      // Tambah Kost
      _buildNavItem(Icons.chat_bubble_outline, 2),// Pesan/Ulasan dari Penghuni
      _buildNavItem(Icons.person_outline, 3),    // Profil Pemilik
    ];
  }

  // --- FUNGSI MENU UNTUK PENGHUNI ---
  List<Widget> _buildPenghuniMenu() {
    return [
      _buildNavItem(Icons.home, 0),              // Cari Kost
      _buildNavItem(Icons.bookmark_border, 1),   // Bookmark Kost
      _buildNavItem(Icons.note_alt_outlined, 2), // Catatan Survei (Offline)
      _buildNavItem(Icons.person_outline, 3),    // Profil Penghuni
    ];
  }

  // WIDGET CARD KOST
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
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.image, size: 40, color: Colors.grey), 
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kost.namakost, // Diambil dari model
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
                  kost.alamat, // Diambil dari model
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
                    kost.jenis, // Diambil dari model
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kost.harga, // Diambil dari model
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
                        onPressed: () {},
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
                        onPressed: () {},
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

  // WIDGET ICON BOTTOM NAVIGATION BAR
  Widget _buildNavItem(IconData icon, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.6), 
        ),
      ),
    );
  }
}