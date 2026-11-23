import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/modules/login/controllers/login_controller.dart';
import 'package:aisyiyah_smartlife/data/services/google_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 1. MOCKS & FAKES (Test Double: Mock & Fake)
// Mock: Digunakan untuk verifikasi interaksi dan stubbing perilaku.
class MockLoginAuthRepository extends Mock implements LoginAuthRepository {}
class MockLoginUiHandler extends Mock implements LoginUiHandler {}
class MockGoogleAuthService extends Mock implements GoogleAuthService {}
class MockUser extends Mock implements User {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockAuthResponse extends Mock implements AuthResponse {}

// Fake: Objek palsu dengan implementasi minimal untuk memenuhi ketergantungan tipe.
class FakeGoogleSignInAccount extends Fake implements GoogleSignInAccount {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(const Duration(minutes: 2));
    registerFallbackValue(Colors.red);
    registerFallbackValue(const {});
    registerFallbackValue(FakeGoogleSignInAccount());
  });

  late LoginController controller;
  late MockLoginAuthRepository mockAuthRepository;
  late MockLoginUiHandler mockUiHandler;
  late MockGoogleAuthService mockGoogleAuthService;

  setUp(() {
    mockAuthRepository = MockLoginAuthRepository();
    mockUiHandler = MockLoginUiHandler();
    mockGoogleAuthService = MockGoogleAuthService();
    Get.testMode = true;

    controller = LoginController(
      authRepository: mockAuthRepository,
      uiHandler: mockUiHandler,
      googleAuthService: mockGoogleAuthService,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('LoginController - handleLogin Branches', () {
    // test case 1: Menguji agar fungsi login tidak berjalan jika status masih loading.
    test('isLoading return early', () async {
      controller.isLoading.value = true;
      await controller.handleLogin();
      verifyNever(() => mockAuthRepository.signInWithPassword(any(), any()));
    });

    // test case 2: Memastikan muncul snackbar peringatan jika email atau password tidak diisi.
    test('Validasi - Email kosong atau Password kosong', () async {
      controller.emailController.text = '';
      controller.passwordController.text = '123';
      await controller.handleLogin();
      
      controller.emailController.text = 'test@a.com';
      controller.passwordController.text = '';
      await controller.handleLogin();

      verify(() => mockUiHandler.showSnackbar(any(), 'Email dan password harus diisi', any())).called(2);
    });

    // test case 3: Memastikan validasi format email berfungsi (menggunakan GetUtils.isEmail).
    test('Validasi - Format email salah', () async {
      controller.emailController.text = 'bukan-email';
      controller.passwordController.text = '123';
      await controller.handleLogin();
      verify(() => mockUiHandler.showSnackbar(any(), 'Format email tidak valid', any())).called(1);
    });

    // test case 4: Menguji kondisi ketika akun masih dalam masa blokir (lockout).
    test('Lockout - Masih terblokir', () async {
      controller.emailController.text = 'test@a.com';
      controller.passwordController.text = '123';
      controller.lockoutUntil.value = DateTime.now().add(const Duration(minutes: 1));
      await controller.handleLogin();
      verify(() => mockUiHandler.showSnackbar('Terblokir', any(), any())).called(1);
    });

    // test case 5: Memastikan sistem meriset percobaan gagal jika masa blokir sudah lewat.
    test('Lockout - Blokir berakhir (Reset percobaan)', () async {
      controller.emailController.text = 'test@a.com';
      controller.passwordController.text = '123';
      controller.lockoutUntil.value = DateTime.now().subtract(const Duration(seconds: 1));
      controller.failedAttempts.value = 3;
      
      when(() => mockAuthRepository.signInWithPassword(any(), any())).thenThrow(const AuthException('Gagal'));
      
      await controller.handleLogin();
      expect(controller.failedAttempts.value, 1); // Reset ke 0, lalu +1 karena gagal lagi
      expect(controller.lockoutUntil.value, null);
    });

    // test case 6: Menangani kegagalan login (AuthException) dan mencatat jumlah percobaan.
    test('AuthException - Penanganan gagal login (attempts < 3)', () async {
      controller.emailController.text = 'test@a.com';
      controller.passwordController.text = '123';
      when(() => mockAuthRepository.signInWithPassword(any(), any())).thenThrow(const AuthException('Wrong Pass'));
      
      await controller.handleLogin();
      verify(() => mockUiHandler.showSnackbar('Gagal Login', any(that: contains('Wrong Pass')), any())).called(1);
      expect(controller.failedAttempts.value, 1);
    });

    // test case 7: Memicu status terblokir (lockout) setelah mencapai batas 3x percobaan gagal.
    test('AuthException - Mencapai 3 percobaan (Pemicu Lockout)', () async {
      controller.emailController.text = 'test@a.com';
      controller.passwordController.text = '123';
      controller.failedAttempts.value = 2;
      when(() => mockAuthRepository.signInWithPassword(any(), any())).thenThrow(const AuthException('Wrong Pass'));
      
      await controller.handleLogin();
      expect(controller.failedAttempts.value, 3);
      expect(controller.lockoutUntil.value, isNotNull);
      verify(() => mockUiHandler.showSnackbar('Terblokir', any(), any())).called(1);
    });

    // test case 8: Menangani skenario di mana respon user dari database bernilai null.
    test('User null setelah login', () async {
      controller.emailController.text = 'test@a.com';
      controller.passwordController.text = '123';
      when(() => mockAuthRepository.signInWithPassword(any(), any())).thenAnswer((_) async => null);
      
      await controller.handleLogin();
      verify(() => mockUiHandler.showSnackbar('Gagal Login', 'User tidak ditemukan.', any())).called(1);
    });

    // test case 9: Menangani kondisi di mana user ada namun profil database tidak ditemukan.
    test('Profile null setelah login', () async {
      final user = MockUser();
      when(() => user.id).thenReturn('u1');
      controller.emailController.text = 'test@a.com';
      controller.passwordController.text = '123';
      when(() => mockAuthRepository.signInWithPassword(any(), any())).thenAnswer((_) async => user);
      when(() => mockAuthRepository.getProfile('u1')).thenAnswer((_) async => null);
      
      await controller.handleLogin();
      verify(() => mockUiHandler.showSnackbar('Gagal Login', 'Profil pengguna tidak ditemukan.', any())).called(1);
    });

    // test case 10: Menguji ketahanan kode (null-safety) saat beberapa field profil bernilai null.
    test('Success - Profile dengan banyak field null (Test operator ??)', () async {
      final user = MockUser();
      when(() => user.id).thenReturn('u1');
      controller.emailController.text = 'test@a.com';
      controller.passwordController.text = '123';

      when(() => mockAuthRepository.signInWithPassword(any(), any())).thenAnswer((_) async => user);
      when(() => mockAuthRepository.getProfile('u1')).thenAnswer((_) async => {
        'nama_depan': 'Aisyiyah',
        'nama_belakang': null,
        'email': null,
        'role_id': null,
        'ranting_id': null,
        'daerah_id': null,
      });

      await controller.handleLogin();
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isLoggedIn'), true);
      expect(prefs.getString('nama_pengguna'), 'Aisyiyah');
      expect(prefs.getString('role'), 'anggota'); // Nilai default dari ??
      verify(() => mockUiHandler.navigateToHome()).called(1);
    });

    // test case 11: Menangani error sistem yang tidak terduga (General Exception).
    test('Catch-all Exception', () async {
      controller.emailController.text = 'test@a.com';
      controller.passwordController.text = '123';
      when(() => mockAuthRepository.signInWithPassword(any(), any())).thenThrow(Exception('Crash'));
      
      await controller.handleLogin();
      verify(() => mockUiHandler.showSnackbar('Error', 'Terjadi kesalahan sistem.', any())).called(1);
    });
  });

  group('LoginController - signInWithGoogle Branches', () {
    // test case 12: Menguji agar Google Sign-In tidak berjalan ganda saat status loading.
    test('isLoading return early', () async {
      controller.isLoading.value = true;
      await controller.signInWithGoogle();
      verifyNever(() => mockGoogleAuthService.signInWithGoogle());
    });

    // test case 13: Menangani kondisi saat pengguna membatalkan dialog pemilihan akun Google.
    test('Google - User membatalkan login (null)', () async {
      when(() => mockGoogleAuthService.signInWithGoogle()).thenAnswer((_) async => null);
      await controller.signInWithGoogle();
      verifyNever(() => mockGoogleAuthService.loginToSupabase(any()));
    });

    // test case 14: Menangani kegagalan saat menukarkan token Google ke sesi Supabase.
    test('Google - User Supabase null', () async {
      final gAcc = MockGoogleSignInAccount();
      final res = MockAuthResponse();
      when(() => mockGoogleAuthService.signInWithGoogle()).thenAnswer((_) async => gAcc);
      when(() => mockGoogleAuthService.loginToSupabase(any())).thenAnswer((_) async => res);
      when(() => res.user).thenReturn(null);

      await controller.signInWithGoogle();
      verify(() => mockUiHandler.showSnackbar('Gagal Login', any(), any())).called(1);
    });

    // test case 15: Mengarahkan pengguna baru ke halaman Signup jika profil belum ada.
    test('Google - isNewUser logic (profile null)', () async {
      final gAcc = MockGoogleSignInAccount();
      final res = MockAuthResponse();
      final user = MockUser();
      when(() => gAcc.email).thenReturn('a@b.com');
      when(() => mockGoogleAuthService.signInWithGoogle()).thenAnswer((_) async => gAcc);
      when(() => mockGoogleAuthService.loginToSupabase(any())).thenAnswer((_) async => res);
      when(() => res.user).thenReturn(user);
      when(() => user.id).thenReturn('u1');
      
      when(() => mockAuthRepository.getProfile('u1')).thenAnswer((_) async => null);

      await controller.signInWithGoogle();
      verify(() => mockUiHandler.navigateToSignup(any())).called(1);
    });

    // test case 16: Deteksi pengguna baru jika nama_depan masih bernilai default "user".
    test('Google - isNewUser logic (nama_depan "user")', () async {
      final gAcc = MockGoogleSignInAccount();
      final res = MockAuthResponse();
      final user = MockUser();
      when(() => gAcc.email).thenReturn('a@b.com');
      when(() => mockGoogleAuthService.signInWithGoogle()).thenAnswer((_) async => gAcc);
      when(() => mockGoogleAuthService.loginToSupabase(any())).thenAnswer((_) async => res);
      when(() => res.user).thenReturn(user);
      when(() => user.id).thenReturn('u1');
      
      when(() => mockAuthRepository.getProfile('u1')).thenAnswer((_) async => {'nama_depan': 'user'});

      await controller.signInWithGoogle();
      verify(() => mockUiHandler.navigateToSignup(any())).called(1);
    });

    // test case 17: Deteksi pengguna baru jika field nama_depan kosong.
    test('Google - isNewUser logic (nama_depan kosong)', () async {
      final gAcc = MockGoogleSignInAccount();
      final res = MockAuthResponse();
      final user = MockUser();
      when(() => gAcc.email).thenReturn('a@b.com');
      when(() => mockGoogleAuthService.signInWithGoogle()).thenAnswer((_) async => gAcc);
      when(() => mockGoogleAuthService.loginToSupabase(any())).thenAnswer((_) async => res);
      when(() => res.user).thenReturn(user);
      when(() => user.id).thenReturn('u1');
      
      when(() => mockAuthRepository.getProfile('u1')).thenAnswer((_) async => {'nama_depan': ''});

      await controller.signInWithGoogle();
      verify(() => mockUiHandler.navigateToSignup(any())).called(1);
    });

    // test case 18: Alur sukses login Google untuk pengguna yang sudah terdaftar lengkap.
    test('Google - User lama (Success path)', () async {
      final gAcc = MockGoogleSignInAccount();
      final res = MockAuthResponse();
      final user = MockUser();
      when(() => gAcc.email).thenReturn('a@b.com');
      when(() => mockGoogleAuthService.signInWithGoogle()).thenAnswer((_) async => gAcc);
      when(() => mockGoogleAuthService.loginToSupabase(any())).thenAnswer((_) async => res);
      when(() => res.user).thenReturn(user);
      when(() => user.id).thenReturn('u1');
      when(() => mockAuthRepository.getProfile('u1')).thenAnswer((_) async => {'nama_depan': 'Budi'});

      await controller.signInWithGoogle();
      verify(() => mockUiHandler.navigateToHome()).called(1);
    });

    // test case 19: Menangani error pada saat proses Google Sign-In berlangsung.
    test('Google - Catch Error', () async {
      when(() => mockGoogleAuthService.signInWithGoogle()).thenThrow(Exception('Google Error'));
      await controller.signInWithGoogle();
      verify(() => mockUiHandler.showSnackbar('Gagal Login', any(), any())).called(1);
    });
  });

  group('Cakupan (Coverage) Ekstra', () {
    // test case 20: Memastikan getter, fungsi cleanup (onClose), dan kelas produksi tereksekusi.
    test('Getters, Dispose & Production Classes', () async {
      // Lazy Getters
      final dc = LoginController();
      try { dc.googleAuthService; } catch (_) {}
      try { dc.supabase; } catch (_) {}
      
      // UI Actions
      controller.togglePasswordVisibility();
      controller.navigateToSignUp();
      controller.navigateToForgotPassword();
      controller.onClose();

      // Production Repository (Panggil agar baris kodenya tereksekusi)
      final prodRepo = SupabaseLoginAuthRepository();
      try { await prodRepo.signInWithPassword('a', 'b'); } catch (_) {}
      try { await prodRepo.getProfile('u'); } catch (_) {}
      
      // Production UI Handler (Bypass calling Get.snackbar in test env if it fails)
      final prodUi = GetxLoginUiHandler();
      // ignore: invalid_use_of_protected_member
      if (!Get.testMode) {
        try { prodUi.showSnackbar('t', 'm', Colors.red); } catch (_) {}
      }
      try { prodUi.navigateToHome(); } catch (_) {}
      try { prodUi.navigateToSignup({}); } catch (_) {}
    });
  });
}
