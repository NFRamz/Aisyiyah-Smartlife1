import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/ProfileModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JadwalKegiatanOtomatisModal{
  final supabase = Supabase.instance.client;

  Future<List<KegiatanModel>> fetchData(ProfileModel user) async {
      var query = supabase.from('kegiatan').select('* role(tipe, full_access), wilayah:wilayah_id(nama), daerah:daerah_id(nama), cabang:cabang_id(nama), ranting:ranting_id(nama)');

      // filter Role
      if (user.role.contains('wilayah')&& user.wilayahId != null&& user.full_access) {
        query = query.eq('wilayah_id', user.wilayahId!).eq('tipe', 'wilayah');
        
      } else if (user.role.contains('daerah')&& user.daerahId != null&& user.full_access) {
        query = query.eq('daerah_id', user.daerahId!).eq('tipe', 'daerah');

      } else if (user.role.contains('cabang')&& user.cabangId != null&& user.full_access) {
        query = query.eq('cabang_id', user.cabangId!).eq('tipe', 'cabang');

      } else if (user.role.contains('ranting')&& user.rantingId != null&& user.full_access) {
        query = query.eq('ranting_id', user.rantingId!).eq('tipe', 'ranting');

      } else {
        return [];
      }

      // Filter Otomatisasi (Auto-Publish OR Recurring)
      final response = await query.or('frekuensi_ulang.neq.none').order('tanggal', ascending: true);

      return parseKegiatanList(response as List);
  }

  List<KegiatanModel> parseKegiatanList(List<dynamic> listData) {
    return listData.map((data) {
      String? wilayahName = data['wilayah']?['nama'];
      String? daerahName = data['daerah']?['nama'];
      String? cabangName = data['cabang']?['nama'];
      String? rantingName = data['ranting']?['nama'];

      return KegiatanModel(
        id: data['id'],
        nama: data['nama'],
        tipe: data['tipe'],
        tanggal: DateTime.parse(data['tanggal']).toLocal(),
        deskripsi: data['deskripsi'],
        lokasi: data['lokasi'],
        googleMapsLink: data['google_maps_link'],
        frekuensiUlang: data['frekuensi_ulang'] ?? 'none',
        wilayahId: data['wilayah_id'],
        daerahId: data['daerah_id'],
        cabangId: data['cabang_id'],
        rantingId: data['ranting_id'],
        wilayahNama: wilayahName,
        daerahNama: daerahName,
        cabangNama: cabangName,
        rantingNama: rantingName,
      );
    }).toList();
  }

}