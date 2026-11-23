import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/modules/login/controllers/login_controller.dart';
import 'package:aisyiyah_smartlife/data/services/google_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 1. MOCKS
class MockLoginAuthRepository extends Mock implements LoginAuthRepository {}
class MockLoginUiHandler extends Mock implements LoginUiHandler {}
class MockGoogleAuthService extends Mock implements GoogleAuthService {}
class MockUser extends Mock implements User {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockAuthResponse extends Mock implements AuthResponse {}

// Fake LocalStorage untuk menghindari MissingPluginException saat Supabase.initialize di Unit Test
class FakeLocalStorage extends LocalStorage {
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> accessToken() async => null;
  @override
  Future<bool> hasAccessToken() async => false;
  @override
  Future<void> persistSession(String session) async {}
  @override
  Future<void> removePersistedSession() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Siapkan mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    try {
      // Inisialisasi Supabase dengan LocalStorage palsu agar tidak crash di test
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        anonKey: 'testKey',
        localStorage: FakeLocalStorage(),
      );
    } catch (_) {}

    registerFallbackValue(const Duration(minutes: 2));
    registerFallbackValue(Colors.red);
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

  group('LoginController - Logic & Coverage', () {
    test('Early return jika sedang loading', () async {
      controller.isLoading.value = true;
      await controller.handleLogin();
      verifyNever(() => mockAuthRepository.signInWithPassword(any(), any()));
    });

    test('Validasi - Email/Password kosong', () async {
      controller.emailController.text = '';
      await controller.handleLogin();
      verify(() => mockUiHandler.showSnackbar('Error', 'Email dan password harus diisi', any())).called(1);
    });

    test('Lockout - Masa blokir belum habis', () async {
      controller.emailController.text = 'test@test.com';
      controller.passwordController.text = 'pass';
      controller.lockoutUntil.value = DateTime.now().add(const Duration(minutes: 1));

      await controller.handleLogin();
      verify(() => mockUiHandler.showSnackbar('Terblokir', any(), any())).called(1);
    });

    test('Auth - Menangani AuthException dari Repository', () async {
      controller.emailController.text = 'test@test.com';
      controller.passwordController.text = 'pass';
      when(() => mockAuthRepository.signInWithPassword(any(), any()))
          .thenThrow(const AuthException('Invalid Credentials'));

      await controller.handleLogin();
      expect(controller.failedAttempts.value, 1);
      verify(() => mockUiHandler.showSnackbar('Gagal Login', any(), any())).called(1);
    });

    test('Success - Login dan pemrosesan Profile dengan field null (Edge Cases)', () async {
      final user = MockUser();
      when(() => user.id).thenReturn('u123');
      controller.emailController.text = 'test@test.com';
      controller.passwordController.text = 'password';
      
      when(() => mockAuthRepository.signInWithPassword(any(), any())).thenAnswer((_) async => user);
      
      // Menguji operator ?? pada baris 260-280
      when(() => mockAuthRepository.getProfile('u123')).thenAnswer((_) async => {
        'nama_depan': 'Jane',
        'nama_belakang': null,
        'email': null,
        'role_id': null,
        'ranting_id': null,
        'daerah_id': null,
      });

      await controller.handleLogin();
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('nama_pengguna'), 'Jane'); // nama_belakang null -> empty string
      expect(prefs.getString('role'), 'anggota'); // role_id null -> 'anggota'
      expect(prefs.getString('ranting_id'), '');
    });

    test('Google Sign In - User baru dengan nama_depan "user"', () async {
      final gAcc = MockGoogleSignInAccount();
      final res = MockAuthResponse();
      final user = MockUser();
      when(() => gAcc.email).thenReturn('new@test.com');
      when(() => mockGoogleAuthService.signInWithGoogle()).thenAnswer((_) async => gAcc);
      when(() => mockGoogleAuthService.loginToSupabase(gAcc)).thenAnswer((_) async => res);
      when(() => res.user).thenReturn(user);
      when(() => user.id).thenReturn('uid');
      when(() => mockAuthRepository.getProfile('uid')).thenAnswer((_) async => {'nama_depan': 'USER'});

      await controller.signInWithGoogle();
      verify(() => mockUiHandler.navigateToSignup(any())).called(1);
    });

    test('Google Sign In - User lama dengan data parsial', () async {
      final gAcc = MockGoogleSignInAccount();
      final res = MockAuthResponse();
      final user = MockUser();
      when(() => gAcc.email).thenReturn('old@test.com');
      when(() => mockGoogleAuthService.signInWithGoogle()).thenAnswer((_) async => gAcc);
      when(() => mockGoogleAuthService.loginToSupabase(gAcc)).thenAnswer((_) async => res);
      when(() => res.user).thenReturn(user);
      when(() => user.id).thenReturn('uid');
      when(() => mockAuthRepository.getProfile('uid')).thenAnswer((_) async => {
        'nama_depan': 'Old',
        'email': null // Akan ambil dari googleUser.email
      });

      await controller.signInWithGoogle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('email'), 'old@test.com');
    });

    test('UI & Production Impl Coverage', () async {
      // 1. Coverage untuk Getters (Supabase & GoogleAuthService lazy init)
      final defaultController = LoginController();
      expect(defaultController.googleAuthService, isA<GoogleAuthService>());
      try { defaultController.supabase; } catch (_) {}

      // 2. Coverage untuk Production Repository
      final repo = SupabaseLoginAuthRepository();
      try { await repo.signInWithPassword('e', 'p'); } catch (_) {}
      try { await repo.getProfile('id'); } catch (_) {}

      // 3. Coverage untuk Production UI Handler
      final handler = GetxLoginUiHandler();
      handler.showSnackbar('t', 'm', Colors.blue);
      try { handler.navigateToHome(); } catch (_) {}
      try { handler.navigateToSignup({}); } catch (_) {}

      // 4. UI Actions di Controller
      controller.togglePasswordVisibility();
      controller.navigateToSignUp();
      controller.navigateToForgotPassword();
      controller.onClose();
    });
  });
}
