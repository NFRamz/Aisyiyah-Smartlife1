class Umkm_model {
  final String  id;
  final String  nama;
  final String? deskripsi;
  final String? mapsLink;
  final String? gambar;
  final String? cabangId;
  final String? rantingId;
  final Map<String, dynamic>? socialMedia;

  Umkm_model({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.mapsLink,
    this.gambar,
    this.cabangId,
    this.rantingId,
    this.socialMedia,
  });

  factory Umkm_model.fromJson(Map<String, dynamic> json) {
    return Umkm_model(
      id          : json['id'].toString(),
      nama        : json['nama'] ?? '',
      deskripsi   : json['deskripsi'],
      mapsLink    : json['maps_link'],
      gambar      : json['gambar'],
      cabangId    : json['cabang_id'],
      rantingId   : json['ranting_id'],
      socialMedia : json['social_media'] != null ? Map<String, dynamic>.from(json['social_media']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama'        : nama,
      'deskripsi'   : deskripsi,
      'maps_link'   : mapsLink,
      'gambar'      : gambar,
      'cabang_id'   : cabangId,
      'ranting_id'  : rantingId,
      'social_media': socialMedia,
    };
  }
}