import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Indeks aktif untuk Bottom Navigation Bar
  int _selectedIndex = 0;

  // Warna-warna yang digunakan (sesuai desain)
  final Color backgroundColor = const Color(0xFFEFEBE1); // Krem terang
  final Color cardColor = const Color(0xFFFBFBF9); // Putih tulang
  final Color primaryGreen = const Color(0xFF4A6525); // Hijau olive
  final Color buttonYellow = const Color(0xFFEBC144); // Kuning mustard
  final Color buttonRed = const Color(0xFF6B1212); // Merah marun

  // Data dummy (sementara) untuk list kost
  final List<Map<String, String>> dummyKostData = [
    {
      'nama': 'Kost Bahagia',
      'alamat': 'Jl. Ciwaruga RT 01 RW 01',
      'jenis': 'Putri',
      'harga': 'RP. 600.000/bulan',
      // 'image': 'assets/kost1.png', // Uncomment & ganti dengan path gambar aslimu nanti
    },
    {
      'nama': 'Kost Bahagia',
      'alamat': 'Jl. Ciwaruga RT 01 RW 01',
      'jenis': 'Putri',
      'harga': 'RP. 600.000/bulan',
    },
    {
      'nama': 'Kost Bahagia',
      'alamat': 'Jl. Ciwaruga RT 01 RW 01',
      'jenis': 'Putri',
      'harga': 'RP. 600.000/bulan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // SafeArea agar konten tidak tertutup status bar (baterai/jam)
      body: SafeArea(
        // Menggunakan Stack untuk memastikan konten utama tidak tertutup oleh lengkungan BottomNav
        child: Stack(
          children: [
            // Konten Utama
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                // HEADER: Teks Judul
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

                // SEARCH BAR & LOGO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      // Logo Aplikasi
                      Image.asset(
                        'assets/logo_hunianku.png', // GANTI DENGAN NAMA FILE LOGO-MU DI FOLDER ASSETS
                        height: 36, // Sesuaikan ukuran
                        width: 36,
                      ),
                      const SizedBox(width: 12),
                      
                      // Kotak Pencarian
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25), // Rounded penuh (pill)
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
                              // Ikon filter (burger/menu) di sebelah kanan
                              suffixIcon: Icon(Icons.menu, color: Colors.black87),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 15), // Pusatkan teks vertikal
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // LIST KOST (Scrollable)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 24.0, 
                      right: 24.0, 
                      bottom: 100.0, // Beri jarak bawah agar card terakhir tidak tertutup BottomNav
                    ),
                    itemCount: dummyKostData.length,
                    itemBuilder: (context, index) {
                      final kost = dummyKostData[index];
                      return _buildKostCard(kost);
                    },
                  ),
                ),
              ],
            ),

            // BOTTOM NAVIGATION BAR (Melengkung)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 70, // Tinggi navigasi
                decoration: BoxDecoration(
                  color: primaryGreen, // Warna background navbar
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
                  children: [
                    _buildNavItem(Icons.home, 0),
                    _buildNavItem(Icons.vpn_key_outlined, 1),
                    _buildNavItem(Icons.add, 2),
                    _buildNavItem(Icons.edit_square, 3), // Atau Icons.chat_bubble_outline tergantung fungsi
                    _buildNavItem(Icons.person_outline, 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET CARD KOST
  Widget _buildKostCard(Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20), // Jarak antar card
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
          // Gambar Kost
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300], // Warna skeleton jika gambar belum ada
              borderRadius: BorderRadius.circular(16),
              // Jika sudah punya gambar aslinya, gunakan kode di bawah ini:
              // image: DecorationImage(
              //   image: AssetImage(data['image']!),
              //   fit: BoxFit.cover,
              // ),
            ),
            // Placeholder icon (bisa dihapus jika gambar asli sudah dipasang)
            child: const Icon(Icons.image, size: 40, color: Colors.grey), 
          ),
          const SizedBox(width: 16),
          
          // Informasi Kost
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Kost
                Text(
                  data['nama']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Alamat
                Text(
                  data['alamat']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Tag Jenis (Putri/Putra)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: backgroundColor, // Menggunakan warna krem background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['jenis']!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Harga
                Text(
                  data['harga']!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Tombol Aksi (Lihat Ulasan & Lihat Detail)
                Row(
                  children: [
                    // Tombol Lihat Ulasan
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonYellow,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 0), // Hilangkan padding vertikal default
                          minimumSize: const Size(0, 32), // Tinggi tombol lebih kecil
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Lihat Ulasan',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol Lihat Detail
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
                        child: const Text(
                          'Lihat Detail',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
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
          // Ikon aktif warnanya putih pekat, yang non-aktif agak redup
          color: isActive ? Colors.white : Colors.white.withOpacity(0.6), 
        ),
      ),
    );
  }
}