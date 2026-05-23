import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/bookmark/controllers/bookmark_controller.dart'; 
import 'package:hunianku/services/session_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailKostPage extends StatefulWidget {
  final KostModel kost;
  const DetailKostPage({super.key, required this.kost});

  @override
  State<DetailKostPage> createState() => _DetailKostPageState();
}

class _DetailKostPageState extends State<DetailKostPage> {
  // Panggil Singleton Controller (Agar datanya sinkron dengan halaman Bookmark)
  final BookmarkController _bookmarkController = BookmarkController();
  
  bool isBookmarked = false;
  String _userRole = '';

  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color cardColor = const Color(0x80FBFBF9); 

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    // Mengecek apakah kost ini ada di dalam daftar bookmark saat halaman dibuka
    isBookmarked = _bookmarkController.isKostBookmarked(widget.kost.idkost);
  }

  Future<void> _loadUserRole() async {
    final role = await SessionService.getRole() ?? 'penghuni';
    setState(() {
      _userRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false, 
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16), 
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.kost.namakost,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // --- TOMBOL BOOKMARK BINTANG ---
                    if (_userRole == 'penghuni')
                      ValueListenableBuilder<bool>(
                        valueListenable: _bookmarkController.isLoading,
                        builder: (context, isLoading, child) {
                          return IconButton(
                            icon: isLoading 
                              ? const SizedBox(
                                  width: 24, height: 24, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEBC144))
                                )
                              : Icon(
                                  isBookmarked ? Icons.star : Icons.star_border,
                                  color: const Color(0xFFEBC144), 
                                  size: 28,
                                ),
                            onPressed: isLoading ? null : () async {
                              // Panggil Controller untuk eksekusi ke MongoDB
                              if (isBookmarked) {
                                await _bookmarkController.removeBookmarkByKostId(context, widget.kost.idkost);
                              } else {
                                await _bookmarkController.addBookmark(context, widget.kost);
                              }
                              
                              // Perbarui status bintang di layar
                              setState(() {
                                isBookmarked = _bookmarkController.isKostBookmarked(widget.kost.idkost);
                              });
                            },
                          );
                        }
                      ),

                    // --- SPACER KOSONG JIKA PEMILIK ---
                    if (_userRole == 'pemilik')
                      const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- KONTEN DETAIL KOST ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.kost.daftarFoto.isEmpty)
                      Center(
                        child: Container(
                          width: 220, 
                          height: 260, 
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(24),         
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),                          
                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      )
                      else
                        SizedBox(
                          height: 260, 
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.kost.daftarFoto.length, 
                            itemBuilder: (context, index) {
                              return Container(
                                width: 220, 
                                margin: EdgeInsets.only(
                                  right: 16.0, 
                                  left: widget.kost.daftarFoto.length == 1 ? (MediaQuery.of(context).size.width - 220 - 48) / 2 : 0, 
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(24),
                                  image: DecorationImage(
                                    image: NetworkImage(widget.kost.daftarFoto[index]), // Ambil foto ke-1, ke-2, dst
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),                          
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 32),
                      ExcludeSemantics(),
                      const SizedBox(height: 32),
                      _buildDetailItem('Jenis Kost:', widget.kost.jenis),
                      const SizedBox(height: 16),
                      _buildDetailItem('Alamat:', widget.kost.alamat),
                      const SizedBox(height: 16),
                      
                      // --- MEMANGGIL WIDGET MAP PREVIEW ---
                      _buildMapPreview('Lokasi:', widget.kost.lokasi),
                      
                      const SizedBox(height: 16),
                      _buildDetailItem('Harga:', widget.kost.harga), 
                      const SizedBox(height: 16),
                      _buildDetailItem('Fasilitas:', widget.kost.daftarfasilitas),
                      const SizedBox(height: 16),
                      _buildDetailItem('Contact Person:', widget.kost.kontak),
                      const SizedBox(height: 16),
                      _buildDetailItem('Deskripsi:', widget.kost.deskripsi),
                      const SizedBox(height: 40), 
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET BIASA (UNTUK TEKS)
  Widget _buildDetailItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
        ),
      ],
    );
  }

  // --- WIDGET BARU KHUSUS UNTUK PREVIEW PETA (BISA DIKLIK) ---
  Widget _buildMapPreview(String title, String locString) {
    LatLng? location;
    
    // Pecah teks "lat,lng" menjadi koordinat asli
    try {
      final parts = locString.split(',');
      if (parts.length == 2) {
        location = LatLng(double.parse(parts[0].trim()), double.parse(parts[1].trim()));
      }
    } catch (e) {
      location = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        
        // Cek apakah koordinat valid
        if (location == null) 
          const Text('Lokasi belum diatur', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kotak Peta Mini
              Container(
                height: 200, 
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: location,
                      zoom: 16,
                    ),
                    // Matikan gestur agar peta preview tidak bergeser saat layar di-scroll
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('kost-location'),
                        position: location,
                      ),
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Tombol untuk membuka di aplikasi Google Maps
              OutlinedButton.icon(
                onPressed: () async {
                  // Membuat URL format pencarian Google Maps berdasarkan koordinat
                  final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${location!.latitude},${location.longitude}');
                  
                  // Perintah membuka aplikasi eksternal
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tidak dapat membuka Google Maps'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 16, color: Color(0xFF4A6525)), 
                label: const Text('Buka di Google Maps', style: TextStyle(color: Color(0xFF4A6525), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4A6525)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
      ],
    );
  }
}