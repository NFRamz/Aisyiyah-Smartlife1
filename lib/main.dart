import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

//firebase
import 'firebase_options.dart';


import 'package:aisyiyah_smartlife/pages/SplashScreen.dart';

Future<void> main() async {
  // Memastikan semua plugin siap sebelum aplikasi berjalan.
  WidgetsFlutterBinding.ensureInitialized();

  //  inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('id_ID', null);

  runApp(const AisyiyahSmartLifeApp());
}

class AisyiyahSmartLifeApp extends StatelessWidget {
  const AisyiyahSmartLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color aisyiyahGreen = Color(0xFF4A9D9C);
    const Color aisyiyahCream = Color(0xFFFFF7E8);

    return MaterialApp(

      title: 'Aisyiyah Smart Life',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: aisyiyahGreen,
        scaffoldBackgroundColor: aisyiyahCream,
        appBarTheme: const AppBarTheme(
          backgroundColor: aisyiyahGreen,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: aisyiyahGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: aisyiyahGreen, width: 2),
          ),
        ),

        colorScheme: ColorScheme.fromSeed(seedColor: aisyiyahGreen),
        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}

