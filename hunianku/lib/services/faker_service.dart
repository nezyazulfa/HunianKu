import 'package:faker/faker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:hunianku/features/auth/model/user_model.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/note/model/note_model.dart';
import 'package:hunianku/features/review/model/review_model.dart';
import 'package:hunianku/features/bookmark/model/bookmark_model.dart';
import 'package:hunianku/services/mongo_service.dart';

class FakerService {
  final Faker faker = Faker();
  final cloudinary = CloudinaryPublic('dwkgodr76', 'hunianku_preset');
  final MongoService _mongo = MongoService();

  Future<void> seedIfEmpty() async {
    final userCol = await _mongo.getCollection('user');
    final count = await userCol.count();
    if (count > 1) {
      print("Database sudah berisi data, Seeding dibatalkan.");
      return;
    }
    print("Memulai Seeding Massal (Tunggu sebentar...)");
    print("Mengunggah gambar dummy ke Cloudinary...");
    String dummyPhotoUrl = 'https://picsum.photos/400/300';
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromUrl('https://picsum.photos/400/300?random=1', resourceType: CloudinaryResourceType.Image),
      );
      dummyPhotoUrl = response.secureUrl;
    } catch (e) {
      print("Gagal ke Cloudinary, pakai URL asli Picsum");
    }

    // 2. Buat 10 User (5 Pemilik, 5 Penghuni)
    List<UserModel> listPemilik = [];
    List<UserModel> listPenghuni = [];    
    for (int i = 0; i < 10; i++) {
      String role = i % 2 == 0 ? 'pemilik' : 'penghuni'; // Selang-seling role
      var newUser = UserModel(
        iduser: 'USR-${faker.randomGenerator.integer(99999)}',
        nama: faker.person.name(),
        email: 'user$i@dummy.com',
        password: 'password123',
        role: role,
      );
      await _mongo.insertDocument('user', newUser.toMap());
      if (role == 'pemilik') listPemilik.add(newUser);
      else listPenghuni.add(newUser);
    }

    // 3. Buat 100 Kost (Dibagi rata ke 5 pemilik)
    List<KostModel> listKost = [];
    for (int i = 0; i < 100; i++) {
      UserModel pemilikAcak = listPemilik[faker.randomGenerator.integer(listPemilik.length)];
      var newKost = KostModel(
        idkost: 'K-${faker.guid.guid()}',
        user: pemilikAcak, 
        namakost: 'Kost ${faker.address.city()}',
        alamat: faker.address.streetAddress(),
        harga: '${faker.randomGenerator.integer(2000, min: 500)}000',
        daftarFoto: [dummyPhotoUrl], 
        lokasi: 'https://maps.google.com',
        kontak: faker.phoneNumber.us(),
        daftarfasilitas: 'WiFi, Kasur, Lemari, Meja Belajar',
        deskripsi: faker.lorem.sentences(2).join(' '),
        status: faker.randomGenerator.boolean() ? 'Tersedia' : 'Penuh',
        jenis: faker.randomGenerator.boolean() ? 'Putra' : 'Putri',
      );
      await _mongo.insertDocument('kost', newKost.toMap());
      listKost.add(newKost);
    }

    // 4. Buat 100 Note, 100 Review, 100 Bookmark
    for (int i = 0; i < 100; i++) {
      UserModel penghuniAcak = listPenghuni[faker.randomGenerator.integer(listPenghuni.length)];
      KostModel kostAcak = listKost[faker.randomGenerator.integer(listKost.length)];
      var note = NoteModel(
        idnote: 'N-${faker.guid.guid()}',
        user: penghuniAcak, 
        kost: kostAcak,
        catatan: 'Laporan fasilitas: ${faker.lorem.sentence()}', tanggal: DateTime.now().toString(),
      );
      await _mongo.insertDocument('note', note.toMap());

      // Simpan Review
      var review = ReviewModel(
        idreview: 'R-${faker.guid.guid()}', 
        user: penghuniAcak, 
        kost: kostAcak,
        rating: faker.randomGenerator.integer(5, min: 1).toString(), 
        komentar: faker.lorem.sentence(), tanggal: DateTime.now().toString(),
      );
      await _mongo.insertDocument('review', review.toMap());

      // Simpan Bookmark
      var bookmark = BookmarkModel(
        idbookmark: 'B-${faker.guid.guid()}', 
        user: penghuniAcak, 
        kost: kostAcak,
        tanggal: DateTime.now().toString(),
      );
      await _mongo.insertDocument('bookmark', bookmark.toMap());
    }
    print("SEEDING MASSAL SELESAI! (10 User, 100 Kost, 100 Note, 100 Review, 100 Bookmark)");
  }

  // FUNGSI RESET: MENGHAPUS SEMUA DATA SEKETIKA
  Future<void> resetDatabase() async {
    final collections = ['user', 'kost', 'note', 'review', 'bookmark'];
    for (var col in collections) {
      final collection = await _mongo.getCollection(col);
      await collection.drop(); 
    }
    print("DATABASE TELAH DIBERSIHKAN TOTAL!");
  }
}