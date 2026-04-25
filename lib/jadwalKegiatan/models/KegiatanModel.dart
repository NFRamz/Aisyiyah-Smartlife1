class KegiatanModel {
  String id;
  String nama;
  String tipe;
  DateTime tanggal;
  String? deskripsi;
  String? lokasi;          // Field Baru
  String? googleMapsLink;  // Field Baru
  String? frekuensiUlang;

  // ID Hirarki
  String? wilayahId;
  String? daerahId;
  String? cabangId;
  String? rantingId;

  // Nama Hirarki (Hasil Join)
  String? wilayahNama;
  String? daerahNama;
  String? cabangNama;
  String? rantingNama;



  KegiatanModel({
    required this.id, required this.nama, required this.tipe, required this.tanggal,
    this.deskripsi, this.lokasi, this.googleMapsLink, this.wilayahId, this.daerahId, this.cabangId, this.rantingId,
    this.wilayahNama, this.daerahNama, this.cabangNama, this.rantingNama,this.frekuensiUlang, // Constructor update
  });

  factory KegiatanModel.fromJson(Map<String, dynamic> json) {
    try {
      return KegiatanModel(
        id: json['id'].toString(),
        nama: json['nama'] ?? '',
        tipe: json['tipe'] ?? '',
        // Parsing tanggal yang aman
        tanggal: json['tanggal'] != null
            ? DateTime.parse(json['tanggal']).toLocal()
            : DateTime.now(),
        deskripsi: json['deskripsi'],
        lokasi: json['lokasi'],
        googleMapsLink: json['google_maps_link'],
        frekuensiUlang: json['frekuensi_ulang'] ?? 'none',

        wilayahId: json['wilayah_id']?.toString(),
        daerahId: json['daerah_id']?.toString(),
        cabangId: json['cabang_id']?.toString(),
        rantingId: json['ranting_id']?.toString(),

        // Menangkap data dari select join: wilayah:wilayah_id(nama)
        wilayahNama: json['wilayah'] is Map ? json['wilayah']['nama'] : null,
        daerahNama: json['daerah'] is Map ? json['daerah']['nama'] : null,
        cabangNama: json['cabang'] is Map ? json['cabang']['nama'] : null,
        rantingNama: json['ranting'] is Map ? json['ranting']['nama'] : null,
      );
    } catch (e) {
      print("Error Parsing KegiatanModel:");
      rethrow;
    }
  }
}