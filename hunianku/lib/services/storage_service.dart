import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StorageService {
  final String cloudName = 'dwkgodr76'; 
  final String uploadPreset = 'hunianku_preset';

  Future<List<String>> uploadBanyakFoto(List<File> daftarFileFoto) async {
    List<String> daftarUrlFoto = [];    
    // URL API Cloudinary
    final Uri apiUrl = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    for (int i = 0; i < daftarFileFoto.length; i++) {
      try {
        var request = http.MultipartRequest('POST', apiUrl);
        request.fields['upload_preset'] = uploadPreset;        
        // Masukkan file ke dalam request
        request.files.add(
          await http.MultipartFile.fromPath('file', daftarFileFoto[i].path)
        );
        // Kirim ke Cloudinary
        var response = await request.send();
        // Jika berhasil (Status 200), ambil URL-nya
        if (response.statusCode == 200) {
          var responseData = await response.stream.toBytes();
          var responseString = String.fromCharCodes(responseData);
          var jsonMap = jsonDecode(responseString);          
          String urlFoto = jsonMap['secure_url'];
          daftarUrlFoto.add(urlFoto); 
        } else {
          print("Gagal upload foto ke-$i, Status: ${response.statusCode}");
        }
      } catch (e) {
        print("Error upload foto: $e");
      }
    }
    return daftarUrlFoto;
  }
}