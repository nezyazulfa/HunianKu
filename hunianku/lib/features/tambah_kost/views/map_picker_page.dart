import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;
  const MapPickerPage({super.key, this.initialLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _pickedLocation;
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;
  
  @override
  void initState() {
    super.initState();
    // Default awal jika GPS mati atau belum ada lokasi
    _pickedLocation = widget.initialLocation ?? const LatLng(-6.8730, 107.5758);

    // Hanya cari lokasi saat ini jika menambahkan kost BARU (initialLocation kosong)
    if (widget.initialLocation == null) {
      _getCurrentLocation();
    }
  }

  // --- FUNGSI MENDAPATKAN LOKASI SAAT INI (GPS) ---
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // 1. Cek apakah layanan GPS di HP menyala
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Harap nyalakan GPS / Lokasi di HP Anda')),
          );
        }
        return;
      }

      // 2. Cek perizinan aplikasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return; // Izin ditolak
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return; // Izin ditolak permanen
      }

      // 3. Ambil titik koordinat HP dengan akurasi tinggi
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      // 4. Perbarui pin merah dan pindahkan kamera peta
      setState(() {
        _pickedLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_pickedLocation, 17), // Zoom level 17 agar cukup dekat
      );

    } catch (e) {
      debugPrint("Gagal mendapatkan lokasi GPS: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Kost', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickedLocation,
              zoom: 16,
            ),
            // Simpan controller saat peta berhasil dimuat
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            // Mengubah posisi pin saat layar diklik
            onTap: (LatLng location) {
              setState(() {
                _pickedLocation = location;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('picked-location'),
                position: _pickedLocation,
                infoWindow: const InfoWindow(title: 'Lokasi Kost'),
              ),
            },
            // Menampilkan tombol "Lokasi Saya" bawaan Google Maps
            myLocationEnabled: true, 
            myLocationButtonEnabled: false, // Kita matikan karena akan tertumpuk tombol simpan
          ),
          
          // --- INDIKATOR LOADING PENCARIAN GPS ---
          if (_isLoadingLocation)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Mencari lokasi Anda...', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

          // --- TOMBOL KEMBALI KE LOKASI SAYA ---
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'btn-my-location',
              backgroundColor: Colors.white,
              mini: true,
              onPressed: _getCurrentLocation, // Panggil ulang pencarian GPS
              child: const Icon(Icons.my_location, color: Colors.black87),
            ),
          ),

          // --- TOMBOL SIMPAN LOKASI ---
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6525),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                // Mengirim kembali koordinat ke form halaman Tambah/Edit
                Navigator.pop(context, _pickedLocation);
              },
              child: const Text('Simpan Lokasi Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}