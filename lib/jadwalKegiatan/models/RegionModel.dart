class RegionModel {
  String id;
  String nama;
  String? wilayahId;
  String? daerahId;
  String? cabangId;

  RegionModel({
    required this.id,
    required this.nama,
    this.wilayahId,
    this.daerahId,
    this.cabangId
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      // Parsing aman untuk berbagai kemungkinan struktur response
      wilayahId: json['wilayah_id']?.toString() ?? json['daerah']?['wilayah_id']?.toString(),
      daerahId: json['daerah_id']?.toString() ?? json['cabang']?['daerah_id']?.toString(),
      cabangId: json['cabang_id']?.toString(),
    );
  }
}