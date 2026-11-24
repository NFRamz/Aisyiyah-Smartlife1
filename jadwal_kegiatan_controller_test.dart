import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/test_jadwal_kegiatan_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockJadwalRepo extends Mock implements JadwalKegiatanRepository {}
class MockJadwalUi extends Mock implements JadwalKegiatanUiHandler {}
class MockUser extends Mock implements User {}

void main() {
  late TestJadwalKegiatanController controller;
  late MockJadwalRepo mockRepo;
  late MockJadwalUi mockUi;

  setUp(() {
    mockRepo = MockJadwalRepo();
    mockUi = MockJadwalUi();

    when(() => mockRepo.currentUser).thenReturn(null);
    when(() => mockRepo.fetchUserProfile(any())).thenAnswer((_) async => null);
    when(() => mockRepo.fetchKegiatan(any())).thenAnswer((_) async => []);

    controller = TestJadwalKegiatanController(repository: mockRepo, uiHandler: mockUi);
  });

  group('JadwalKegiatanController Tests', () {
    test('fetchUserProfile sets currentUser data', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('u1');
      when(() => mockRepo.currentUser).thenReturn(mockUser);
      when(() => mockRepo.fetchUserProfile('u1')).thenAnswer((_) async => {
        'id': 'u1',
        'role': {'tipe': 'admin', 'full_access': true},
        'wilayah_id': 'w1'
      });

      await controller.fetchUserProfile();

      expect(controller.currentUser.value?.id, 'u1');
      expect(controller.currentUser.value?.role, 'admin');
    });

    test('updateAttendance shows snackbar and updates local state on success', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('u1');
      when(() => mockRepo.currentUser).thenReturn(mockUser);
      when(() => mockRepo.upsertAttendance(any())).thenAnswer((_) async => {});
      when(() => mockRepo.fetchKegiatan(any())).thenAnswer((_) async => []);
      when(() => mockRepo.fetchUserAttendance(any())).thenAnswer((_) async => []);

      await controller.updateAttendance('keg1', 'bersedia');

      expect(controller.userAttendance['keg1'], 'bersedia');
      verify(() => mockUi.showSnackbar('Berhasil', any())).called(1);
    });

    test('updateAttendance handles error', () async {
      final mockUser = MockUser();
      when(() => mockRepo.currentUser).thenReturn(mockUser);
      when(() => mockRepo.upsertAttendance(any())).thenThrow(Exception('DB Error'));

      await controller.updateAttendance('keg1', 'bersedia');

      verify(() => mockUi.showSnackbar('Error', any())).called(1);
    });
  });
}

// Semantic Commit: test(jadwal): pengujian fitur polling kehadiran dan sinkronisasi data kegiatan

